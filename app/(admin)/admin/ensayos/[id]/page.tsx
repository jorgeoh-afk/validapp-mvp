import { notFound } from "next/navigation";
import {
  getEssay,
  listEssayDistributions,
  listEssayQuestionsWithDetails,
  updateEssayStatus,
} from "@/lib/data/essays";
import { ESSAY_STATUSES } from "@/lib/data/essay-constants";
import { listSubjects } from "@/lib/data/content";
import { listLearningObjectives } from "@/lib/data/curriculum";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { EssayForm } from "../essay-form";
import { DistributionForm } from "./distribution-form";
import { GeneratePanel } from "./generate-panel";
import { ReplaceButton } from "./replace-button";

const STATUS_LABEL: Record<string, string> = {
  borrador: "Borrador",
  en_revision: "En revisión",
  programado: "Programado",
  publicado: "Publicado",
  finalizado: "Finalizado",
  archivado: "Archivado",
};

const DIFFICULTY_LABEL: Record<string, string> = {
  inicial: "Inicial",
  intermedia: "Intermedia",
  avanzada: "Avanzada",
};

export default async function EnsayoDetallePage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const essay = await getEssay(id);
  if (!essay) notFound();

  const [subjects, learningObjectivesRaw, distributions, essayQuestions] =
    await Promise.all([
      listSubjects(),
      listLearningObjectives(),
      listEssayDistributions(id),
      listEssayQuestionsWithDetails(id),
    ]);

  const learningObjectives = learningObjectivesRaw
    .filter((o) => o.level_id === essay.level_id)
    .map((o) => ({
      id: o.id,
      short_name: o.short_name,
      subjectName:
        (
          o.units as unknown as {
            strands: { subjects: { name: string } | null } | null;
          } | null
        )?.strands?.subjects?.name ?? "—",
    }));

  const totalPoints = essayQuestions.reduce((sum, r) => {
    const q = r.questions as unknown as { points: number } | null;
    return sum + (q?.points ?? 0);
  }, 0);
  const totalSeconds = essayQuestions.reduce((sum, r) => {
    const q = r.questions as unknown as { estimated_seconds: number | null } | null;
    return sum + (q?.estimated_seconds ?? 0);
  }, 0);
  const estimatedMinutes = Math.ceil(totalSeconds / 60);

  return (
    <main className="mx-auto flex max-w-3xl flex-col gap-6 px-6 py-12">
      <header className="flex flex-wrap items-center justify-between gap-2">
        <h1 className="font-heading text-xl font-semibold text-foreground">
          {essay.name}
        </h1>
        <Badge>{essay.levels?.name ?? "—"}</Badge>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Estado del ensayo</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-2">
          <div className="flex flex-wrap items-center gap-2">
            {ESSAY_STATUSES.map((s) => (
              <Badge key={s} variant={s === essay.status ? "default" : "outline"}>
                {STATUS_LABEL[s]}
              </Badge>
            ))}
          </div>
          <form action={updateEssayStatus} className="flex items-center gap-2">
            <input type="hidden" name="id" value={essay.id} />
            <select
              name="status"
              defaultValue={essay.status}
              className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            >
              {ESSAY_STATUSES.map((s) => (
                <option key={s} value={s}>
                  {STATUS_LABEL[s]}
                </option>
              ))}
            </select>
            <Button type="submit" size="sm" variant="outline">
              Cambiar estado
            </Button>
          </form>
          <p className="text-xs text-muted-foreground">
            La transición entre estados es manual por ahora: revisa que el
            ensayo esté generado y sin alertas antes de marcarlo como publicado.
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Configuración base</CardTitle>
        </CardHeader>
        <CardContent>
          <EssayForm
            editing={{
              id: essay.id,
              name: essay.name,
              level_id: essay.level_id,
              essay_type: essay.essay_type,
              total_questions: essay.total_questions,
              time_limit_minutes: essay.time_limit_minutes,
              order_mode: essay.order_mode,
              allow_repeat_questions: essay.allow_repeat_questions,
              available_from: essay.available_from,
              max_attempts: essay.max_attempts,
              feedback_mode: essay.feedback_mode,
            }}
            levels={[{ id: essay.level_id, name: essay.levels?.name ?? "" }]}
          />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Distribución solicitada</CardTitle>
        </CardHeader>
        <CardContent>
          <DistributionForm
            essayId={essay.id}
            subjects={subjects}
            learningObjectives={learningObjectives}
            initialSubjects={distributions.subjects}
            initialObjectives={distributions.objectives}
            initialDifficulty={distributions.difficulty}
          />
        </CardContent>
      </Card>

      <GeneratePanel essayId={essay.id} />

      <Card>
        <CardHeader>
          <CardTitle>Vista previa de la selección</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <div className="flex flex-wrap gap-2">
            <Badge variant="outline">
              {essayQuestions.length}/{essay.total_questions} preguntas
            </Badge>
            <Badge variant="outline">{totalPoints} puntos</Badge>
            <Badge variant="outline">
              ~{estimatedMinutes || essay.time_limit_minutes || 0} min estimados
            </Badge>
            {essay.time_limit_minutes != null && (
              <Badge variant="outline">
                Límite: {essay.time_limit_minutes} min
              </Badge>
            )}
          </div>
          <ul className="flex flex-col gap-2">
            {essayQuestions.map((row) => {
              const q = row.questions as unknown as {
                prompt: string;
                difficulty: string;
                points: number;
                subjects: { name: string } | null;
                learning_objectives: { short_name: string } | null;
              } | null;
              if (!q) return null;
              return (
                <li
                  key={row.id}
                  className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-start sm:justify-between sm:gap-4"
                >
                  <div className="flex flex-col gap-1.5">
                    <span>{q.prompt}</span>
                    <div className="flex flex-wrap gap-1.5">
                      <Badge variant="outline">{q.subjects?.name ?? "—"}</Badge>
                      {q.learning_objectives?.short_name && (
                        <Badge variant="muted">
                          {q.learning_objectives.short_name}
                        </Badge>
                      )}
                      <Badge>{DIFFICULTY_LABEL[q.difficulty] ?? q.difficulty}</Badge>
                      <Badge variant="outline">{q.points} pts</Badge>
                    </div>
                  </div>
                  <ReplaceButton essayId={essay.id} essayQuestionId={row.id} />
                </li>
              );
            })}
            {essayQuestions.length === 0 && (
              <p className="text-sm text-muted-foreground">
                Aún no se ha generado la selección de preguntas para este
                ensayo.
              </p>
            )}
          </ul>
        </CardContent>
      </Card>
    </main>
  );
}
