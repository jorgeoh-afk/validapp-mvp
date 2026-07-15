"use server";

import { createClient } from "@/lib/supabase/server";

const POINTS_PER_LESSON = 10;
const POINTS_PER_DIAGNOSTIC = 5;

type Stats = {
  student_id: string;
  total_points: number;
  current_streak: number;
  longest_streak: number;
  last_activity_date: string | null;
  badges: string[];
};

async function getOrCreateStats(
  supabase: Awaited<ReturnType<typeof createClient>>,
  studentId: string
): Promise<Stats> {
  const { data } = await supabase
    .from("gamification_stats")
    .select("*")
    .eq("student_id", studentId)
    .maybeSingle();
  if (data) return data as Stats;

  const { data: created } = await supabase
    .from("gamification_stats")
    .insert({ student_id: studentId })
    .select("*")
    .single();
  return created as Stats;
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function yesterday() {
  return new Date(Date.now() - 86400000).toISOString().slice(0, 10);
}

function applyStreak(stats: Stats) {
  const now = today();
  if (stats.last_activity_date === now) {
    return { current_streak: stats.current_streak, last_activity_date: now };
  }
  const current_streak =
    stats.last_activity_date === yesterday() ? stats.current_streak + 1 : 1;
  return { current_streak, last_activity_date: now };
}

async function saveStats(
  supabase: Awaited<ReturnType<typeof createClient>>,
  studentId: string,
  stats: Stats,
  extraPoints: number,
  extraBadges: Set<string>
) {
  const { current_streak, last_activity_date } = applyStreak(stats);
  const longest_streak = Math.max(stats.longest_streak, current_streak);

  const badges = new Set(stats.badges ?? []);
  extraBadges.forEach((b) => badges.add(b));
  if (current_streak >= 3) badges.add("racha_3");

  await supabase
    .from("gamification_stats")
    .update({
      total_points: stats.total_points + extraPoints,
      current_streak,
      longest_streak,
      last_activity_date,
      badges: Array.from(badges),
      updated_at: new Date().toISOString(),
    })
    .eq("student_id", studentId);
}

export async function recordLessonCompleted(
  studentId: string,
  subjectId: string
) {
  const supabase = await createClient();
  const stats = await getOrCreateStats(supabase, studentId);

  const { count: lessonCount } = await supabase
    .from("lesson_progress")
    .select("id", { count: "exact", head: true })
    .eq("student_id", studentId);

  const badges = new Set<string>();
  if ((lessonCount ?? 0) <= 1) badges.add("primera_leccion");

  const { data: subjectLessons } = await supabase
    .from("lessons")
    .select("id")
    .eq("subject_id", subjectId);
  const subjectLessonIds = (subjectLessons ?? []).map((l) => l.id);

  if (subjectLessonIds.length > 0) {
    const { data: completedRows } = await supabase
      .from("lesson_progress")
      .select("lesson_id")
      .eq("student_id", studentId)
      .in("lesson_id", subjectLessonIds);
    if ((completedRows?.length ?? 0) >= subjectLessonIds.length) {
      badges.add("asignatura_completada");
    }
  }

  await saveStats(supabase, studentId, stats, POINTS_PER_LESSON, badges);
}

export async function recordDiagnosticCompleted(studentId: string) {
  const supabase = await createClient();
  const stats = await getOrCreateStats(supabase, studentId);

  const { count } = await supabase
    .from("diagnostics")
    .select("id", { count: "exact", head: true })
    .eq("student_id", studentId);

  const badges = new Set<string>();
  if ((count ?? 0) <= 1) badges.add("primer_diagnostico");

  await saveStats(supabase, studentId, stats, POINTS_PER_DIAGNOSTIC, badges);
}

export async function getGamificationStats(
  studentId: string
): Promise<Stats | null> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("gamification_stats")
    .select("*")
    .eq("student_id", studentId)
    .maybeSingle();
  return data as Stats | null;
}
