import Link from "next/link";
import { notFound } from "next/navigation";
import { getLesson, getLessonQuestions } from "@/lib/data/lessons";
import { PracticeForm } from "./practice-form";

export default async function LeccionPage({
  params,
}: {
  params: Promise<{ lessonId: string }>;
}) {
  const { lessonId } = await params;
  const lesson = await getLesson(lessonId);
  if (!lesson) notFound();

  const questions = await getLessonQuestions(lessonId);

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href={`/ruta/${lesson.subject_id}`} className="text-sm underline">
        ← Mi ruta
      </Link>
      <h1 className="mt-2 text-xl font-semibold">
        {lesson.title}{" "}
        <span className="text-sm font-normal text-zinc-500">
          ({lesson.levels?.name})
        </span>
      </h1>
      <p className="mt-4 whitespace-pre-line text-zinc-700 dark:text-zinc-300">
        {lesson.content}
      </p>

      <PracticeForm
        lessonId={lessonId}
        subjectId={lesson.subject_id}
        questions={questions}
      />
    </main>
  );
}
