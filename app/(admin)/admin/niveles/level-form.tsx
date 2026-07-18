"use client";

import { useActionState, useEffect, useRef } from "react";
import { upsertLevel } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function LevelForm({
  editing,
  programs,
  educationLevels,
}: {
  editing?: {
    id: string;
    name: string;
    order_index: number;
    program_id: string | null;
    education_level_id: string | null;
  } | null;
  programs: { id: string; name: string }[];
  educationLevels: { id: string; name: string }[];
}) {
  const [state, formAction, pending] = useActionState(upsertLevel, null);
  const formRef = useRef<HTMLFormElement>(null);

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
      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending}>
        {editing ? "Guardar cambios" : "Agregar"}
      </Button>
    </form>
  );
}
