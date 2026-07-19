"use server";

// Dominio: Resultados y progreso — experiencia del estudiante rindiendo un
// ensayo (Fase 6). Complementa (sin modificar) `essays.ts` (Fase 5, dominio
// "Contenido y preguntas"). Ver decisiones de diseño en el encabezado de la
// migración `0013_essay_attempts.sql`.

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import {
  shuffleArray,
  shuffleIndices,
  originalIndexFromVisual,
  visualPositionFromOriginal,
  applyShuffledOrder,
} from "./essay-attempt-shuffle";

type SupabaseClient = Awaited<ReturnType<typeof createClient>>;

// ---------- Formas de retorno de las funciones RPC de la migración 0019 ----------
// El cliente de Supabase se crea sin un tipo `Database` generado (ver
// `lib/supabase/server.ts`), así que `.rpc(...)` no puede inferir la forma
// de la fila por sí solo. `.returns<>()`/`.overrideTypes<>()` no sirven aquí
// porque, sin schema de `Database`, esta versión de postgrest-js no puede
// determinar si el resultado de `.rpc()` es un arreglo o un solo objeto y
// devuelve un tipo de error de compilación en vez de inferir. Se usa en su
// lugar un cast explícito desde `unknown` (mismo criterio que ya usan los
// `as unknown as {...}` existentes en este archivo para las columnas
// embebidas de Supabase).
function asRpcRows<T>(data: unknown): T[] | null {
  return (data as T[] | null) ?? null;
}
function asRpcRow<T>(data: unknown): T | null {
  return (data as T | null) ?? null;
}
type AttemptQuestionChoiceRow = {
  question_id: string;
  position: number;
  prompt: string;
  choices: string[];
  resource_url: string | null;
  points: number;
};

type GradeEssayAnswerRow = {
  is_correct: boolean;
  correct_index: number;
  explanation: string | null;
};

type AttemptResultAnswerRow = {
  question_id: string;
  display_position: number;
  shuffled_choice_order: number[];
  selected_index: number | null;
  is_correct: boolean | null;
  prompt: string;
  choices: string[];
  correct_index: number;
  explanation: string | null;
  points: number;
};

// ---------- Determinación del curso/nivel del estudiante ----------
//
// Decisión de diseño: hoy no existe un campo confiable de "curso actual" del
// estudiante (profiles.target_level es texto libre, sin llenar en ningún
// flujo). El único dato con nivel estimado por el propio sistema es el
// diagnóstico (por asignatura). Se usa el nivel estimado del diagnóstico más
// reciente del estudiante, sin importar la asignatura, como aproximación de
// "su curso actual" para priorizar/filtrar ensayos — mismo tipo de señal que
// ya usa `getLearningPath` en `progress.ts`, pero a nivel global en lugar de
// por asignatura. Si el estudiante no tiene ningún diagnóstico rendido, se
// muestran los ensayos publicados de TODOS los cursos (no se oculta nada),
// ordenados por curso, para no dejar al estudiante nuevo sin ensayos que
// rendir.
async function getStudentLevelId(
  supabase: SupabaseClient,
  studentId: string
): Promise<string | null> {
  const { data } = await supabase
    .from("diagnostics")
    .select("estimated_level_id, completed_at")
    .eq("student_id", studentId)
    .order("completed_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  return data?.estimated_level_id ?? null;
}

// ---------- Listado de ensayos disponibles ----------

export type AvailableEssay = {
  id: string;
  name: string;
  essayType: string;
  levelId: string;
  levelName: string;
  totalQuestions: number;
  timeLimitMinutes: number | null;
  maxAttempts: number | null;
  attemptsUsed: number;
  attemptsRemaining: number | null;
  canStart: boolean;
  inProgressAttemptId: string | null;
  matchesStudentLevel: boolean;
};

export async function listAvailableEssaysForStudent(): Promise<AvailableEssay[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const studentLevelId = await getStudentLevelId(supabase, user.id);
  const nowIso = new Date().toISOString();

  const { data: essays } = await supabase
    .from("essays")
    .select(
      "id, name, essay_type, level_id, total_questions, time_limit_minutes, max_attempts, available_from, status, levels(name, order_index)"
    )
    .eq("status", "publicado")
    .or(`available_from.is.null,available_from.lte.${nowIso}`);

  if (!essays || essays.length === 0) return [];

  const { data: attempts } = await supabase
    .from("essay_attempts")
    .select("id, essay_id, status")
    .eq("student_id", user.id);

  const attemptsByEssay = new Map<
    string,
    { closedCount: number; inProgressId: string | null }
  >();
  for (const a of attempts ?? []) {
    const entry =
      attemptsByEssay.get(a.essay_id) ?? { closedCount: 0, inProgressId: null };
    if (a.status === "en_curso") {
      entry.inProgressId = a.id;
    } else {
      entry.closedCount += 1;
    }
    attemptsByEssay.set(a.essay_id, entry);
  }

  const list: AvailableEssay[] = essays.map((e) => {
    const levels = e.levels as unknown as {
      name: string;
      order_index: number;
    } | null;
    const usage = attemptsByEssay.get(e.id) ?? {
      closedCount: 0,
      inProgressId: null,
    };
    const attemptsRemaining =
      e.max_attempts != null ? Math.max(0, e.max_attempts - usage.closedCount) : null;
    const canStart =
      usage.inProgressId != null || attemptsRemaining === null || attemptsRemaining > 0;
    return {
      id: e.id,
      name: e.name,
      essayType: e.essay_type,
      levelId: e.level_id,
      levelName: levels?.name ?? "—",
      totalQuestions: e.total_questions,
      timeLimitMinutes: e.time_limit_minutes,
      maxAttempts: e.max_attempts,
      attemptsUsed: usage.closedCount,
      attemptsRemaining,
      canStart,
      inProgressAttemptId: usage.inProgressId,
      matchesStudentLevel: studentLevelId != null && e.level_id === studentLevelId,
    };
  });

  const orderIndexById = new Map(
    essays.map((e) => [
      e.id,
      (e.levels as unknown as { order_index: number } | null)?.order_index ?? 0,
    ])
  );

  list.sort((a, b) => {
    if (a.matchesStudentLevel !== b.matchesStudentLevel) {
      return a.matchesStudentLevel ? -1 : 1;
    }
    const orderDiff = (orderIndexById.get(a.id) ?? 0) - (orderIndexById.get(b.id) ?? 0);
    if (orderDiff !== 0) return orderDiff;
    return a.name.localeCompare(b.name);
  });

  return list;
}

// ---------- Detalle de un ensayo antes de iniciar el intento ----------

export type EssayStartInfo = {
  id: string;
  name: string;
  essayType: string;
  levelName: string;
  totalQuestions: number;
  timeLimitMinutes: number | null;
  totalPoints: number | null;
  feedbackMode: "inmediata" | "al_finalizar";
  maxAttempts: number | null;
  attemptsUsed: number;
  attemptsRemaining: number | null;
  canStart: boolean;
  blockedReason: string | null;
  inProgressAttemptId: string | null;
} | null;

export async function getEssayStartInfo(essayId: string): Promise<EssayStartInfo> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: essay } = await supabase
    .from("essays")
    .select(
      "id, name, essay_type, status, available_from, total_questions, time_limit_minutes, total_points, feedback_mode, max_attempts, levels(name)"
    )
    .eq("id", essayId)
    .maybeSingle();
  if (!essay) return null;

  const { data: attempts } = await supabase
    .from("essay_attempts")
    .select("id, status")
    .eq("essay_id", essayId)
    .eq("student_id", user.id);

  const closedCount = (attempts ?? []).filter((a) => a.status !== "en_curso").length;
  const inProgress = (attempts ?? []).find((a) => a.status === "en_curso") ?? null;
  const attemptsRemaining =
    essay.max_attempts != null ? Math.max(0, essay.max_attempts - closedCount) : null;

  let blockedReason: string | null = null;
  if (essay.status !== "publicado") {
    blockedReason = "Este ensayo todavía no está publicado.";
  } else if (essay.available_from && new Date(essay.available_from) > new Date()) {
    blockedReason = "Este ensayo aún no está disponible.";
  } else if (attemptsRemaining === 0 && !inProgress) {
    blockedReason = "Ya usaste todos tus intentos disponibles para este ensayo.";
  }

  return {
    id: essay.id,
    name: essay.name,
    essayType: essay.essay_type,
    levelName: (essay.levels as unknown as { name: string } | null)?.name ?? "—",
    totalQuestions: essay.total_questions,
    timeLimitMinutes: essay.time_limit_minutes,
    totalPoints: essay.total_points,
    feedbackMode: essay.feedback_mode as "inmediata" | "al_finalizar",
    maxAttempts: essay.max_attempts,
    attemptsUsed: closedCount,
    attemptsRemaining,
    canStart: !blockedReason || Boolean(inProgress),
    blockedReason: inProgress ? null : blockedReason,
    inProgressAttemptId: inProgress?.id ?? null,
  };
}

// ---------- Iniciar un intento ----------

export type StartEssayAttemptState = { error: string } | null;

export async function startEssayAttempt(
  _prevState: StartEssayAttemptState,
  formData: FormData
): Promise<StartEssayAttemptState> {
  const essayId = String(formData.get("essayId") ?? "");
  if (!essayId) return { error: "Falta el ensayo." };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Debes iniciar sesión." };

  const { data: essay } = await supabase
    .from("essays")
    .select("id, status, available_from, order_mode, max_attempts")
    .eq("id", essayId)
    .maybeSingle();
  if (!essay) return { error: "No se encontró el ensayo." };
  if (essay.status !== "publicado") {
    return { error: "Este ensayo todavía no está publicado." };
  }
  if (essay.available_from && new Date(essay.available_from) > new Date()) {
    return { error: "Este ensayo aún no está disponible." };
  }

  const { data: existingAttempts } = await supabase
    .from("essay_attempts")
    .select("id, status")
    .eq("essay_id", essayId)
    .eq("student_id", user.id);

  // Si ya hay un intento en curso, se reutiliza en vez de crear uno nuevo:
  // evita intentos huérfanos si el estudiante recarga o vuelve a esta
  // pantalla antes de terminar.
  const inProgress = (existingAttempts ?? []).find((a) => a.status === "en_curso");
  if (inProgress) {
    redirect(`/ensayos/${essayId}/intento/${inProgress.id}`);
  }

  const closedCount = (existingAttempts ?? []).filter(
    (a) => a.status !== "en_curso"
  ).length;
  if (essay.max_attempts != null && closedCount >= essay.max_attempts) {
    return { error: "Ya usaste todos tus intentos disponibles para este ensayo." };
  }

  // Solo se necesita saber si el ensayo tiene preguntas generadas; el
  // contenido (`choices`) se trae después, vía RPC, una vez creado el
  // intento (ver `get_attempt_question_choices` en la migración 0019: exige
  // que el intento ya exista y sea del usuario autenticado). Esta cuenta no
  // toca `questions`, así que no depende de la política RLS endurecida.
  const { count: essayQuestionCount } = await supabase
    .from("essay_questions")
    .select("id", { count: "exact", head: true })
    .eq("essay_id", essayId);

  if (!essayQuestionCount) {
    return { error: "Este ensayo todavía no tiene preguntas generadas." };
  }

  const { data: attempt, error: attemptError } = await supabase
    .from("essay_attempts")
    .insert({ essay_id: essayId, student_id: user.id, status: "en_curso" })
    .select("id")
    .single();
  if (attemptError || !attempt) {
    return { error: attemptError?.message ?? "No se pudo iniciar el intento." };
  }

  // A partir de aquí ya existe el intento, así que `get_attempt_question_choices`
  // puede validar ownership (`essay_attempts.student_id = auth.uid()`) y
  // devolver las preguntas SIN `correct_index` ni `explanation`, ya
  // ordenadas por `essay_questions.position`.
  const { data: questionChoicesRaw, error: choicesError } = await supabase.rpc(
    "get_attempt_question_choices",
    { p_attempt_id: attempt.id }
  );
  const questionChoices = asRpcRows<AttemptQuestionChoiceRow>(questionChoicesRaw);
  if (choicesError || !questionChoices || questionChoices.length === 0) {
    return {
      error: choicesError?.message ?? "No se pudieron cargar las preguntas del ensayo.",
    };
  }

  // Orden de presentación de las preguntas: 'fijo' respeta la posición
  // congelada en essay_questions (ya reflejada en el orden devuelto por la
  // función); 'aleatorio' se baraja una sola vez, aquí, por intento (ver
  // decisión de diseño en la migración 0013).
  const orderedIndexes =
    essay.order_mode === "aleatorio"
      ? shuffleArray(questionChoices.map((_, i) => i))
      : questionChoices.map((_, i) => i);

  const rows = questionChoices.map((qc, originalIndex) => {
    const choicesLength = Array.isArray(qc.choices) ? qc.choices.length : 0;
    const displayPosition = orderedIndexes.indexOf(originalIndex);
    return {
      attempt_id: attempt.id,
      question_id: qc.question_id,
      display_position: displayPosition,
      shuffled_choice_order: shuffleIndices(choicesLength),
      selected_index: null,
      is_correct: null,
      answered_at: null,
    };
  });

  const { error: answersError } = await supabase
    .from("essay_attempt_answers")
    .insert(rows);
  if (answersError) {
    // Deja el intento igual creado; el estudiante puede reintentar entrar y
    // se reutilizará por la lógica de "intento en curso" de arriba. No se
    // borra automáticamente para no perder rastro del intento fallido.
    return { error: answersError.message };
  }

  redirect(`/ensayos/${essayId}/intento/${attempt.id}`);
}

// ---------- Rendir el intento (preguntas y respuestas) ----------

export type AttemptQuestionView = {
  answerId: string;
  questionId: string;
  displayPosition: number;
  prompt: string;
  choices: string[]; // ya en el orden barajado para este intento
  points: number;
  selectedVisualPosition: number | null;
  isCorrect: boolean | null;
  answered: boolean;
};

export type AttemptView = {
  attemptId: string;
  essayId: string;
  essayName: string;
  status: "en_curso" | "enviado" | "expirado";
  feedbackMode: "inmediata" | "al_finalizar";
  timeLimitMinutes: number | null;
  startedAt: string;
  questions: AttemptQuestionView[];
} | null;

export async function getAttemptView(attemptId: string): Promise<AttemptView> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: attempt } = await supabase
    .from("essay_attempts")
    .select(
      "id, essay_id, student_id, status, started_at, essays(name, feedback_mode, time_limit_minutes)"
    )
    .eq("id", attemptId)
    .maybeSingle();
  if (!attempt || attempt.student_id !== user.id) return null;

  const { data: answers } = await supabase
    .from("essay_attempt_answers")
    .select(
      "id, question_id, display_position, shuffled_choice_order, selected_index, is_correct"
    )
    .eq("attempt_id", attemptId)
    .order("display_position");

  // `prompt`/`choices`/`points` ya no se leen con un join directo a
  // `questions` (bloqueado para estudiantes por la política RLS de la
  // migración 0019): se obtienen vía la misma función usada al iniciar el
  // intento, que ya valida que el intento es del usuario autenticado.
  const { data: questionMetaRaw } = await supabase.rpc("get_attempt_question_choices", {
    p_attempt_id: attemptId,
  });
  const questionMeta = asRpcRows<AttemptQuestionChoiceRow>(questionMetaRaw);
  const metaByQuestion = new Map(
    (questionMeta ?? []).map((q) => [q.question_id, q])
  );

  const essay = attempt.essays as unknown as {
    name: string;
    feedback_mode: "inmediata" | "al_finalizar";
    time_limit_minutes: number | null;
  } | null;

  const questions: AttemptQuestionView[] = (answers ?? []).map((a) => {
    const meta = metaByQuestion.get(a.question_id);
    const shuffledOrder = (a.shuffled_choice_order as number[] | null) ?? [];
    const choices = applyShuffledOrder(meta?.choices ?? [], shuffledOrder);
    const selectedVisualPosition =
      a.selected_index != null
        ? visualPositionFromOriginal(shuffledOrder, a.selected_index)
        : null;
    return {
      answerId: a.id,
      questionId: a.question_id,
      displayPosition: a.display_position,
      prompt: meta?.prompt ?? "",
      choices,
      points: meta?.points ?? 1,
      selectedVisualPosition,
      isCorrect: a.is_correct,
      answered: a.selected_index != null,
    };
  });

  return {
    attemptId: attempt.id,
    essayId: attempt.essay_id,
    essayName: essay?.name ?? "",
    status: attempt.status as "en_curso" | "enviado" | "expirado",
    feedbackMode: essay?.feedback_mode ?? "al_finalizar",
    timeLimitMinutes: essay?.time_limit_minutes ?? null,
    startedAt: attempt.started_at,
    questions,
  };
}

export type SubmitEssayAnswerResult =
  | { error: string }
  | {
      correct: boolean;
      correctVisualPosition: number;
      explanation: string | null;
    };

/**
 * Guarda la respuesta de una pregunta del intento. `selectedVisualPosition`
 * viene en la posición visible (según el orden barajado de este intento); se
 * traduce al índice original antes de comparar con `correct_index` y de
 * guardar `selected_index` (ver decisión de diseño en la migración 0013).
 */
export async function submitEssayAnswer(
  attemptId: string,
  answerId: string,
  selectedVisualPosition: number
): Promise<SubmitEssayAnswerResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Debes iniciar sesión." };

  // Ownership del intento (defensa en profundidad: `essay_attempt_answers`
  // conserva su propia RLS `_select_own`, ajena al cambio de esta migración,
  // así que esta lectura ya filtra por el usuario dueño del intento). La
  // comprobación de `status en_curso` la repite igual `grade_essay_answer`
  // dentro de la base de datos, para que no sea posible saltársela llamando
  // al RPC directamente sin pasar por esta Server Action.
  const { data: answer } = await supabase
    .from("essay_attempt_answers")
    .select("id, question_id, shuffled_choice_order")
    .eq("id", answerId)
    .eq("attempt_id", attemptId)
    .maybeSingle();
  if (!answer) return { error: "Pregunta no encontrada en este intento." };

  const shuffledOrder = (answer.shuffled_choice_order as number[] | null) ?? [];
  const originalIndex = originalIndexFromVisual(shuffledOrder, selectedVisualPosition);

  // `grade_essay_answer` compara internamente contra `correct_index` (que
  // nunca sale de la función salvo en este valor de retorno, YA calificado)
  // y actualiza `essay_attempt_answers`. Verifica de nuevo, dentro de la
  // base de datos, que el intento es del usuario autenticado y está
  // `en_curso` antes de calificar.
  const { data: gradedRaw, error } = await supabase
    .rpc("grade_essay_answer", {
      p_attempt_id: attemptId,
      p_question_id: answer.question_id,
      p_selected_original_index: originalIndex,
    })
    .maybeSingle();
  const graded = asRpcRow<GradeEssayAnswerRow>(gradedRaw);
  if (error || !graded) {
    return { error: error?.message ?? "No se pudo calificar la respuesta." };
  }

  return {
    correct: graded.is_correct,
    correctVisualPosition: visualPositionFromOriginal(shuffledOrder, graded.correct_index),
    explanation: graded.explanation ?? null,
  };
}

// ---------- Cerrar el intento ----------

export type SubmitEssayAttemptResult =
  | { error: string }
  | { score: number; totalPoints: number; timeSpentSeconds: number };

export async function submitEssayAttempt(
  attemptId: string,
  reason: "enviado" | "expirado" = "enviado"
): Promise<SubmitEssayAttemptResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Debes iniciar sesión." };

  const { data: attempt } = await supabase
    .from("essay_attempts")
    .select("id, student_id, status, started_at, essay_id")
    .eq("id", attemptId)
    .maybeSingle();
  if (!attempt || attempt.student_id !== user.id) {
    return { error: "Intento no encontrado." };
  }
  if (attempt.status !== "en_curso") {
    const { data: closed } = await supabase
      .from("essay_attempts")
      .select("score, total_points, time_spent_seconds")
      .eq("id", attemptId)
      .maybeSingle();
    return {
      score: closed?.score ?? 0,
      totalPoints: closed?.total_points ?? 0,
      timeSpentSeconds: closed?.time_spent_seconds ?? 0,
    };
  }

  const { data: answers } = await supabase
    .from("essay_attempt_answers")
    .select("question_id, is_correct")
    .eq("attempt_id", attemptId);

  // `points` ya no se lee con un join directo a `questions`: se reutiliza la
  // misma función security-definer que ya valida ownership del intento.
  const { data: questionMetaRaw } = await supabase.rpc("get_attempt_question_choices", {
    p_attempt_id: attemptId,
  });
  const questionMeta = asRpcRows<AttemptQuestionChoiceRow>(questionMetaRaw);
  const pointsByQuestion = new Map(
    (questionMeta ?? []).map((q) => [q.question_id, q.points ?? 1])
  );

  let score = 0;
  let totalPoints = 0;
  for (const a of answers ?? []) {
    const points = pointsByQuestion.get(a.question_id) ?? 1;
    totalPoints += points;
    if (a.is_correct) score += points;
  }

  const submittedAt = new Date();
  const timeSpentSeconds = Math.max(
    0,
    Math.round((submittedAt.getTime() - new Date(attempt.started_at).getTime()) / 1000)
  );

  const { error } = await supabase
    .from("essay_attempts")
    .update({
      status: reason,
      submitted_at: submittedAt.toISOString(),
      score,
      total_points: totalPoints,
      time_spent_seconds: timeSpentSeconds,
    })
    .eq("id", attemptId);
  if (error) return { error: error.message };

  return { score, totalPoints, timeSpentSeconds };
}

// ---------- Resultado final ----------

export type AttemptResultQuestion = {
  prompt: string;
  choices: string[]; // en el orden barajado del intento
  selectedVisualPosition: number | null;
  correctVisualPosition: number;
  isCorrect: boolean;
  explanation: string | null;
  points: number;
};

export type AttemptResult = {
  essayName: string;
  status: "enviado" | "expirado";
  score: number;
  totalPoints: number;
  timeSpentSeconds: number;
  questions: AttemptResultQuestion[];
} | null;

// Decisión de diseño: la pantalla de resultado final SIEMPRE muestra el
// detalle completo de aciertos/errores, sin importar `feedback_mode`. El
// modo de retroalimentación solo controla si se muestra algo INMEDIATAMENTE
// tras cada pregunta mientras el ensayo está en curso; una vez enviado, no
// tiene sentido ocultar el detalle de un intento ya cerrado (mismo criterio
// que la práctica de lecciones existente).
export async function getAttemptResult(attemptId: string): Promise<AttemptResult> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: attempt } = await supabase
    .from("essay_attempts")
    .select(
      "id, student_id, status, score, total_points, time_spent_seconds, essays(name)"
    )
    .eq("id", attemptId)
    .maybeSingle();
  if (!attempt || attempt.student_id !== user.id) return null;
  if (attempt.status === "en_curso") return null;

  // Intento ya cerrado (verificado arriba): `get_attempt_result_answers`
  // revela `correct_index`/`explanation` solo bajo esa condición (la función
  // vuelve a comprobarlo dentro de la base de datos, no confía únicamente en
  // esta verificación de TypeScript) — un intento `en_curso` nunca puede
  // llegar aquí a ver respuestas correctas de preguntas sin responder.
  const { data: answersRaw } = await supabase.rpc("get_attempt_result_answers", {
    p_attempt_id: attemptId,
  });
  const answers = asRpcRows<AttemptResultAnswerRow>(answersRaw);

  const questions: AttemptResultQuestion[] = (answers ?? []).map((a) => {
    const shuffledOrder = (a.shuffled_choice_order as number[] | null) ?? [];
    return {
      prompt: a.prompt ?? "",
      choices: applyShuffledOrder(a.choices ?? [], shuffledOrder),
      selectedVisualPosition:
        a.selected_index != null
          ? visualPositionFromOriginal(shuffledOrder, a.selected_index)
          : null,
      correctVisualPosition: visualPositionFromOriginal(shuffledOrder, a.correct_index),
      isCorrect: Boolean(a.is_correct),
      explanation: a.explanation ?? null,
      points: a.points ?? 1,
    };
  });

  return {
    essayName: (attempt.essays as unknown as { name: string } | null)?.name ?? "",
    status: attempt.status as "enviado" | "expirado",
    score: attempt.score ?? 0,
    totalPoints: attempt.total_points ?? 0,
    timeSpentSeconds: attempt.time_spent_seconds ?? 0,
    questions,
  };
}
