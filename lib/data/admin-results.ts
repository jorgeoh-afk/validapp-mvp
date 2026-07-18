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

  // Solo intentos cerrados (enviado/expirado) cuentan como "rendidos"; un
  // intento en_curso todavía no tiene score/total_points definitivos.
  const { data: essayAttempts } = await supabase
    .from("essay_attempts")
    .select("student_id, score, total_points, status")
    .in("status", ["enviado", "expirado"]);

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

  const essaysByStudent = new Map<
    string,
    { count: number; percentSum: number; percentCount: number }
  >();
  for (const a of essayAttempts ?? []) {
    const entry = essaysByStudent.get(a.student_id) ?? {
      count: 0,
      percentSum: 0,
      percentCount: 0,
    };
    entry.count += 1;
    if (a.total_points != null && a.total_points > 0 && a.score != null) {
      entry.percentSum += (a.score / a.total_points) * 100;
      entry.percentCount += 1;
    }
    essaysByStudent.set(a.student_id, entry);
  }

  return (students ?? []).map((student) => {
    const diag = diagByStudent.get(student.id);
    const gam = statsByStudent.get(student.id);
    const essay = essaysByStudent.get(student.id);
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
      essaysCompleted: essay?.count ?? 0,
      essaysAvgPercent:
        essay && essay.percentCount > 0
          ? Math.round(essay.percentSum / essay.percentCount)
          : null,
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

/**
 * Resultados agregados por ensayo. Los ensayos se agrupan por curso (no por
 * asignatura, ya que un ensayo puede combinar preguntas de varias
 * asignaturas), así que viven en su propia tabla separada de "Por
 * asignatura". Solo cuenta intentos cerrados (enviado/expirado); no expone
 * qué estudiante rindió cada intento, solo el agregado.
 */
export async function getEssayResults() {
  const supabase = await createClient();

  type EssayRow = {
    id: string;
    name: string;
    status: string;
    levels: { name: string } | null;
  };
  const { data: essaysData } = await supabase
    .from("essays")
    .select("id, name, status, levels(name)")
    .order("name");
  const essays = (essaysData ?? []) as unknown as EssayRow[];
  const { data: attempts } = await supabase
    .from("essay_attempts")
    .select("essay_id, score, total_points, status")
    .in("status", ["enviado", "expirado"]);

  const byEssay = new Map<
    string,
    { count: number; percentSum: number; percentCount: number }
  >();
  for (const a of attempts ?? []) {
    const entry = byEssay.get(a.essay_id) ?? {
      count: 0,
      percentSum: 0,
      percentCount: 0,
    };
    entry.count += 1;
    if (a.total_points != null && a.total_points > 0 && a.score != null) {
      entry.percentSum += (a.score / a.total_points) * 100;
      entry.percentCount += 1;
    }
    byEssay.set(a.essay_id, entry);
  }

  return essays.map((essay) => {
    const agg = byEssay.get(essay.id);
    return {
      id: essay.id,
      name: essay.name,
      status: essay.status,
      levelName: essay.levels?.name ?? "—",
      attemptsCount: agg?.count ?? 0,
      avgScorePercent:
        agg && agg.percentCount > 0
          ? Math.round(agg.percentSum / agg.percentCount)
          : null,
    };
  });
}
