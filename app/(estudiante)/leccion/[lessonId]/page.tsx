import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { getLesson, getLessonQuestions } from "@/lib/data/lessons";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
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
    <main className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Link
        href={`/ruta/${lesson.subject_id}`}
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Mi ruta
      </Link>

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">{lesson.title}</CardTitle>
          {lesson.levels?.name && <CardDescription>{lesson.levels.name}</CardDescription>}
        </CardHeader>
        <CardContent>
          <p className="whitespace-pre-line text-sm text-foreground/90">{lesson.content}</p>
        </CardContent>
      </Card>

      <PracticeForm
        lessonId={lessonId}
        subjectId={lesson.subject_id}
        questions={questions}
      />
    </main>
  );
}
