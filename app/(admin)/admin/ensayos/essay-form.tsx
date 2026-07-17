"use client";

import { useActionState } from "react";
import { upsertEssay } from "@/lib/data/essays";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const ESSAY_TYPE_LABEL: Record<string, string> = {
  general_curso: "General del curso",
  por_asignatura: "Por asignatura",
  por_objetivo: "Por objetivo de aprendizaje",
  diagnostico: "Diagnóstico",
  personalizado: "Personalizado",
  practica_errores: "Práctica de errores",
  refuerzo_objetivos: "Refuerzo de objetivos",
};

export type EssayEditing = {
  id: string;
  name: string;
  level_id: string;
  essay_type: string;
  total_questions: number;
  time_limit_minutes: number | null;
  order_mode: string;
  allow_repeat_questions: boolean;
  available_from: string | null;
  max_attempts: number | null;
  feedback_mode: string;
} | null;

export function EssayForm({
  editing,
  levels,
}: {
  editing?: EssayEditing;
  levels: { id: string; name: string }[];
}) {
  const [state, formAction, pending] = useActionState(upsertEssay, null);

  return (
    <form action={formAction} className="flex flex-col gap-4">
      <input type="hidden" name="id" defaultValue={editing?.id ?? ""} />
      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-name">Nombre del ensayo</Label>
          <Input
            id="essay-name"
            name="name"
            defaultValue={editing?.name ?? ""}
            placeholder="p. ej. Ensayo general Matemática 1° Medio"
            required
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-level">Curso</Label>
          <select
            id="essay-level"
            name="levelId"
            defaultValue={editing?.level_id ?? ""}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            required
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
          <Label htmlFor="essay-type">Tipo de ensayo</Label>
          <select
            id="essay-type"
            name="essayType"
            defaultValue={editing?.essay_type ?? "general_curso"}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            {Object.entries(ESSAY_TYPE_LABEL).map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="flex flex-wrap gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-total-questions">Cantidad de preguntas</Label>
          <Input
            id="essay-total-questions"
            name="totalQuestions"
            type="number"
            min={1}
            defaultValue={editing?.total_questions ?? 10}
            className="w-28"
            required
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-time-limit">
            Tiempo límite (minutos, opcional)
          </Label>
          <Input
            id="essay-time-limit"
            name="timeLimitMinutes"
            type="number"
            min={0}
            defaultValue={editing?.time_limit_minutes ?? ""}
            className="w-32"
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-order-mode">Orden de las preguntas</Label>
          <select
            id="essay-order-mode"
            name="orderMode"
            defaultValue={editing?.order_mode ?? "aleatorio"}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="aleatorio">Aleatorio</option>
            <option value="fijo">Fijo</option>
          </select>
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-feedback-mode">Retroalimentación</Label>
          <select
            id="essay-feedback-mode"
            name="feedbackMode"
            defaultValue={editing?.feedback_mode ?? "al_finalizar"}
            className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
          >
            <option value="al_finalizar">Al finalizar</option>
            <option value="inmediata">Inmediata</option>
          </select>
        </div>
      </div>

      <div className="flex flex-wrap items-end gap-3">
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-max-attempts">
            Máximo de intentos (vacío = ilimitado)
          </Label>
          <Input
            id="essay-max-attempts"
            name="maxAttempts"
            type="number"
            min={1}
            defaultValue={editing?.max_attempts ?? ""}
            className="w-32"
          />
        </div>
        <div className="flex flex-col gap-1">
          <Label htmlFor="essay-available-from">
            Disponible desde (opcional)
          </Label>
          <Input
            id="essay-available-from"
            name="availableFrom"
            type="datetime-local"
            defaultValue={editing?.available_from?.slice(0, 16) ?? ""}
          />
        </div>
        <label className="flex items-center gap-2 text-sm">
          <input
            type="checkbox"
            name="allowRepeatQuestions"
            defaultChecked={editing?.allow_repeat_questions ?? false}
            className="h-4 w-4"
          />
          Permitir repetir preguntas entre intentos
        </label>
      </div>

      {state?.error && <p className="text-sm text-destructive">{state.error}</p>}

      <Button type="submit" size="sm" className="w-fit" disabled={pending}>
        {editing ? "Guardar configuración" : "Crear ensayo"}
      </Button>
    </form>
  );
}
