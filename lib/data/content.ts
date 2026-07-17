"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type FormState = { error: string } | null;

// ---------- Asignaturas ----------

export async function listSubjects() {
  const supabase = await createClient();
  const { data } = await supabase.from("subjects").select("*").order("name");
  return data ?? [];
}

export async function upsertSubject(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  if (!name) return { error: "El nombre es obligatorio." };

  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("subjects").update({ name }).eq("id", id)
    : await supabase.from("subjects").insert({ name });

  if (error) return { error: error.message };
  revalidatePath("/admin/asignaturas");
  return null;
}

export async function deleteSubject(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("subjects").delete().eq("id", id);
  revalidatePath("/admin/asignaturas");
}

// ---------- Niveles ----------

export async function listLevels() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("levels")
    .select("*, programs(name), education_levels(name)")
    .order("order_index");
  return data ?? [];
}

export async function upsertLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  if (!name) return { error: "El nombre es obligatorio." };

  const supabase = await createClient();
  const { error } = id
    ? await supabase
        .from("levels")
        .update({ name, order_index: orderIndex })
        .eq("id", id)
    : await supabase.from("levels").insert({ name, order_index: orderIndex });

  if (error) return { error: error.message };
  revalidatePath("/admin/niveles");
  return null;
}

export async function deleteLevel(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("levels").delete().eq("id", id);
  revalidatePath("/admin/niveles");
}

// ---------- Lecciones ----------

export async function listLessons() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("lessons")
    .select("*, subjects(name), levels(name)")
    .order("order_index");
  return data ?? [];
}

export async function upsertLesson(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  const title = String(formData.get("title") ?? "").trim();
  const content = String(formData.get("content") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);

  if (!subjectId || !levelId || !title) {
    return { error: "Asignatura, nivel y título son obligatorios." };
  }

  const record = {
    subject_id: subjectId,
    level_id: levelId,
    title,
    content,
    order_index: orderIndex,
  };

  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("lessons").update(record).eq("id", id)
    : await supabase.from("lessons").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/lecciones");
  return null;
}

export async function deleteLesson(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("lessons").delete().eq("id", id);
  revalidatePath("/admin/lecciones");
}

// ---------- Preguntas ----------

const QUESTION_DIFFICULTIES = ["inicial", "intermedia", "avanzada"] as const;
const QUESTION_REVIEW_STATUSES = [
  "borrador",
  "en_revision",
  "aprobado",
  "archivado",
] as const;

export async function listQuestions() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("questions")
    .select(
      "*, subjects(name), levels(name), lessons(title), learning_objectives(short_name), skills(name), question_tag_assignments(question_tags(id, name))"
    )
    .order("created_at", { ascending: false });
  return data ?? [];
}

export async function listQuestionTags() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("question_tags")
    .select("*")
    .order("name");
  return data ?? [];
}

/**
 * Busca o crea etiquetas a partir de una lista de nombres (tal como las
 * escribe el administrador, separadas por coma en el paso 5 del wizard) y
 * devuelve sus ids. Se normaliza a minúsculas/trim para evitar duplicados
 * como "Álgebra" y "álgebra ".
 */
export async function resolveTagIds(
  supabase: Awaited<ReturnType<typeof createClient>>,
  tagNamesRaw: string[]
): Promise<{ ids: string[]; error?: string }> {
  const names = Array.from(
    new Set(
      tagNamesRaw
        .map((n) => n.trim())
        .filter(Boolean)
        .map((n) => n.toLowerCase())
    )
  );
  if (names.length === 0) return { ids: [] };

  const { data: existing, error: existingError } = await supabase
    .from("question_tags")
    .select("id, name")
    .in("name", names);
  if (existingError) return { ids: [], error: existingError.message };

  const existingNames = new Set((existing ?? []).map((t) => t.name));
  const missing = names.filter((n) => !existingNames.has(n));

  const created: { id: string; name: string }[] = [];
  if (missing.length > 0) {
    const { data: inserted, error: insertError } = await supabase
      .from("question_tags")
      .insert(missing.map((name) => ({ name })))
      .select("id, name");
    if (insertError) return { ids: [], error: insertError.message };
    created.push(...(inserted ?? []));
  }

  return { ids: [...(existing ?? []), ...created].map((t) => t.id) };
}

export async function upsertQuestion(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  const lessonId = String(formData.get("lessonId") ?? "");
  const learningObjectiveId = String(
    formData.get("learningObjectiveId") ?? ""
  );
  const skillId = String(formData.get("skillId") ?? "");
  const prompt = String(formData.get("prompt") ?? "").trim();
  const resourceUrl = String(formData.get("resourceUrl") ?? "").trim();
  const explanation = String(formData.get("explanation") ?? "").trim();
  const choicesRaw = String(formData.get("choices") ?? "");
  const correctIndex = Number(formData.get("correctIndex") ?? 0);
  const difficulty = String(formData.get("difficulty") ?? "intermedia");
  const points = Number(formData.get("points") ?? 1);
  const estimatedSecondsRaw = String(
    formData.get("estimatedSeconds") ?? ""
  ).trim();
  const estimatedSeconds = estimatedSecondsRaw
    ? Number(estimatedSecondsRaw)
    : null;
  const source = String(formData.get("source") ?? "").trim();
  const reviewStatus = String(formData.get("reviewStatus") ?? "borrador");
  const tagsRaw = String(formData.get("tags") ?? "");

  const choices = choicesRaw
    .split("\n")
    .map((c) => c.trim())
    .filter(Boolean);

  if (!subjectId || !levelId || !prompt || choices.length < 2) {
    return {
      error:
        "Asignatura, nivel, pregunta y al menos 2 alternativas son obligatorios.",
    };
  }
  const normalizedChoices = choices.map((c) => c.toLowerCase());
  if (new Set(normalizedChoices).size !== choices.length) {
    return { error: "No puede haber alternativas repetidas." };
  }
  if (correctIndex < 0 || correctIndex >= choices.length) {
    return { error: "Debes marcar cuál alternativa es la correcta." };
  }
  if (!QUESTION_DIFFICULTIES.includes(difficulty as never)) {
    return { error: "Dificultad no válida." };
  }
  if (!QUESTION_REVIEW_STATUSES.includes(reviewStatus as never)) {
    return { error: "Estado de revisión no válido." };
  }

  const record = {
    subject_id: subjectId,
    level_id: levelId,
    lesson_id: lessonId || null,
    learning_objective_id: learningObjectiveId || null,
    skill_id: skillId || null,
    prompt,
    resource_url: resourceUrl || null,
    explanation: explanation || null,
    choices,
    correct_index: correctIndex,
    difficulty,
    points: Number.isFinite(points) && points > 0 ? points : 1,
    estimated_seconds: estimatedSeconds,
    source: source || null,
    review_status: reviewStatus,
    updated_at: new Date().toISOString(),
  };

  const supabase = await createClient();
  const { ids: tagIds, error: tagsError } = await resolveTagIds(
    supabase,
    tagsRaw.split(",")
  );
  if (tagsError) return { error: tagsError };

  let questionId = id;
  if (id) {
    const { error } = await supabase
      .from("questions")
      .update(record)
      .eq("id", id);
    if (error) return { error: error.message };
  } else {
    const { data, error } = await supabase
      .from("questions")
      .insert(record)
      .select("id")
      .single();
    if (error) return { error: error.message };
    questionId = data.id;
  }

  // Sincroniza las etiquetas asociadas (borra y reinserta el set completo).
  await supabase
    .from("question_tag_assignments")
    .delete()
    .eq("question_id", questionId);
  if (tagIds.length > 0) {
    const { error: assignError } = await supabase
      .from("question_tag_assignments")
      .insert(tagIds.map((tagId) => ({ question_id: questionId, tag_id: tagId })));
    if (assignError) return { error: assignError.message };
  }

  revalidatePath("/admin/preguntas");
  return null;
}

export async function deleteQuestion(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("questions").delete().eq("id", id);
  revalidatePath("/admin/preguntas");
}
