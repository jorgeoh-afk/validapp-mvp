"use client";

import { useActionState, useEffect, useRef } from "react";
import { upsertLearningObjective } from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

type Editing = {
  id: string;
  unit_id: string;
  level_id: string;
  code: string | null;
  short_name: string;
  description: string;
  priority: string;
  min_recommended_questions: number;
  status: string;
  curricular_source: string;
  reference_year: number | null;
  pedagogical_notes: string;
  order_index: number;
  active: boolean;
  skillIds: string[];
} | null;

export function LearningObjectiveForm({
  editing,
  units,
  levels,
  skills,
}: {
  editing?: Editing;
  units: { id: string; label: string }[];
  levels: { id: string; name: string }[];
  skills: { id: string; name: string }[];
}) {
  const [state, formAction, pending] = useActionState(
    upsertLearningObjective,
    null
  );
  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    if (!state && !editing) formRef.current?.reset();
  }, [state, editing]);

  const key = editing?.id ?? "new";
  const selectedSkillIds = editing?.skillIds ?? [];

  return (
    <form
      ref={formRef}
      action={formAction}
      className="flex flex-col gap-3 rounded-lg border border-border p-4"
    >
      <input type="hidden" name="id" defaultValue={editing?.id ?? ""} />
      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor="unitId">Unidad</Label>
          <select
            id="unitId"
            name="unitId"
            defaultValue={editing?.unit_id ?? ""}
            key={`${key}-unit`}
            required
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="" disabled>
              Selecciona...
            </option>
            {units.map((u) => (
              <option key={u.id} value={u.id}>
                {u.label}
              </option>
            ))}
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="levelId">Curso</Label>
          <select
            id="levelId"
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
          <Label htmlFor="code">Código curricular</Label>
          <Input
            id="code"
            name="code"
            placeholder="p. ej. OA05"
            defaultValue={editing?.code ?? ""}
            key={`${key}-code`}
            className="w-32"
          />
        </div>
      </div>

      <div className="flex flex-col gap-1">
        <Label htmlFor="shortName">Nombre corto</Label>
        <Input
          id="shortName"
          name="shortName"
          defaultValue={editing?.short_name ?? ""}
          key={`${key}-short-name`}
          required
        />
      </div>

      <div className="flex flex-col gap-1">
        <Label htmlFor="description">Descripción completa</Label>
        <textarea
          id="description"
          name="description"
          defaultValue={editing?.description ?? ""}
          key={`${key}-description`}
          rows={3}
          className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
        />
      </div>

      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor="priority">Prioridad</Label>
          <select
            id="priority"
            name="priority"
            defaultValue={editing?.priority ?? "media"}
            key={`${key}-priority`}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="baja">Baja</option>
            <option value="media">Media</option>
            <option value="alta">Alta</option>
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="status">Estado</Label>
          <select
            id="status"
            name="status"
            defaultValue={editing?.status ?? "borrador"}
            key={`${key}-status`}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="borrador">Borrador</option>
            <option value="en_revision">En revisión</option>
            <option value="aprobado">Aprobado</option>
            <option value="archivado">Archivado</option>
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="minRecommendedQuestions">
            Preguntas mínimas recomendadas
          </Label>
          <Input
            id="minRecommendedQuestions"
            name="minRecommendedQuestions"
            type="number"
            min={0}
            defaultValue={editing?.min_recommended_questions ?? 5}
            key={`${key}-min-questions`}
            className="w-32"
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="orderIndex">Orden</Label>
          <Input
            id="orderIndex"
            name="orderIndex"
            type="number"
            defaultValue={editing?.order_index ?? 0}
            key={`${key}-order`}
            className="w-24"
          />
        </div>
        <div className="flex items-center gap-2 self-end pb-1.5">
          <input
            id="active"
            name="active"
            type="checkbox"
            defaultChecked={editing?.active ?? true}
            key={`${key}-active`}
            className="h-4 w-4"
          />
          <Label htmlFor="active">Activo</Label>
        </div>
      </div>

      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor="curricularSource">Fuente curricular</Label>
          <Input
            id="curricularSource"
            name="curricularSource"
            placeholder="p. ej. MINEDUC Bases Curriculares"
            defaultValue={editing?.curricular_source ?? ""}
            key={`${key}-source`}
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="referenceYear">Año de referencia</Label>
          <Input
            id="referenceYear"
            name="referenceYear"
            type="number"
            defaultValue={editing?.reference_year ?? ""}
            key={`${key}-year`}
            className="w-28"
          />
        </div>
      </div>

      <div className="flex flex-col gap-1">
        <Label htmlFor="pedagogicalNotes">Observaciones pedagógicas</Label>
        <textarea
          id="pedagogicalNotes"
          name="pedagogicalNotes"
          defaultValue={editing?.pedagogical_notes ?? ""}
          key={`${key}-notes`}
          rows={2}
          className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
        />
      </div>

      <fieldset className="flex flex-col gap-1">
        <legend className="text-sm font-medium">
          Habilidades asociadas
        </legend>
        {skills.length === 0 ? (
          <p className="text-sm text-zinc-500">
            Aún no hay habilidades en el catálogo.
          </p>
        ) : (
          <div className="flex flex-wrap gap-3" key={`${key}-skills`}>
            {skills.map((skill) => (
              <label
                key={skill.id}
                className="flex items-center gap-1.5 text-sm"
              >
                <input
                  type="checkbox"
                  name="skillIds"
                  value={skill.id}
                  defaultChecked={selectedSkillIds.includes(skill.id)}
                  className="h-4 w-4"
                />
                {skill.name}
              </label>
            ))}
          </div>
        )}
      </fieldset>

      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending} className="w-fit">
        {editing ? "Guardar cambios" : "Agregar objetivo de aprendizaje"}
      </Button>
    </form>
  );
}
