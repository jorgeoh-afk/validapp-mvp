"use client";

import { useActionState, useEffect, useRef } from "react";
import { upsertLevel } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function LevelForm({
  editing,
}: {
  editing?: { id: string; name: string; order_index: number } | null;
}) {
  const [state, formAction, pending] = useActionState(upsertLevel, null);
  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    if (!state && !editing) formRef.current?.reset();
  }, [state, editing]);

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
          key={editing?.id ?? "new-name"}
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
          key={editing?.id ?? "new-order"}
          className="w-24"
        />
      </div>
      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending}>
        {editing ? "Guardar cambios" : "Agregar"}
      </Button>
    </form>
  );
}
