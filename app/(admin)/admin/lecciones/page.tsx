import Link from "next/link";
import { listLessons, listSubjects, listLevels, deleteLesson } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { LessonForm } from "./lesson-form";

export default async function LeccionesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [lessons, subjects, levels] = await Promise.all([
    listLessons(),
    listSubjects(),
    listLevels(),
  ]);
  const editing = edit ? lessons.find((l) => l.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Lecciones</h1>

      {subjects.length === 0 || levels.length === 0 ? (
        <p className="mt-6 text-sm text-zinc-600 dark:text-zinc-400">
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
      ) : (
        <div className="mt-6">
          <LessonForm editing={editing} subjects={subjects} levels={levels} />
        </div>
      )}

      <ul className="mt-6 flex flex-col gap-2">
        {lessons.map((lesson) => (
          <li
            key={lesson.id}
            className="flex items-center justify-between rounded-lg border border-border px-3 py-2"
          >
            <span>
              {lesson.title}{" "}
              <span className="text-zinc-500">
                ({lesson.subjects?.name} · {lesson.levels?.name})
              </span>
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/lecciones?edit=${lesson.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <form action={deleteLesson}>
                <input type="hidden" name="id" value={lesson.id} />
                <Button type="submit" variant="ghost" size="sm">
                  Eliminar
                </Button>
              </form>
            </div>
          </li>
        ))}
        {lessons.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay lecciones.</p>
        )}
      </ul>
    </main>
  );
}
