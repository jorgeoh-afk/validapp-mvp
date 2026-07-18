import Link from "next/link";
import { ArrowLeft, Check, Lightbulb, Lock, Play } from "lucide-react";
import { getLearningPath } from "@/lib/data/progress";
import { listSubjects, listLevels } from "@/lib/data/content";
import {
  getApprovedBigIdeas,
  getApprovedEssentialKnowledge,
} from "@/lib/data/big-ideas";
import { LessonNode } from "@/components/ruta/lesson-node";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";

const LEVEL_STATUS_CONFIG = {
  completado: {
    label: "Completado",
    className: "border-success/30 bg-success/10 text-success",
    icon: <Check className="size-3.5" aria-hidden="true" />,
  },
  en_curso: {
    label: "En curso",
    className: "border-primary/30 bg-primary/10 text-primary",
    icon: <Play className="size-3.5" aria-hidden="true" />,
  },
  bloqueado: {
    label: "Bloqueado",
    className: "border-border bg-muted text-muted-foreground",
    icon: <Lock className="size-3.5" aria-hidden="true" />,
  },
} as const;

export default async function RutaPage({
  params,
}: {
  params: Promise<{ subjectId: string }>;
}) {
  const { subjectId } = await params;
  const [path, subjects, levels] = await Promise.all([
    getLearningPath(subjectId),
    listSubjects(),
    listLevels(),
  ]);
  const subject = subjects.find((s) => s.id === subjectId);
  const levelIdByName = new Map(levels.map((l) => [l.name, l.id]));

  const total = path.length;
  const completedCount = path.filter((l) => l.status === "completada").length;
  const percent = total === 0 ? 0 : Math.round((completedCount / total) * 100);

  const groups: { levelName: string; lessons: typeof path }[] = [];
  for (const lesson of path) {
    const levelName = lesson.levels?.name ?? "Sin nivel";
    const lastGroup = groups[groups.length - 1];
    if (lastGroup && lastGroup.levelName === levelName) {
      lastGroup.lessons.push(lesson);
    } else {
      groups.push({ levelName, lessons: [lesson] });
    }
  }

  // Grandes ideas y conocimientos esenciales aprobados, por curso, para dar
  // contexto antes de las lecciones. Solo se consultan los cursos que ya
  // tienen lecciones en esta asignatura.
  const curriculumContextByLevel = new Map(
    await Promise.all(
      groups.map(async (group) => {
        const levelId = levelIdByName.get(group.levelName);
        if (!levelId) return [group.levelName, null] as const;
        const [bigIdeas, essentialKnowledge] = await Promise.all([
          getApprovedBigIdeas(subjectId, levelId),
          getApprovedEssentialKnowledge(subjectId, levelId),
        ]);
        if (bigIdeas.length === 0 && essentialKnowledge.length === 0) {
          return [group.levelName, null] as const;
        }
        return [group.levelName, { bigIdeas, essentialKnowledge }] as const;
      })
    )
  );

  return (
    <main className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Link
        href="/ruta"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Ruta educativa
      </Link>

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">
            Ruta de {subject?.name ?? "asignatura"}
          </CardTitle>
          <CardDescription>
            Avanza lección a lección. Cada paso desbloquea el siguiente.
          </CardDescription>
        </CardHeader>
        {total > 0 && (
          <CardContent className="flex flex-col gap-2">
            <div className="flex items-center justify-between text-sm">
              <span className="font-medium text-foreground">
                {completedCount} de {total} lecciones completadas
              </span>
              <span className="text-muted-foreground">{percent}%</span>
            </div>
            <div
              role="progressbar"
              aria-valuenow={percent}
              aria-valuemin={0}
              aria-valuemax={100}
              aria-label="Progreso de la ruta"
              className="h-2.5 w-full overflow-hidden rounded-full bg-muted"
            >
              <div
                className="h-full rounded-full bg-primary transition-all"
                style={{ width: `${percent}%` }}
              />
            </div>
          </CardContent>
        )}
      </Card>

      {path.length === 0 ? (
        <p className="text-sm text-muted-foreground">
          Todavía no hay lecciones para esta asignatura.
        </p>
      ) : (
        <div className="flex flex-col gap-8">
          {groups.map((group) => {
            const allCompleted = group.lessons.every(
              (l) => l.status === "completada"
            );
            const allLocked = group.lessons.every(
              (l) => l.status === "bloqueada"
            );
            const levelStatusKey: keyof typeof LEVEL_STATUS_CONFIG =
              allCompleted ? "completado" : allLocked ? "bloqueado" : "en_curso";
            const levelStatus = LEVEL_STATUS_CONFIG[levelStatusKey];
            const context = curriculumContextByLevel.get(group.levelName);

            return (
              <section key={group.levelName} className="flex flex-col gap-3">
                <div className="flex items-center gap-2">
                  <h2 className="text-sm font-semibold tracking-wide text-foreground uppercase">
                    {group.levelName}
                  </h2>
                  <span
                    className={cn(
                      "inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-xs font-medium",
                      levelStatus.className
                    )}
                  >
                    {levelStatus.icon}
                    {levelStatus.label}
                  </span>
                </div>

                {context && (
                  <Card className="border-dashed bg-muted/30">
                    <CardContent className="flex flex-col gap-3 pt-4">
                      {context.bigIdeas.length > 0 && (
                        <div className="flex flex-col gap-1.5">
                          <p className="flex items-center gap-1.5 text-xs font-semibold tracking-wide text-foreground uppercase">
                            <Lightbulb
                              className="size-3.5 text-warning"
                              aria-hidden="true"
                            />
                            Grandes ideas de esta unidad
                          </p>
                          <ul className="flex flex-col gap-1 text-sm text-foreground/90">
                            {context.bigIdeas.map((idea) => (
                              <li key={idea.id}>• {idea.statement}</li>
                            ))}
                          </ul>
                        </div>
                      )}
                      {context.essentialKnowledge.length > 0 && (
                        <div className="flex flex-col gap-1.5">
                          <p className="text-xs font-semibold tracking-wide text-foreground uppercase">
                            Lo que vas a aprender
                          </p>
                          <ul className="flex flex-col gap-1 text-sm text-muted-foreground">
                            {context.essentialKnowledge.map((item) => (
                              <li key={item.id}>• {item.statement}</li>
                            ))}
                          </ul>
                        </div>
                      )}
                    </CardContent>
                  </Card>
                )}

                <ol className="flex flex-col gap-4">
                  {group.lessons.map((lesson, index) => (
                    <LessonNode
                      key={lesson.id}
                      lessonId={lesson.id}
                      order={
                        path.findIndex((l) => l.id === lesson.id) + 1
                      }
                      title={lesson.title}
                      status={lesson.status}
                      isLast={index === group.lessons.length - 1}
                    />
                  ))}
                </ol>
              </section>
            );
          })}
        </div>
      )}
    </main>
  );
}
