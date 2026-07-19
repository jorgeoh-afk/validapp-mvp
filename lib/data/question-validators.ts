// Dominio: Contenido y preguntas — validadores automáticos del generador de
// preguntas EPJA (Fase 7). Lógica pura, sin llamadas a Supabase, para poder
// probarla igual que `essay-selection.ts`/`syllabus-import-shared.ts`.
//
// Estos validadores son el "automatically_validated" del flujo de estados
// (0023_question_generation_pipeline.sql): pasar todos ellos NO equivale a
// revisión humana, solo a que la pregunta no tiene defectos mecánicos
// detectables (respuesta ambigua, duplicado exacto, alternativas
// degeneradas, vínculo curricular roto).

import { createHash } from "node:crypto";

export type QuestionType =
  | "seleccion_multiple"
  | "respuesta_abierta_breve"
  | "respuesta_abierta_extensa";

export type ValidatableQuestion = {
  prompt: string;
  questionType: QuestionType;
  choices?: string[] | null;
  correctIndex?: number | null;
  answerKey?: string | null;
  rubric?: unknown;
  learningObjectiveId: string | null;
  subjectId: string;
  levelId: string;
  frameworkId: string | null;
};

// `error`: defecto estructural que nunca debe llegar a un ensayo publicado
// (respuesta ambigua o inexistente, alternativas duplicadas/vacías, sin
// vínculo curricular). `warning`: heurística blanda que el propio usuario
// pidió tratar como "marca para revisión", no como bloqueo — casi-
// duplicados, pistas de longitud, "todas las anteriores", posible fuga de
// la respuesta en el enunciado (este último tiene falsos positivos
// legítimos, p. ej. preguntas sobre una tabla donde TODAS las alternativas
// son categorías que ya aparecen en el enunciado).
export type IssueSeverity = "error" | "warning";
export type ValidationIssue = { code: string; message: string; severity: IssueSeverity };
export type ValidationResult = { valid: boolean; issues: ValidationIssue[] };

const WARNING_CODES = new Set(["catch_all_choice", "length_hint", "answer_leaked_in_prompt"]);
function issue(code: string, message: string): ValidationIssue {
  return { code, message, severity: WARNING_CODES.has(code) ? "warning" : "error" };
}

/** Normaliza texto para hash/similitud: minúsculas, sin tildes, sin puntuación, espacios colapsados. */
export function normalizeForComparison(text: string): string {
  return text
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/** Hash estable del enunciado normalizado, para detectar duplicados exactos (questions.content_hash). */
export function computeContentHash(prompt: string): string {
  return createHash("sha256").update(normalizeForComparison(prompt)).digest("hex");
}

/**
 * Similitud por shingles de palabras (Jaccard sobre bigramas), 0 a 1.
 * Suficiente para detectar preguntas "casi iguales" (mismo enunciado con una
 * palabra cambiada) sin depender de una librería externa.
 */
export function textSimilarity(a: string, b: string): number {
  const wordsA = normalizeForComparison(a).split(" ").filter(Boolean);
  const wordsB = normalizeForComparison(b).split(" ").filter(Boolean);
  if (wordsA.length === 0 || wordsB.length === 0) return 0;

  const shingles = (words: string[]) => {
    const set = new Set<string>();
    for (let i = 0; i < words.length - 1; i++) set.add(`${words[i]}_${words[i + 1]}`);
    if (words.length === 1) set.add(words[0]);
    return set;
  };
  const setA = shingles(wordsA);
  const setB = shingles(wordsB);
  if (setA.size === 0 || setB.size === 0) return wordsA.join(" ") === wordsB.join(" ") ? 1 : 0;

  let intersection = 0;
  for (const s of setA) if (setB.has(s)) intersection += 1;
  const union = setA.size + setB.size - intersection;
  return union === 0 ? 0 : intersection / union;
}

// Nota de calibración: con Jaccard sobre bigramas de palabras, cambiar UNA
// sola palabra en una oración de ~15 palabras ya baja la similitud a ~0.75
// (cada palabra cambiada afecta 2 bigramas). Un umbral de 0.85 casi nunca se
// alcanzaría salvo textos prácticamente idénticos, así que no serviría para
// detectar el caso real que interesa ("mismo enunciado con 1-2 palabras
// distintas"). 0.7 sí lo captura sin marcar como duplicadas preguntas
// genuinamente distintas (ver pruebas en question-validators.test.ts).
const NEAR_DUPLICATE_THRESHOLD = 0.7;

/** Marca como duplicado exacto (mismo hash) o casi-duplicado (similitud alta) contra un pool ya existente. */
export function findDuplicate(
  prompt: string,
  existing: { id: string; prompt: string; contentHash: string }[]
): { id: string; kind: "exact" | "near" } | null {
  const hash = computeContentHash(prompt);
  for (const e of existing) {
    if (e.contentHash === hash) return { id: e.id, kind: "exact" };
  }
  for (const e of existing) {
    if (textSimilarity(prompt, e.prompt) >= NEAR_DUPLICATE_THRESHOLD) {
      return { id: e.id, kind: "near" };
    }
  }
  return null;
}

/**
 * Validación mecánica de una pregunta individual. No evalúa corrección
 * pedagógica ni factual (eso requiere revisión humana) — solo defectos
 * estructurales detectables sin criterio humano.
 */
export function validateQuestion(q: ValidatableQuestion): ValidationResult {
  const issues: ValidationIssue[] = [];

  if (!q.prompt || q.prompt.trim().length < 10) {
    issues.push(issue("prompt_too_short", "El enunciado es demasiado corto o está vacío."));
  }
  if (!q.learningObjectiveId) {
    issues.push(issue("missing_curricular_link", "Falta el objetivo de aprendizaje (vínculo curricular)."));
  }
  if (!q.subjectId || !q.levelId) {
    issues.push(issue("missing_subject_or_level", "Falta asignatura o nivel."));
  }

  if (q.questionType === "seleccion_multiple") {
    const choices = q.choices ?? [];
    if (choices.length < 3) {
      issues.push(issue("too_few_choices", "Selección múltiple requiere al menos 3 alternativas."));
    }
    if (q.correctIndex == null || q.correctIndex < 0 || q.correctIndex >= choices.length) {
      issues.push(issue("invalid_correct_index", "El índice de la respuesta correcta es inválido."));
    }
    // OJO: no usar `normalizeForComparison` aquí -- esa función quita todo
    // signo no alfanumérico, incluidos `+`/`-`/`²`, que en una alternativa
    // algebraica SON el contenido (p. ej. "2x + 4" vs "2x - 4" son
    // alternativas completamente distintas, pero `normalizeForComparison`
    // las dejaría idénticas: "2x 4"). Para duplicados de alternativas basta
    // una normalización mucho más suave: espacios y mayúsculas.
    const normalizedChoices = choices.map((c) => c.trim().toLowerCase().replace(/\s+/g, " "));
    const uniqueChoices = new Set(normalizedChoices);
    if (uniqueChoices.size !== normalizedChoices.length) {
      issues.push(issue("duplicate_choices", "Hay alternativas repetidas (mismo texto)."));
    }
    if (choices.some((c) => !c || c.trim().length === 0)) {
      issues.push(issue("empty_choice", "Hay una alternativa vacía."));
    }
    const lower = choices.map((c) => c.toLowerCase());
    if (lower.some((c) => c.includes("todas las anteriores") || c.includes("ninguna de las anteriores"))) {
      issues.push(
        issue(
          "catch_all_choice",
          '"Todas/ninguna de las anteriores" requiere justificación explícita; se marca para revisión.'
        )
      );
    }
    // Pista por longitud: si la alternativa correcta es notoriamente más
    // larga o más corta que el resto, puede delatar la respuesta.
    if (q.correctIndex != null && choices[q.correctIndex]) {
      const lengths = choices.map((c) => c.length);
      const correctLength = lengths[q.correctIndex];
      const others = lengths.filter((_, i) => i !== q.correctIndex);
      const avgOthers = others.reduce((s, l) => s + l, 0) / (others.length || 1);
      if (avgOthers > 0 && (correctLength > avgOthers * 1.8 || correctLength < avgOthers * 0.5)) {
        issues.push(
          issue("length_hint", "La alternativa correcta difiere mucho en longitud del resto (posible pista).")
        );
      }
    }
    if (q.prompt && q.correctIndex != null && choices[q.correctIndex]) {
      // Compara por secuencia de TOKENS completos (no substring crudo), para
      // que una respuesta corta como "4" no se confunda con el "4" dentro de
      // "24", pero sí se detecte si aparece como palabra/frase suelta en el
      // enunciado (p. ej. "...el resultado es 4" con alternativa "4").
      const promptTokens = normalizeForComparison(q.prompt).split(" ").filter(Boolean);
      const answerTokens = normalizeForComparison(choices[q.correctIndex]).split(" ").filter(Boolean);
      const matchesAsPhrase =
        answerTokens.length > 0 &&
        promptTokens.some((_, i) => answerTokens.every((t, j) => promptTokens[i + j] === t));
      if (matchesAsPhrase) {
        issues.push(
          issue("answer_leaked_in_prompt", "El enunciado parece incluir el texto de la respuesta correcta.")
        );
      }
    }
  } else {
    // respuesta_abierta_breve | respuesta_abierta_extensa
    if (!q.answerKey || q.answerKey.trim().length === 0) {
      issues.push(issue("missing_answer_key", "Falta la respuesta esperada / pauta."));
    }
    if (!q.rubric) {
      issues.push(issue("missing_rubric", "Falta la rúbrica de corrección."));
    }
  }

  return { valid: !issues.some((i) => i.severity === "error"), issues };
}

/** Verifica que un objetivo/eje declarado en la matriz pertenezca realmente a la asignatura+nivel+framework del ensayo. */
export function validateCurricularConsistency(params: {
  questionSubjectId: string;
  questionLevelId: string;
  questionFrameworkId: string | null;
  essaySubjectId: string;
  essayLevelId: string;
  essayFrameworkId: string | null;
}): ValidationResult {
  const issues: ValidationIssue[] = [];
  if (params.questionSubjectId !== params.essaySubjectId) {
    issues.push(issue("subject_mismatch", "La pregunta no pertenece a la asignatura del ensayo."));
  }
  if (params.questionLevelId !== params.essayLevelId) {
    issues.push(issue("level_mismatch", "La pregunta no pertenece al nivel del ensayo."));
  }
  if (
    params.essayFrameworkId &&
    params.questionFrameworkId &&
    params.questionFrameworkId !== params.essayFrameworkId
  ) {
    issues.push(issue("framework_mismatch", "La pregunta pertenece a otra versión curricular."));
  }
  return { valid: issues.length === 0, issues };
}
