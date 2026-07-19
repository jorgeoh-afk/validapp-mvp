"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type FormState = { error: string } | null;

// ---------- Asignaturas ----------

export async function listSubjects() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("subjects")
    .select("*")
    .order("name");
  if (error) console.error("listSubjects falló:", error.message);
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

export type DeleteImpact = {
  counts: { label: string; value: number }[];
  blockedReason?: string | null;
  /**
   * Efecto informativo NO destructivo (p. ej. una fila que queda con una
   * columna en `null` por un `on delete set null`, en vez de eliminarse).
   * Ver `components/admin/confirm-delete-dialog.tsx` para cómo se muestra.
   */
  note?: string | null;
};

/**
 * Cuenta cuántas filas dependientes (lecciones, preguntas, grandes ideas,
 * conocimientos esenciales) se perderían por el `on delete cascade` real de
 * la migración 0002/0014 si se elimina esta asignatura. Se usa para mostrar
 * el conteo real en el diálogo de confirmación antes de borrar.
 */
export async function getSubjectDeleteImpact(
  subjectId: string
): Promise<DeleteImpact> {
  const supabase = await createClient();
  const [lessons, questions, bigIdeas, essentialKnowledge] = await Promise.all([
    supabase
      .from("lessons")
      .select("id", { count: "exact", head: true })
      .eq("subject_id", subjectId),
    supabase
      .from("questions")
      .select("id", { count: "exact", head: true })
      .eq("subject_id", subjectId),
    supabase
      .from("big_ideas")
      .select("id", { count: "exact", head: true })
      .eq("subject_id", subjectId),
    supabase
      .from("essential_knowledge")
      .select("id", { count: "exact", head: true })
      .eq("subject_id", subjectId),
  ]);

  return {
    counts: [
      { label: "lecciones", value: lessons.count ?? 0 },
      { label: "preguntas", value: questions.count ?? 0 },
      { label: "grandes ideas", value: bigIdeas.count ?? 0 },
      { label: "conocimientos esenciales", value: essentialKnowledge.count ?? 0 },
    ],
  };
}

export async function deleteSubject(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.from("subjects").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/asignaturas");
  return null;
}

// ---------- Niveles ----------

export async function listLevels() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("levels")
    .select("*, programs(name), education_levels(name)")
    .order("order_index");
  if (error) console.error("listLevels falló:", error.message);
  return data ?? [];
}

export async function upsertLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const programId = String(formData.get("programId") ?? "");
  const educationLevelId = String(formData.get("educationLevelId") ?? "");
  if (!name) return { error: "El nombre es obligatorio." };
  if (!programId || !educationLevelId) {
    return { error: "Programa y nivel educativo son obligatorios." };
  }

  const record = {
    name,
    order_index: orderIndex,
    program_id: programId,
    education_level_id: educationLevelId,
  };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("levels").update(record).eq("id", id)
    : await supabase.from("levels").insert(record);

  if (error) {
    if (error.code === "23505") {
      return {
        error: `Ya existe un nivel llamado "${name}". Búscalo en la lista de abajo para editarlo o clasificarlo, no hace falta crearlo de nuevo.`,
      };
    }
    return { error: error.message };
  }
  revalidatePath("/admin/niveles");
  return null;
}

/**
 * Cuenta ensayos que cuelgan de este curso (`essays.level_id`, migración
 * 0012) y, adicionalmente, los intentos de estudiantes (`essay_attempts`,
 * migración 0013) registrados sobre esos ensayos — ambos con `on delete
 * cascade` real hacia `levels`.
 */
export async function getLevelDeleteImpact(levelId: string): Promise<DeleteImpact> {
  const supabase = await createClient();
  const { data: essays } = await supabase
    .from("essays")
    .select("id")
    .eq("level_id", levelId);
  const essayIds = (essays ?? []).map((e) => e.id);

  let attemptsCount = 0;
  if (essayIds.length > 0) {
    const { count } = await supabase
      .from("essay_attempts")
      .select("id", { count: "exact", head: true })
      .in("essay_id", essayIds);
    attemptsCount = count ?? 0;
  }

  return {
    counts: [
      { label: "ensayos", value: essayIds.length },
      { label: "intentos de estudiantes en esos ensayos", value: attemptsCount },
    ],
  };
}

export async function deleteLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.from("levels").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/niveles");
  return null;
}

// ---------- Lecciones ----------

export async function listLessons() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("lessons")
    .select("*, subjects(name), levels(name)")
    .order("order_index");
  if (error) console.error("listLessons falló:", error.message);
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

/**
 * Cuenta el progreso de estudiantes (`lesson_progress`, migración 0005) que
 * se perdería al eliminar esta lección (`on delete cascade` real hacia
 * `lessons`).
 */
export async function getLessonDeleteImpact(lessonId: string): Promise<DeleteImpact> {
  const supabase = await createClient();
  const { count } = await supabase
    .from("lesson_progress")
    .select("id", { count: "exact", head: true })
    .eq("lesson_id", lessonId);

  return {
    counts: [
      { label: "registros de progreso de estudiantes", value: count ?? 0 },
    ],
  };
}

export async function deleteLesson(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.from("lessons").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/lecciones");
  return null;
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
  const { data, error } = await supabase
    .from("questions")
    .select(
      "*, subjects(name), levels(name), lessons(title), learning_objectives(short_name), skills(name), question_tag_assignments(question_tags(id, name))"
    )
    .order("created_at", { ascending: false });
  if (error) console.error("listQuestions falló:", error.message);
  return data ?? [];
}

export async function listQuestionTags() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("question_tags")
    .select("*")
    .order("name");
  if (error) console.error("listQuestionTags falló:", error.message);
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

/**
 * Cuenta cuántos `essay_questions` (migración 0012) y `diagnostic_answers`
 * (migración 0004) referencian esta pregunta. Si hay al menos 1 de
 * cualquiera de los dos, se bloquea el borrado: ya hay evidencia real de uso
 * (la pregunta quedó congelada en un ensayo generado, o un estudiante ya
 * respondió un diagnóstico con ella) y borrarla rompería ese historial. En
 * ese caso se sugiere archivarla con `updateQuestionReviewStatus`
 * (`review_status = 'archivado'`), que ya excluye la pregunta de nuevos
 * ensayos/diagnósticos sin destruir las respuestas ya registradas.
 */
export async function getQuestionDeleteImpact(
  questionId: string
): Promise<DeleteImpact> {
  const supabase = await createClient();
  const [essayQuestions, diagnosticAnswers] = await Promise.all([
    supabase
      .from("essay_questions")
      .select("id", { count: "exact", head: true })
      .eq("question_id", questionId),
    supabase
      .from("diagnostic_answers")
      .select("id", { count: "exact", head: true })
      .eq("question_id", questionId),
  ]);
  const essayQuestionsCount = essayQuestions.count ?? 0;
  const diagnosticAnswersCount = diagnosticAnswers.count ?? 0;

  return {
    counts: [
      { label: "usos en ensayos generados", value: essayQuestionsCount },
      { label: "respuestas de diagnóstico", value: diagnosticAnswersCount },
    ],
    blockedReason:
      essayQuestionsCount > 0 || diagnosticAnswersCount > 0
        ? `Esta pregunta ya se usó en ${essayQuestionsCount} ensayo(s) generado(s) y tiene ${diagnosticAnswersCount} respuesta(s) de diagnóstico registradas. No se puede eliminar porque borraría ese historial. Usa el botón "Archivar" en la lista para sacarla de circulación sin perder los resultados ya registrados.`
        : null,
  };
}

export async function deleteQuestion(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  if (!id) return { error: "Falta la pregunta a eliminar." };

  // Re-verifica el bloqueo en el servidor: no basta con ocultar el botón en
  // la UI, porque un POST directo al endpoint podría saltárselo.
  const impact = await getQuestionDeleteImpact(id);
  if (impact.blockedReason) return { error: impact.blockedReason };

  const supabase = await createClient();
  const { error } = await supabase.from("questions").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/preguntas");
  return null;
}

export async function updateQuestionReviewStatus(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  if (!id || !QUESTION_REVIEW_STATUSES.includes(status as never)) return;
  const supabase = await createClient();
  await supabase
    .from("questions")
    .update({ review_status: status, updated_at: new Date().toISOString() })
    .eq("id", id);
  revalidatePath("/admin/preguntas");
}
