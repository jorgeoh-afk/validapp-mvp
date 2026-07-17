import Link from "next/link";
import { getCoverageReport } from "@/lib/data/essays";
import { Badge } from "@/components/ui/badge";

export default async function CoberturaPage() {
  const report = await getCoverageReport();

  return (
    <main className="mx-auto max-w-3xl px-6 py-12">
      <Link href="/admin/ensayos" className="text-sm underline">
        ← Ensayos
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Cobertura curricular</h1>
      <p className="mt-1 text-sm text-muted-foreground">
        Solo cuenta preguntas con estado &quot;aprobado&quot;. Úsalo para
        detectar qué necesitas cargar antes de generar más ensayos. Para ver
        cómo les está yendo realmente a los estudiantes con las preguntas ya
        publicadas, revisa{" "}
        <Link href="/admin/estadisticas" className="underline">
          estadísticas de desempeño
        </Link>
        .
      </p>

      <section className="mt-6">
        <h2 className="text-sm font-semibold">
          Preguntas aprobadas por curso y asignatura
        </h2>
        <div className="mt-2 overflow-x-auto">
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
      </section>

      <section className="mt-8">
        <h2 className="text-sm font-semibold">
          Objetivos de aprendizaje sin preguntas aprobadas
        </h2>
        <ul className="mt-2 flex flex-col gap-1.5">
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
      </section>

      <section className="mt-8">
        <h2 className="text-sm font-semibold">
          Objetivos con cobertura insuficiente
        </h2>
        <p className="text-xs text-muted-foreground">
          Comparado contra el mínimo recomendado configurado en cada objetivo.
        </p>
        <ul className="mt-2 flex flex-col gap-1.5">
          {report.objectivesWithInsufficientCoverage.map((o) => (
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
              <Badge variant="warning">
                {o.available}/{o.recommended} preguntas
              </Badge>
            </li>
          ))}
          {report.objectivesWithInsufficientCoverage.length === 0 && (
            <p className="text-sm text-muted-foreground">
              No hay objetivos por debajo del mínimo recomendado.
            </p>
          )}
        </ul>
      </section>

      <section className="mt-8">
        <h2 className="text-sm font-semibold">Preguntas pendientes de revisión</h2>
        <p className="mt-2 text-sm">
          <Badge variant="warning">
            {report.pendingReviewCount} preguntas en revisión
          </Badge>
        </p>
      </section>
    </main>
  );
}
