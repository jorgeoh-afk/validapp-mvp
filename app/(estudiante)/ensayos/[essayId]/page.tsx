import Link from "next/link";
import { notFound } from "next/navigation";
import { Clock, ListChecks, RotateCcw, Trophy } from "lucide-react";
import { getEssayStartInfo } from "@/lib/data/essay-attempts";
import { buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { StartEssayButton } from "./start-essay-button";

const ESSAY_TYPE_LABEL: Record<string, string> = {
  general_curso: "General del curso",
  por_asignatura: "Por asignatura",
  por_objetivo: "Por objetivo",
  diagnostico: "Diagnóstico",
  personalizado: "Personalizado",
  practica_errores: "Práctica de errores",
  refuerzo_objetivos: "Refuerzo de objetivos",
};

export default async function EnsayoDetallePage({
  params,
}: {
  params: Promise<{ essayId: string }>;
}) {
  const { essayId } = await params;
  const info = await getEssayStartInfo(essayId);
  if (!info) notFound();

  return (
    <main className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Link
        href="/ensayos"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        ← Ensayos
      </Link>

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">{info.name}</CardTitle>
          <CardDescription>
            {info.levelName} · {ESSAY_TYPE_LABEL[info.essayType] ?? info.essayType}
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="flex flex-wrap gap-2 text-xs text-muted-foreground">
            <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
              <ListChecks className="size-3.5" aria-hidden="true" />
              {info.totalQuestions} preguntas
            </span>
            {info.timeLimitMinutes != null && (
              <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
                <Clock className="size-3.5" aria-hidden="true" />
                {info.timeLimitMinutes} minutos
              </span>
            )}
            {info.totalPoints != null && (
              <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
                <Trophy className="size-3.5" aria-hidden="true" />
                {info.totalPoints} puntos
              </span>
            )}
            <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
              <RotateCcw className="size-3.5" aria-hidden="true" />
              {info.maxAttempts != null
                ? `${info.attemptsRemaining} de ${info.maxAttempts} intentos restantes`
                : `${info.attemptsUsed} intento${info.attemptsUsed === 1 ? "" : "s"} rendido${info.attemptsUsed === 1 ? "" : "s"}`}
            </span>
          </div>

          <p className="text-sm text-foreground/90">
            {info.feedbackMode === "inmediata"
              ? "Sabrás si acertaste apenas respondas cada pregunta."
              : "Verás tu resultado y la revisión completa recién al terminar el ensayo."}
            {info.timeLimitMinutes != null &&
              " Si se acaba el tiempo, el ensayo se entrega automáticamente con las respuestas que alcances a marcar."}
          </p>

          {info.inProgressAttemptId ? (
            <Link
              href={`/ensayos/${essayId}/intento/${info.inProgressAttemptId}`}
              className={cn(buttonVariants({ variant: "default", size: "lg" }), "w-full")}
            >
              Continuar mi intento
            </Link>
          ) : info.blockedReason ? (
            <p className="rounded-xl bg-muted p-4 text-sm text-muted-foreground">
              {info.blockedReason}
            </p>
          ) : (
            <StartEssayButton essayId={essayId} />
          )}
        </CardContent>
      </Card>
    </main>
  );
}
