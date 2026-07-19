import Link from "next/link";
import { notFound } from "next/navigation";
import { PartyPopper, Target } from "lucide-react";
import { getDiagnosticResult } from "@/lib/data/diagnostics";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ProgressBar } from "@/components/ui/progress-bar";
import { cn } from "@/lib/utils";

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
    <main className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Card>
        <CardHeader className="text-center">
          <div className="mx-auto flex size-14 items-center justify-center rounded-full bg-primary/10">
            <PartyPopper className="size-7 text-primary" aria-hidden="true" />
          </div>
          <CardTitle className="text-xl">
            Diagnóstico de {diagnostic.subjects?.name} completado
          </CardTitle>
          <CardDescription>
            Respondiste correctamente {diagnostic.score} de{" "}
            {diagnostic.total_questions} preguntas.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <ProgressBar value={porcentaje} label="Resultado" />
          {diagnostic.estimated_level?.name && (
            <div className="flex justify-center">
              <Badge className="gap-1.5 px-3 py-1 text-sm">
                <Target className="size-3.5" aria-hidden="true" />
                Nivel estimado: {diagnostic.estimated_level.name}
              </Badge>
            </div>
          )}
        </CardContent>
      </Card>

      <Link
        href="/panel"
        className={cn(
          buttonVariants({ variant: "default", size: "lg" }),
          "w-full"
        )}
      >
        Volver a mi panel
      </Link>
    </main>
  );
}
