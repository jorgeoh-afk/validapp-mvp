"use client";

import { useActionState } from "react";
import Link from "next/link";
import { submitLessonPractice } from "@/lib/data/lessons";
import { Button, buttonVariants } from "@/components/ui/button";

type Question = {
  id: string;
  prompt: string;
  choices: string[];
};

export function PracticeForm({
  lessonId,
  subjectId,
  questions,
}: {
  lessonId: string;
  subjectId: string;
  questions: Question[];
}) {
  const [state, formAction, pending] = useActionState(
    submitLessonPractice,
    null
  );

  if (state && "results" in state) {
    return (
      <div className="mt-6 flex flex-col gap-6">
        <p className="text-lg font-medium">
          Resultado: {state.score} de {state.total} correctas
        </p>
        {state.results.map((result, index) => (
          <div
            key={result.id}
            className={`rounded-lg border p-4 ${
              result.isCorrect
                ? "border-green-600/40 bg-green-600/5"
                : "border-red-600/40 bg-red-600/5"
            }`}
          >
            <p className="text-sm font-medium">
              {index + 1}. {result.prompt}
            </p>
            <p className="mt-2 text-sm">
              Tu respuesta:{" "}
              {result.selectedIndex >= 0
                ? result.choices[result.selectedIndex]
                : "(sin responder)"}{" "}
              {result.isCorrect ? "✓" : "✗"}
            </p>
            {!result.isCorrect && (
              <p className="text-sm text-zinc-600 dark:text-zinc-400">
                Respuesta correcta: {result.choices[result.correctIndex]}
              </p>
            )}
          </div>
        ))}
        <Link
          href={`/ruta/${subjectId}`}
          className={buttonVariants({ variant: "outline", className: "w-fit" })}
        >
          Volver a mi ruta
        </Link>
      </div>
    );
  }

  return (
    <form action={formAction} className="mt-6 flex flex-col gap-6">
      <input type="hidden" name="lessonId" value={lessonId} />
      <input
        type="hidden"
        name="questionIds"
        value={questions.map((q) => q.id).join(",")}
      />

      {questions.map((question, index) => (
        <fieldset key={question.id} className="rounded-lg border border-border p-4">
          <legend className="text-sm font-medium">
            {index + 1}. {question.prompt}
          </legend>
          <div className="mt-2 flex flex-col gap-2">
            {question.choices.map((choice, choiceIndex) => (
              <label key={choiceIndex} className="flex items-center gap-2 text-sm">
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

      {state && "error" in state && (
        <p className="text-sm text-red-600">{state.error}</p>
      )}
      <Button type="submit" disabled={pending} className="w-fit">
        {pending
          ? "Enviando..."
          : questions.length > 0
          ? "Enviar práctica"
          : "Marcar como completada"}
      </Button>
    </form>
  );
}
