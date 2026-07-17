// Dominio: Contenido y preguntas — generador automático de ensayos (Fase 5).
//
// Este módulo NO lleva la directiva "use server": es lógica pura (sin
// llamadas a Supabase) para poder probarla y reutilizarla tanto al generar
// un ensayo completo como al reemplazar una sola pregunta de la selección.
// Sigue el mismo espíritu que `question-import-shared.ts` en la Fase 4.
//
// Decisión de diseño — equilibrio de posiciones de la respuesta correcta:
// esta fase NO baraja ni guarda el orden de las alternativas de cada
// pregunta seleccionada. `correct_index` en `questions` asume un orden fijo
// de `choices` y aquí solo se congela QUÉ preguntas entran al ensayo (y en
// qué posición dentro del ensayo, si `order_mode` es 'fijo'), no el orden
// interno de las alternativas de cada pregunta. Barajar las alternativas de
// forma útil (evitar que todos los estudiantes vean el mismo orden) requiere
// guardarlo por intento individual, y el concepto de "intento" no existe
// todavía en esta fase — se define recién en la Fase 6, que es también donde
// se renderiza la pregunta al estudiante. Adelantar el cálculo aquí sin poder
// persistirlo por intento no aportaría valor y complicaría el modelo de
// datos de esta fase sin necesidad.

import { normalizeKey } from "./question-import-shared";

export type EssayDifficulty = "inicial" | "intermedia" | "avanzada";

export type CandidateQuestion = {
  id: string;
  subjectId: string;
  learningObjectiveId: string | null;
  difficulty: EssayDifficulty;
  prompt: string;
  points: number;
  estimatedSeconds: number | null;
  reviewStatus: string;
  timesUsed: number;
};

export type SubjectRequirement = { subjectId: string; count: number };
export type ObjectiveRequirement = {
  learningObjectiveId: string;
  subjectId: string;
  count: number;
};
export type DifficultyRequirement = { difficulty: EssayDifficulty; count: number };

export type RequirementAxis = "objetivo" | "asignatura" | "dificultad" | "libre";

export type SelectedEssayQuestion = {
  questionId: string;
  subjectId: string;
  learningObjectiveId: string | null;
  difficulty: EssayDifficulty;
  prompt: string;
  points: number;
  estimatedSeconds: number | null;
  matchedAxis: RequirementAxis;
};

export type MissingRequirement = {
  subjectName: string | null;
  objectiveName: string | null;
  difficulty: EssayDifficulty | null;
  available: number;
  missing: number;
};

export type EssaySelectionResult = {
  selected: SelectedEssayQuestion[];
  missing: MissingRequirement[];
};

type NameMaps = {
  subjectNames: Record<string, string>;
  objectiveNames: Record<string, string>;
};

/** Baraja simple (Fisher-Yates) usando un generador reemplazable para pruebas. */
function shuffle<T>(items: T[], rng: () => number): T[] {
  const arr = [...items];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

/**
 * Ordena candidatos priorizando menor `timesUsed` (menos usados primero) y
 * baraja aleatoriamente entre los que tienen el mismo `timesUsed`, para no
 * favorecer siempre la misma pregunta cuando hay empate de uso.
 */
function prioritizeByUsage(
  candidates: CandidateQuestion[],
  rng: () => number
): CandidateQuestion[] {
  const groups = new Map<number, CandidateQuestion[]>();
  for (const c of candidates) {
    const list = groups.get(c.timesUsed) ?? [];
    list.push(c);
    groups.set(c.timesUsed, list);
  }
  const sortedKeys = [...groups.keys()].sort((a, b) => a - b);
  return sortedKeys.flatMap((k) => shuffle(groups.get(k)!, rng));
}

/**
 * Toma hasta `count` candidatos del pool que cumplan `filterFn`, evitando
 * ids ya usados y enunciados muy parecidos (misma noción de similitud que la
 * carga masiva: normalizeKey exacto) a preguntas ya elegidas en este ensayo.
 */
function pickFromPool(
  pool: CandidateQuestion[],
  count: number,
  filterFn: (c: CandidateQuestion) => boolean,
  usedIds: Set<string>,
  usedPrompts: Set<string>,
  rng: () => number
): CandidateQuestion[] {
  if (count <= 0) return [];
  const eligible = pool.filter(
    (c) =>
      filterFn(c) &&
      !usedIds.has(c.id) &&
      !usedPrompts.has(normalizeKey(c.prompt))
  );
  const ordered = prioritizeByUsage(eligible, rng);
  const picked: CandidateQuestion[] = [];
  for (const candidate of ordered) {
    if (picked.length >= count) break;
    picked.push(candidate);
    usedIds.add(candidate.id);
    usedPrompts.add(normalizeKey(candidate.prompt));
  }
  return picked;
}

function toSelected(
  c: CandidateQuestion,
  axis: RequirementAxis
): SelectedEssayQuestion {
  return {
    questionId: c.id,
    subjectId: c.subjectId,
    learningObjectiveId: c.learningObjectiveId,
    difficulty: c.difficulty,
    prompt: c.prompt,
    points: c.points,
    estimatedSeconds: c.estimatedSeconds,
    matchedAxis: axis,
  };
}

/**
 * Selección automática de preguntas para un ensayo. Aplica, sobre el mismo
 * pool de preguntas aprobadas, las 3 restricciones a la vez: por objetivo de
 * aprendizaje (más específico), luego por asignatura (para lo que no quedó
 * cubierto por objetivos) y luego por dificultad (ajuste final). Si al
 * completar un pase falta un requisito, se reporta en `missing` — nunca se
 * rellena silenciosamente con preguntas fuera de ese criterio.
 *
 * El remanente (totalQuestions menos la suma de todo lo pedido en las 3
 * distribuciones) sí se completa desde el pool general aprobado, porque no
 * corresponde a ningún requisito específico incumplido.
 */
export function selectEssayQuestions(params: {
  candidates: CandidateQuestion[];
  totalQuestions: number;
  subjectRequirements: SubjectRequirement[];
  objectiveRequirements: ObjectiveRequirement[];
  difficultyRequirements: DifficultyRequirement[];
  excludeQuestionIds?: string[];
  rng?: () => number;
} & NameMaps): EssaySelectionResult {
  const {
    candidates,
    totalQuestions,
    subjectRequirements,
    objectiveRequirements,
    difficultyRequirements,
    subjectNames,
    objectiveNames,
    excludeQuestionIds = [],
    rng = Math.random,
  } = params;

  const approved = candidates.filter((c) => c.reviewStatus === "aprobado");
  const usedIds = new Set<string>(excludeQuestionIds);
  const usedPrompts = new Set<string>(
    approved
      .filter((c) => excludeQuestionIds.includes(c.id))
      .map((c) => normalizeKey(c.prompt))
  );

  const selected: SelectedEssayQuestion[] = [];
  const missing: MissingRequirement[] = [];

  // Pase 1: por objetivo de aprendizaje (el requisito más específico).
  for (const req of objectiveRequirements) {
    const picked = pickFromPool(
      approved,
      req.count,
      (c) => c.learningObjectiveId === req.learningObjectiveId,
      usedIds,
      usedPrompts,
      rng
    );
    selected.push(...picked.map((c) => toSelected(c, "objetivo")));
    if (picked.length < req.count) {
      const available = approved.filter(
        (c) => c.learningObjectiveId === req.learningObjectiveId
      ).length;
      missing.push({
        subjectName: subjectNames[req.subjectId] ?? null,
        objectiveName: objectiveNames[req.learningObjectiveId] ?? null,
        difficulty: null,
        available,
        missing: req.count - picked.length,
      });
    }
  }

  // Pase 2: por asignatura, descontando lo ya cubierto por objetivos de esa
  // misma asignatura.
  for (const req of subjectRequirements) {
    const alreadyForSubject = selected.filter(
      (s) => s.subjectId === req.subjectId
    ).length;
    const remaining = req.count - alreadyForSubject;
    if (remaining <= 0) continue;
    const picked = pickFromPool(
      approved,
      remaining,
      (c) => c.subjectId === req.subjectId,
      usedIds,
      usedPrompts,
      rng
    );
    selected.push(...picked.map((c) => toSelected(c, "asignatura")));
    if (picked.length < remaining) {
      const available = approved.filter(
        (c) => c.subjectId === req.subjectId && !usedIds.has(c.id)
      ).length;
      missing.push({
        subjectName: subjectNames[req.subjectId] ?? null,
        objectiveName: null,
        difficulty: null,
        available,
        missing: remaining - picked.length,
      });
    }
  }

  // Pase 3: por dificultad, descontando lo ya seleccionado con esa dificultad.
  for (const req of difficultyRequirements) {
    const alreadyForDifficulty = selected.filter(
      (s) => s.difficulty === req.difficulty
    ).length;
    const remaining = req.count - alreadyForDifficulty;
    if (remaining <= 0) continue;
    const picked = pickFromPool(
      approved,
      remaining,
      (c) => c.difficulty === req.difficulty,
      usedIds,
      usedPrompts,
      rng
    );
    selected.push(...picked.map((c) => toSelected(c, "dificultad")));
    if (picked.length < remaining) {
      const available = approved.filter(
        (c) => c.difficulty === req.difficulty && !usedIds.has(c.id)
      ).length;
      missing.push({
        subjectName: null,
        objectiveName: null,
        difficulty: req.difficulty,
        available,
        missing: remaining - picked.length,
      });
    }
  }

  // Remanente libre: completa hasta totalQuestions desde el pool general
  // (esto no corresponde a un requisito incumplido, así que no se reporta
  // como "missing"; si no alcanza, el ensayo simplemente queda con menos
  // preguntas de las pedidas, visible en la vista previa).
  const freeSlots = totalQuestions - selected.length;
  if (freeSlots > 0) {
    const picked = pickFromPool(
      approved,
      freeSlots,
      () => true,
      usedIds,
      usedPrompts,
      rng
    );
    selected.push(...picked.map((c) => toSelected(c, "libre")));
  }

  return { selected, missing };
}

/**
 * Reemplaza una sola pregunta de una selección ya generada, respetando el
 * mismo eje (objetivo, asignatura, dificultad o libre) que cumplía la
 * pregunta original, sin repetir ninguna de las preguntas ya elegidas en el
 * ensayo. Devuelve `null` si no hay ninguna alternativa disponible.
 */
export function replaceEssaySelectionSlot(params: {
  candidates: CandidateQuestion[];
  currentSelection: SelectedEssayQuestion[];
  slotToReplace: SelectedEssayQuestion;
  rng?: () => number;
}): SelectedEssayQuestion | null {
  const { candidates, currentSelection, slotToReplace, rng = Math.random } =
    params;
  const approved = candidates.filter((c) => c.reviewStatus === "aprobado");
  const usedIds = new Set(currentSelection.map((s) => s.questionId));
  const usedPrompts = new Set(
    currentSelection.map((s) => normalizeKey(s.prompt))
  );

  let filterFn: (c: CandidateQuestion) => boolean;
  switch (slotToReplace.matchedAxis) {
    case "objetivo":
      filterFn = (c) =>
        c.learningObjectiveId === slotToReplace.learningObjectiveId;
      break;
    case "asignatura":
      filterFn = (c) => c.subjectId === slotToReplace.subjectId;
      break;
    case "dificultad":
      filterFn = (c) => c.difficulty === slotToReplace.difficulty;
      break;
    default:
      filterFn = () => true;
  }

  const [picked] = pickFromPool(
    approved,
    1,
    filterFn,
    usedIds,
    usedPrompts,
    rng
  );
  return picked ? toSelected(picked, slotToReplace.matchedAxis) : null;
}
