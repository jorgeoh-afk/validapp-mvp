"use client";

import { useActionState } from "react";
import { replaceEssayQuestion } from "@/lib/data/essays";
import { Button } from "@/components/ui/button";

export function ReplaceButton({
  essayId,
  essayQuestionId,
}: {
  essayId: string;
  essayQuestionId: string;
}) {
  const [state, formAction, pending] = useActionState(
    replaceEssayQuestion,
    null
  );

  return (
    <form action={formAction} className="flex flex-col items-end gap-1">
      <input type="hidden" name="essayId" value={essayId} />
      <input type="hidden" name="essayQuestionId" value={essayQuestionId} />
      <Button type="submit" variant="outline" size="sm" disabled={pending}>
        {pending ? "Reemplazando..." : "Reemplazar"}
      </Button>
      {state?.error && (
        <p className="max-w-[14rem] text-right text-xs text-destructive">
          {state.error}
        </p>
      )}
    </form>
  );
}
