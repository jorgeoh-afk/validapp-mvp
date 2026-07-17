// Dominio: Contenido y preguntas — carga masiva (Fase 4).
//
// Este módulo NO lleva la directiva "use server": es lógica pura,
// sin llamadas a Supabase, que se ejecuta tanto en el cliente (para la
// vista previa antes de guardar) como en el servidor (para revalidar todo
// de nuevo antes de insertar, sin confiar en lo que ya validó el cliente).

export const CSV_COLUMNS = [
  "asignatura",
  "curso",
  "eje",
  "unidad",
  "objetivo_aprendizaje",
  "enunciado",
  "alternativa_1",
  "alternativa_2",
  "alternativa_3",
  "alternativa_4",
  "alternativa_5",
  "alternativa_6",
  "respuesta_correcta",
  "explicacion",
  "dificultad",
  "puntaje",
  "tiempo_estimado",
  "fuente",
  "etiquetas",
] as const;

export type CsvColumn = (typeof CSV_COLUMNS)[number];

/** Fila cruda tal cual llega del CSV (todos los valores como texto). */
export type RawImportRow = Record<CsvColumn, string>;

const DIFFICULTIES = ["inicial", "intermedia", "avanzada"] as const;
const CHOICE_COLUMNS: CsvColumn[] = [
  "alternativa_1",
  "alternativa_2",
  "alternativa_3",
  "alternativa_4",
  "alternativa_5",
  "alternativa_6",
];

export type CatalogSubject = { id: string; name: string };
export type CatalogLevel = { id: string; name: string };
export type CatalogLearningObjective = {
  id: string;
  short_name: string;
  level_id: string;
};
export type ExistingPrompt = { subject_id: string; prompt: string };

export type ImportCatalogs = {
  subjects: CatalogSubject[];
  levels: CatalogLevel[];
  learningObjectives: CatalogLearningObjective[];
  existingPrompts: ExistingPrompt[];
};

export type ImportRowStatus = "valida" | "advertencia" | "error";

export type NormalizedQuestionRecord = {
  subject_id: string;
  level_id: string;
  learning_objective_id: string | null;
  prompt: string;
  choices: string[];
  correct_index: number;
  explanation: string | null;
  difficulty: string;
  points: number;
  estimated_seconds: number | null;
  source: string | null;
  tags: string[];
};

export type ValidatedImportRow = {
  rowNumber: number; // 1-based, sin contar el encabezado
  status: ImportRowStatus;
  errors: string[];
  warnings: string[];
  record: NormalizedQuestionRecord | null;
  preview: {
    asignatura: string;
    curso: string;
    enunciado: string;
    alternativas: string[];
    respuestaCorrecta: string;
    dificultad: string;
  };
};

function normalizeText(value: unknown): string {
  return String(value ?? "").trim();
}

function normalizeKey(value: string): string {
  return value.trim().toLowerCase();
}

/**
 * Cuenta cuántas veces aparece el mismo enunciado (normalizado) dentro del
 * propio archivo, agrupado por asignatura escrita en la fila. Se calcula una
 * sola vez antes de validar fila por fila.
 */
function computeFileDuplicateCounts(
  rows: RawImportRow[]
): Map<string, number> {
  const counts = new Map<string, number>();
  for (const row of rows) {
    const key = `${normalizeKey(row.asignatura)}|${normalizeKey(row.enunciado)}`;
    if (!key.trim().replace("|", "")) continue;
    counts.set(key, (counts.get(key) ?? 0) + 1);
  }
  return counts;
}

function validateRow(
  raw: RawImportRow,
  rowNumber: number,
  catalogs: ImportCatalogs,
  fileDuplicateCounts: Map<string, number>
): ValidatedImportRow {
  const errors: string[] = [];
  const warnings: string[] = [];

  const asignaturaText = normalizeText(raw.asignatura);
  const cursoText = normalizeText(raw.curso);
  const enunciado = normalizeText(raw.enunciado);
  const objetivoText = normalizeText(raw.objetivo_aprendizaje);

  if (!asignaturaText) errors.push("Falta la asignatura.");
  if (!cursoText) errors.push("Falta el curso.");
  if (!enunciado) errors.push("Falta el enunciado.");

  const subject = asignaturaText
    ? catalogs.subjects.find(
        (s) => normalizeKey(s.name) === normalizeKey(asignaturaText)
      )
    : undefined;
  if (asignaturaText && !subject) {
    errors.push(`La asignatura "${asignaturaText}" no existe en el catálogo.`);
  }

  const level = cursoText
    ? catalogs.levels.find(
        (l) => normalizeKey(l.name) === normalizeKey(cursoText)
      )
    : undefined;
  if (cursoText && !level) {
    errors.push(`El curso "${cursoText}" no existe en el catálogo.`);
  }

  let learningObjectiveId: string | null = null;
  if (objetivoText) {
    const candidates = catalogs.learningObjectives.filter(
      (o) => normalizeKey(o.short_name) === normalizeKey(objetivoText)
    );
    const objective = level
      ? (candidates.find((o) => o.level_id === level.id) ?? candidates[0])
      : candidates[0];
    if (!objective) {
      errors.push(
        `El objetivo de aprendizaje "${objetivoText}" no existe en el catálogo.`
      );
    } else {
      learningObjectiveId = objective.id;
    }
  }

  // Alternativas: se toman las columnas no vacías, en orden.
  const rawChoices = CHOICE_COLUMNS.map((col) => normalizeText(raw[col]));
  const choices = rawChoices.filter(Boolean);
  if (choices.length < 2) {
    errors.push("Debes indicar al menos 2 alternativas.");
  }
  const normalizedChoices = choices.map((c) => c.toLowerCase());
  if (new Set(normalizedChoices).size !== choices.length) {
    errors.push("Hay alternativas duplicadas en la misma fila.");
  }

  const respuestaCorrectaText = normalizeText(raw.respuesta_correcta);
  let correctIndex = -1;
  if (!respuestaCorrectaText) {
    errors.push("Falta indicar la respuesta correcta.");
  } else {
    const asNumber = Number(respuestaCorrectaText);
    if (Number.isFinite(asNumber) && Number.isInteger(asNumber)) {
      correctIndex = asNumber - 1; // el CSV usa índice 1-based
      if (correctIndex < 0 || correctIndex >= choices.length) {
        errors.push(
          `La respuesta correcta "${respuestaCorrectaText}" no corresponde a ninguna alternativa.`
        );
        correctIndex = -1;
      }
    } else {
      const foundIndex = normalizedChoices.indexOf(
        respuestaCorrectaText.toLowerCase()
      );
      if (foundIndex === -1) {
        errors.push(
          `La respuesta correcta "${respuestaCorrectaText}" no corresponde a ninguna alternativa.`
        );
      } else {
        correctIndex = foundIndex;
      }
    }
  }

  const difficultyText = normalizeText(raw.dificultad).toLowerCase();
  let difficulty = "intermedia";
  if (difficultyText) {
    if (!DIFFICULTIES.includes(difficultyText as (typeof DIFFICULTIES)[number])) {
      errors.push(
        `La dificultad "${raw.dificultad}" no es válida (usa inicial, intermedia o avanzada).`
      );
    } else {
      difficulty = difficultyText;
    }
  }

  const puntajeText = normalizeText(raw.puntaje);
  let points = 1;
  if (puntajeText) {
    const parsed = Number(puntajeText);
    if (!Number.isFinite(parsed) || parsed <= 0) {
      errors.push(`El puntaje "${puntajeText}" no es un número válido.`);
    } else {
      points = parsed;
    }
  }

  const tiempoText = normalizeText(raw.tiempo_estimado);
  let estimatedSeconds: number | null = null;
  if (tiempoText) {
    const parsed = Number(tiempoText);
    if (!Number.isFinite(parsed) || parsed < 0) {
      errors.push(`El tiempo estimado "${tiempoText}" no es un número válido.`);
    } else {
      estimatedSeconds = parsed;
    }
  }

  const source = normalizeText(raw.fuente) || null;
  const explanation = normalizeText(raw.explicacion) || null;
  const tags = Array.from(
    new Set(
      normalizeText(raw.etiquetas)
        .split(",")
        .map((t) => t.trim())
        .filter(Boolean)
        .map((t) => t.toLowerCase())
    )
  );

  // Duplicados: no bloquean, solo advierten.
  const dupKey = `${normalizeKey(asignaturaText)}|${normalizeKey(enunciado)}`;
  const repeatedInFile = (fileDuplicateCounts.get(dupKey) ?? 0) > 1;
  if (repeatedInFile) {
    warnings.push("El enunciado se repite dentro del mismo archivo.");
  }
  if (subject && enunciado) {
    const existsInDb = catalogs.existingPrompts.some(
      (p) =>
        p.subject_id === subject.id &&
        normalizeKey(p.prompt) === normalizeKey(enunciado)
    );
    if (existsInDb) {
      warnings.push("Ya existe una pregunta muy parecida en esta asignatura.");
    }
  }

  const status: ImportRowStatus =
    errors.length > 0 ? "error" : warnings.length > 0 ? "advertencia" : "valida";

  const record: NormalizedQuestionRecord | null =
    errors.length === 0 && subject && level
      ? {
          subject_id: subject.id,
          level_id: level.id,
          learning_objective_id: learningObjectiveId,
          prompt: enunciado,
          choices,
          correct_index: correctIndex,
          explanation,
          difficulty,
          points,
          estimated_seconds: estimatedSeconds,
          source,
          tags,
        }
      : null;

  return {
    rowNumber,
    status,
    errors,
    warnings,
    record,
    preview: {
      asignatura: asignaturaText,
      curso: cursoText,
      enunciado,
      alternativas: choices,
      respuestaCorrecta: respuestaCorrectaText,
      dificultad: difficultyText || "intermedia",
    },
  };
}

/**
 * Valida todas las filas del archivo contra el catálogo vigente. Se usa tal
 * cual en el cliente (para la vista previa) y en el servidor (para
 * revalidar todo antes de insertar, sin confiar en el resultado del
 * cliente).
 */
export function validateImportRows(
  rows: RawImportRow[],
  catalogs: ImportCatalogs
): ValidatedImportRow[] {
  const duplicateCounts = computeFileDuplicateCounts(rows);
  return rows.map((row, index) =>
    validateRow(row, index + 1, catalogs, duplicateCounts)
  );
}

const TEMPLATE_ROWS: RawImportRow[] = [
  {
    asignatura: "Matemática",
    curso: "Nivel 1 Básico",
    eje: "Álgebra y funciones",
    unidad: "Ecuaciones lineales",
    objetivo_aprendizaje: "",
    enunciado: "¿Cuál es el valor de x en la ecuación 2x + 4 = 10?",
    alternativa_1: "2",
    alternativa_2: "3",
    alternativa_3: "5",
    alternativa_4: "7",
    alternativa_5: "",
    alternativa_6: "",
    respuesta_correcta: "2",
    explicacion: "2x = 10 - 4 = 6, por lo tanto x = 3.",
    dificultad: "intermedia",
    puntaje: "1",
    tiempo_estimado: "60",
    fuente: "Banco propio ValidApp",
    etiquetas: "álgebra, ecuaciones",
  },
  {
    asignatura: "Lenguaje y Comunicación",
    curso: "Nivel 1 Básico",
    eje: "",
    unidad: "",
    objetivo_aprendizaje: "",
    enunciado: "¿Cuál de las siguientes palabras es un sustantivo?",
    alternativa_1: "Corriendo",
    alternativa_2: "Rápidamente",
    alternativa_3: "Casa",
    alternativa_4: "Y",
    alternativa_5: "",
    alternativa_6: "",
    respuesta_correcta: "Casa",
    explicacion: "\"Casa\" nombra un objeto: es un sustantivo.",
    dificultad: "inicial",
    puntaje: "1",
    tiempo_estimado: "40",
    fuente: "",
    etiquetas: "gramática",
  },
];

/** Serializa un valor para CSV, agregando comillas si es necesario. */
function csvEscape(value: string): string {
  if (value.includes(",") || value.includes("\n") || value.includes('"')) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}

/** Genera el contenido del CSV de plantilla descargable (solo cliente/servidor, sin dependencias). */
export function buildTemplateCsv(): string {
  const header = CSV_COLUMNS.join(",");
  const lines = TEMPLATE_ROWS.map((row) =>
    CSV_COLUMNS.map((col) => csvEscape(row[col] ?? "")).join(",")
  );
  return [header, ...lines].join("\n");
}
