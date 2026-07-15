"use server";

import { createClient } from "@/lib/supabase/server";

export async function getStudentResults() {
  const supabase = await createClient();

  const { data: students } = await supabase
    .from("profiles")
    .select("id, full_name, target_level")
    .eq("role", "estudiante")
    .order("full_name");

  const { data: diagnostics } = await supabase
    .from("diagnostics")
    .select("student_id, score, total_questions");

  const { data: lessonProgress } = await supabase
    .from("lesson_progress")
    .select("student_id");

  const { data: stats } = await supabase
    .from("gamification_stats")
    .select("student_id, total_points, current_streak");

  const diagByStudent = new Map<
    string,
    { count: number; correct: number; total: number }
  >();
  for (const d of diagnostics ?? []) {
    const entry = diagByStudent.get(d.student_id) ?? {
      count: 0,
      correct: 0,
      total: 0,
    };
    entry.count += 1;
    entry.correct += d.score;
    entry.total += d.total_questions;
    diagByStudent.set(d.student_id, entry);
  }

  const lessonsByStudent = new Map<string, number>();
  for (const lp of lessonProgress ?? []) {
    lessonsByStudent.set(
      lp.student_id,
      (lessonsByStudent.get(lp.student_id) ?? 0) + 1
    );
  }

  const statsByStudent = new Map((stats ?? []).map((s) => [s.student_id, s]));

  return (students ?? []).map((student) => {
    const diag = diagByStudent.get(student.id);
    const gam = statsByStudent.get(student.id);
    return {
      id: student.id,
      fullName: student.full_name || "(sin nombre)",
      targetLevel: student.target_level,
      diagnosticsCount: diag?.count ?? 0,
      diagnosticsAvgPercent:
        diag && diag.total > 0
          ? Math.round((diag.correct / diag.total) * 100)
          : null,
      lessonsCompleted: lessonsByStudent.get(student.id) ?? 0,
      totalPoints: gam?.total_points ?? 0,
      currentStreak: gam?.current_streak ?? 0,
    };
  });
}

export async function getSubjectResults() {
  const supabase = await createClient();

  const { data: subjects } = await supabase
    .from("subjects")
    .select("id, name")
    .order("name");
  const { data: diagnostics } = await supabase
    .from("diagnostics")
    .select("subject_id, score, total_questions");
  const { data: lessons } = await supabase
    .from("lessons")
    .select("id, subject_id");
  const { data: lessonProgress } = await supabase
    .from("lesson_progress")
    .select("lesson_id");

  const lessonToSubject = new Map(
    (lessons ?? []).map((l) => [l.id, l.subject_id])
  );

  const diagBySubject = new Map<
    string,
    { count: number; correct: number; total: number }
  >();
  for (const d of diagnostics ?? []) {
    const entry = diagBySubject.get(d.subject_id) ?? {
      count: 0,
      correct: 0,
      total: 0,
    };
    entry.count += 1;
    entry.correct += d.score;
    entry.total += d.total_questions;
    diagBySubject.set(d.subject_id, entry);
  }

  const completedBySubject = new Map<string, number>();
  for (const lp of lessonProgress ?? []) {
    const subjectId = lessonToSubject.get(lp.lesson_id);
    if (!subjectId) continue;
    completedBySubject.set(
      subjectId,
      (completedBySubject.get(subjectId) ?? 0) + 1
    );
  }

  return (subjects ?? []).map((subject) => {
    const diag = diagBySubject.get(subject.id);
    return {
      id: subject.id,
      name: subject.name,
      diagnosticsCount: diag?.count ?? 0,
      diagnosticsAvgPercent:
        diag && diag.total > 0
          ? Math.round((diag.correct / diag.total) * 100)
          : null,
      lessonsCompletedCount: completedBySubject.get(subject.id) ?? 0,
    };
  });
}
