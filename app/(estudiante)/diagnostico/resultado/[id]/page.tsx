import Link from "next/link";
import { notFound } from "next/navigation";
import { PartyPopper, Target } from "lucide-react";
import { getDiagnosticResult } from "@/lib/data/diagnostics";
import { requireEnrolledProfile } from "../../../_lib/enrollment";
import type { CurriculumLevelOption } from "@/lib/data/curriculum";
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
  const [diagnostic, profile] = await Promise.all([
    getDiagnosticResult(id),
    requireEnrolledProfile(),
  ]);

  if (!diagnostic) notFound();

  const porcentaje = Math.round(
    (diagnostic.score / diagnostic.total_questions) * 100
  );

  // El diagnóstico ya no "estima" un nivel (ver `submitDiagnostic`): es una
  // prueba de aprobado/no aprobado del nivel inscrito. Si aprobó,
  // `estimated_level` viene con el mismo nivel inscrito; si no, viene `null`
  // y se usa el nombre del nivel inscrito del perfil (`target_level_detail`)
  // para indicarle al estudiante qué nivel debe reforzar.
  const passed = Boolean(diagnostic.estimated_level?.name);
  const targetLevelDetail =
    profile.target_level_detail as unknown as CurriculumLevelOption | null;
  const enrolledLevelName = targetLevelDetail?.name ?? "tu nivel";

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
          <div className="flex justify-center">
            <Badge
              variant={passed ? "success" : "warning"}
              className="gap-1.5 px-3 py-1 text-sm"
            >
              <Target className="size-3.5" aria-hidden="true" />
              {passed
                ? `¡Aprobaste ${enrolledLevelName}!`
                : `Necesitas reforzar ${enrolledLevelName}`}
            </Badge>
          </div>
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
