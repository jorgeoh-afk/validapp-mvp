"use client";

import { useActionState, useEffect, useRef } from "react";
import { upsertProgram } from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

type Editing = {
  id: string;
  name: string;
  description: string;
  order_index: number;
  active: boolean;
} | null;

export function ProgramForm({ editing }: { editing?: Editing }) {
  const [state, formAction, pending] = useActionState(upsertProgram, null);
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
          <Label htmlFor="name">Nombre del programa</Label>
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
        {editing ? "Guardar cambios" : "Agregar programa"}
      </Button>
    </form>
  );
}
