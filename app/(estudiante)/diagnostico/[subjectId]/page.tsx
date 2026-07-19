import Link from "next/link";
import { ArrowLeft, ClipboardList } from "lucide-react";
import { getDiagnosticQuestions } from "@/lib/data/diagnostics";
import { listSubjects } from "@/lib/data/content";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { DiagnosticForm } from "./diagnostic-form";

export default async function RendirDiagnosticoPage({
  params,
}: {
  params: Promise<{ subjectId: string }>;
}) {
  const { subjectId } = await params;
  const [questions, subjects] = await Promise.all([
    getDiagnosticQuestions(subjectId),
    listSubjects(),
  ]);
  const subject = subjects.find((s) => s.id === subjectId);

  return (
    <main className="mx-auto flex w-full max-w-2xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Link
        href="/diagnostico"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Diagnóstico
      </Link>

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">
            Diagnóstico de {subject?.name ?? "asignatura"}
          </CardTitle>
          <CardDescription>
            {questions.length > 0
              ? `Responde con calma las ${questions.length} preguntas. Esto nos ayuda a conocer tu nivel, no a calificarte.`
              : "Responde con calma; esto nos ayuda a conocer tu nivel actual, no a calificarte."}
          </CardDescription>
        </CardHeader>
      </Card>

      {questions.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center gap-2 py-8 text-center">
            <ClipboardList
              className="size-8 text-muted-foreground"
              aria-hidden="true"
            />
            <p className="text-sm font-medium text-foreground">
              Todavía no hay preguntas de diagnóstico
            </p>
            <p className="text-sm text-muted-foreground">
              Para esta asignatura aún no hay preguntas disponibles. Vuelve a
              intentarlo más tarde.
            </p>
          </CardContent>
        </Card>
      ) : (
        <DiagnosticForm subjectId={subjectId} questions={questions} />
      )}
    </main>
  );
}
