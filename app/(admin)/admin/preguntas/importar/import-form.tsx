"use client";

import { useActionState, useMemo, useState } from "react";
import Papa from "papaparse";
import { importQuestions } from "@/lib/data/question-import";
import {
  CSV_COLUMNS,
  buildTemplateCsv,
  validateImportRows,
  type ImportCatalogs,
  type RawImportRow,
  type ValidatedImportRow,
} from "@/lib/data/question-import-shared";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

const STATUS_LABEL: Record<ValidatedImportRow["status"], string> = {
  valida: "Válida",
  advertencia: "Advertencia",
  error: "Error",
};

const STATUS_VARIANT: Record<
  ValidatedImportRow["status"],
  "success" | "warning" | "destructive"
> = {
  valida: "success",
  advertencia: "warning",
  error: "destructive",
};

function downloadTemplate() {
  const csv = buildTemplateCsv();
  const blob = new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "plantilla-preguntas-validapp.csv";
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

export function ImportForm({ catalogs }: { catalogs: ImportCatalogs }) {
  const [state, formAction, pending] = useActionState(importQuestions, null);
  const [fileName, setFileName] = useState<string | null>(null);
  const [rawRows, setRawRows] = useState<RawImportRow[]>([]);
  const [parseError, setParseError] = useState<string | null>(null);
  const [includeDuplicates, setIncludeDuplicates] = useState(false);

  const validated = useMemo(
    () => validateImportRows(rawRows, catalogs),
    [rawRows, catalogs]
  );

  const summary = useMemo(() => {
    const validCount = validated.filter((r) => r.status === "valida").length;
    const warningCount = validated.filter(
      (r) => r.status === "advertencia"
    ).length;
    const errorCount = validated.filter((r) => r.status === "error").length;
    return { validCount, warningCount, errorCount };
  }, [validated]);

  const importableCount =
    summary.validCount + (includeDuplicates ? summary.warningCount : 0);

  function handleFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setParseError(null);
    setFileName(file.name);
    Papa.parse<Record<string, string>>(file, {
      header: true,
      skipEmptyLines: true,
      complete: (results) => {
        if (results.errors.length > 0) {
          setParseError(
            "El archivo tiene errores de formato CSV. Revisa que uses comas como separador y comillas para textos con comas."
          );
        }
        const rows: RawImportRow[] = results.data.map((row) => {
          const normalized = {} as RawImportRow;
          for (const col of CSV_COLUMNS) {
            normalized[col] = String(row[col] ?? "");
          }
          return normalized;
        });
        setRawRows(rows);
      },
      error: () => {
        setParseError("No se pudo leer el archivo. ¿Es un CSV válido?");
      },
    });
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-2 rounded-xl border border-border p-4">
        <p className="text-sm font-medium">1. Descarga la plantilla</p>
        <p className="text-sm text-muted-foreground">
          Usa este archivo de ejemplo como base: mantén los nombres de columna
          y complétalos con tus preguntas. Asignatura y curso deben escribirse
          igual que en el catálogo (por ejemplo, tal como aparecen en{" "}
          <span className="font-medium">/admin/asignaturas</span> y{" "}
          <span className="font-medium">/admin/niveles</span>).
        </p>
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="w-fit"
          onClick={downloadTemplate}
        >
          Descargar plantilla CSV
        </Button>
      </div>

      <div className="flex flex-col gap-2 rounded-xl border border-border p-4">
        <p className="text-sm font-medium">2. Sube tu archivo</p>
        <input
          type="file"
          accept=".csv,text/csv"
          onChange={handleFile}
          aria-label="Seleccionar archivo CSV de preguntas"
          className="text-sm"
        />
        {fileName && (
          <p className="text-xs text-muted-foreground">
            Archivo cargado: {fileName} ({rawRows.length} fila
            {rawRows.length === 1 ? "" : "s"})
          </p>
        )}
        {parseError && (
          <p className="text-sm text-destructive">{parseError}</p>
        )}
      </div>

      {rawRows.length > 0 && (
        <div className="flex flex-col gap-3 rounded-xl border border-border p-4">
          <p className="text-sm font-medium">3. Revisa la vista previa</p>
          <div className="flex flex-wrap gap-2 text-sm">
            <Badge variant="success">{summary.validCount} válidas</Badge>
            <Badge variant="warning">
              {summary.warningCount} con advertencia (posible duplicado)
            </Badge>
            <Badge variant="destructive">{summary.errorCount} con error</Badge>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full min-w-[720px] text-left text-sm">
              <thead>
                <tr className="border-b border-border text-xs text-muted-foreground">
                  <th className="py-1.5 pr-2">Fila</th>
                  <th className="py-1.5 pr-2">Estado</th>
                  <th className="py-1.5 pr-2">Asignatura</th>
                  <th className="py-1.5 pr-2">Curso</th>
                  <th className="py-1.5 pr-2">Enunciado</th>
                  <th className="py-1.5 pr-2">Detalle</th>
                </tr>
              </thead>
              <tbody>
                {validated.map((row) => (
                  <tr
                    key={row.rowNumber}
                    className="border-b border-border/50 align-top"
                  >
                    <td className="py-1.5 pr-2">{row.rowNumber}</td>
                    <td className="py-1.5 pr-2">
                      <Badge variant={STATUS_VARIANT[row.status]}>
                        {STATUS_LABEL[row.status]}
                      </Badge>
                    </td>
                    <td className="py-1.5 pr-2">{row.preview.asignatura}</td>
                    <td className="py-1.5 pr-2">{row.preview.curso}</td>
                    <td className="py-1.5 pr-2 max-w-[280px]">
                      {row.preview.enunciado || "—"}
                    </td>
                    <td className="py-1.5 pr-2 text-xs text-muted-foreground">
                      {[...row.errors, ...row.warnings].map((msg, i) => (
                        <p key={i}>{msg}</p>
                      ))}
                      {row.errors.length === 0 &&
                        row.warnings.length === 0 &&
                        "Sin observaciones."}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {summary.warningCount > 0 && (
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={includeDuplicates}
                onChange={(e) => setIncludeDuplicates(e.target.checked)}
              />
              Importar también las filas con advertencia de duplicado (
              {summary.warningCount})
            </label>
          )}

          <form action={formAction} className="flex flex-col gap-2">
            <input
              type="hidden"
              name="rows"
              value={JSON.stringify(rawRows)}
            />
            <input
              type="hidden"
              name="includeDuplicates"
              value={includeDuplicates ? "on" : "off"}
            />
            <p className="text-sm text-muted-foreground">
              {summary.errorCount > 0 &&
                `${summary.errorCount} fila${summary.errorCount === 1 ? "" : "s"} con error no se importarán. `}
              Se importarán {importableCount} pregunta
              {importableCount === 1 ? "" : "s"} como borrador.
            </p>
            <Button
              type="submit"
              className="w-fit"
              disabled={pending || importableCount === 0}
            >
              {pending
                ? "Importando..."
                : `Importar ${importableCount} pregunta${importableCount === 1 ? "" : "s"} válida${importableCount === 1 ? "" : "s"}`}
            </Button>
          </form>
        </div>
      )}

      {state && "error" in state && (
        <p className="text-sm text-destructive">{state.error}</p>
      )}
      {state && "insertedCount" in state && (
        <p className="rounded-lg bg-success/15 px-3 py-2 text-sm text-success">
          Se importaron {state.insertedCount} pregunta
          {state.insertedCount === 1 ? "" : "s"} como borrador
          {state.errorCount > 0
            ? `. ${state.errorCount} fila${state.errorCount === 1 ? "" : "s"} con error se omitieron.`
            : "."}
          {state.skippedDuplicateCount > 0
            ? ` ${state.skippedDuplicateCount} fila${state.skippedDuplicateCount === 1 ? "" : "s"} con posible duplicado no se importaron.`
            : ""}
        </p>
      )}
    </div>
  );
}
