import Link from "next/link";
import { notFound } from "next/navigation";
import { getDiagnosticResult } from "@/lib/data/diagnostics";
import { buttonVariants } from "@/components/ui/button";

export default async function ResultadoDiagnosticoPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const diagnostic = await getDiagnosticResult(id);

  if (!diagnostic) notFound();

  const porcentaje = Math.round(
    (diagnostic.score / diagnostic.total_questions) * 100
  );

  return (
    <main className="mx-auto flex max-w-xl flex-col items-center gap-4 px-6 py-16 text-center">
      <h1 className="text-2xl font-semibold">
        Resultado — {diagnostic.subjects?.name}
      </h1>
      <p className="text-lg">
        {diagnostic.score} de {diagnostic.total_questions} correctas (
        {porcentaje}%)
      </p>
      {diagnostic.estimated_level?.name && (
        <p className="text-zinc-600 dark:text-zinc-400">
          Nivel estimado: <strong>{diagnostic.estimated_level.name}</strong>
        </p>
      )}
      <Link href="/panel" className={buttonVariants({ variant: "outline" })}>
        Volver a mi panel
      </Link>
    </main>
  );
}
