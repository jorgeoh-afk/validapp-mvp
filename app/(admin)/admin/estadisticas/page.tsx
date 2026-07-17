import Link from "next/link";
import { getQuestionPerformanceReport } from "@/lib/data/question-performance";
import { Badge } from "@/components/ui/badge";

function formatSeconds(seconds: number | null) {
  if (seconds == null) return "—";
  if (seconds < 60) return `~${seconds} s`;
  const minutes = Math.round(seconds / 60);
  return `~${minutes} min`;
}

export default async function EstadisticasPage() {
  const report = await getQuestionPerformanceReport();

  return (
    <main className="mx-auto max-w-4xl px-6 py-12">
      <Link href="/admin/cobertura" className="text-sm underline">
        ← Cobertura curricular
      </Link>
      <h1 className="mt-2 text-xl font-semibold">
        Estadísticas de desempeño de preguntas
      </h1>
      <p className="mt-1 text-sm text-muted-foreground">
        Calculadas a partir de respuestas reales de estudiantes en ensayos
        (no incluye intentos sin terminar ni identifica a qué estudiante
        respondió qué).
      </p>

      <section className="mt-6">
        <h2 className="text-sm font-semibold">Preguntas con respuestas registradas</h2>
        <p className="mt-1 text-xs text-muted-foreground">
          Las etiquetas &quot;fácil&quot;, &quot;difícil&quot; y &quot;sugerida
          a revisar&quot; solo se muestran con al menos{" "}
          {report.minAnswersForSignal} respuestas registradas, para no sacar
          conclusiones de pocos datos. El tiempo es una estimación (diferencia
          entre el momento en que se respondió cada pregunta y la anterior
          dentro del mismo intento), no una medición exacta.
        </p>

        {report.questions.length === 0 ? (
          <p className="mt-4 rounded-lg border border-border px-4 py-6 text-center text-sm text-muted-foreground">
            Todavía no hay respuestas de estudiantes registradas en ningún
            ensayo. Estas estadísticas aparecerán apenas se rindan y cierren
            los primeros intentos.
          </p>
        ) : (
          <div className="mt-3 overflow-x-auto">
            <table className="w-full min-w-[720px] border-collapse text-sm">
              <thead>
                <tr className="border-b border-border text-left">
                  <th className="py-2 pr-4">Pregunta</th>
                  <th className="py-2 pr-4">Curso / asignatura</th>
                  <th className="py-2 pr-4">Usos</th>
                  <th className="py-2 pr-4">% acierto</th>
                  <th className="py-2 pr-4">Tiempo (estimado)</th>
                  <th className="py-2 pr-4">Alternativa errónea más elegida</th>
                  <th className="py-2 pr-4">Señales</th>
                </tr>
              </thead>
              <tbody>
                {report.questions.map((q) => (
                  <tr key={q.questionId} className="border-b border-border/50 align-top">
                    <td className="py-2 pr-4 max-w-[240px]">{q.prompt}</td>
                    <td className="py-2 pr-4 whitespace-nowrap">
                      {q.levelName} · {q.subjectName}
                    </td>
                    <td className="py-2 pr-4">{q.timesUsed}</td>
                    <td className="py-2 pr-4">{q.correctPercent}%</td>
                    <td className="py-2 pr-4">{formatSeconds(q.avgEstimatedSeconds)}</td>
                    <td className="py-2 pr-4 max-w-[200px]">
                      {q.mostSelectedWrongChoiceText
                        ? `${q.mostSelectedWrongChoiceText} (${q.mostSelectedWrongChoiceCount})`
                        : "—"}
                    </td>
                    <td className="py-2 pr-4">
                      <div className="flex flex-wrap gap-1">
                        {q.tooEasy && <Badge variant="success">Muy fácil</Badge>}
                        {q.tooHard && <Badge variant="destructive">Muy difícil</Badge>}
                        {q.suggestReview && (
                          <Badge variant="warning">Sugerida a revisar</Badge>
                        )}
                        {!q.tooEasy && !q.tooHard && !q.suggestReview && (
                          <span className="text-xs text-muted-foreground">—</span>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {report.questionsWithoutData > 0 && (
          <p className="mt-3 text-xs text-muted-foreground">
            {report.questionsWithoutData} pregunta(s) del banco aún no han
            sido respondidas por ningún estudiante y no aparecen en la tabla.
          </p>
        )}
      </section>

      <section className="mt-10">
        <h2 className="text-sm font-semibold">
          Desempeño real por objetivo de aprendizaje
        </h2>
        <p className="mt-1 text-xs text-muted-foreground">
          Promedio del % de acierto de las preguntas de cada objetivo que ya
          tienen respuestas registradas. Distinto de la cobertura (cuántas
          preguntas existen): esto muestra qué tan bien les está yendo a los
          estudiantes en la práctica.
        </p>

        {report.objectives.length === 0 ? (
          <p className="mt-4 rounded-lg border border-border px-4 py-6 text-center text-sm text-muted-foreground">
            Todavía no hay suficientes respuestas para calcular el desempeño
            por objetivo de aprendizaje.
          </p>
        ) : (
          <ul className="mt-3 flex flex-col gap-1.5">
            {report.objectives.map((o) => (
              <li
                key={o.objectiveId}
                className="flex items-center justify-between gap-2 rounded-lg border border-border px-3 py-1.5 text-sm"
              >
                <span>
                  {o.objectiveName}{" "}
                  <span className="text-muted-foreground">
                    ({o.subjectName} · {o.levelName}) — {o.questionsWithData}{" "}
                    pregunta(s) con datos
                  </span>
                </span>
                <Badge
                  variant={
                    o.avgCorrectPercent <= 30
                      ? "destructive"
                      : o.avgCorrectPercent >= 90
                        ? "success"
                        : "warning"
                  }
                >
                  {o.avgCorrectPercent}% acierto
                </Badge>
              </li>
            ))}
          </ul>
        )}
      </section>
    </main>
  );
}
