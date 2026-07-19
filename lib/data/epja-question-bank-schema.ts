// Dominio: Contenido y preguntas — esquema de los archivos JSON de banco de
// preguntas EPJA generadas (Fase 7). Un archivo por combinación
// framework×nivel×asignatura, en `data/epja/exams/<framework>/<level>/
// <subject>/question-bank.json`. Reutilizado tanto por el validador de
// pruebas (data/epja/exams/question-banks.test.ts) como por el importador
// (lib/data/epja-question-bank-import.ts).

export type EpjaQuestionType =
  | "seleccion_multiple"
  | "respuesta_abierta_breve"
  | "respuesta_abierta_extensa";

export type EpjaDifficulty = "inicial" | "intermedia" | "avanzada";

export type EpjaBankQuestion = {
  localId: string;
  prompt: string;
  questionType: EpjaQuestionType;
  choices?: string[];
  correctIndex?: number;
  answerKey?: string;
  rubric?: { criterio: string; puntaje_maximo: number; descripcion?: string }[];
  explanation: string;
  /** Debe coincidir con `learning_objectives.short_name` ya cargado por el seed curricular. */
  objectiveShortName: string;
  /** Debe coincidir con `strands.name` ya cargado por el seed curricular. */
  strandName: string;
  difficulty: EpjaDifficulty;
  points?: number;
  estimatedSeconds?: number;
};

/** Valida la FORMA del JSON (no la calidad pedagógica -- eso lo hace question-validators.ts). */
export function isWellFormedBankQuestion(q: unknown): q is EpjaBankQuestion {
  if (typeof q !== "object" || q === null) return false;
  const r = q as Record<string, unknown>;
  return (
    typeof r.localId === "string" &&
    typeof r.prompt === "string" &&
    (r.questionType === "seleccion_multiple" ||
      r.questionType === "respuesta_abierta_breve" ||
      r.questionType === "respuesta_abierta_extensa") &&
    typeof r.explanation === "string" &&
    typeof r.objectiveShortName === "string" &&
    typeof r.strandName === "string" &&
    (r.difficulty === "inicial" || r.difficulty === "intermedia" || r.difficulty === "avanzada")
  );
}
