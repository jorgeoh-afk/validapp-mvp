"use server";

// Dominio: Contenido y preguntas — cola de revisión humana para preguntas
// generadas por el pipeline EPJA (migración 0023). Es un flujo DISTINTO del
// `review_status` genérico de `lib/data/content.ts` (pensado para preguntas
// creadas a mano una por una): aquí se revisan lotes de preguntas
// `source_type='validapp_original'` que llegaron con `validation_status`
// 'automatically_validated' o 'ai_generated_review_required' (nunca
// 'approved_for_exam' de entrada — eso lo impone el trigger
// `questions_prevent_ai_self_approval`).
//
// "Aprobar para examen" deja la pregunta disponible para `essay-selection.ts`
// (que exige `validation_status='approved_for_exam'` Y
// `review_status='aprobado'` a la vez, ver `essay-coverage.ts`), así que esta
// acción actualiza ambos campos juntos.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type PendingQuestionGroup = {
  subjectId: string;
  subjectName: string;
  levelId: string;
  levelName: string;
  automaticallyValidated: number;
  reviewRequired: number;
};

/** Cuenta preguntas pendientes de revisión, agrupadas por asignatura+nivel. */
export async function listPendingReviewGroups(): Promise<PendingQuestionGroup[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("questions")
    .select("subject_id, level_id, validation_status, subjects(name), levels(name)")
    .eq("source_type", "validapp_original")
    .in("validation_status", ["automatically_validated", "ai_generated_review_required"]);

  const groups = new Map<string, PendingQuestionGroup>();
  for (const row of data ?? []) {
    const subject = row.subjects as unknown as { name: string } | null;
    const level = row.levels as unknown as { name: string } | null;
    const key = `${row.subject_id}::${row.level_id}`;
    const existing = groups.get(key) ?? {
      subjectId: row.subject_id as string,
      subjectName: subject?.name ?? "—",
      levelId: row.level_id as string,
      levelName: level?.name ?? "—",
      automaticallyValidated: 0,
      reviewRequired: 0,
    };
    if (row.validation_status === "automatically_validated") existing.automaticallyValidated += 1;
    else existing.reviewRequired += 1;
    groups.set(key, existing);
  }

  return Array.from(groups.values()).sort(
    (a, b) => a.subjectName.localeCompare(b.subjectName) || a.levelName.localeCompare(b.levelName)
  );
}

export type PendingQuestion = {
  id: string;
  prompt: string;
  choices: string[] | null;
  correct_index: number | null;
  explanation: string | null;
  difficulty: string | null;
  validation_status: string;
  learning_objective_short_name: string | null;
  strand_name: string | null;
};

export async function listPendingQuestionsForGroup(
  subjectId: string,
  levelId: string
): Promise<PendingQuestion[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("questions")
    .select(
      "id, prompt, choices, correct_index, explanation, difficulty, validation_status, learning_objectives(short_name, units(strands(name)))"
    )
    .eq("subject_id", subjectId)
    .eq("level_id", levelId)
    .eq("source_type", "validapp_original")
    .in("validation_status", ["automatically_validated", "ai_generated_review_required"])
    .order("created_at", { ascending: true });

  type Row = {
    id: string;
    prompt: string;
    choices: string[] | null;
    correct_index: number | null;
    explanation: string | null;
    difficulty: string | null;
    validation_status: string;
    learning_objectives: {
      short_name: string;
      units: { strands: { name: string } | null } | null;
    } | null;
  };

  return ((data ?? []) as unknown as Row[]).map((q) => ({
    id: q.id,
    prompt: q.prompt,
    choices: q.choices,
    correct_index: q.correct_index,
    explanation: q.explanation,
    difficulty: q.difficulty,
    validation_status: q.validation_status,
    learning_objective_short_name: q.learning_objectives?.short_name ?? null,
    strand_name: q.learning_objectives?.units?.strands?.name ?? null,
  }));
}

export type ReviewActionState = { error: string } | null;

/**
 * Aprueba una pregunta generada para poder usarse en un ensayo. Requiere
 * sesión de administrador real: el trigger `questions_prevent_ai_self_approval`
 * (0023) rechaza este UPDATE si `public.is_admin()` no es verdadero para el
 * usuario autenticado de la sesión.
 *
 * Firma `(_prevState, formData)` para poder usarse con `useActionState` en
 * el cliente (ver `app/(admin)/admin/revision-preguntas/review-actions.tsx`)
 * y así mostrar el error de Supabase en la interfaz en vez de solo
 * registrarlo con `console.error`.
 */
export async function approveQuestionForExam(
  _prevState: ReviewActionState,
  formData: FormData
): Promise<ReviewActionState> {
  const id = String(formData.get("id") ?? "");
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  if (!id) return { error: "Falta la pregunta a aprobar." };
  const supabase = await createClient();
  const { error } = await supabase
    .from("questions")
    .update({
      validation_status: "approved_for_exam",
      review_status: "aprobado",
      updated_at: new Date().toISOString(),
    })
    .eq("id", id);
  if (error) {
    console.error(`approveQuestionForExam(${id}) falló:`, error.message);
    return { error: error.message };
  }
  revalidatePath("/admin/revision-preguntas");
  if (subjectId && levelId) {
    revalidatePath(`/admin/revision-preguntas?subjectId=${subjectId}&levelId=${levelId}`);
  }
  return null;
}

/**
 * Aprueba en bloque todas las preguntas pendientes de una combinación
 * asignatura+nivel (misma regla que `approveQuestionForExam`, una fila a la
 * vez -- Supabase-JS no expone `update ... where id = any(...)` con
 * `returning` fácil desde el cliente, así que se resuelve con un `.in()`).
 */
export async function approveAllQuestionsForExam(
  _prevState: ReviewActionState,
  formData: FormData
): Promise<ReviewActionState> {
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  if (!subjectId || !levelId) {
    return { error: "Falta la asignatura o el nivel a aprobar." };
  }
  const supabase = await createClient();
  const { error } = await supabase
    .from("questions")
    .update({
      validation_status: "approved_for_exam",
      review_status: "aprobado",
      updated_at: new Date().toISOString(),
    })
    .eq("subject_id", subjectId)
    .eq("level_id", levelId)
    .eq("source_type", "validapp_original")
    .in("validation_status", ["automatically_validated", "ai_generated_review_required"]);
  if (error) {
    console.error(`approveAllQuestionsForExam(${subjectId}, ${levelId}) falló:`, error.message);
    return { error: error.message };
  }
  revalidatePath("/admin/revision-preguntas");
  revalidatePath(`/admin/revision-preguntas?subjectId=${subjectId}&levelId=${levelId}`);
  return null;
}

/**
 * Devuelve la pregunta a borrador (no debería usarse en ningún ensayo).
 * Misma firma `(_prevState, formData)` que las otras dos acciones de esta
 * cola, por la misma razón (error visible con `useActionState`).
 */
export async function rejectQuestion(
  _prevState: ReviewActionState,
  formData: FormData
): Promise<ReviewActionState> {
  const id = String(formData.get("id") ?? "");
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  if (!id) return { error: "Falta la pregunta a descartar." };
  const supabase = await createClient();
  const { error } = await supabase
    .from("questions")
    .update({
      is_active: false,
      updated_at: new Date().toISOString(),
    })
    .eq("id", id);
  if (error) {
    console.error(`rejectQuestion(${id}) falló:`, error.message);
    return { error: error.message };
  }
  revalidatePath("/admin/revision-preguntas");
  if (subjectId && levelId) {
    revalidatePath(`/admin/revision-preguntas?subjectId=${subjectId}&levelId=${levelId}`);
  }
  return null;
}
