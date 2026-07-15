import Link from "next/link";
import {
  listQuestions,
  listSubjects,
  listLevels,
  listLessons,
  deleteQuestion,
} from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { QuestionForm } from "./question-form";

export default async function PreguntasPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [questions, subjects, levels, lessons] = await Promise.all([
    listQuestions(),
    listSubjects(),
    listLevels(),
    listLessons(),
  ]);
  const editing = edit ? questions.find((q) => q.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Preguntas</h1>

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
          <QuestionForm
            editing={editing}
            subjects={subjects}
            levels={levels}
            lessons={lessons}
          />
        </div>
      )}

      <ul className="mt-6 flex flex-col gap-2">
        {questions.map((question) => (
          <li
            key={question.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {question.prompt}{" "}
              <span className="text-zinc-500">
                ({question.subjects?.name} · {question.levels?.name}
                {question.lessons?.title ? ` · ${question.lessons.title}` : ""})
              </span>
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/preguntas?edit=${question.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <form action={deleteQuestion}>
                <input type="hidden" name="id" value={question.id} />
                <Button type="submit" variant="ghost" size="sm">
                  Eliminar
                </Button>
              </form>
            </div>
          </li>
        ))}
        {questions.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay preguntas.</p>
        )}
      </ul>
    </main>
  );
}
