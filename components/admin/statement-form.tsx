"use client";

import { useActionState, useEffect, useRef } from "react";
import type { FormState } from "@/lib/data/big-ideas";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const STATUS_OPTIONS = [
  { value: "borrador", label: "Borrador" },
  { value: "en_revision", label: "En revisión" },
  { value: "aprobado", label: "Aprobado" },
  { value: "archivado", label: "Archivado" },
];

export type StatementEditing = {
  id: string;
  subject_id: string;
  level_id: string;
  statement: string;
  order_index: number;
  status: string;
  curricular_source: string;
  reference_year: number | null;
} | null;

/**
 * Formulario compartido para "grandes ideas" y "conocimientos esenciales":
 * ambas tablas tienen exactamente la misma forma (asignatura, curso,
 * enunciado, orden, estado, fuente curricular, año de referencia).
 */
export function StatementForm({
  action,
  editing,
  subjects,
  levels,
  itemLabel,
  statementLabel,
}: {
  action: (state: FormState, formData: FormData) => Promise<FormState>;
  editing?: StatementEditing;
  subjects: { id: string; name: string }[];
  levels: { id: string; name: string }[];
  itemLabel: string;
  statementLabel: string;
}) {
  const [state, formAction, pending] = useActionState(action, null);
  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    if (!state && !editing) formRef.current?.reset();
  }, [state, editing]);

  const key = editing?.id ?? "new";

  return (
    <form
      ref={formRef}
      action={formAction}
      className="flex flex-col gap-3 rounded-lg border border-border p-4"
    >
      <input type="hidden" name="id" defaultValue={editing?.id ?? ""} />
      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor={`${itemLabel}-subject`}>Asignatura</Label>
          <select
            id={`${itemLabel}-subject`}
            name="subjectId"
            defaultValue={editing?.subject_id ?? ""}
            key={`${key}-subject`}
            required
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="" disabled>
              Selecciona...
            </option>
            {subjects.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name}
              </option>
            ))}
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor={`${itemLabel}-level`}>Curso</Label>
          <select
            id={`${itemLabel}-level`}
            name="levelId"
            defaultValue={editing?.level_id ?? ""}
            key={`${key}-level`}
            required
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="" disabled>
              Selecciona...
            </option>
            {levels.map((l) => (
              <option key={l.id} value={l.id}>
                {l.name}
              </option>
            ))}
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor={`${itemLabel}-order`}>Orden</Label>
          <Input
            id={`${itemLabel}-order`}
            name="orderIndex"
            type="number"
            defaultValue={editing?.order_index ?? 0}
            key={`${key}-order`}
            className="w-24"
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor={`${itemLabel}-status`}>Estado</Label>
          <select
            id={`${itemLabel}-status`}
            name="status"
            defaultValue={editing?.status ?? "borrador"}
            key={`${key}-status`}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            {STATUS_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="flex flex-col gap-1">
        <Label htmlFor={`${itemLabel}-statement`}>{statementLabel}</Label>
        <textarea
          id={`${itemLabel}-statement`}
          name="statement"
          defaultValue={editing?.statement ?? ""}
          key={`${key}-statement`}
          rows={3}
          required
          className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
        />
      </div>

      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor={`${itemLabel}-source`}>Fuente curricular</Label>
          <Input
            id={`${itemLabel}-source`}
            name="curricularSource"
            placeholder="p. ej. MINEDUC Bases Curriculares"
            defaultValue={editing?.curricular_source ?? ""}
            key={`${key}-source`}
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor={`${itemLabel}-year`}>Año de referencia</Label>
          <Input
            id={`${itemLabel}-year`}
            name="referenceYear"
            type="number"
            defaultValue={editing?.reference_year ?? ""}
            key={`${key}-year`}
            className="w-28"
          />
        </div>
      </div>

      {state?.error && <p className="text-sm text-destructive">{state.error}</p>}
      <Button type="submit" disabled={pending} className="w-fit">
        {editing ? "Guardar cambios" : `Agregar ${itemLabel}`}
      </Button>
    </form>
  );
}
