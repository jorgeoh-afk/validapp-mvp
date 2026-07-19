import Link from "next/link";
import {
  listCurriculumFrameworks,
  listFrameworkSubjects,
  getFrameworkCoverage,
  markFrameworkVerified,
} from "@/lib/data/curriculum-epja";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const STATUS_LABEL: Record<string, string> = {
  draft: "Borrador",
  verified: "Verificado",
  active: "Activo",
  archived: "Archivado",
  superseded: "Reemplazado",
};

const STATUS_VARIANT: Record<
  string,
  "muted" | "warning" | "success" | "destructive"
> = {
  draft: "warning",
  verified: "success",
  active: "success",
  archived: "muted",
  superseded: "muted",
};

const PERIOD_LABEL: Record<string, string> = {
  primer_periodo: "1er período",
  segundo_periodo: "2do período",
};

export default async function CurriculumEpjaPage() {
  const frameworks = await listCurriculumFrameworks();
  const details = await Promise.all(
    frameworks.map(async (framework) => ({
      framework,
      subjects: await listFrameworkSubjects(framework.id),
      coverage: await getFrameworkCoverage(framework.id),
    }))
  );

  return (
    <main className="mx-auto flex max-w-4xl flex-col gap-8 px-6 py-12">
      <header className="flex flex-col gap-1">
        <Link href="/admin" className="text-sm underline">
          ← Panel admin
        </Link>
        <h1 className="font-heading text-xl font-semibold text-foreground">
          Currículum EPJA
        </h1>
        <p className="text-sm text-muted-foreground">
          Versiones curriculares (decreto + período de examinación) para
          Enseñanza Media EPJA, con trazabilidad a la fuente oficial. Una
          misma asignatura/nivel puede tener nombre oficial distinto según la
          versión — ver &quot;Asignaturas examinadas&quot; en cada tarjeta.
        </p>
      </header>

      {details.length === 0 && (
        <Card>
          <CardContent className="pt-4">
            <p className="text-sm text-muted-foreground">
              Aún no hay ninguna versión curricular EPJA registrada. Se crean
              mediante el script de importación piloto
              (<code>supabase/seed/0001_epja_pilot_matematica.sql</code>).
            </p>
          </CardContent>
        </Card>
      )}

      {details.map(({ framework, subjects, coverage }) => (
        <Card key={framework.id}>
          <CardHeader className="flex-row items-start justify-between gap-4">
            <div className="flex flex-col gap-1">
              <CardTitle>{framework.name}</CardTitle>
              <p className="text-xs text-muted-foreground">
                D.S. N.° {framework.decree_number}/{framework.decree_year} ·
                Examinación {framework.exam_year} ·{" "}
                {PERIOD_LABEL[framework.exam_period] ?? framework.exam_period}
              </p>
            </div>
            <Badge variant={STATUS_VARIANT[framework.status] ?? "muted"}>
              {STATUS_LABEL[framework.status] ?? framework.status}
            </Badge>
          </CardHeader>
          <CardContent className="flex flex-col gap-4">
            <div>
              <p className="text-xs font-semibold tracking-wide text-muted-foreground uppercase">
                Fuente oficial
              </p>
              {framework.source_url ? (
                <a
                  href={framework.source_url}
                  target="_blank"
                  rel="noreferrer"
                  className="text-sm text-primary underline-offset-4 hover:underline"
                >
                  {framework.source_name ?? framework.source_url}
                </a>
              ) : (
                <p className="text-sm text-warning-foreground">
                  Sin fuente registrada todavía.
                </p>
              )}
              {framework.verified_at && (
                <p className="text-xs text-muted-foreground">
                  Verificado el{" "}
                  {new Intl.DateTimeFormat("es-CL", { dateStyle: "long" }).format(
                    new Date(framework.verified_at)
                  )}
                  .
                </p>
              )}
            </div>

            <div>
              <p className="text-xs font-semibold tracking-wide text-muted-foreground uppercase">
                Asignaturas examinadas
              </p>
              {subjects.length === 0 ? (
                <p className="text-sm text-muted-foreground">
                  Sin asignaturas asociadas todavía.
                </p>
              ) : (
                <ul className="mt-1 flex flex-wrap gap-1.5">
                  {subjects.map((s) => (
                    <li key={s.id}>
                      <Badge variant="muted">
                        {s.official_name}
                        {s.levels?.name ? ` · ${s.levels.name}` : ""}
                      </Badge>
                    </li>
                  ))}
                </ul>
              )}
            </div>

            <div>
              <p className="text-xs font-semibold tracking-wide text-muted-foreground uppercase">
                Cobertura
              </p>
              <div className="mt-1 flex flex-wrap gap-1.5 text-sm">
                <Badge variant="muted">{coverage.strandsCount} ejes</Badge>
                <Badge variant="muted">{coverage.unitsCount} unidades</Badge>
                <Badge
                  variant={
                    coverage.objectivesWithSourceCount === coverage.objectivesCount &&
                    coverage.objectivesCount > 0
                      ? "success"
                      : "warning"
                  }
                >
                  {coverage.objectivesWithSourceCount}/{coverage.objectivesCount} objetivos
                  con fuente
                </Badge>
                <Badge
                  variant={
                    coverage.questionsApprovedForExamCount > 0 ? "success" : "warning"
                  }
                >
                  {coverage.questionsApprovedForExamCount}/{coverage.questionsCount}{" "}
                  preguntas publicables
                </Badge>
              </div>
            </div>

            {framework.status !== "verified" && framework.source_url && (
              <form action={markFrameworkVerified}>
                <input type="hidden" name="id" value={framework.id} />
                <Button type="submit" variant="outline" size="sm">
                  Marcar como verificado
                </Button>
              </form>
            )}
          </CardContent>
        </Card>
      ))}
    </main>
  );
}
