"use server";

import { createClient } from "@/lib/supabase/server";

export type LessonStatus = "bloqueada" | "disponible" | "completada";

export type PathLesson = {
  id: string;
  title: string;
  order_index: number;
  levels: { name: string; order_index: number } | null;
  status: LessonStatus;
};

export async function getLearningPath(
  subjectId: string
): Promise<PathLesson[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const { data: lessons } = await supabase
    .from("lessons")
    .select("id, title, order_index, levels(name, order_index)")
    .eq("subject_id", subjectId)
    .returns<
      {
        id: string;
        title: string;
        order_index: number;
        levels: { name: string; order_index: number } | null;
      }[]
    >();

  const sortedLessons = (lessons ?? []).slice().sort((a, b) => {
    const levelDiff = (a.levels?.order_index ?? 0) - (b.levels?.order_index ?? 0);
    return levelDiff !== 0 ? levelDiff : a.order_index - b.order_index;
  });

  const { data: progressRows } = await supabase
    .from("lesson_progress")
    .select("lesson_id")
    .eq("student_id", user.id);
  const completedIds = new Set((progressRows ?? []).map((r) => r.lesson_id));

  const { data: diagnostic } = await supabase
    .from("diagnostics")
    .select("estimated_level:levels!estimated_level_id(order_index)")
    .eq("student_id", user.id)
    .eq("subject_id", subjectId)
    .order("completed_at", { ascending: false })
    .limit(1)
    .maybeSingle()
    .returns<{ estimated_level: { order_index: number } | null }>();

  const estimatedOrder = diagnostic?.estimated_level?.order_index;

  let startIndex = 0;
  if (typeof estimatedOrder === "number") {
    const idx = sortedLessons.findIndex(
      (l) => (l.levels?.order_index ?? 0) >= estimatedOrder
    );
    startIndex = idx === -1 ? sortedLessons.length : idx;
  }

  let previousUnlocked = true;
  return sortedLessons.map((lesson, index) => {
    let status: LessonStatus;
    if (completedIds.has(lesson.id)) {
      status = "completada";
    } else if (index < startIndex) {
      status = "completada";
    } else if (previousUnlocked) {
      status = "disponible";
    } else {
      status = "bloqueada";
    }
    previousUnlocked = status === "completada" || status === "disponible";
    return { ...lesson, status };
  });
}
