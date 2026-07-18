"use client";

import { useActionState, useMemo, useState } from "react";
import Papa from "papaparse";
import { importSyllabus } from "@/lib/data/syllabus-import";
import {
  SYLLABUS_CSV_COLUMNS,
  buildSyllabusTemplateCsv,
  validateSyllabusRows,
  type RawSyllabusRow,
  type SyllabusCatalogs,
  type ValidatedSyllabusRow,
} from "@/lib/data/syllabus-import-shared";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

const TYPE_LABEL: Record<string, string> = {
  eje: "Eje",
  unidad: "Unidad",
  objetivo: "Objetivo",
  gran_idea: "Gran idea",
  conocimiento_esencial: "Conocimiento esencial",
  leccion: "Lección",
};

function downloadTemplate(catalogs: SyllabusCatalogs) {
  const csv = buildSyllabusTemplateCsv(
    catalogs.subjects[0]?.name,
    catalogs.levels[0]?.name
  );
  const blob = new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "plantilla-temario-validapp.csv";
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

export function SyllabusImportForm({ catalogs }: { catalogs: SyllabusCatalogs }) {
  const [state, formAction, pending] = useActionState(importSyllabus, null);
  const [fileName, setFileName] = useState<string | null>(null);
  const [rawRows, setRawRows] = useState<RawSyllabusRow[]>([]);
  const [parseError, setParseError] = useState<string | null>(null);

  const validated: ValidatedSyllabusRow[] = useMemo(
    () => validateSyllabusRows(rawRows, catalogs),
    [rawRows, catalogs]
  );

  const validCount = validated.filter((r) => r.status === "valida").length;
  const errorCount = validated.filter((r) => r.status === "error").length;

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
            "El archivo tiene errores de formato CSV. Revisa que uses comas como separador."
          );
        }
        const rows: RawSyllabusRow[] = results.data.map((row) => {
          const normalized = {} as RawSyllabusRow;
          for (const col of SYLLABUS_CSV_COLUMNS) {
            normalized[col] = String(row[col] ?? "");
          }
          return normalized;
        });
        setRawRows(rows);
      },
      error: () => setParseError("No se pudo leer el archivo. ¿Es un CSV válido?"),
    });
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-2 rounded-xl border border-border p-4">
        <p className="text-sm font-medium">1. Descarga la plantilla</p>
        <p className="text-sm text-muted-foreground">
          Incluye un ejemplo encadenado de cada tipo de fila (eje → unidad →
          objetivo → gran idea → conocimiento esencial → lección). La
          columna <code>tipo</code> indica qué es cada fila; una unidad
          puede referenciar un eje definido más arriba en el mismo archivo,
          y un objetivo puede referenciar una unidad definida más arriba,
          sin que existan todavía en la base de datos.
        </p>
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="w-fit"
          onClick={() => downloadTemplate(catalogs)}
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
          aria-label="Seleccionar archivo CSV de temario"
          className="text-sm"
        />
        {fileName && (
          <p className="text-xs text-muted-foreground">
            Archivo cargado: {fileName} ({rawRows.length} fila
            {rawRows.length === 1 ? "" : "s"})
          </p>
        )}
        {parseError && <p className="text-sm text-destructive">{parseError}</p>}
      </div>

      {rawRows.length > 0 && (
        <div className="flex flex-col gap-3 rounded-xl border border-border p-4">
          <p className="text-sm font-medium">3. Revisa la vista previa</p>
          <div className="flex flex-wrap gap-2 text-sm">
            <Badge variant="success">{validCount} válidas</Badge>
            <Badge variant="destructive">{errorCount} con error</Badge>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full min-w-[720px] text-left text-sm">
              <thead>
                <tr className="border-b border-border text-xs text-muted-foreground">
                  <th className="py-1.5 pr-2">Fila</th>
                  <th className="py-1.5 pr-2">Tipo</th>
                  <th className="py-1.5 pr-2">Asignatura</th>
                  <th className="py-1.5 pr-2">Curso</th>
                  <th className="py-1.5 pr-2">Nombre</th>
                  <th className="py-1.5 pr-2">Detalle</th>
                </tr>
              </thead>
              <tbody>
                {validated.map((row) => (
                  <tr key={row.rowNumber} className="border-b border-border/50 align-top">
                    <td className="py-1.5 pr-2">{row.rowNumber}</td>
                    <td className="py-1.5 pr-2">
                      <Badge variant={row.status === "valida" ? "success" : "destructive"}>
                        {TYPE_LABEL[row.preview.tipo] ?? row.preview.tipo}
                      </Badge>
                    </td>
                    <td className="py-1.5 pr-2">{row.preview.asignatura}</td>
                    <td className="py-1.5 pr-2">{row.preview.curso}</td>
                    <td className="py-1.5 pr-2 max-w-[240px]">{row.preview.nombre}</td>
                    <td className="py-1.5 pr-2 text-xs text-muted-foreground">
                      {row.errors.length > 0
                        ? row.errors.map((msg, i) => <p key={i}>{msg}</p>)
                        : "Sin observaciones."}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <form action={formAction} className="flex flex-col gap-2">
            <input type="hidden" name="rows" value={JSON.stringify(rawRows)} />
            <p className="text-sm text-muted-foreground">
              {errorCount > 0 &&
                `${errorCount} fila${errorCount === 1 ? "" : "s"} con error no se importará${errorCount === 1 ? "" : "n"}. `}
              Se importarán {validCount} fila{validCount === 1 ? "" : "s"}.
            </p>
            <Button
              type="submit"
              className="w-fit"
              disabled={pending || validCount === 0}
            >
              {pending ? "Importando..." : `Importar ${validCount} fila${validCount === 1 ? "" : "s"}`}
            </Button>
          </form>
        </div>
      )}

      {state && "error" in state && (
        <p className="text-sm text-destructive">{state.error}</p>
      )}
      {state && "insertedCount" in state && (
        <div className="rounded-lg bg-success/15 px-3 py-2 text-sm text-success">
          <p>
            Se importaron {state.insertedCount} fila
            {state.insertedCount === 1 ? "" : "s"}
            {Object.keys(state.byType).length > 0 && (
              <>
                {" "}
                (
                {Object.entries(state.byType)
                  .map(([k, v]) => `${TYPE_LABEL[k] ?? k}: ${v}`)
                  .join(", ")}
                )
              </>
            )}
            .
          </p>
          {state.failures.length > 0 && (
            <div className="mt-2 text-destructive">
              <p className="font-medium">
                {state.failures.length} fila{state.failures.length === 1 ? "" : "s"} no
                se pudo{state.failures.length === 1 ? "" : "n"} importar:
              </p>
              <ul className="mt-1 list-disc pl-4">
                {state.failures.map((f) => (
                  <li key={f.rowNumber}>
                    Fila {f.rowNumber}: {f.reason}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
