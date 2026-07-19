"use client";

// Botones cliente para la cola de revisión de preguntas generadas por IA.
// Usan `useActionState` (mismo patrón que `distribution-form.tsx`/
// `generate-panel.tsx`/`replace-button.tsx` en `/admin/ensayos/[id]`) para
// que el error de Supabase devuelto por `approveQuestionForExam`/
// `approveAllQuestionsForExam`/`rejectQuestion` (lib/data/question-review.ts)
// se muestre en la interfaz en vez de quedar solo en el log del servidor.

import { useActionState } from "react";
import { AlertCircle } from "lucide-react";
import {
  approveQuestionForExam,
  approveAllQuestionsForExam,
  rejectQuestion,
} from "@/lib/data/question-review";
import { Button } from "@/components/ui/button";

export function ApproveQuestionButton({
  id,
  subjectId,
  levelId,
}: {
  id: string;
  subjectId: string;
  levelId: string;
}) {
  const [state, formAction, pending] = useActionState(
    approveQuestionForExam,
    null
  );

  return (
    <form action={formAction} className="flex flex-col gap-1">
      <input type="hidden" name="id" value={id} />
      <input type="hidden" name="subjectId" value={subjectId} />
      <input type="hidden" name="levelId" value={levelId} />
      <Button type="submit" variant="default" size="sm" disabled={pending}>
        {pending ? "Aprobando..." : "Aprobar para examen"}
      </Button>
      <div aria-live="polite">
        {state?.error && (
          <p className="flex items-center gap-1.5 text-xs text-destructive">
            <AlertCircle className="size-3.5 shrink-0" aria-hidden="true" />
            {state.error}
          </p>
        )}
      </div>
    </form>
  );
}

export function RejectQuestionButton({
  id,
  subjectId,
  levelId,
}: {
  id: string;
  subjectId: string;
  levelId: string;
}) {
  const [state, formAction, pending] = useActionState(rejectQuestion, null);

  return (
    <form action={formAction} className="flex flex-col gap-1">
      <input type="hidden" name="id" value={id} />
      <input type="hidden" name="subjectId" value={subjectId} />
      <input type="hidden" name="levelId" value={levelId} />
      <Button type="submit" variant="ghost" size="sm" disabled={pending}>
        {pending ? "Descartando..." : "Descartar (desactivar)"}
      </Button>
      <div aria-live="polite">
        {state?.error && (
          <p className="flex items-center gap-1.5 text-xs text-destructive">
            <AlertCircle className="size-3.5 shrink-0" aria-hidden="true" />
            {state.error}
          </p>
        )}
      </div>
    </form>
  );
}

export function ApproveAllButton({
  subjectId,
  levelId,
  count,
}: {
  subjectId: string;
  levelId: string;
  count: number;
}) {
  const [state, formAction, pending] = useActionState(
    approveAllQuestionsForExam,
    null
  );

  return (
    <form action={formAction} className="flex flex-col items-end gap-1">
      <input type="hidden" name="subjectId" value={subjectId} />
      <input type="hidden" name="levelId" value={levelId} />
      <Button type="submit" variant="default" size="sm" disabled={pending}>
        {pending ? "Aprobando..." : `Aprobar todas las visibles (${count})`}
      </Button>
      <div aria-live="polite">
        {state?.error && (
          <p className="flex items-center gap-1.5 text-xs text-destructive">
            <AlertCircle className="size-3.5 shrink-0" aria-hidden="true" />
            {state.error}
          </p>
        )}
      </div>
    </form>
  );
}
