"use server";

// Dominio: Resultados y progreso — Fase 7 (final) del rediseño del módulo de
// contenido/evaluación. Agrega estadísticas de DESEMPEÑO REAL de preguntas y
// objetivos de aprendizaje a partir del uso real de estudiantes registrado en
// `essay_attempt_answers` (Fase 6). Es de solo lectura: no modifica
// `lib/data/diagnostics.ts`, `lib/data/lessons.ts` ni `lib/data/essay-attempts.ts`.
//
// Decisión de diseño — cálculo al vuelo vs. persistido: se eligió calcular
// TODO al vuelo (queries de agregación al cargar la página), sin escribir en
// `question_usage_stats` ni crear una Server Action de "Recalcular". Motivo:
// el volumen de datos de ValidApp en este MVP es bajo (pocos ensayos, pocos
// intentos), por lo que el costo de recalcular en cada carga es despreciable,
// y esto evita el problema de invalidación (mantener `question_usage_stats`
// sincronizada con cada respuesta nueva) sin tocar el flujo de
// `submitEssayAnswer` de la Fase 6. La tabla `question_usage_stats` queda tal
// como se dejó en la Fase 3 (estructura lista, sin conectar); si el volumen
// de datos crece y esto se vuelve lento, se puede migrar a un cálculo
// persistido más adelante sin cambiar la forma en que la UI consume estos
// datos.
//
// Umbrales elegidos (heurísticas, no hechos):
// - MIN_ANSWERS_FOR_SIGNAL = 5: cantidad mínima de respuestas registradas
//   para que una pregunta reciba una etiqueta de "fácil", "difícil" o
//   "sugerida a revisar". Con menos respuestas que esto, cualquier
//   porcentaje es poco confiable (ej. 1/1 = 100%), así que no se etiqueta.
// - "Demasiado fácil": % de acierto >= 90% con al menos MIN_ANSWERS_FOR_SIGNAL.
// - "Demasiado difícil": % de acierto <= 30% con al menos MIN_ANSWERS_FOR_SIGNAL.
// - "Sugerida para revisar" (heurística, no certeza): discrepancia entre la
//   dificultad declarada por el autor y el desempeño real observado:
//     - declarada 'inicial' pero % de acierto real < 50%.
//     - declarada 'avanzada' pero % de acierto real > 85%.
//   Solo se evalúa con al menos MIN_ANSWERS_FOR_SIGNAL respuestas. Preguntas
//   'intermedia' no se etiquetan por esta heurística (rango esperado es más
//   amplio y una discrepancia es menos informativa).
//
// Limitación documentada — tiempo promedio de respuesta: no existe un campo
// de tiempo por respuesta individual; solo `answered_at` (marca de tiempo) y
// el `time_spent_seconds` total del intento completo. Se aproxima el tiempo
// de cada respuesta como la diferencia entre su `answered_at` y el
// `answered_at` de la respuesta anterior dentro del mismo intento (o el
// `started_at` del intento si es la primera respuesta). Es una aproximación
// razonable pero no exacta (no captura pausas fuera de la pestaña, por
// ejemplo), por eso la UI debe presentarlo siempre como "estimado". Se acota
// a un máximo de 1 hora por respuesta para no dejar que un intento
// abandonado y retomado mucho después distorsione el promedio.

import { createClient } from "@/lib/supabase/server";

const MIN_ANSWERS_FOR_SIGNAL = 5;
const MAX_ESTIMATED_SECONDS_PER_ANSWER = 60 * 60;

export type QuestionPerformance = {
  questionId: string;
  prompt: string;
  subjectName: string;
  levelName: string;
  learningObjectiveId: string | null;
  learningObjectiveName: string | null;
  declaredDifficulty: "inicial" | "intermedia" | "avanzada";
  reviewStatus: string;
  timesUsed: number;
  correctPercent: number;
  avgEstimatedSeconds: number | null;
  mostSelectedWrongChoiceText: string | null;
  mostSelectedWrongChoiceCount: number;
  tooEasy: boolean;
  tooHard: boolean;
  suggestReview: boolean;
};

export type ObjectivePerformance = {
  objectiveId: string;
  objectiveName: string;
  subjectName: string;
  levelName: string;
  questionsWithData: number;
  avgCorrectPercent: number;
};

export type PerformanceReport = {
  questions: QuestionPerformance[];
  questionsWithoutData: number;
  objectives: ObjectivePerformance[];
  minAnswersForSignal: number;
};

type QuestionRow = {
  id: string;
  prompt: string;
  choices: string[] | null;
  correct_index: number;
  difficulty: "inicial" | "intermedia" | "avanzada";
  review_status: string;
  learning_objective_id: string | null;
  subjects: { name: string } | null;
  levels: { name: string } | null;
  learning_objectives: { short_name: string } | null;
};

export async function getQuestionPerformanceReport(): Promise<PerformanceReport> {
  const supabase = await createClient();

  const [{ data: questions }, { data: answers }] = await Promise.all([
    supabase
      .from("questions")
      .select(
        "id, prompt, choices, correct_index, difficulty, review_status, learning_objective_id, subjects(name), levels(name), learning_objectives(short_name)"
      ),
    // Solo respuestas realmente contestadas (is_correct no nulo): descarta
    // intentos 'en_curso' sin responder esa pregunta todavía.
    supabase
      .from("essay_attempt_answers")
      .select(
        "attempt_id, question_id, selected_index, is_correct, answered_at, essay_attempts(started_at)"
      )
      .not("is_correct", "is", null),
  ]);

  const questionRows = (questions ?? []) as unknown as QuestionRow[];

  type Agg = {
    total: number;
    correct: number;
    wrongChoiceCounts: Map<number, number>;
    estimatedSecondsSum: number;
    estimatedSecondsCount: number;
  };
  const aggByQuestion = new Map<string, Agg>();

  // Para el tiempo estimado se necesita, por cada intento, el orden temporal
  // real de sus respuestas contestadas (por answered_at), comparando cada
  // una contra la anterior (o contra el inicio del intento si es la primera).
  type AnswerRow = {
    attempt_id: string;
    question_id: string;
    selected_index: number | null;
    is_correct: boolean | null;
    answered_at: string | null;
    essay_attempts: { started_at: string } | null;
  };
  const answerRows = (answers ?? []) as unknown as AnswerRow[];

  const byAttempt = new Map<string, AnswerRow[]>();
  for (const a of answerRows) {
    if (!a.answered_at) continue;
    const list = byAttempt.get(a.attempt_id) ?? [];
    list.push(a);
    byAttempt.set(a.attempt_id, list);
  }

  for (const [, list] of byAttempt) {
    list.sort(
      (a, b) => new Date(a.answered_at!).getTime() - new Date(b.answered_at!).getTime()
    );
    let previousTime: number | null = null;
    const startedAt = list[0]?.essay_attempts?.started_at;
    if (startedAt) previousTime = new Date(startedAt).getTime();

    for (const a of list) {
      const answeredTime = new Date(a.answered_at!).getTime();
      let estimatedSeconds: number | null = null;
      if (previousTime != null) {
        const deltaSeconds = Math.round((answeredTime - previousTime) / 1000);
        if (deltaSeconds >= 0) {
          estimatedSeconds = Math.min(deltaSeconds, MAX_ESTIMATED_SECONDS_PER_ANSWER);
        }
      }
      previousTime = answeredTime;

      const agg =
        aggByQuestion.get(a.question_id) ??
        ({
          total: 0,
          correct: 0,
          wrongChoiceCounts: new Map<number, number>(),
          estimatedSecondsSum: 0,
          estimatedSecondsCount: 0,
        } as Agg);
      agg.total += 1;
      if (a.is_correct) agg.correct += 1;
      else if (a.selected_index != null) {
        agg.wrongChoiceCounts.set(
          a.selected_index,
          (agg.wrongChoiceCounts.get(a.selected_index) ?? 0) + 1
        );
      }
      if (estimatedSeconds != null) {
        agg.estimatedSecondsSum += estimatedSeconds;
        agg.estimatedSecondsCount += 1;
      }
      aggByQuestion.set(a.question_id, agg);
    }
  }

  const performances: QuestionPerformance[] = [];
  let questionsWithoutData = 0;

  for (const q of questionRows) {
    const agg = aggByQuestion.get(q.id);
    if (!agg || agg.total === 0) {
      questionsWithoutData += 1;
      continue;
    }

    const correctPercent = Math.round((agg.correct / agg.total) * 100);
    const hasSignal = agg.total >= MIN_ANSWERS_FOR_SIGNAL;

    let mostSelectedWrongIndex: number | null = null;
    let mostSelectedWrongCount = 0;
    for (const [index, count] of agg.wrongChoiceCounts) {
      if (count > mostSelectedWrongCount) {
        mostSelectedWrongIndex = index;
        mostSelectedWrongCount = count;
      }
    }
    const mostSelectedWrongChoiceText =
      mostSelectedWrongIndex != null
        ? (q.choices ?? [])[mostSelectedWrongIndex] ?? null
        : null;

    const tooEasy = hasSignal && correctPercent >= 90;
    const tooHard = hasSignal && correctPercent <= 30;
    const suggestReview =
      hasSignal &&
      ((q.difficulty === "inicial" && correctPercent < 50) ||
        (q.difficulty === "avanzada" && correctPercent > 85));

    performances.push({
      questionId: q.id,
      prompt: q.prompt,
      subjectName: q.subjects?.name ?? "—",
      levelName: q.levels?.name ?? "—",
      learningObjectiveId: q.learning_objective_id,
      learningObjectiveName: q.learning_objectives?.short_name ?? null,
      declaredDifficulty: q.difficulty,
      reviewStatus: q.review_status,
      timesUsed: agg.total,
      correctPercent,
      avgEstimatedSeconds:
        agg.estimatedSecondsCount > 0
          ? Math.round(agg.estimatedSecondsSum / agg.estimatedSecondsCount)
          : null,
      mostSelectedWrongChoiceText,
      mostSelectedWrongChoiceCount: mostSelectedWrongCount,
      tooEasy,
      tooHard,
      suggestReview,
    });
  }

  performances.sort((a, b) => b.timesUsed - a.timesUsed);

  // ---------- Desempeño por objetivo de aprendizaje ----------
  // Promedio simple del % de acierto de cada pregunta con datos, agrupado por
  // objetivo. Distinto de la "cobertura" (cuántas preguntas existen): esto
  // mide qué tan bien les está yendo realmente a los estudiantes.
  const byObjective = new Map<
    string,
    { name: string; subjectName: string; levelName: string; percents: number[] }
  >();
  for (const p of performances) {
    if (!p.learningObjectiveId) continue;
    const entry =
      byObjective.get(p.learningObjectiveId) ??
      {
        name: p.learningObjectiveName ?? "—",
        subjectName: p.subjectName,
        levelName: p.levelName,
        percents: [],
      };
    entry.percents.push(p.correctPercent);
    byObjective.set(p.learningObjectiveId, entry);
  }

  const objectives: ObjectivePerformance[] = [...byObjective.entries()].map(
    ([objectiveId, entry]) => ({
      objectiveId,
      objectiveName: entry.name,
      subjectName: entry.subjectName,
      levelName: entry.levelName,
      questionsWithData: entry.percents.length,
      avgCorrectPercent: Math.round(
        entry.percents.reduce((sum, p) => sum + p, 0) / entry.percents.length
      ),
    })
  );
  objectives.sort((a, b) => a.avgCorrectPercent - b.avgCorrectPercent);

  return {
    questions: performances,
    questionsWithoutData,
    objectives,
    minAnswersForSignal: MIN_ANSWERS_FOR_SIGNAL,
  };
}
