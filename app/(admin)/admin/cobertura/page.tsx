import Link from "next/link";
import { getCoverageReport } from "@/lib/data/essays";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ProgressBar } from "@/components/ui/progress-bar";

export default async function CoberturaPage() {
  const report = await getCoverageReport();

  return (
    <main className="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-12">
      <header className="flex flex-col gap-1">
        <h1 className="font-heading text-xl font-semibold text-foreground">
          Cobertura curricular
        </h1>
        <p className="text-sm text-muted-foreground">
          Solo cuenta preguntas con estado &quot;aprobado&quot;. Úsalo para
          detectar qué necesitas cargar antes de generar más ensayos. Para ver
          cómo les está yendo realmente a los estudiantes con las preguntas ya
          publicadas, revisa{" "}
          <Link href="/admin/estadisticas" className="underline">
            estadísticas de desempeño
          </Link>
          .
        </p>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Preguntas aprobadas por curso y asignatura</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[560px] text-left text-sm">
              <thead>
                <tr className="border-b border-border text-muted-foreground">
                  <th className="py-1.5 pr-2">Curso</th>
                  <th className="py-1.5 pr-2">Asignatura</th>
                  <th className="py-1.5 pr-2">Total</th>
                  <th className="py-1.5 pr-2">Inicial</th>
                  <th className="py-1.5 pr-2">Intermedia</th>
                  <th className="py-1.5 pr-2">Avanzada</th>
                </tr>
              </thead>
              <tbody>
                {report.bySubjectLevel.map((row) => (
                  <tr
                    key={`${row.levelId}-${row.subjectId}`}
                    className="border-b border-border/60"
                  >
                    <td className="py-1.5 pr-2">{row.levelName}</td>
                    <td className="py-1.5 pr-2">{row.subjectName}</td>
                    <td className="py-1.5 pr-2">{row.total}</td>
                    <td className="py-1.5 pr-2">{row.inicial}</td>
                    <td className="py-1.5 pr-2">{row.intermedia}</td>
                    <td className="py-1.5 pr-2">{row.avanzada}</td>
                  </tr>
                ))}
                {report.bySubjectLevel.length === 0 && (
                  <tr>
                    <td colSpan={6} className="py-3 text-muted-foreground">
                      Aún no hay preguntas aprobadas.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Objetivos de aprendizaje sin preguntas aprobadas</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="flex flex-col gap-1.5">
            {report.objectivesWithoutQuestions.map((o) => (
              <li
                key={o.objectiveId}
                className="flex items-center justify-between gap-2 rounded-lg border border-border px-3 py-1.5 text-sm"
              >
                <span>
                  {o.objectiveName}{" "}
                  <span className="text-muted-foreground">
                    ({o.subjectName} · {o.levelName})
                  </span>
                </span>
                <Badge variant="destructive">Sin cobertura</Badge>
              </li>
            ))}
            {report.objectivesWithoutQuestions.length === 0 && (
              <p className="text-sm text-muted-foreground">
                Todos los objetivos activos tienen al menos una pregunta
                aprobada.
              </p>
            )}
          </ul>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Objetivos con cobertura insuficiente</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <p className="text-xs text-muted-foreground">
            Comparado contra el mínimo recomendado configurado en cada objetivo.
          </p>
          <ul className="flex flex-col gap-2">
            {report.objectivesWithInsufficientCoverage.map((o) => (
              <li
                key={o.objectiveId}
                className="flex flex-col gap-1.5 rounded-lg border border-border px-3 py-1.5 text-sm sm:flex-row sm:items-center sm:justify-between sm:gap-4"
              >
                <span>
                  {o.objectiveName}{" "}
                  <span className="text-muted-foreground">
                    ({o.subjectName} · {o.levelName})
                  </span>
                </span>
                <div className="flex items-center gap-2 sm:w-48">
                  <ProgressBar
                    value={(o.available / (o.recommended || 1)) * 100}
                    showValue={false}
                    size="sm"
                    className="flex-1"
                  />
                  <Badge variant="warning" className="shrink-0">
                    {o.available}/{o.recommended} preguntas
                  </Badge>
                </div>
              </li>
            ))}
            {report.objectivesWithInsufficientCoverage.length === 0 && (
              <p className="text-sm text-muted-foreground">
                No hay objetivos por debajo del mínimo recomendado.
              </p>
            )}
          </ul>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Preguntas pendientes de revisión</CardTitle>
        </CardHeader>
        <CardContent>
          <Badge variant="warning">
            {report.pendingReviewCount} preguntas en revisión
          </Badge>
        </CardContent>
      </Card>
    </main>
  );
}
