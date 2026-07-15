"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { recordDiagnosticCompleted } from "@/lib/data/gamification";

export async function getDiagnosticQuestions(subjectId: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("questions")
    .select("id, prompt, choices, level_id")
    .eq("subject_id", subjectId)
    .is("lesson_id", null);

  const questions = data ?? [];
  for (let i = questions.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [questions[i], questions[j]] = [questions[j], questions[i]];
  }
  return questions;
}

export type DiagnosticFormState = { error: string } | null;

export async function submitDiagnostic(
  _prevState: DiagnosticFormState,
  formData: FormData
): Promise<DiagnosticFormState> {
  const subjectId = String(formData.get("subjectId") ?? "");
  const questionIds = String(formData.get("questionIds") ?? "")
    .split(",")
    .filter(Boolean);

  if (!subjectId || questionIds.length === 0) {
    return { error: "No hay preguntas para este diagnóstico." };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Debes iniciar sesión." };

  const { data: questions } = await supabase
    .from("questions")
    .select("id, correct_index, level_id")
    .in("id", questionIds);

  if (!questions || questions.length === 0) {
    return { error: "No se pudieron cargar las preguntas." };
  }

  let score = 0;
  const answerRows: {
    question_id: string;
    selected_index: number;
    is_correct: boolean;
  }[] = [];
  const levelStats = new Map<string, { correct: number; total: number }>();

  for (const q of questions) {
    const selectedRaw = formData.get(`answer_${q.id}`);
    const selectedIndex = selectedRaw === null ? -1 : Number(selectedRaw);
    const isCorrect = selectedIndex === q.correct_index;
    if (isCorrect) score += 1;
    answerRows.push({
      question_id: q.id,
      selected_index: selectedIndex,
      is_correct: isCorrect,
    });

    const stats = levelStats.get(q.level_id) ?? { correct: 0, total: 0 };
    stats.total += 1;
    if (isCorrect) stats.correct += 1;
    levelStats.set(q.level_id, stats);
  }

  const { data: levels } = await supabase
    .from("levels")
    .select("id, order_index")
    .order("order_index");

  let estimatedLevelId: string | null = null;
  if (levels && levels.length > 0) {
    for (const level of [...levels].reverse()) {
      const stats = levelStats.get(level.id);
      if (stats && stats.correct / stats.total >= 0.6) {
        estimatedLevelId = level.id;
        break;
      }
    }
    if (!estimatedLevelId) {
      estimatedLevelId = levels[0].id;
    }
  }

  const { data: diagnostic, error } = await supabase
    .from("diagnostics")
    .insert({
      student_id: user.id,
      subject_id: subjectId,
      estimated_level_id: estimatedLevelId,
      score,
      total_questions: questions.length,
    })
    .select("id")
    .single();

  if (error || !diagnostic) {
    return { error: error?.message ?? "No se pudo guardar el diagnóstico." };
  }

  await supabase
    .from("diagnostic_answers")
    .insert(answerRows.map((a) => ({ ...a, diagnostic_id: diagnostic.id })));

  await recordDiagnosticCompleted(user.id);

  redirect(`/diagnostico/resultado/${diagnostic.id}`);
}

export async function getDiagnosticResult(id: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("diagnostics")
    .select("*, subjects(name), estimated_level:levels!estimated_level_id(name)")
    .eq("id", id)
    .single();
  return data;
}
