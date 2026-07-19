"use client";

import { useActionState } from "react";
import { AlertCircle, CheckCircle2, Circle } from "lucide-react";
import { submitDiagnostic } from "@/lib/data/diagnostics";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

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
    <form action={formAction} className="flex flex-col gap-4">
      <input type="hidden" name="subjectId" value={subjectId} />
      <input
        type="hidden"
        name="questionIds"
        value={questions.map((q) => q.id).join(",")}
      />

      {questions.map((question, index) => (
        <Card key={question.id}>
          <CardHeader>
            <CardDescription>
              Pregunta {index + 1} de {questions.length}
            </CardDescription>
            <CardTitle className="text-base leading-snug font-medium">
              {question.prompt}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div
              role="radiogroup"
              aria-label={`Alternativas de la pregunta ${index + 1}`}
              className="flex flex-col gap-2.5"
            >
              {question.choices.map((choice, choiceIndex) => (
                <label
                  key={choiceIndex}
                  className="flex min-h-14 cursor-pointer items-center gap-3 rounded-xl border-2 border-border bg-card px-4 py-3 text-left text-sm font-medium text-foreground transition-all has-[:checked]:border-primary has-[:checked]:bg-primary/5 has-[:focus-visible]:ring-3 has-[:focus-visible]:ring-ring/50"
                >
                  <input
                    type="radio"
                    name={`answer_${question.id}`}
                    value={choiceIndex}
                    required
                    className="peer sr-only"
                  />
                  <Circle
                    className="size-5 shrink-0 text-muted-foreground peer-checked:hidden"
                    aria-hidden="true"
                  />
                  <CheckCircle2
                    className="hidden size-5 shrink-0 text-primary peer-checked:block"
                    aria-hidden="true"
                  />
                  <span>{choice}</span>
                </label>
              ))}
            </div>
          </CardContent>
        </Card>
      ))}

      {state?.error && (
        <p className="flex items-center gap-2 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          <AlertCircle className="size-4 shrink-0" aria-hidden="true" />
          {state.error}
        </p>
      )}

      <Button
        type="submit"
        disabled={pending}
        size="lg"
        className="w-full sm:w-fit"
      >
        {pending ? "Enviando..." : "Enviar diagnóstico"}
      </Button>
    </form>
  );
}
