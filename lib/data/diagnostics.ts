"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { recordDiagnosticCompleted } from "@/lib/data/gamification";

// ---------- Formas de retorno de las funciones RPC de la migración 0019 ----------
// El cliente de Supabase se crea sin un tipo `Database` generado (ver
// `lib/supabase/server.ts`), así que `.rpc(...)` no puede inferir la forma
// de la fila por sí solo. `.returns<>()`/`.overrideTypes<>()` no sirven aquí
// porque, sin schema de `Database`, esta versión de postgrest-js no puede
// determinar si el resultado de `.rpc()` es un arreglo o un solo objeto y
// devuelve un tipo de error de compilación en vez de inferir. Se usa en su
// lugar un cast explícito desde `unknown`.
type DiagnosticQuestionRow = {
  id: string;
  prompt: string;
  choices: string[];
  level_id: string;
};
type GradeDiagnosticQuestionRow = {
  question_id: string;
  level_id: string;
  is_correct: boolean;
};

function asRpcRows<T>(data: unknown): T[] | null {
  return (data as T[] | null) ?? null;
}

export async function getDiagnosticQuestions(subjectId: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  // Restricción total por inscripción (decisión explícita del usuario, ver
  // 0028_regular_epja_curriculum_hierarchy.sql y
  // 0029_diagnostic_scoped_to_enrolled_level.sql): el diagnóstico deja de
  // estimar nivel y pasa a ser una prueba fija del nivel inscrito
  // (`profiles.target_level_id`). Si el perfil todavía no tiene nivel
  // objetivo asignado (no debería llegar aquí -- el wizard de `/perfil` y el
  // gate de UI lo exigen antes -- pero se es defensivo), no se entrega
  // ninguna pregunta.
  const { data: profile } = await supabase
    .from("profiles")
    .select("target_level_id")
    .eq("id", user.id)
    .maybeSingle();
  const targetLevelId = profile?.target_level_id ?? null;
  if (!targetLevelId) return [];

  // La lectura directa de `questions` está restringida a administradores
  // (migración 0019); un estudiante autenticado solo puede leer preguntas
  // sin `correct_index` a través de esta función security-definer. Desde la
  // migración 0029, la función exige también `p_level_id` -- ya no devuelve
  // preguntas de todos los niveles de la asignatura.
  const { data: rawData } = await supabase.rpc("get_diagnostic_questions", {
    p_subject_id: subjectId,
    p_level_id: targetLevelId,
  });

  const questions = asRpcRows<DiagnosticQuestionRow>(rawData) ?? [];
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

  // Restricción total por inscripción (misma decisión que
  // `get_diagnostic_questions`, ver 0029_diagnostic_scoped_to_enrolled_level.sql
  // y `getDiagnosticQuestions` más arriba en este archivo): un request
  // manipulado podría enviar `question_ids` que no pertenezcan al nivel
  // inscrito del estudiante. `grade_diagnostic_questions` (migración
  // 0030_grade_diagnostic_questions_scoped_to_level.sql, solo local, aún no
  // aplicada a ninguna base de datos) exige también `p_level_id` y filtra
  // `q.level_id = p_level_id` -- las preguntas que no calcen simplemente no
  // aparecen en `graded`, mismo comportamiento defensivo que ya existía para
  // ids inexistentes.
  const { data: profile } = await supabase
    .from("profiles")
    .select("target_level_id")
    .eq("id", user.id)
    .maybeSingle();
  const targetLevelId = profile?.target_level_id ?? null;

  // `grade_diagnostic_questions` compara internamente contra `correct_index`
  // (una función security-definer, mismo patrón que la lectura de arriba) y
  // devuelve solo `is_correct` ya calculado — el índice correcto nunca sale
  // hacia este código. Los dos arreglos van en el mismo orden que
  // `questionIds` para que el emparejamiento posicional dentro de la función
  // SQL sea correcto.
  const { data: gradedRaw } = await supabase.rpc("grade_diagnostic_questions", {
    p_question_ids: questionIds,
    p_selected_indexes: questionIds.map((id) => {
      const raw = formData.get(`answer_${id}`);
      return raw === null ? -1 : Number(raw);
    }),
    p_level_id: targetLevelId,
  });
  const graded = asRpcRows<GradeDiagnosticQuestionRow>(gradedRaw);

  if (!graded || graded.length === 0) {
    return { error: "No se pudieron cargar las preguntas." };
  }

  let score = 0;
  const answerRows: {
    question_id: string;
    selected_index: number;
    is_correct: boolean;
  }[] = [];
  const levelStats = new Map<string, { correct: number; total: number }>();

  for (const q of graded) {
    const selectedRaw = formData.get(`answer_${q.question_id}`);
    const selectedIndex = selectedRaw === null ? -1 : Number(selectedRaw);
    if (q.is_correct) score += 1;
    answerRows.push({
      question_id: q.question_id,
      selected_index: selectedIndex,
      is_correct: q.is_correct,
    });

    const stats = levelStats.get(q.level_id) ?? { correct: 0, total: 0 };
    stats.total += 1;
    if (q.is_correct) stats.correct += 1;
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
      total_questions: graded.length,
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
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Defensa en profundidad: además de la política RLS `diagnostics_select_own`,
  // se filtra explícitamente por el dueño del diagnóstico en la query de la
  // aplicación, para no depender únicamente de RLS.
  const { data } = await supabase
    .from("diagnostics")
    .select("*, subjects(name), estimated_level:levels!estimated_level_id(name)")
    .eq("id", id)
    .eq("student_id", user.id)
    .maybeSingle();
  return data;
}
