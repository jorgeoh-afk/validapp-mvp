import Link from "next/link";
import {
  listQuestions,
  listQuestionTags,
  listSubjects,
  listLevels,
  listLessons,
  deleteQuestion,
  getQuestionDeleteImpact,
  updateQuestionReviewStatus,
} from "@/lib/data/content";
import {
  listStrands,
  listUnits,
  listLearningObjectives,
  listSkills,
} from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ConfirmDeleteDialog } from "@/components/admin/confirm-delete-dialog";
import { QuestionForm, type Editing } from "./question-form";

const DIFFICULTY_LABEL: Record<string, string> = {
  inicial: "Inicial",
  intermedia: "Intermedia",
  avanzada: "Avanzada",
};

const REVIEW_STATUS_LABEL: Record<string, string> = {
  borrador: "Borrador",
  en_revision: "En revisión",
  aprobado: "Aprobado",
  archivado: "Archivado",
};

const REVIEW_STATUS_VARIANT: Record<
  string,
  "muted" | "warning" | "success" | "destructive"
> = {
  borrador: "muted",
  en_revision: "warning",
  aprobado: "success",
  archivado: "destructive",
};

/** Próximas transiciones de estado disponibles desde cada estado actual. */
const REVIEW_STATUS_ACTIONS: Record<string, { label: string; status: string }[]> = {
  borrador: [{ label: "Enviar a revisión", status: "en_revision" }],
  en_revision: [
    { label: "Aprobar", status: "aprobado" },
    { label: "Devolver a borrador", status: "borrador" },
  ],
  aprobado: [{ label: "Archivar", status: "archivado" }],
  archivado: [{ label: "Reactivar como borrador", status: "borrador" }],
};

export default async function PreguntasPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string; duplicate?: string }>;
}) {
  const { edit, duplicate } = await searchParams;
  const [
    questions,
    subjects,
    levels,
    lessons,
    strands,
    units,
    learningObjectives,
    skills,
    tags,
  ] = await Promise.all([
    listQuestions(),
    listSubjects(),
    listLevels(),
    listLessons(),
    listStrands(),
    listUnits(),
    listLearningObjectives(),
    listSkills(),
    listQuestionTags(),
  ]);

  // Aplana unidades para exponer strand_id directo (para el selector encadenado).
  const unitOptions = units.map((u) => ({
    id: u.id,
    name: u.name,
    strand_id: u.strand_id,
  }));
  const strandOptions = strands.map((s) => ({
    id: s.id,
    name: s.name,
    subject_id: s.subject_id,
  }));
  const objectiveOptions = learningObjectives.map((o) => ({
    id: o.id,
    short_name: o.short_name,
    unit_id: o.unit_id,
    level_id: o.level_id,
  }));

  function toEditing(question: (typeof questions)[number], keepId: boolean): Editing {
    const objective = learningObjectives.find(
      (o) => o.id === question.learning_objective_id
    );
    const unit = objective
      ? units.find((u) => u.id === objective.unit_id)
      : undefined;
    const tagNames = (question.question_tag_assignments ?? [])
      .map((a: { question_tags: { name: string } | null }) => a.question_tags?.name)
      .filter(Boolean)
      .join(", ");

    return {
      id: keepId ? question.id : "",
      subject_id: question.subject_id,
      level_id: question.level_id,
      lesson_id: question.lesson_id,
      strand_id: unit?.strand_id ?? "",
      unit_id: objective?.unit_id ?? "",
      learning_objective_id: question.learning_objective_id ?? "",
      skill_id: question.skill_id ?? "",
      prompt: question.prompt,
      resource_url: question.resource_url ?? "",
      explanation: question.explanation ?? "",
      choices: question.choices ?? [],
      correct_index: question.correct_index,
      difficulty: question.difficulty ?? "intermedia",
      points: question.points ?? 1,
      estimated_seconds: question.estimated_seconds ?? null,
      source: question.source ?? "",
      review_status: keepId ? question.review_status ?? "borrador" : "borrador",
      tags: tagNames,
    };
  }

  const editingSource = edit
    ? questions.find((q) => q.id === edit)
    : duplicate
      ? questions.find((q) => q.id === duplicate)
      : null;

  const editing = editingSource
    ? toEditing(editingSource, Boolean(edit))
    : null;

  const existingQuestions = questions.map((q) => ({
    id: q.id,
    subject_id: q.subject_id,
    prompt: q.prompt,
  }));

  return (
    <main className="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-12">
      <header className="flex flex-col gap-1">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <h1 className="font-heading text-xl font-semibold text-foreground">
            Preguntas
          </h1>
          <Link
            href="/admin/preguntas/importar"
            className="text-sm font-medium text-primary underline-offset-4 hover:underline"
          >
            Importar preguntas (CSV)
          </Link>
        </div>
        <p className="text-sm text-muted-foreground">
          Crea preguntas paso a paso: curso y asignatura, ubicación curricular,
          enunciado, alternativas y detalles pedagógicos.
        </p>
      </header>

      {subjects.length === 0 || levels.length === 0 ? (
        <Card>
          <CardContent className="pt-4">
            <p className="text-sm text-muted-foreground">
              Primero crea al menos una{" "}
              <Link href="/admin/asignaturas" className="underline">
                asignatura
              </Link>{" "}
              y un{" "}
              <Link href="/admin/niveles" className="underline">
                nivel
              </Link>
              .
            </p>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardHeader>
            <CardTitle>
              {editing?.id ? "Editar pregunta" : "Nueva pregunta"}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <QuestionForm
              key={editing?.id ? `edit-${editing.id}` : duplicate ? `dup-${duplicate}` : "new"}
              editing={editing}
              subjects={subjects}
              levels={levels}
              lessons={lessons}
              strands={strandOptions}
              units={unitOptions}
              learningObjectives={objectiveOptions}
              skills={skills}
              tagSuggestions={tags.map((t) => t.name)}
              existingQuestions={existingQuestions}
            />
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Preguntas registradas</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="flex flex-col gap-2">
            {questions.map((question) => (
              <li
                key={question.id}
                className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-start sm:justify-between sm:gap-4"
              >
                <div className="flex flex-col gap-1.5">
                  <span>
                    {question.prompt}{" "}
                    <span className="text-muted-foreground">
                      ({question.subjects?.name} · {question.levels?.name}
                      {question.lessons?.title
                        ? ` · ${question.lessons.title}`
                        : ""}
                      )
                    </span>
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    <Badge variant="outline">
                      {DIFFICULTY_LABEL[question.difficulty ?? "intermedia"]}
                    </Badge>
                    <Badge
                      variant={
                        REVIEW_STATUS_VARIANT[question.review_status ?? "borrador"]
                      }
                    >
                      {REVIEW_STATUS_LABEL[question.review_status ?? "borrador"]}
                    </Badge>
                    {(question.question_tag_assignments ?? []).map(
                      (a: { question_tags: { id: string; name: string } | null }) =>
                        a.question_tags ? (
                          <Badge key={a.question_tags.id} variant="muted">
                            {a.question_tags.name}
                          </Badge>
                        ) : null
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-2 self-start">
                  <Link
                    href={`/admin/preguntas?edit=${question.id}`}
                    className="text-sm font-medium text-primary underline-offset-4 hover:underline"
                  >
                    Editar
                  </Link>
                  <Link
                    href={`/admin/preguntas?duplicate=${question.id}`}
                    className="text-sm font-medium text-primary underline-offset-4 hover:underline"
                  >
                    Duplicar
                  </Link>
                  {(REVIEW_STATUS_ACTIONS[question.review_status ?? "borrador"] ?? []).map(
                    (action) => (
                      <form key={action.status} action={updateQuestionReviewStatus}>
                        <input type="hidden" name="id" value={question.id} />
                        <input type="hidden" name="status" value={action.status} />
                        <Button type="submit" variant="ghost" size="sm">
                          {action.label}
                        </Button>
                      </form>
                    )
                  )}
                  <ConfirmDeleteDialog
                    id={question.id}
                    itemLabel="esta pregunta"
                    action={deleteQuestion}
                    loadImpact={getQuestionDeleteImpact}
                  />
                </div>
              </li>
            ))}
            {questions.length === 0 && (
              <p className="text-sm text-muted-foreground">Aún no hay preguntas.</p>
            )}
          </ul>
        </CardContent>
      </Card>
    </main>
  );
}
