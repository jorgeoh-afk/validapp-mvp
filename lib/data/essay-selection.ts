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
  strandId: string | null;
  learningObjectiveId: string | null;
  difficulty: EssayDifficulty;
  prompt: string;
  points: number;
  estimatedSeconds: number | null;
  reviewStatus: string;
  timesUsed: number;
};

export type SubjectRequirement = { subjectId: string; count: number };
export type StrandRequirement = { strandId: string; count: number };
export type ObjectiveRequirement = {
  learningObjectiveId: string;
  subjectId: string;
  count: number;
};
export type DifficultyRequirement = { difficulty: EssayDifficulty; count: number };

export type RequirementAxis =
  | "objetivo"
  | "eje"
  | "asignatura"
  | "dificultad"
  | "libre";

export type SelectedEssayQuestion = {
  questionId: string;
  subjectId: string;
  strandId: string | null;
  learningObjectiveId: string | null;
  difficulty: EssayDifficulty;
  prompt: string;
  points: number;
  estimatedSeconds: number | null;
  matchedAxis: RequirementAxis;
};

export type MissingRequirement = {
  subjectName: string | null;
  strandName: string | null;
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
  strandNames: Record<string, string>;
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
    strandId: c.strandId,
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
  strandRequirements?: StrandRequirement[];
  objectiveRequirements: ObjectiveRequirement[];
  difficultyRequirements: DifficultyRequirement[];
  excludeQuestionIds?: string[];
  rng?: () => number;
} & NameMaps): EssaySelectionResult {
  const {
    candidates,
    totalQuestions,
    subjectRequirements,
    strandRequirements = [],
    objectiveRequirements,
    difficultyRequirements,
    subjectNames,
    strandNames,
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
        strandName: null,
        objectiveName: objectiveNames[req.learningObjectiveId] ?? null,
        difficulty: null,
        available,
        missing: req.count - picked.length,
      });
    }
  }

  // Pase 2: por eje temático, descontando lo ya cubierto por objetivos que
  // pertenezcan a ese eje (un objetivo cuelga de una unidad, que cuelga de
  // un eje). Va antes que asignatura porque es más específico (asignatura
  // engloba varios ejes).
  for (const req of strandRequirements) {
    const alreadyForStrand = selected.filter(
      (s) => s.strandId === req.strandId
    ).length;
    const remaining = req.count - alreadyForStrand;
    if (remaining <= 0) continue;
    const picked = pickFromPool(
      approved,
      remaining,
      (c) => c.strandId === req.strandId,
      usedIds,
      usedPrompts,
      rng
    );
    selected.push(...picked.map((c) => toSelected(c, "eje")));
    if (picked.length < remaining) {
      const available = approved.filter(
        (c) => c.strandId === req.strandId && !usedIds.has(c.id)
      ).length;
      missing.push({
        subjectName: null,
        strandName: strandNames[req.strandId] ?? null,
        objectiveName: null,
        difficulty: null,
        available,
        missing: remaining - picked.length,
      });
    }
  }

  // Pase 3 (asignatura): descuenta lo ya cubierto por objetivos/ejes de esa
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
        strandName: null,
        objectiveName: null,
        difficulty: null,
        available,
        missing: remaining - picked.length,
      });
    }
  }

  // Pase 4: por dificultad, descontando lo ya seleccionado con esa dificultad.
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
        strandName: null,
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
    case "eje":
      filterFn = (c) => c.strandId === slotToReplace.strandId;
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

// ---------- Requisitos derivados del historial del estudiante ----------
// `practica_errores` y `refuerzo_objetivos` (declarados en el check de
// `essays.essay_type` desde 0012) no tenían, hasta ahora, ninguna lógica que
// construyera requisitos a partir del desempeño del alumno: el resto del
// módulo es agnóstico al tipo de ensayo y solo sabe consumir
// `ObjectiveRequirement[]`. Estas dos funciones traducen el historial de
// respuestas (ya cargado por quien las llama, típicamente uniendo
// `essay_attempt_answers`/`diagnostic_answers` con `questions`) a esa misma
// forma, para poder pasarlas tal cual a `selectEssayQuestions`.

export type StudentAnswerRecord = {
  learningObjectiveId: string | null;
  subjectId: string;
  isCorrect: boolean;
};

/**
 * Reparte `totalQuestions` proporcionalmente al peso de cada objetivo,
 * usando el método del mayor resto para que la suma final coincida siempre
 * con `totalQuestions` (o menos, si hay menos objetivos con peso que
 * preguntas por asignar). Ordena de mayor a menor peso primero para que,
 * cuando `totalQuestions` es chico, se prioricen los objetivos con más
 * errores / peor desempeño en vez de repartir en partes iguales.
 */
function distributeByWeight(
  weighted: Map<string, { subjectId: string; weight: number }>,
  totalQuestions: number
): ObjectiveRequirement[] {
  const entries = [...weighted.entries()]
    .filter(([, v]) => v.weight > 0)
    .sort((a, b) => b[1].weight - a[1].weight);
  const totalWeight = entries.reduce((sum, [, v]) => sum + v.weight, 0);
  if (totalWeight <= 0 || entries.length === 0) return [];

  const raw = entries.map(([objectiveId, v]) => {
    const exact = (v.weight / totalWeight) * totalQuestions;
    return { objectiveId, subjectId: v.subjectId, exact, base: Math.floor(exact) };
  });
  let remainder = totalQuestions - raw.reduce((sum, r) => sum + r.base, 0);
  const byRemainderDesc = [...raw].sort(
    (a, b) => b.exact - b.base - (a.exact - a.base)
  );
  for (const r of byRemainderDesc) {
    if (remainder <= 0) break;
    r.base += 1;
    remainder -= 1;
  }

  return raw
    .filter((r) => r.base > 0)
    .map((r) => ({
      learningObjectiveId: r.objectiveId,
      subjectId: r.subjectId,
      count: r.base,
    }));
}

/**
 * `practica_errores`: prioriza los objetivos donde el estudiante más se ha
 * equivocado (peso = cantidad de respuestas incorrectas registradas por
 * objetivo). Objetivos sin ningún error no entran.
 */
export function buildErrorPracticeRequirements(
  answers: StudentAnswerRecord[],
  totalQuestions: number
): ObjectiveRequirement[] {
  const weighted = new Map<string, { subjectId: string; weight: number }>();
  for (const a of answers) {
    if (a.isCorrect || !a.learningObjectiveId) continue;
    const entry = weighted.get(a.learningObjectiveId) ?? {
      subjectId: a.subjectId,
      weight: 0,
    };
    entry.weight += 1;
    weighted.set(a.learningObjectiveId, entry);
  }
  return distributeByWeight(weighted, totalQuestions);
}

/**
 * `refuerzo_objetivos`: prioriza los objetivos con MENOR tasa de acierto
 * (peso = 1 - aciertos/total respuestas), entre los objetivos con al menos
 * una respuesta registrada. Un objetivo con 100% de acierto tiene peso 0 y
 * no entra.
 */
export function buildReinforcementRequirements(
  answers: StudentAnswerRecord[],
  totalQuestions: number
): ObjectiveRequirement[] {
  const statsByObjective = new Map<
    string,
    { subjectId: string; correct: number; total: number }
  >();
  for (const a of answers) {
    if (!a.learningObjectiveId) continue;
    const entry = statsByObjective.get(a.learningObjectiveId) ?? {
      subjectId: a.subjectId,
      correct: 0,
      total: 0,
    };
    entry.total += 1;
    if (a.isCorrect) entry.correct += 1;
    statsByObjective.set(a.learningObjectiveId, entry);
  }
  const weighted = new Map<string, { subjectId: string; weight: number }>();
  for (const [objectiveId, s] of statsByObjective) {
    weighted.set(objectiveId, {
      subjectId: s.subjectId,
      weight: 1 - s.correct / s.total,
    });
  }
  return distributeByWeight(weighted, totalQuestions);
}
