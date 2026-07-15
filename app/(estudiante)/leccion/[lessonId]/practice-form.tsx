"use client";

import { useMemo, useState, useTransition } from "react";
import Link from "next/link";
import { CheckCircle2, XCircle, Circle, Loader2, PartyPopper } from "lucide-react";
import {
  submitLessonPractice,
  checkPracticeAnswer,
  type PracticeState,
} from "@/lib/data/lessons";
import { Button, buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";

const BLOCK_SIZE = 5;

type Question = {
  id: string;
  prompt: string;
  choices: string[];
};

type CheckResult = {
  correct: boolean;
  correctIndex: number;
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
  const total = questions.length;
  const blocks = useMemo(() => {
    const chunks: Question[][] = [];
    for (let i = 0; i < questions.length; i += BLOCK_SIZE) {
      chunks.push(questions.slice(i, i + BLOCK_SIZE));
    }
    return chunks;
  }, [questions]);
  const totalBlocks = blocks.length;

  const [current, setCurrent] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [revealed, setRevealed] = useState(false);
  const [answers, setAnswers] = useState<Record<string, number>>({});
  const [checkResults, setCheckResults] = useState<Record<string, CheckResult>>({});
  const [checkError, setCheckError] = useState<string | null>(null);
  const [phase, setPhase] = useState<"question" | "block-summary" | "done">(
    total === 0 ? "block-summary" : "question"
  );
  const [finalResult, setFinalResult] = useState<PracticeState>(null);
  const [isPending, startTransition] = useTransition();
  const [isChecking, startCheckTransition] = useTransition();

  const blockIndex = Math.min(Math.floor(current / BLOCK_SIZE), Math.max(totalBlocks - 1, 0));
  const currentBlock = blocks[blockIndex] ?? [];
  const questionInBlock = current % BLOCK_SIZE;
  const currentQuestion = questions[current];
  const isLastQuestionOfBlock = questionInBlock === currentBlock.length - 1;
  const isLastBlock = blockIndex === totalBlocks - 1;

  function submitToServer(finalAnswers: Record<string, number>) {
    const formData = new FormData();
    formData.set("lessonId", lessonId);
    formData.set("questionIds", questions.map((q) => q.id).join(","));
    for (const q of questions) {
      const value = finalAnswers[q.id];
      if (value !== undefined) {
        formData.set(`answer_${q.id}`, String(value));
      }
    }
    startTransition(async () => {
      const result = await submitLessonPractice(null, formData);
      setFinalResult(result);
      setPhase("done");
    });
  }

  function handleCheck() {
    if (selected === null || !currentQuestion) return;
    setAnswers((prev) => ({ ...prev, [currentQuestion.id]: selected }));
    setCheckError(null);
    startCheckTransition(async () => {
      const result = await checkPracticeAnswer(currentQuestion.id, selected);
      if ("error" in result) {
        setCheckError(result.error);
        return;
      }
      setCheckResults((prev) => ({ ...prev, [currentQuestion.id]: result }));
      setRevealed(true);
    });
  }

  function handleNext() {
    setCheckError(null);
    if (isLastQuestionOfBlock) {
      setPhase("block-summary");
      return;
    }
    setCurrent((c) => c + 1);
    setSelected(null);
    setRevealed(false);
  }

  function handleContinueAfterBlock() {
    if (isLastBlock) {
      submitToServer(answers);
      return;
    }
    setCurrent((c) => c + 1);
    setSelected(null);
    setRevealed(false);
    setPhase("question");
  }

  // Sin preguntas: marcar la lección como completada directamente.
  if (total === 0 && phase !== "done") {
    return (
      <div className="mt-6 flex flex-col gap-4">
        <Card>
          <CardContent className="flex flex-col gap-3 py-2 text-center">
            <p className="text-sm text-muted-foreground">
              Esta lección todavía no tiene preguntas de práctica.
            </p>
            <Button
              onClick={() => submitToServer({})}
              disabled={isPending}
              className="w-fit self-center"
            >
              {isPending ? (
                <>
                  <Loader2 className="size-4 animate-spin" aria-hidden="true" />
                  Guardando...
                </>
              ) : (
                "Marcar como completada"
              )}
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (phase === "done") {
    if (!finalResult) {
      return (
        <div className="mt-6 flex items-center justify-center gap-2 py-10 text-sm text-muted-foreground">
          <Loader2 className="size-4 animate-spin" aria-hidden="true" />
          Guardando tu progreso...
        </div>
      );
    }
    if ("error" in finalResult) {
      return (
        <p className="mt-6 rounded-xl border border-destructive/30 bg-destructive/10 p-4 text-sm text-destructive">
          {finalResult.error}
        </p>
      );
    }

    const { score, total: totalAnswered, results } = finalResult;
    const percent = totalAnswered === 0 ? 100 : Math.round((score / totalAnswered) * 100);

    return (
      <div className="mt-6 flex flex-col gap-6">
        <Card>
          <CardHeader className="text-center">
            <div className="mx-auto flex size-14 items-center justify-center rounded-full bg-warning/15">
              <PartyPopper className="size-7 text-warning" aria-hidden="true" />
            </div>
            <CardTitle className="text-xl">¡Lección completada!</CardTitle>
            <CardDescription>
              Respondiste correctamente {score} de {totalAnswered} preguntas.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-2">
            <div
              role="progressbar"
              aria-valuenow={percent}
              aria-valuemin={0}
              aria-valuemax={100}
              aria-label="Porcentaje de logro"
              className="h-2.5 w-full overflow-hidden rounded-full bg-muted"
            >
              <div
                className="h-full rounded-full bg-success transition-all"
                style={{ width: `${percent}%` }}
              />
            </div>
            <p className="text-right text-sm text-muted-foreground">{percent}% de logro</p>
          </CardContent>
        </Card>

        {results.length > 0 && (
          <div className="flex flex-col gap-3">
            <h2 className="text-sm font-semibold text-foreground">Revisión de tus respuestas</h2>
            {results.map((result, index) => (
              <div
                key={result.id}
                className={cn(
                  "rounded-xl border p-4",
                  result.isCorrect
                    ? "border-success/30 bg-success/5"
                    : "border-destructive/30 bg-destructive/5"
                )}
              >
                <p className="flex items-start gap-2 text-sm font-medium text-foreground">
                  {result.isCorrect ? (
                    <CheckCircle2 className="mt-0.5 size-4 shrink-0 text-success" aria-hidden="true" />
                  ) : (
                    <XCircle className="mt-0.5 size-4 shrink-0 text-destructive" aria-hidden="true" />
                  )}
                  <span>
                    {index + 1}. {result.prompt}
                  </span>
                </p>
                <p className="mt-2 pl-6 text-sm text-muted-foreground">
                  Tu respuesta:{" "}
                  {result.selectedIndex >= 0
                    ? result.choices[result.selectedIndex]
                    : "(sin responder)"}
                </p>
                {!result.isCorrect && (
                  <p className="pl-6 text-sm text-muted-foreground">
                    Respuesta correcta: {result.choices[result.correctIndex]}
                  </p>
                )}
              </div>
            ))}
          </div>
        )}

        <Link
          href={`/ruta/${subjectId}`}
          className={cn(buttonVariants({ variant: "default", size: "lg" }), "w-full sm:w-fit")}
        >
          Volver a mi ruta
        </Link>
      </div>
    );
  }

  if (phase === "block-summary") {
    const blockResults = currentBlock.map((q) => ({
      question: q,
      isCorrect: checkResults[q.id]?.correct ?? false,
    }));
    const blockScore = blockResults.filter((r) => r.isCorrect).length;

    return (
      <div className="mt-6 flex flex-col gap-4">
        <Card>
          <CardHeader className="text-center">
            <div className="mx-auto flex size-14 items-center justify-center rounded-full bg-primary/10">
              <PartyPopper className="size-7 text-primary" aria-hidden="true" />
            </div>
            <CardTitle className="text-xl">
              {isLastBlock ? "¡Último bloque completado!" : "¡Bloque completado!"}
            </CardTitle>
            <CardDescription>
              Acertaste {blockScore} de {blockResults.length} preguntas de este bloque.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-4">
            <div className="flex justify-center gap-2" aria-hidden="true">
              {blockResults.map((r, i) => (
                <span
                  key={i}
                  className={cn(
                    "flex size-8 items-center justify-center rounded-full text-xs font-semibold",
                    r.isCorrect
                      ? "bg-success/15 text-success"
                      : "bg-destructive/15 text-destructive"
                  )}
                >
                  {r.isCorrect ? (
                    <CheckCircle2 className="size-4" />
                  ) : (
                    <XCircle className="size-4" />
                  )}
                </span>
              ))}
            </div>
            <Button
              onClick={handleContinueAfterBlock}
              disabled={isPending}
              size="lg"
              className="w-full"
            >
              {isPending ? (
                <>
                  <Loader2 className="size-4 animate-spin" aria-hidden="true" />
                  Guardando tu progreso...
                </>
              ) : isLastBlock ? (
                "Ver mi resultado"
              ) : (
                "Continuar con el siguiente bloque"
              )}
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  // phase === "question"
  const currentCheckResult = currentQuestion ? checkResults[currentQuestion.id] : undefined;
  const isCorrectChoice = (idx: number) =>
    revealed && currentCheckResult !== undefined && currentCheckResult.correctIndex === idx;
  const isSelectedCorrect = revealed && Boolean(currentCheckResult?.correct);

  return (
    <div className="mt-6 flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <div className="flex items-center justify-between text-sm">
          <span className="font-medium text-foreground">
            Pregunta {current + 1} de {total}
          </span>
          <span className="text-muted-foreground">
            Bloque {blockIndex + 1} de {totalBlocks}
          </span>
        </div>
        <div
          role="progressbar"
          aria-valuenow={current}
          aria-valuemin={0}
          aria-valuemax={total}
          aria-label="Progreso de la práctica"
          className="h-2.5 w-full overflow-hidden rounded-full bg-muted"
        >
          <div
            className="h-full rounded-full bg-primary transition-all"
            style={{ width: `${((current + (revealed ? 1 : 0)) / total) * 100}%` }}
          />
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg leading-snug">{currentQuestion.prompt}</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <div role="radiogroup" aria-label="Alternativas" className="flex flex-col gap-2.5">
            {currentQuestion.choices.map((choice, idx) => {
              const isSelected = selected === idx;
              const showAsCorrect = revealed && isCorrectChoice(idx);
              const showAsWrong = revealed && isSelected && !isCorrectChoice(idx);

              return (
                <button
                  key={idx}
                  type="button"
                  role="radio"
                  aria-checked={isSelected}
                  disabled={revealed}
                  onClick={() => setSelected(idx)}
                  className={cn(
                    "flex min-h-14 items-center gap-3 rounded-xl border-2 px-4 py-3 text-left text-sm font-medium transition-all",
                    "disabled:cursor-not-allowed",
                    !revealed && !isSelected && "border-border bg-card hover:border-primary/40",
                    !revealed && isSelected && "border-primary bg-primary/5 text-foreground",
                    showAsCorrect && "border-success bg-success/10 text-foreground",
                    showAsWrong && "border-destructive bg-destructive/10 text-foreground",
                    revealed && !isSelected && !isCorrectChoice(idx) && "border-border bg-card opacity-60"
                  )}
                >
                  {showAsCorrect ? (
                    <CheckCircle2 className="size-5 shrink-0 text-success" aria-hidden="true" />
                  ) : showAsWrong ? (
                    <XCircle className="size-5 shrink-0 text-destructive" aria-hidden="true" />
                  ) : (
                    <Circle
                      className={cn(
                        "size-5 shrink-0",
                        isSelected ? "text-primary" : "text-muted-foreground"
                      )}
                      aria-hidden="true"
                    />
                  )}
                  <span>{choice}</span>
                </button>
              );
            })}
          </div>

          <div aria-live="polite">
            {revealed && (
              <div
                className={cn(
                  "rounded-xl p-4 text-sm",
                  isSelectedCorrect ? "bg-success/10 text-foreground" : "bg-destructive/10 text-foreground"
                )}
              >
                <p className="flex items-center gap-2 font-semibold">
                  {isSelectedCorrect ? (
                    <>
                      <CheckCircle2 className="size-4 text-success" aria-hidden="true" />
                      ¡Correcto!
                    </>
                  ) : (
                    <>
                      <XCircle className="size-4 text-destructive" aria-hidden="true" />
                      No era esa alternativa
                    </>
                  )}
                </p>
                <p className="mt-1 text-muted-foreground">
                  {isSelectedCorrect
                    ? "Muy bien, dominas este contenido. Sigue así."
                    : currentCheckResult
                      ? `La respuesta correcta es: "${currentQuestion.choices[currentCheckResult.correctIndex]}". Vuelve a revisar el contenido de la lección si tienes dudas.`
                      : ""}
                </p>
              </div>
            )}
            {checkError && (
              <p className="rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
                {checkError}
              </p>
            )}
          </div>

          {!revealed ? (
            <Button
              onClick={handleCheck}
              disabled={selected === null || isChecking}
              size="lg"
              className="w-full"
            >
              {isChecking ? (
                <>
                  <Loader2 className="size-4 animate-spin" aria-hidden="true" />
                  Comprobando...
                </>
              ) : (
                "Comprobar respuesta"
              )}
            </Button>
          ) : (
            <Button onClick={handleNext} size="lg" className="w-full">
              {isLastQuestionOfBlock ? "Ver resumen del bloque" : "Siguiente pregunta"}
            </Button>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
