"use server";

// Dominio: Contenido y preguntas — generador automático de ensayos (Fase 5).
// Configuración administrativa de ensayos y su selección automática de
// preguntas. La experiencia de RENDIR el ensayo (intentos del estudiante)
// es la Fase 6 y no se implementa aquí.

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import {
  selectEssayQuestions,
  replaceEssaySelectionSlot,
  buildErrorPracticeRequirements,
  buildReinforcementRequirements,
  type CandidateQuestion,
  type SelectedEssayQuestion,
  type MissingRequirement,
  type EssayDifficulty,
  type ObjectiveRequirement,
  type StudentAnswerRecord,
} from "./essay-selection";
import {
  ESSAY_TYPES,
  ORDER_MODES,
  FEEDBACK_MODES,
  ESSAY_STATUSES,
} from "./essay-constants";

export type FormState = { error: string } | null;

// ---------- Listado y CRUD básico de ensayos ----------

export async function listEssays() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("essays")
    .select("*, levels(name), essay_questions(id)")
    .order("created_at", { ascending: false });
  return data ?? [];
}

export async function getEssay(id: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("essays")
    .select("*, levels(name)")
    .eq("id", id)
    .single();
  return data;
}

export async function upsertEssay(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const levelId = String(formData.get("levelId") ?? "");
  const essayType = String(formData.get("essayType") ?? "general_curso");
  const totalQuestions = Number(formData.get("totalQuestions") ?? 10);
  const timeLimitRaw = String(formData.get("timeLimitMinutes") ?? "").trim();
  const timeLimitMinutes = timeLimitRaw ? Number(timeLimitRaw) : null;
  const orderMode = String(formData.get("orderMode") ?? "aleatorio");
  const allowRepeatQuestions = formData.get("allowRepeatQuestions") === "on";
  const availableFromRaw = String(formData.get("availableFrom") ?? "").trim();
  const availableFrom = availableFromRaw
    ? new Date(availableFromRaw).toISOString()
    : null;
  const maxAttemptsRaw = String(formData.get("maxAttempts") ?? "").trim();
  const maxAttempts = maxAttemptsRaw ? Number(maxAttemptsRaw) : null;
  const feedbackMode = String(formData.get("feedbackMode") ?? "al_finalizar");

  if (!name || !levelId) {
    return { error: "Nombre y curso son obligatorios." };
  }
  if (!ESSAY_TYPES.includes(essayType as (typeof ESSAY_TYPES)[number])) {
    return { error: "Tipo de ensayo no válido." };
  }
  if (!ORDER_MODES.includes(orderMode as (typeof ORDER_MODES)[number])) {
    return { error: "Modo de orden no válido." };
  }
  if (!FEEDBACK_MODES.includes(feedbackMode as (typeof FEEDBACK_MODES)[number])) {
    return { error: "Modo de retroalimentación no válido." };
  }
  if (!Number.isFinite(totalQuestions) || totalQuestions <= 0) {
    return { error: "La cantidad de preguntas debe ser mayor a 0." };
  }

  const record = {
    name,
    level_id: levelId,
    essay_type: essayType,
    total_questions: totalQuestions,
    time_limit_minutes: timeLimitMinutes,
    order_mode: orderMode,
    allow_repeat_questions: allowRepeatQuestions,
    available_from: availableFrom,
    max_attempts: maxAttempts,
    feedback_mode: feedbackMode,
    updated_at: new Date().toISOString(),
  };

  const supabase = await createClient();
  let essayId = id;
  if (id) {
    const { error } = await supabase.from("essays").update(record).eq("id", id);
    if (error) return { error: error.message };
  } else {
    const { data, error } = await supabase
      .from("essays")
      .insert(record)
      .select("id")
      .single();
    if (error) return { error: error.message };
    essayId = data.id;
  }

  revalidatePath("/admin/ensayos");
  if (!id) {
    redirect(`/admin/ensayos/${essayId}`);
  }
  revalidatePath(`/admin/ensayos/${essayId}`);
  return null;
}

/**
 * Antes de esta fase, cualquier ensayo podía pasar a `publicado` sin
 * verificar que el banco de preguntas realmente alcanzara para cumplir sus
 * reglas de distribución — ese es un cambio de comportamiento nuevo de esta
 * etapa. Si el destino es `publicado` y `checkEssayAvailability` no
 * devuelve `ready`, se bloquea la transición: se guarda el `coverage_status`
 * calculado (visible en el panel admin) pero NO se cambia `essays.status`.
 */
export async function updateEssayStatus(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const status = String(formData.get("status") ?? "");
  if (!id || !ESSAY_STATUSES.includes(status as (typeof ESSAY_STATUSES)[number])) {
    return;
  }
  const supabase = await createClient();

  if (status === "publicado") {
    const { checkEssayAvailability } = await import("./essay-coverage");
    const coverage = await checkEssayAvailability(id);
    await supabase
      .from("essays")
      .update({
        coverage_status: coverage.status,
        coverage_checked_at: new Date().toISOString(),
      })
      .eq("id", id);
    if (coverage.status !== "ready") {
      revalidatePath("/admin/ensayos");
      revalidatePath(`/admin/ensayos/${id}`);
      return;
    }
  }

  await supabase
    .from("essays")
    .update({
      status,
      coverage_status: status === "publicado" ? "published" : undefined,
      updated_at: new Date().toISOString(),
    })
    .eq("id", id);
  revalidatePath("/admin/ensayos");
  revalidatePath(`/admin/ensayos/${id}`);
}

export type DeleteImpact = {
  counts: { label: string; value: number }[];
  blockedReason?: string | null;
};

/**
 * Cuenta los `essay_attempts` (migración 0013) registrados sobre este
 * ensayo. Si ya hay al menos 1 intento, o el ensayo está `publicado`/
 * `finalizado` (ya visible o ya rendido por estudiantes), se bloquea el
 * borrado: eliminarlo destruiría resultados históricos reales. En ese caso
 * se sugiere archivarlo desde su página de configuración (`updateEssayStatus`
 * ya soporta el estado `archivado`) en vez de borrarlo.
 */
export async function getEssayDeleteImpact(essayId: string): Promise<DeleteImpact> {
  const supabase = await createClient();
  const [{ count: attemptsCount }, { data: essay }] = await Promise.all([
    supabase
      .from("essay_attempts")
      .select("id", { count: "exact", head: true })
      .eq("essay_id", essayId),
    supabase.from("essays").select("status").eq("id", essayId).single(),
  ]);
  const attempts = attemptsCount ?? 0;
  const status = essay?.status ?? "borrador";
  const isPublishedOrFinished = status === "publicado" || status === "finalizado";

  let blockedReason: string | null = null;
  if (attempts > 0) {
    blockedReason = `Este ensayo ya tiene ${attempts} intento(s) de estudiantes registrados. No se puede eliminar porque borraría esos resultados. Archívalo desde su página de configuración en vez de eliminarlo.`;
  } else if (isPublishedOrFinished) {
    blockedReason = `Este ensayo está "${status}" y puede estar visible para estudiantes. No se puede eliminar en ese estado. Cámbialo a "archivado" desde su página de configuración en vez de eliminarlo.`;
  }

  return {
    counts: [{ label: "intentos de estudiantes", value: attempts }],
    blockedReason,
  };
}

export async function deleteEssay(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  if (!id) return { error: "Falta el ensayo a eliminar." };

  // Re-verifica el bloqueo en el servidor: no basta con ocultar el botón en
  // la UI, porque un POST directo al endpoint podría saltárselo.
  const impact = await getEssayDeleteImpact(id);
  if (impact.blockedReason) return { error: impact.blockedReason };

  const supabase = await createClient();
  const { error } = await supabase.from("essays").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/ensayos");
  return null;
}

// ---------- Distribuciones (asignatura / objetivo / dificultad) ----------

export async function listEssayDistributions(essayId: string) {
  const supabase = await createClient();
  const [subjects, strands, objectives, difficulty] = await Promise.all([
    supabase
      .from("essay_subjects")
      .select("*, subjects(name)")
      .eq("essay_id", essayId),
    supabase
      .from("essay_strand_distribution")
      .select("*, strands(name, subject_id)")
      .eq("essay_id", essayId),
    supabase
      .from("essay_objectives")
      .select("*, learning_objectives(short_name, units(strands(subject_id)))")
      .eq("essay_id", essayId),
    supabase
      .from("essay_difficulty_distribution")
      .select("*")
      .eq("essay_id", essayId),
  ]);
  return {
    subjects: subjects.data ?? [],
    strands: strands.data ?? [],
    objectives: objectives.data ?? [],
    difficulty: difficulty.data ?? [],
  };
}

type DistributionRow = { count: number | null; percent: number | null };

/**
 * Guarda las 3 distribuciones de una sola vez: borra y reinserta el set
 * completo para el ensayo (mismo patrón usado para etiquetas/habilidades en
 * fases anteriores). Se recibe un único JSON en el FormData para no depender
 * de arreglos paralelos de campos.
 */
export async function saveEssayDistributions(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const essayId = String(formData.get("essayId") ?? "");
  if (!essayId) return { error: "Falta el ensayo." };

  let payload: {
    subjects: ({ subjectId: string } & DistributionRow)[];
    strands?: ({ strandId: string; isRequired?: boolean } & DistributionRow)[];
    objectives: ({ learningObjectiveId: string } & DistributionRow)[];
    difficulty: ({ difficulty: EssayDifficulty } & DistributionRow)[];
  };
  try {
    payload = JSON.parse(String(formData.get("distributionsJson") ?? "{}"));
  } catch {
    return { error: "Las distribuciones enviadas no son válidas." };
  }

  const supabase = await createClient();

  await supabase.from("essay_subjects").delete().eq("essay_id", essayId);
  await supabase.from("essay_strand_distribution").delete().eq("essay_id", essayId);
  await supabase.from("essay_objectives").delete().eq("essay_id", essayId);
  await supabase
    .from("essay_difficulty_distribution")
    .delete()
    .eq("essay_id", essayId);

  if (payload.strands?.length) {
    const { error } = await supabase.from("essay_strand_distribution").insert(
      payload.strands.map((s) => ({
        essay_id: essayId,
        strand_id: s.strandId,
        question_count: s.count,
        question_percent: s.percent,
        is_required: s.isRequired ?? false,
      }))
    );
    if (error) return { error: error.message };
  }
  if (payload.subjects?.length) {
    const { error } = await supabase.from("essay_subjects").insert(
      payload.subjects.map((s) => ({
        essay_id: essayId,
        subject_id: s.subjectId,
        question_count: s.count,
        question_percent: s.percent,
      }))
    );
    if (error) return { error: error.message };
  }
  if (payload.objectives?.length) {
    const { error } = await supabase.from("essay_objectives").insert(
      payload.objectives.map((o) => ({
        essay_id: essayId,
        learning_objective_id: o.learningObjectiveId,
        question_count: o.count,
        question_percent: o.percent,
      }))
    );
    if (error) return { error: error.message };
  }
  if (payload.difficulty?.length) {
    const { error } = await supabase.from("essay_difficulty_distribution").insert(
      payload.difficulty.map((d) => ({
        essay_id: essayId,
        difficulty: d.difficulty,
        question_count: d.count,
        question_percent: d.percent,
      }))
    );
    if (error) return { error: error.message };
  }

  revalidatePath(`/admin/ensayos/${essayId}`);
  return null;
}

// ---------- Generación automática ----------

function resolveCount(
  row: DistributionRow,
  totalQuestions: number
): number {
  if (row.count != null) return row.count;
  if (row.percent != null) return Math.round((row.percent / 100) * totalQuestions);
  return 0;
}

/**
 * `requirePublishable`: cuando es `true`, restringe el pool a preguntas
 * `is_active=true` + `validation_status='approved_for_exam'` (además del
 * `review_status='aprobado'` que ya filtra `selectEssayQuestions`), y —si se
 * pasa `frameworkId`— a esa versión curricular exacta. Lo usa
 * `essay-coverage.ts` para calcular disponibilidad REAL de publicación; la
 * generación administrativa normal (`generateEssay`) sigue usando el pool
 * amplio (incluye preguntas en revisión, para que el admin vea el estado
 * real del banco al generar una vista previa).
 */
export async function buildCandidatePool(
  levelId: string,
  options?: { requirePublishable?: boolean; frameworkId?: string | null }
): Promise<CandidateQuestion[]> {
  const supabase = await createClient();
  let query = supabase
    .from("questions")
    .select(
      "id, subject_id, learning_objective_id, difficulty, prompt, points, estimated_seconds, review_status, question_usage_stats(times_used), learning_objectives(units(strand_id))"
    )
    .eq("level_id", levelId);

  if (options?.requirePublishable) {
    query = query
      .eq("is_active", true)
      .eq("validation_status", "approved_for_exam");
    if (options.frameworkId) {
      query = query.eq("framework_id", options.frameworkId);
    }
  }

  const { data } = await query;

  type StrandJoin = { units: { strand_id: string } | null } | null;

  return (data ?? []).map((q) => ({
    id: q.id,
    subjectId: q.subject_id,
    strandId: (q.learning_objectives as unknown as StrandJoin)?.units?.strand_id ?? null,
    learningObjectiveId: q.learning_objective_id,
    difficulty: (q.difficulty ?? "intermedia") as EssayDifficulty,
    prompt: q.prompt,
    points: q.points ?? 1,
    estimatedSeconds: q.estimated_seconds,
    reviewStatus: q.review_status ?? "borrador",
    timesUsed:
      (q.question_usage_stats as { times_used: number }[] | null)?.[0]
        ?.times_used ?? 0,
  }));
}

export async function buildNameMaps(essayId: string) {
  const supabase = await createClient();
  const [subjects, strands, objectives] = await Promise.all([
    supabase.from("subjects").select("id, name"),
    supabase.from("strands").select("id, name"),
    supabase.from("learning_objectives").select("id, short_name"),
  ]);
  const subjectNames: Record<string, string> = {};
  for (const s of subjects.data ?? []) subjectNames[s.id] = s.name;
  const strandNames: Record<string, string> = {};
  for (const s of strands.data ?? []) strandNames[s.id] = s.name;
  const objectiveNames: Record<string, string> = {};
  for (const o of objectives.data ?? []) objectiveNames[o.id] = o.short_name;
  void essayId;
  return { subjectNames, strandNames, objectiveNames };
}

/**
 * Carga el historial de respuestas de un estudiante (ensayos + diagnóstico)
 * con su objetivo de aprendizaje y asignatura, para alimentar
 * `buildErrorPracticeRequirements`/`buildReinforcementRequirements`.
 * Solo incluye respuestas ya calificadas (`is_correct` no nulo).
 */
export async function buildStudentAnswerHistory(
  studentId: string
): Promise<StudentAnswerRecord[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("essay_attempt_answers")
    .select(
      "is_correct, questions(subject_id, learning_objective_id), essay_attempts!inner(student_id)"
    )
    .eq("essay_attempts.student_id", studentId)
    .not("is_correct", "is", null);

  type Row = {
    is_correct: boolean | null;
    questions: { subject_id: string; learning_objective_id: string | null } | null;
  };
  return ((data ?? []) as unknown as Row[])
    .filter((r) => r.questions != null)
    .map((r) => ({
      isCorrect: Boolean(r.is_correct),
      subjectId: r.questions!.subject_id,
      learningObjectiveId: r.questions!.learning_objective_id,
    }));
}

export type GenerateEssayState = {
  error?: string;
  missing?: MissingRequirement[];
  generatedCount?: number;
} | null;

export type EssayRow = {
  id: string;
  level_id: string;
  essay_type: string;
  total_questions: number;
  framework_id: string | null;
  target_student_id: string | null;
};

export type ResolvedEssayRequirements =
  | {
      error: null;
      subjectRequirements: { subjectId: string; count: number }[];
      strandRequirements: { strandId: string; count: number }[];
      objectiveRequirements: ObjectiveRequirement[];
      difficultyRequirements: { difficulty: EssayDifficulty; count: number }[];
    }
  | { error: string };

/**
 * Resuelve las 4 distribuciones de un ensayo a la forma que consume
 * `selectEssayQuestions`. Compartido por `generateEssay` (persiste la
 * selección) y `checkEssayAvailability` en `essay-coverage.ts` (solo cuenta
 * disponibilidad, no persiste nada) para no duplicar la lógica de
 * `practica_errores`/`refuerzo_objetivos` en dos lugares.
 */
export async function resolveEssayRequirements(
  essay: EssayRow
): Promise<ResolvedEssayRequirements> {
  const { subjects, strands, objectives, difficulty } =
    await listEssayDistributions(essay.id);

  const subjectRequirements = subjects.map((s) => ({
    subjectId: s.subject_id as string,
    count: resolveCount(
      { count: s.question_count, percent: s.question_percent },
      essay.total_questions
    ),
  }));
  const strandRequirements = strands.map((s) => ({
    strandId: s.strand_id as string,
    count: resolveCount(
      { count: s.question_count, percent: s.question_percent },
      essay.total_questions
    ),
  }));
  const difficultyRequirements = difficulty.map((d) => ({
    difficulty: d.difficulty as EssayDifficulty,
    count: resolveCount(
      { count: d.question_count, percent: d.question_percent },
      essay.total_questions
    ),
  }));

  // `practica_errores`/`refuerzo_objetivos`: los requisitos por objetivo no
  // los configura el administrador manualmente (no tiene sentido: dependen
  // del historial de un estudiante puntual, `essay.target_student_id`) sino
  // que se derivan de su historial de respuestas. Para el resto de los
  // tipos de ensayo, los requisitos por objetivo siguen viniendo de
  // `essay_objectives`, configurados a mano.
  let objectiveRequirements: ObjectiveRequirement[];
  if (essay.essay_type === "practica_errores" || essay.essay_type === "refuerzo_objetivos") {
    if (!essay.target_student_id) {
      return {
        error:
          "Este ensayo es de práctica personalizada pero no tiene un estudiante asignado (target_student_id).",
      };
    }
    const history = await buildStudentAnswerHistory(essay.target_student_id);
    objectiveRequirements =
      essay.essay_type === "practica_errores"
        ? buildErrorPracticeRequirements(history, essay.total_questions)
        : buildReinforcementRequirements(history, essay.total_questions);
  } else {
    objectiveRequirements = objectives.map((o) => ({
      learningObjectiveId: o.learning_objective_id as string,
      subjectId:
        (
          o.learning_objectives as {
            units: { strands: { subject_id: string } | null } | null;
          } | null
        )?.units?.strands?.subject_id ?? "",
      count: resolveCount(
        { count: o.question_count, percent: o.question_percent },
        essay.total_questions
      ),
    }));
  }

  return {
    error: null,
    subjectRequirements,
    strandRequirements,
    objectiveRequirements,
    difficultyRequirements,
  };
}

export async function generateEssay(
  _prevState: GenerateEssayState,
  formData: FormData
): Promise<GenerateEssayState> {
  const essayId = String(formData.get("essayId") ?? "");
  if (!essayId) return { error: "Falta el ensayo." };

  const supabase = await createClient();
  const { data: essay, error: essayError } = await supabase
    .from("essays")
    .select("*")
    .eq("id", essayId)
    .single();
  if (essayError || !essay) return { error: "No se encontró el ensayo." };

  const requirements = await resolveEssayRequirements(essay);
  if (requirements.error !== null) return { error: requirements.error };
  const {
    subjectRequirements,
    strandRequirements,
    objectiveRequirements,
    difficultyRequirements,
  } = requirements;

  const candidates = await buildCandidatePool(essay.level_id);
  const { subjectNames, strandNames, objectiveNames } = await buildNameMaps(
    essayId
  );

  const result = selectEssayQuestions({
    candidates,
    totalQuestions: essay.total_questions,
    subjectRequirements,
    strandRequirements,
    objectiveRequirements,
    difficultyRequirements,
    subjectNames,
    strandNames,
    objectiveNames,
  });

  await supabase.from("essay_questions").delete().eq("essay_id", essayId);
  if (result.selected.length > 0) {
    const rows = result.selected.map((s, index) => ({
      essay_id: essayId,
      question_id: s.questionId,
      position: index,
    }));
    const { error } = await supabase.from("essay_questions").insert(rows);
    if (error) return { error: error.message };
  }

  const totalPoints = result.selected.reduce((sum, s) => sum + s.points, 0);
  await supabase
    .from("essays")
    .update({ total_points: totalPoints, updated_at: new Date().toISOString() })
    .eq("id", essayId);

  revalidatePath(`/admin/ensayos/${essayId}`);
  return { missing: result.missing, generatedCount: result.selected.length };
}

export async function listEssayQuestionsWithDetails(essayId: string) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("essay_questions")
    .select(
      "id, position, question_id, questions(prompt, subject_id, learning_objective_id, difficulty, points, estimated_seconds, subjects(name), learning_objectives(short_name, units(strand_id)))"
    )
    .eq("essay_id", essayId)
    .order("position");
  return data ?? [];
}

export type ReplaceEssayQuestionState = { error?: string } | null;

export async function replaceEssayQuestion(
  _prevState: ReplaceEssayQuestionState,
  formData: FormData
): Promise<ReplaceEssayQuestionState> {
  const essayId = String(formData.get("essayId") ?? "");
  const essayQuestionId = String(formData.get("essayQuestionId") ?? "");
  if (!essayId || !essayQuestionId) return { error: "Falta información del ensayo." };

  const supabase = await createClient();
  const { data: essay } = await supabase
    .from("essays")
    .select("level_id")
    .eq("id", essayId)
    .single();
  if (!essay) return { error: "No se encontró el ensayo." };

  const current = await listEssayQuestionsWithDetails(essayId);
  const currentRow = current.find((r) => r.id === essayQuestionId);
  if (!currentRow) return { error: "No se encontró la pregunta a reemplazar." };

  type QuestionJoin = {
    prompt: string;
    subject_id: string;
    learning_objective_id: string | null;
    difficulty: EssayDifficulty;
    points: number;
    estimated_seconds: number | null;
    learning_objectives: { units: { strand_id: string } | null } | null;
  };
  const q = currentRow.questions as unknown as QuestionJoin | null;
  if (!q) return { error: "La pregunta original ya no existe." };
  const strandIdOf = (rq: QuestionJoin) => rq.learning_objectives?.units?.strand_id ?? null;

  const currentSelection: SelectedEssayQuestion[] = current.map((r) => {
    const rq = r.questions as unknown as QuestionJoin;
    return {
      questionId: r.question_id,
      subjectId: rq.subject_id,
      strandId: strandIdOf(rq),
      learningObjectiveId: rq.learning_objective_id,
      difficulty: rq.difficulty,
      prompt: rq.prompt,
      points: rq.points,
      estimatedSeconds: rq.estimated_seconds,
      matchedAxis: "libre",
    };
  });
  // El eje real de la pregunta a reemplazar se infiere de si coincide con
  // algún requisito guardado (objetivo primero, luego eje, luego
  // asignatura, luego dificultad); si no coincide con ninguno, se trata
  // como "libre".
  const { subjects, strands, objectives, difficulty } =
    await listEssayDistributions(essayId);
  const questionStrandId = strandIdOf(q);
  const slotToReplace: SelectedEssayQuestion = {
    questionId: currentRow.question_id,
    subjectId: q.subject_id,
    strandId: questionStrandId,
    learningObjectiveId: q.learning_objective_id,
    difficulty: q.difficulty,
    prompt: q.prompt,
    points: q.points,
    estimatedSeconds: q.estimated_seconds,
    matchedAxis: objectives.some(
      (o) => o.learning_objective_id === q.learning_objective_id
    )
      ? "objetivo"
      : strands.some((s) => s.strand_id === questionStrandId)
        ? "eje"
        : subjects.some((s) => s.subject_id === q.subject_id)
          ? "asignatura"
          : difficulty.some((d) => d.difficulty === q.difficulty)
            ? "dificultad"
            : "libre",
  };

  const candidates = await buildCandidatePool(essay.level_id);
  const replacement = replaceEssaySelectionSlot({
    candidates,
    currentSelection,
    slotToReplace,
  });

  if (!replacement) {
    return {
      error:
        "No hay otra pregunta disponible que cumpla el mismo criterio para reemplazar esta.",
    };
  }

  const { error } = await supabase
    .from("essay_questions")
    .update({ question_id: replacement.questionId })
    .eq("id", essayQuestionId);
  if (error) return { error: error.message };

  const refreshed = await listEssayQuestionsWithDetails(essayId);
  const newTotalPoints = refreshed.reduce((sum, r) => {
    const rq = r.questions as unknown as QuestionJoin;
    return sum + (rq?.points ?? 0);
  }, 0);
  await supabase
    .from("essays")
    .update({ total_points: newTotalPoints, updated_at: new Date().toISOString() })
    .eq("id", essayId);

  revalidatePath(`/admin/ensayos/${essayId}`);
  return null;
}

// ---------- Panel de cobertura curricular ----------

export async function getCoverageReport() {
  const supabase = await createClient();
  const [levelsRes, subjectsRes, questionsRes, objectivesRes] =
    await Promise.all([
      supabase.from("levels").select("id, name"),
      supabase.from("subjects").select("id, name"),
      supabase
        .from("questions")
        .select("id, level_id, subject_id, learning_objective_id, difficulty, review_status"),
      supabase
        .from("learning_objectives")
        .select(
          "id, short_name, level_id, min_recommended_questions, active, units(strands(subject_id))"
        ),
    ]);

  const levels = levelsRes.data ?? [];
  const subjects = subjectsRes.data ?? [];
  const questions = questionsRes.data ?? [];
  const objectives = objectivesRes.data ?? [];

  const subjectNameById = new Map(subjects.map((s) => [s.id, s.name]));
  const levelNameById = new Map(levels.map((l) => [l.id, l.name]));

  const approvedQuestions = questions.filter((q) => q.review_status === "aprobado");

  // Disponibilidad por curso + asignatura + dificultad.
  const bySubjectLevel = new Map<
    string,
    {
      levelId: string;
      levelName: string;
      subjectId: string;
      subjectName: string;
      total: number;
      inicial: number;
      intermedia: number;
      avanzada: number;
    }
  >();
  for (const q of approvedQuestions) {
    const key = `${q.level_id}|${q.subject_id}`;
    const entry =
      bySubjectLevel.get(key) ??
      {
        levelId: q.level_id,
        levelName: levelNameById.get(q.level_id) ?? "—",
        subjectId: q.subject_id,
        subjectName: subjectNameById.get(q.subject_id) ?? "—",
        total: 0,
        inicial: 0,
        intermedia: 0,
        avanzada: 0,
      };
    entry.total += 1;
    if (q.difficulty === "inicial") entry.inicial += 1;
    else if (q.difficulty === "avanzada") entry.avanzada += 1;
    else entry.intermedia += 1;
    bySubjectLevel.set(key, entry);
  }

  // Cobertura por objetivo de aprendizaje.
  const approvedCountByObjective = new Map<string, number>();
  for (const q of approvedQuestions) {
    if (!q.learning_objective_id) continue;
    approvedCountByObjective.set(
      q.learning_objective_id,
      (approvedCountByObjective.get(q.learning_objective_id) ?? 0) + 1
    );
  }

  type ObjectiveJoin = {
    id: string;
    short_name: string;
    level_id: string;
    min_recommended_questions: number;
    active: boolean;
    units: { strands: { subject_id: string } | null } | null;
  };

  const objectiveCoverage = (objectives as unknown as ObjectiveJoin[])
    .filter((o) => o.active)
    .map((o) => {
      const available = approvedCountByObjective.get(o.id) ?? 0;
      const subjectId = o.units?.strands?.subject_id ?? null;
      return {
        objectiveId: o.id,
        objectiveName: o.short_name,
        levelName: levelNameById.get(o.level_id) ?? "—",
        subjectName: subjectId ? subjectNameById.get(subjectId) ?? "—" : "—",
        available,
        recommended: o.min_recommended_questions,
        deficit: Math.max(0, o.min_recommended_questions - available),
      };
    });

  const objectivesWithoutQuestions = objectiveCoverage.filter(
    (o) => o.available === 0
  );
  const objectivesWithInsufficientCoverage = objectiveCoverage.filter(
    (o) => o.available > 0 && o.deficit > 0
  );

  const pendingReviewCount = questions.filter(
    (q) => q.review_status === "en_revision"
  ).length;

  return {
    bySubjectLevel: [...bySubjectLevel.values()],
    objectiveCoverage,
    objectivesWithoutQuestions,
    objectivesWithInsufficientCoverage,
    pendingReviewCount,
  };
}

