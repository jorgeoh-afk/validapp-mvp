import Link from "next/link";
import { notFound } from "next/navigation";
import { CheckCircle2, Clock, PartyPopper, Trophy, XCircle } from "lucide-react";
import { getAttemptResult } from "@/lib/data/essay-attempts";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";

function formatMinutes(totalSeconds: number) {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (minutes === 0) return `${seconds} seg`;
  return `${minutes} min ${seconds} seg`;
}

export default async function ResultadoEnsayoPage({
  params,
}: {
  params: Promise<{ essayId: string; attemptId: string }>;
}) {
  const { attemptId } = await params;
  const result = await getAttemptResult(attemptId);
  if (!result) notFound();

  const percent =
    result.totalPoints === 0 ? 0 : Math.round((result.score / result.totalPoints) * 100);

  return (
    <main className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Card>
        <CardHeader className="text-center">
          <div className="mx-auto flex size-14 items-center justify-center rounded-full bg-warning/15">
            <PartyPopper className="size-7 text-warning" aria-hidden="true" />
          </div>
          <CardTitle className="text-xl">
            {result.status === "expirado" ? "Ensayo entregado por tiempo" : "¡Ensayo completado!"}
          </CardTitle>
          <CardDescription>{result.essayName}</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <div
            role="progressbar"
            aria-valuenow={percent}
            aria-valuemin={0}
            aria-valuemax={100}
            aria-label="Puntaje obtenido"
            className="h-2.5 w-full overflow-hidden rounded-full bg-muted"
          >
            <div
              className="h-full rounded-full bg-success transition-all"
              style={{ width: `${percent}%` }}
            />
          </div>
          <div className="flex flex-wrap items-center justify-between gap-2 text-sm">
            <span className="inline-flex items-center gap-1.5 font-medium text-foreground">
              <Trophy className="size-4 text-warning" aria-hidden="true" />
              {result.score} de {result.totalPoints} puntos ({percent}%)
            </span>
            <span className="inline-flex items-center gap-1.5 text-muted-foreground">
              <Clock className="size-4" aria-hidden="true" />
              {formatMinutes(result.timeSpentSeconds)}
            </span>
          </div>
        </CardContent>
      </Card>

      {result.questions.length > 0 && (
        <div className="flex flex-col gap-3">
          <h2 className="text-sm font-semibold text-foreground">
            Revisión de tus respuestas
          </h2>
          {result.questions.map((q, index) => (
            <div
              key={index}
              className={cn(
                "rounded-xl border p-4",
                q.isCorrect ? "border-success/30 bg-success/5" : "border-destructive/30 bg-destructive/5"
              )}
            >
              <p className="flex items-start gap-2 text-sm font-medium text-foreground">
                {q.isCorrect ? (
                  <CheckCircle2 className="mt-0.5 size-4 shrink-0 text-success" aria-hidden="true" />
                ) : (
                  <XCircle className="mt-0.5 size-4 shrink-0 text-destructive" aria-hidden="true" />
                )}
                <span>
                  {index + 1}. {q.prompt}
                </span>
              </p>
              <p className="mt-2 pl-6 text-sm text-muted-foreground">
                Tu respuesta:{" "}
                {q.selectedVisualPosition != null && q.selectedVisualPosition >= 0
                  ? q.choices[q.selectedVisualPosition]
                  : "(sin responder)"}
              </p>
              {!q.isCorrect && q.correctVisualPosition >= 0 && (
                <p className="pl-6 text-sm text-muted-foreground">
                  Respuesta correcta: {q.choices[q.correctVisualPosition]}
                </p>
              )}
              {q.explanation && (
                <p className="mt-1 pl-6 text-sm text-muted-foreground">{q.explanation}</p>
              )}
            </div>
          ))}
        </div>
      )}

      <Link
        href="/ensayos"
        className={cn(buttonVariants({ variant: "default", size: "lg" }), "w-full sm:w-fit")}
      >
        Volver a ensayos
      </Link>
    </main>
  );
}
