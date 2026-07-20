"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { upsertLevel } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const SELECT_CLASSNAME =
  "h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30";

export function LevelForm({
  editing,
  programs,
  educationLevels,
  regularLevels,
}: {
  editing?: {
    id: string;
    name: string;
    order_index: number;
    program_id: string | null;
    education_level_id: string | null;
    code?: string | null;
    education_type?: string | null;
    equivalent_grade_from_level_id?: string | null;
    equivalent_grade_to_level_id?: string | null;
  } | null;
  programs: { id: string; name: string }[];
  educationLevels: { id: string; name: string }[];
  /** Cursos con `education_type = 'menor_18'`, para los selectores de
   * equivalencia (solo tiene sentido para niveles EPJA de adultos). */
  regularLevels: { id: string; name: string }[];
}) {
  const [state, formAction, pending] = useActionState(upsertLevel, null);
  const formRef = useRef<HTMLFormElement>(null);
  const [educationType, setEducationType] = useState(
    editing?.education_type ?? ""
  );

  useEffect(() => {
    if (!state && !editing) formRef.current?.reset();
  }, [state, editing]);

  const key = editing?.id ?? "new";

  return (
    <form
      ref={formRef}
      action={formAction}
      className="flex flex-wrap items-end gap-3"
    >
      <input type="hidden" name="id" defaultValue={editing?.id ?? ""} />
      <div className="flex flex-col gap-1">
        <Label htmlFor="name">Nombre del nivel</Label>
        <Input
          id="name"
          name="name"
          defaultValue={editing?.name ?? ""}
          key={`${key}-name`}
          required
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
      <div className="flex flex-col gap-1">
        <Label htmlFor="programId">Programa</Label>
        <select
          id="programId"
          name="programId"
          defaultValue={editing?.program_id ?? ""}
          key={`${key}-program`}
          required
          className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
        >
          <option value="" disabled>
            Selecciona...
          </option>
          {programs.map((p) => (
            <option key={p.id} value={p.id}>
              {p.name}
            </option>
          ))}
        </select>
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="educationLevelId">Nivel educativo</Label>
        <select
          id="educationLevelId"
          name="educationLevelId"
          defaultValue={editing?.education_level_id ?? ""}
          key={`${key}-edu-level`}
          required
          className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
        >
          <option value="" disabled>
            Selecciona...
          </option>
          {educationLevels.map((l) => (
            <option key={l.id} value={l.id}>
              {l.name}
            </option>
          ))}
        </select>
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="code">Código estable</Label>
        <Input
          id="code"
          name="code"
          placeholder="ej. regular_1_basico"
          defaultValue={editing?.code ?? ""}
          key={`${key}-code`}
          className="w-56"
        />
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="educationType">Tipo de estudiante</Label>
        <select
          id="educationType"
          name="educationType"
          value={educationType}
          onChange={(e) => setEducationType(e.target.value)}
          key={`${key}-education-type`}
          className={SELECT_CLASSNAME}
        >
          <option value="">Sin definir</option>
          <option value="menor_18">Menores de 18 años</option>
          <option value="mayor_18">Mayores de 18 años</option>
        </select>
      </div>
      {educationType === "mayor_18" && (
        <>
          <div className="flex flex-col gap-1">
            <Label htmlFor="equivalentGradeFromLevelId">
              Equivale desde (curso regular)
            </Label>
            <select
              id="equivalentGradeFromLevelId"
              name="equivalentGradeFromLevelId"
              defaultValue={editing?.equivalent_grade_from_level_id ?? ""}
              key={`${key}-equiv-from`}
              className={SELECT_CLASSNAME}
            >
              <option value="">— Ninguno —</option>
              {regularLevels.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.name}
                </option>
              ))}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <Label htmlFor="equivalentGradeToLevelId">
              Equivale hasta (curso regular)
            </Label>
            <select
              id="equivalentGradeToLevelId"
              name="equivalentGradeToLevelId"
              defaultValue={editing?.equivalent_grade_to_level_id ?? ""}
              key={`${key}-equiv-to`}
              className={SELECT_CLASSNAME}
            >
              <option value="">— Ninguno —</option>
              {regularLevels.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.name}
                </option>
              ))}
            </select>
          </div>
        </>
      )}
      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending}>
        {editing ? "Guardar cambios" : "Agregar"}
      </Button>
    </form>
  );
}
