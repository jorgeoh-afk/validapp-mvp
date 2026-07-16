"use client";

import { useActionState, useEffect, useRef } from "react";
import { upsertSkill } from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

type Editing = {
  id: string;
  name: string;
  description: string;
  category: string;
} | null;

export function SkillForm({ editing }: { editing?: Editing }) {
  const [state, formAction, pending] = useActionState(upsertSkill, null);
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
          <Label htmlFor="name">Nombre de la habilidad</Label>
          <Input
            id="name"
            name="name"
            defaultValue={editing?.name ?? ""}
            key={`${key}-name`}
            required
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="category">Categoría</Label>
          <Input
            id="category"
            name="category"
            placeholder="p. ej. cognitiva"
            defaultValue={editing?.category ?? ""}
            key={`${key}-category`}
          />
        </div>
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="description">Descripción</Label>
        <textarea
          id="description"
          name="description"
          defaultValue={editing?.description ?? ""}
          key={`${key}-description`}
          rows={2}
          className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
        />
      </div>
      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending} className="w-fit">
        {editing ? "Guardar cambios" : "Agregar habilidad"}
      </Button>
    </form>
  );
}
