"use client";

import { useActionState, useEffect, useRef } from "react";
import { upsertLesson } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

type Editing = {
  id: string;
  subject_id: string;
  level_id: string;
  title: string;
  content: string;
  order_index: number;
} | null;

export function LessonForm({
  editing,
  subjects,
  levels,
}: {
  editing?: Editing;
  subjects: { id: string; name: string }[];
  levels: { id: string; name: string }[];
}) {
  const [state, formAction, pending] = useActionState(upsertLesson, null);
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
          <Label htmlFor="subjectId">Asignatura</Label>
          <select
            id="subjectId"
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
          <Label htmlFor="levelId">Nivel</Label>
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
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="title">Título</Label>
        <Input
          id="title"
          name="title"
          defaultValue={editing?.title ?? ""}
          key={`${key}-title`}
          required
        />
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="content">Contenido</Label>
        <textarea
          id="content"
          name="content"
          defaultValue={editing?.content ?? ""}
          key={`${key}-content`}
          rows={4}
          className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
        />
      </div>
      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending} className="w-fit">
        {editing ? "Guardar cambios" : "Agregar lección"}
      </Button>
    </form>
  );
}
