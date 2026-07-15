import Link from "next/link";
import { getDiagnosticQuestions } from "@/lib/data/diagnostics";
import { listSubjects } from "@/lib/data/content";
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
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/diagnostico" className="text-sm underline">
        ← Diagnóstico
      </Link>
      <h1 className="mt-2 text-xl font-semibold">
        Diagnóstico de {subject?.name ?? "asignatura"}
      </h1>

      {questions.length === 0 ? (
        <p className="mt-6 text-sm text-zinc-600 dark:text-zinc-400">
          Todavía no hay preguntas de diagnóstico para esta asignatura.
        </p>
      ) : (
        <DiagnosticForm subjectId={subjectId} questions={questions} />
      )}
    </main>
  );
}
