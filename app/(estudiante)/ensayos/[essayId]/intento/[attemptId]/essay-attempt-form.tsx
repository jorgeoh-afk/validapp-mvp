"use client";

import { useCallback, useEffect, useMemo, useRef, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { CheckCircle2, Circle, Clock, Loader2, XCircle } from "lucide-react";
import {
  submitEssayAnswer,
  submitEssayAttempt,
  type AttemptView,
} from "@/lib/data/essay-attempts";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { cn } from "@/lib/utils";

type Attempt = NonNullable<AttemptView>;

function formatTime(totalSeconds: number) {
  const clamped = Math.max(0, totalSeconds);
  const minutes = Math.floor(clamped / 60);
  const seconds = clamped % 60;
  return `${minutes}:${String(seconds).padStart(2, "0")}`;
}

export function EssayAttemptForm({ attempt }: { attempt: Attempt }) {
  const router = useRouter();
  const total = attempt.questions.length;

  const [current, setCurrent] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [revealed, setRevealed] = useState(false);
  const [feedback, setFeedback] = useState<{
    correct: boolean;
    correctVisualPosition: number;
    explanation: string | null;
  } | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isSaving, startSaving] = useTransition();
  const [isFinishing, startFinishing] = useTransition();
  const finishedRef = useRef(false);

  const deadline = useMemo(() => {
    if (attempt.timeLimitMinutes == null) return null;
    return new Date(attempt.startedAt).getTime() + attempt.timeLimitMinutes * 60_000;
  }, [attempt.startedAt, attempt.timeLimitMinutes]);

  const [remainingSeconds, setRemainingSeconds] = useState<number | null>(() =>
    deadline ? Math.max(0, Math.round((deadline - Date.now()) / 1000)) : null
  );

  const finishAttempt = useCallback(
    (status: "enviado" | "expirado") => {
      if (finishedRef.current) return;
      finishedRef.current = true;
      startFinishing(async () => {
        await submitEssayAttempt(attempt.attemptId, status);
        router.push(`/ensayos/${attempt.essayId}/resultado/${attempt.attemptId}`);
      });
    },
    [attempt.attemptId, attempt.essayId, router]
  );

  useEffect(() => {
    if (!deadline) return;
    const interval = setInterval(() => {
      const secondsLeft = Math.max(0, Math.round((deadline - Date.now()) / 1000));
      setRemainingSeconds(secondsLeft);
      if (secondsLeft <= 0) {
        clearInterval(interval);
        finishAttempt("expirado");
      }
    }, 1000);
    return () => clearInterval(interval);
  }, [deadline, finishAttempt]);

  const currentQuestion = attempt.questions[current];
  const isLast = current === total - 1;

  function handleCheck() {
    if (selected === null || !currentQuestion) return;
    setError(null);
    startSaving(async () => {
      const result = await submitEssayAnswer(
        attempt.attemptId,
        currentQuestion.answerId,
        selected
      );
      if ("error" in result) {
        setError(result.error);
        return;
      }
      if (attempt.feedbackMode === "inmediata") {
        setFeedback(result);
        setRevealed(true);
        return;
      }
      goToNext();
    });
  }

  function goToNext() {
    if (isLast) {
      finishAttempt("enviado");
      return;
    }
    setCurrent((c) => c + 1);
    setSelected(null);
    setRevealed(false);
    setFeedback(null);
  }

  if (total === 0) {
    return (
      <Card>
        <CardContent className="flex flex-col items-center gap-3 py-8 text-center">
          <p className="text-sm text-muted-foreground">
            Este ensayo no tiene preguntas cargadas.
          </p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <div className="flex items-center justify-between text-sm">
          <span className="font-medium text-foreground">
            Pregunta {current + 1} de {total}
          </span>
          {remainingSeconds !== null && (
            <span
              className={cn(
                "inline-flex items-center gap-1 font-medium",
                remainingSeconds <= 60 ? "text-destructive" : "text-muted-foreground"
              )}
              aria-live="polite"
            >
              <Clock className="size-3.5" aria-hidden="true" />
              {formatTime(remainingSeconds)}
            </span>
          )}
        </div>
        <div
          role="progressbar"
          aria-valuenow={current}
          aria-valuemin={0}
          aria-valuemax={total}
          aria-label="Progreso del ensayo"
          className="h-2.5 w-full overflow-hidden rounded-full bg-muted"
        >
          <div
            className="h-full rounded-full bg-primary transition-all"
            style={{ width: `${(current / total) * 100}%` }}
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
              const showAsCorrect = revealed && feedback?.correctVisualPosition === idx;
              const showAsWrong = revealed && isSelected && !showAsCorrect;

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
                    revealed &&
                      !isSelected &&
                      feedback?.correctVisualPosition !== idx &&
                      "border-border bg-card opacity-60"
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
            {revealed && feedback && (
              <div
                className={cn(
                  "rounded-xl p-4 text-sm",
                  feedback.correct ? "bg-success/10 text-foreground" : "bg-destructive/10 text-foreground"
                )}
              >
                <p className="flex items-center gap-2 font-semibold">
                  {feedback.correct ? (
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
                {feedback.explanation && (
                  <p className="mt-1 text-muted-foreground">{feedback.explanation}</p>
                )}
              </div>
            )}
            {error && (
              <p className="rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
                {error}
              </p>
            )}
          </div>

          {!revealed ? (
            <Button
              onClick={handleCheck}
              disabled={selected === null || isSaving || isFinishing}
              size="lg"
              className="w-full"
            >
              {isSaving ? (
                <>
                  <Loader2 className="size-4 animate-spin" aria-hidden="true" />
                  Guardando...
                </>
              ) : attempt.feedbackMode === "inmediata" ? (
                "Comprobar respuesta"
              ) : isLast ? (
                "Entregar ensayo"
              ) : (
                "Guardar y continuar"
              )}
            </Button>
          ) : (
            <Button onClick={goToNext} size="lg" className="w-full" disabled={isFinishing}>
              {isFinishing ? (
                <>
                  <Loader2 className="size-4 animate-spin" aria-hidden="true" />
                  Entregando...
                </>
              ) : isLast ? (
                "Ver mi resultado"
              ) : (
                "Siguiente pregunta"
              )}
            </Button>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
