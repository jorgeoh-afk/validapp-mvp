"use client";

import { useActionState, useEffect, useRef } from "react";
import { upsertQuestion } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

type Editing = {
  id: string;
  subject_id: string;
  level_id: string;
  lesson_id: string | null;
  prompt: string;
  choices: string[];
  correct_index: number;
} | null;

export function QuestionForm({
  editing,
  subjects,
  levels,
  lessons,
}: {
  editing?: Editing;
  subjects: { id: string; name: string }[];
  levels: { id: string; name: string }[];
  lessons: { id: string; title: string }[];
}) {
  const [state, formAction, pending] = useActionState(upsertQuestion, null);
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
          <Label htmlFor="lessonId">Lección (opcional)</Label>
          <select
            id="lessonId"
            name="lessonId"
            defaultValue={editing?.lesson_id ?? ""}
            key={`${key}-lesson`}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="">— Solo diagnóstico —</option>
            {lessons.map((l) => (
              <option key={l.id} value={l.id}>
                {l.title}
              </option>
            ))}
          </select>
        </div>
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="prompt">Pregunta</Label>
        <textarea
          id="prompt"
          name="prompt"
          defaultValue={editing?.prompt ?? ""}
          key={`${key}-prompt`}
          rows={2}
          required
          className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
        />
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="choices">Alternativas (una por línea)</Label>
        <textarea
          id="choices"
          name="choices"
          defaultValue={editing?.choices?.join("\n") ?? ""}
          key={`${key}-choices`}
          rows={4}
          required
          className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
        />
      </div>
      <div className="flex flex-col gap-1">
        <Label htmlFor="correctIndex">
          Índice de la alternativa correcta (0 = primera)
        </Label>
        <Input
          id="correctIndex"
          name="correctIndex"
          type="number"
          min={0}
          defaultValue={editing?.correct_index ?? 0}
          key={`${key}-correct`}
          className="w-24"
        />
      </div>
      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending} className="w-fit">
        {editing ? "Guardar cambios" : "Agregar pregunta"}
      </Button>
    </form>
  );
}
