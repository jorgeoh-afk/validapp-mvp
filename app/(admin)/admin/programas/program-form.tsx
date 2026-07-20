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
  code?: string | null;
  curriculum_type?: string | null;
  minimum_age?: number | null;
  maximum_age?: number | null;
} | null;

const SELECT_CLASSNAME =
  "h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30";

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
      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor="code">Código estable</Label>
          <Input
            id="code"
            name="code"
            placeholder="ej. epja_regular"
            defaultValue={editing?.code ?? ""}
            key={`${key}-code`}
            className="w-56"
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="curriculumType">Tipo de currículum</Label>
          <select
            id="curriculumType"
            name="curriculumType"
            defaultValue={editing?.curriculum_type ?? ""}
            key={`${key}-curriculum-type`}
            className={SELECT_CLASSNAME}
          >
            <option value="">Sin definir</option>
            <option value="regular">Regular (menores de 18)</option>
            <option value="epja">EPJA (mayores de 18)</option>
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="minimumAge">Edad mínima</Label>
          <Input
            id="minimumAge"
            name="minimumAge"
            type="number"
            min={0}
            defaultValue={editing?.minimum_age ?? ""}
            key={`${key}-min-age`}
            className="w-24"
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="maximumAge">Edad máxima</Label>
          <Input
            id="maximumAge"
            name="maximumAge"
            type="number"
            min={0}
            defaultValue={editing?.maximum_age ?? ""}
            key={`${key}-max-age`}
            className="w-24"
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
        {editing ? "Guardar cambios" : "Agregar programa"}
      </Button>
    </form>
  );
}
