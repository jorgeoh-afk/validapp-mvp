"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { getLearningPath } from "@/lib/data/progress";
import { recordLessonCompleted } from "@/lib/data/gamification";

export async function getLesson(lessonId: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("lessons")
    .select("id, title, content, subject_id, levels(name)")
    .eq("id", lessonId)
    .single()
    .returns<{
      id: string;
      title: string;
      content: string;
      subject_id: string;
      levels: { name: string } | null;
    }>();
  return data;
}

export async function getLessonQuestions(lessonId: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("questions")
    .select("id, prompt, choices")
    .eq("lesson_id", lessonId);
  return data ?? [];
}

export type PracticeResultQuestion = {
  id: string;
  prompt: string;
  choices: string[];
  selectedIndex: number;
  correctIndex: number;
  isCorrect: boolean;
};

export type PracticeState =
  | { error: string }
  | { score: number; total: number; results: PracticeResultQuestion[] }
  | null;

export async function submitLessonPractice(
  _prevState: PracticeState,
  formData: FormData
): Promise<PracticeState> {
  const lessonId = String(formData.get("lessonId") ?? "");
  const questionIds = String(formData.get("questionIds") ?? "")
    .split(",")
    .filter(Boolean);

  if (!lessonId) return { error: "Lección inválida." };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Debes iniciar sesión." };

  const lesson = await getLesson(lessonId);
  if (!lesson) return { error: "Lección no encontrada." };

  const path = await getLearningPath(lesson.subject_id);
  const status = path.find((l) => l.id === lessonId)?.status;
  if (status === "bloqueada") {
    return { error: "Esta lección todavía está bloqueada." };
  }

  let results: PracticeResultQuestion[] = [];
  let score = 0;

  if (questionIds.length > 0) {
    const { data: questions } = await supabase
      .from("questions")
      .select("id, prompt, choices, correct_index")
      .in("id", questionIds);

    for (const q of questions ?? []) {
      const selectedRaw = formData.get(`answer_${q.id}`);
      const selectedIndex = selectedRaw === null ? -1 : Number(selectedRaw);
      const isCorrect = selectedIndex === q.correct_index;
      if (isCorrect) score += 1;
      results.push({
        id: q.id,
        prompt: q.prompt,
        choices: q.choices,
        selectedIndex,
        correctIndex: q.correct_index,
        isCorrect,
      });
    }
  }

  await supabase.from("lesson_progress").upsert(
    {
      student_id: user.id,
      lesson_id: lessonId,
      score,
      total_questions: results.length,
    },
    { onConflict: "student_id,lesson_id" }
  );

  if (status !== "completada") {
    await recordLessonCompleted(user.id, lesson.subject_id);
  }

  revalidatePath(`/ruta/${lesson.subject_id}`);
  revalidatePath("/panel");
  return { score, total: results.length, results };
}
