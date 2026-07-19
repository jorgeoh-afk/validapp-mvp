import Link from "next/link";
import {
  listPendingReviewGroups,
  listPendingQuestionsForGroup,
} from "@/lib/data/question-review";
import {
  ApproveQuestionButton,
  ApproveAllButton,
  RejectQuestionButton,
} from "./review-actions";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

const VALIDATION_STATUS_LABEL: Record<string, string> = {
  automatically_validated: "Validación automática (sin observaciones)",
  ai_generated_review_required: "Requiere revisión (con observaciones)",
};

const VALIDATION_STATUS_VARIANT: Record<string, "muted" | "warning"> = {
  automatically_validated: "muted",
  ai_generated_review_required: "warning",
};

export default async function RevisionPreguntasPage({
  searchParams,
}: {
  searchParams: Promise<{ subjectId?: string; levelId?: string }>;
}) {
  const { subjectId, levelId } = await searchParams;
  const groups = await listPendingReviewGroups();

  const activeGroup =
    subjectId && levelId
      ? groups.find((g) => g.subjectId === subjectId && g.levelId === levelId)
      : null;
  const questions = activeGroup
    ? await listPendingQuestionsForGroup(subjectId!, levelId!)
    : [];

  return (
    <main className="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-12">
      <header className="flex flex-col gap-1">
        <h1 className="font-heading text-xl font-semibold text-foreground">
          Revisión de preguntas generadas
        </h1>
        <p className="text-sm text-muted-foreground">
          Preguntas creadas por el pipeline de generación EPJA
          (<code className="text-xs">validapp_original</code>). Ninguna se
          puede usar en un ensayo hasta que un administrador la apruebe aquí
          — la aprobación queda registrada en <code className="text-xs">audit_log</code>.
        </p>
      </header>

      {!activeGroup && (
        <Card>
          <CardHeader>
            <CardTitle>Pendientes por asignatura y nivel</CardTitle>
          </CardHeader>
          <CardContent>
            {groups.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                No hay preguntas pendientes de revisión.
              </p>
            ) : (
              <ul className="flex flex-col gap-2">
                {groups.map((g) => (
                  <li
                    key={`${g.subjectId}::${g.levelId}`}
                    className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between"
                  >
                    <span className="text-sm font-medium text-foreground">
                      {g.subjectName} · {g.levelName}
                    </span>
                    <div className="flex flex-wrap items-center gap-2">
                      <Badge variant="warning">
                        {g.reviewRequired} con observaciones
                      </Badge>
                      <Badge variant="muted">
                        {g.automaticallyValidated} sin observaciones
                      </Badge>
                      <Link
                        href={`/admin/revision-preguntas?subjectId=${g.subjectId}&levelId=${g.levelId}`}
                        className="text-sm font-medium text-primary underline-offset-4 hover:underline"
                      >
                        Revisar
                      </Link>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>
      )}

      {activeGroup && (
        <>
          <div className="flex items-center justify-between gap-2">
            <div>
              <h2 className="text-base font-semibold text-foreground">
                {activeGroup.subjectName} · {activeGroup.levelName}
              </h2>
              <p className="text-sm text-muted-foreground">
                {questions.length} pregunta{questions.length === 1 ? "" : "s"} pendiente
                {questions.length === 1 ? "" : "s"}.
              </p>
            </div>
            <div className="flex items-center gap-3">
              <ApproveAllButton
                subjectId={activeGroup.subjectId}
                levelId={activeGroup.levelId}
                count={questions.length}
              />
              <Link
                href="/admin/revision-preguntas"
                className="text-sm font-medium text-primary underline-offset-4 hover:underline"
              >
                ← Volver a la lista
              </Link>
            </div>
          </div>

          <div className="flex flex-col gap-4">
            {questions.map((q) => (
              <Card key={q.id}>
                <CardContent className="flex flex-col gap-3 pt-4">
                  <div className="flex flex-wrap items-center gap-1.5">
                    <Badge variant={VALIDATION_STATUS_VARIANT[q.validation_status]}>
                      {VALIDATION_STATUS_LABEL[q.validation_status]}
                    </Badge>
                    {q.strand_name && <Badge variant="outline">{q.strand_name}</Badge>}
                    {q.difficulty && <Badge variant="outline">{q.difficulty}</Badge>}
                  </div>
                  <p className="text-sm font-medium text-foreground">{q.prompt}</p>
                  {q.choices && (
                    <ul className="flex flex-col gap-1">
                      {q.choices.map((choice, i) => (
                        <li
                          key={i}
                          className={
                            "rounded-md border px-2 py-1 text-sm " +
                            (i === q.correct_index
                              ? "border-success bg-success/10 font-medium text-success"
                              : "border-border text-muted-foreground")
                          }
                        >
                          {choice}
                        </li>
                      ))}
                    </ul>
                  )}
                  {q.explanation && (
                    <p className="text-xs text-muted-foreground">{q.explanation}</p>
                  )}
                  {q.learning_objective_short_name && (
                    <p className="text-xs text-muted-foreground">
                      Objetivo: {q.learning_objective_short_name}
                    </p>
                  )}
                  <div className="flex flex-wrap items-start gap-2">
                    <ApproveQuestionButton
                      id={q.id}
                      subjectId={activeGroup.subjectId}
                      levelId={activeGroup.levelId}
                    />
                    <RejectQuestionButton
                      id={q.id}
                      subjectId={activeGroup.subjectId}
                      levelId={activeGroup.levelId}
                    />
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </>
      )}
    </main>
  );
}
