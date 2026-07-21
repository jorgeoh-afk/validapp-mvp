import Link from "next/link";
import { ClipboardList, Clock, ListChecks, RotateCcw } from "lucide-react";
import { listAvailableEssaysForStudent } from "@/lib/data/essay-attempts";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { requireEnrolledProfile } from "../_lib/enrollment";

const ESSAY_TYPE_LABEL: Record<string, string> = {
  general_curso: "General del curso",
  por_asignatura: "Por asignatura",
  por_objetivo: "Por objetivo",
  diagnostico: "Diagnóstico",
  personalizado: "Personalizado",
  practica_errores: "Práctica de errores",
  refuerzo_objetivos: "Refuerzo de objetivos",
};

export default async function EnsayosPage() {
  await requireEnrolledProfile();
  const essays = await listAvailableEssaysForStudent();

  return (
    <main className="mx-auto flex w-full max-w-2xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Link
        href="/panel"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        ← Mi panel
      </Link>

      <div className="flex flex-col gap-1.5">
        <h1 className="text-xl font-semibold text-foreground">Ensayos</h1>
        <p className="text-sm text-muted-foreground">
          Pon a prueba lo que has aprendido con ensayos que combinan preguntas
          de distintas unidades.
        </p>
      </div>

      {essays.length === 0 && (
        <Card>
          <CardContent className="flex flex-col items-center gap-2 py-8 text-center">
            <ClipboardList
              className="size-8 text-muted-foreground"
              aria-hidden="true"
            />
            <p className="text-sm font-medium text-foreground">
              Todavía no hay ensayos disponibles
            </p>
            <p className="text-sm text-muted-foreground">
              Cuando tu institución publique un ensayo para tu curso, lo verás
              aquí.
            </p>
          </CardContent>
        </Card>
      )}

      <div className="flex flex-col gap-3">
        {essays.map((essay) => (
          <Card key={essay.id}>
            <CardHeader>
              <div className="flex items-start justify-between gap-2">
                <CardTitle className="text-base leading-snug">
                  {essay.name}
                </CardTitle>
                <Badge variant={essay.matchesStudentLevel ? "default" : "outline"}>
                  {essay.levelName}
                </Badge>
              </div>
              <CardDescription>
                {ESSAY_TYPE_LABEL[essay.essayType] ?? essay.essayType}
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
              <div className="flex flex-wrap gap-2 text-xs text-muted-foreground">
                <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
                  <ListChecks className="size-3.5" aria-hidden="true" />
                  {essay.totalQuestions} preguntas
                </span>
                {essay.timeLimitMinutes != null && (
                  <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
                    <Clock className="size-3.5" aria-hidden="true" />
                    {essay.timeLimitMinutes} min
                  </span>
                )}
                <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
                  <RotateCcw className="size-3.5" aria-hidden="true" />
                  {essay.maxAttempts != null
                    ? `${essay.attemptsRemaining} de ${essay.maxAttempts} intentos restantes`
                    : `${essay.attemptsUsed} intento${essay.attemptsUsed === 1 ? "" : "s"} rendido${essay.attemptsUsed === 1 ? "" : "s"}`}
                </span>
              </div>
              <Link
                href={`/ensayos/${essay.id}`}
                className={cn(
                  buttonVariants({
                    variant: essay.canStart ? "default" : "outline",
                    size: "default",
                  }),
                  "w-full sm:w-fit"
                )}
              >
                {essay.inProgressAttemptId
                  ? "Continuar intento"
                  : essay.canStart
                    ? "Ver detalles"
                    : "Sin intentos disponibles"}
              </Link>
            </CardContent>
          </Card>
        ))}
      </div>
    </main>
  );
}
