import Link from "next/link";
import { getLearningPath, completeLesson } from "@/lib/data/progress";
import { listSubjects } from "@/lib/data/content";
import { Button } from "@/components/ui/button";

const STATUS_LABEL: Record<string, string> = {
  bloqueada: "Bloqueada",
  disponible: "Disponible",
  completada: "Completada",
};

export default async function RutaPage({
  params,
}: {
  params: Promise<{ subjectId: string }>;
}) {
  const { subjectId } = await params;
  const [path, subjects] = await Promise.all([
    getLearningPath(subjectId),
    listSubjects(),
  ]);
  const subject = subjects.find((s) => s.id === subjectId);

  return (
    <main className="mx-auto max-w-xl px-6 py-12">
      <Link href="/ruta" className="text-sm underline">
        ← Ruta educativa
      </Link>
      <h1 className="mt-2 text-xl font-semibold">
        Ruta de {subject?.name ?? "asignatura"}
      </h1>

      {path.length === 0 ? (
        <p className="mt-6 text-sm text-zinc-600 dark:text-zinc-400">
          Todavía no hay lecciones para esta asignatura.
        </p>
      ) : (
        <ol className="mt-6 flex flex-col gap-2">
          {path.map((lesson, index) => (
            <li
              key={lesson.id}
              className="flex items-center justify-between gap-4 rounded-lg border border-border px-3 py-2"
            >
              <span>
                {index + 1}. {lesson.title}{" "}
                <span className="text-zinc-500">
                  ({lesson.levels?.name} · {STATUS_LABEL[lesson.status]})
                </span>
              </span>
              {lesson.status === "disponible" && (
                <form action={completeLesson}>
                  <input type="hidden" name="lessonId" value={lesson.id} />
                  <input type="hidden" name="subjectId" value={subjectId} />
                  <Button type="submit" size="sm">
                    Marcar como completada
                  </Button>
                </form>
              )}
            </li>
          ))}
        </ol>
      )}
    </main>
  );
}
