"use client";

import { useActionState } from "react";
import { submitDiagnostic } from "@/lib/data/diagnostics";
import { Button } from "@/components/ui/button";

type Question = {
  id: string;
  prompt: string;
  choices: string[];
  level_id: string;
};

export function DiagnosticForm({
  subjectId,
  questions,
}: {
  subjectId: string;
  questions: Question[];
}) {
  const [state, formAction, pending] = useActionState(submitDiagnostic, null);

  return (
    <form action={formAction} className="mt-6 flex flex-col gap-6">
      <input type="hidden" name="subjectId" value={subjectId} />
      <input
        type="hidden"
        name="questionIds"
        value={questions.map((q) => q.id).join(",")}
      />

      {questions.map((question, index) => (
        <fieldset
          key={question.id}
          className="rounded-lg border border-border p-4"
        >
          <legend className="text-sm font-medium">
            {index + 1}. {question.prompt}
          </legend>
          <div className="mt-2 flex flex-col gap-2">
            {question.choices.map((choice, choiceIndex) => (
              <label
                key={choiceIndex}
                className="flex items-center gap-2 text-sm"
              >
                <input
                  type="radio"
                  name={`answer_${question.id}`}
                  value={choiceIndex}
                  required
                />
                {choice}
              </label>
            ))}
          </div>
        </fieldset>
      ))}

      {state?.error && <p className="text-sm text-red-600">{state.error}</p>}
      <Button type="submit" disabled={pending} className="w-fit">
        {pending ? "Enviando..." : "Enviar diagnóstico"}
      </Button>
    </form>
  );
}
