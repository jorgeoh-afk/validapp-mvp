// Dominio: Contenido y preguntas — carga masiva de temario completo.
//
// Este módulo NO lleva "use server": es lógica pura (sin llamadas a
// Supabase), usada tanto en el cliente (vista previa) como en el servidor
// (revalidación real antes de insertar), igual criterio que
// question-import-shared.ts.
//
// Un solo CSV puede describir 6 tipos de fila distintos, cada uno mapeado a
// una tabla real: eje→strands, unidad→units, objetivo→learning_objectives,
// gran_idea→big_ideas, conocimiento_esencial→essential_knowledge,
// leccion→lessons. Se combinan en un archivo porque unidad depende de eje y
// objetivo depende de unidad — al procesar en orden, una fila puede
// referenciar un eje/unidad creado por una fila anterior del MISMO archivo,
// no solo del catálogo ya existente en la base.

export const SYLLABUS_TYPES = [
  "eje",
  "unidad",
  "objetivo",
  "gran_idea",
  "conocimiento_esencial",
  "leccion",
] as const;
export type SyllabusType = (typeof SYLLABUS_TYPES)[number];

export const SYLLABUS_CSV_COLUMNS = [
  "tipo",
  "asignatura",
  "curso",
  "eje",
  "unidad",
  "nombre",
  "descripcion",
  "codigo",
  "prioridad",
  "estado",
  "fuente_curricular",
  "anio_referencia",
  "orden",
] as const;
export type SyllabusCsvColumn = (typeof SYLLABUS_CSV_COLUMNS)[number];

/** Fila cruda tal cual llega del CSV (todos los valores como texto). */
export type RawSyllabusRow = Record<SyllabusCsvColumn, string>;

const STATUSES = ["borrador", "en_revision", "aprobado", "archivado"] as const;
const PRIORITIES = ["baja", "media", "alta"] as const;

export type CatalogSubject = { id: string; name: string };
export type CatalogLevel = { id: string; name: string };
export type CatalogStrand = { id: string; name: string; subject_id: string };
export type CatalogUnit = { id: string; name: string; strand_id: string };

export type SyllabusCatalogs = {
  subjects: CatalogSubject[];
  levels: CatalogLevel[];
  strands: CatalogStrand[];
  units: CatalogUnit[];
};

export type SyllabusRowStatus = "valida" | "error";

export type NormalizedStrand = {
  kind: "eje";
  subjectId: string;
  name: string;
  description: string;
  orderIndex: number;
};
export type NormalizedUnit = {
  kind: "unidad";
  strandKey: string; // clave interna para resolver contra el mapa de ejes de este mismo lote
  name: string;
  description: string;
  orderIndex: number;
};
export type NormalizedObjective = {
  kind: "objetivo";
  unitKey: string;
  levelId: string;
  code: string | null;
  shortName: string;
  description: string;
  priority: string;
  status: string;
  curricularSource: string;
  referenceYear: number | null;
  orderIndex: number;
};
export type NormalizedStatement = {
  kind: "gran_idea" | "conocimiento_esencial";
  subjectId: string;
  levelId: string;
  statement: string;
  status: string;
  curricularSource: string;
  referenceYear: number | null;
  orderIndex: number;
};
export type NormalizedLesson = {
  kind: "leccion";
  subjectId: string;
  levelId: string;
  title: string;
  content: string;
  orderIndex: number;
};

export type NormalizedSyllabusRecord =
  | NormalizedStrand
  | NormalizedUnit
  | NormalizedObjective
  | NormalizedStatement
  | NormalizedLesson;

export type ValidatedSyllabusRow = {
  rowNumber: number;
  status: SyllabusRowStatus;
  errors: string[];
  record: NormalizedSyllabusRecord | null;
  preview: { tipo: string; asignatura: string; curso: string; nombre: string };
};

function normalizeText(value: unknown): string {
  return String(value ?? "").trim();
}
function normalizeKey(value: string): string {
  return value.trim().toLowerCase();
}

/**
 * Valida y normaliza todas las filas de un CSV de temario completo, en
 * orden. Mantiene un registro propio de ejes/unidades "vistos hasta ahora"
 * — sembrado con el catálogo real recibido y ampliado con cada fila
 * `eje`/`unidad` válida que se procesa — para que una fila `unidad` pueda
 * referenciar un eje definido más arriba en el mismo archivo, y una fila
 * `objetivo` pueda referenciar una unidad definida más arriba, sin que
 * ninguno de los dos exista todavía en la base de datos.
 */
export function validateSyllabusRows(
  rows: RawSyllabusRow[],
  catalogs: SyllabusCatalogs
): ValidatedSyllabusRow[] {
  // claves: `${subjectId}|${normalizeKey(name)}` para ejes,
  //         `${strandKey}|${normalizeKey(name)}` para unidades
  const knownStrands = new Map<string, true>();
  for (const s of catalogs.strands) {
    knownStrands.set(`${s.subject_id}|${normalizeKey(s.name)}`, true);
  }
  const knownUnits = new Map<string, true>();
  for (const u of catalogs.units) {
    const strand = catalogs.strands.find((s) => s.id === u.strand_id);
    if (!strand) continue;
    knownUnits.set(
      `${strand.subject_id}|${normalizeKey(strand.name)}|${normalizeKey(u.name)}`,
      true
    );
  }

  return rows.map((raw, index) => {
    const rowNumber = index + 1;
    const errors: string[] = [];
    const tipo = normalizeText(raw.tipo).toLowerCase();
    const asignaturaText = normalizeText(raw.asignatura);
    const cursoText = normalizeText(raw.curso);
    const ejeText = normalizeText(raw.eje);
    const unidadText = normalizeText(raw.unidad);
    const nombreText = normalizeText(raw.nombre);
    const descripcionText = normalizeText(raw.descripcion);
    const orderIndex = Number(raw.orden) || 0;

    const preview = {
      tipo: tipo || "—",
      asignatura: asignaturaText || "—",
      curso: cursoText || "—",
      nombre: nombreText || "—",
    };

    if (!SYLLABUS_TYPES.includes(tipo as SyllabusType)) {
      errors.push(
        `"tipo" debe ser uno de: ${SYLLABUS_TYPES.join(", ")} (llegó "${raw.tipo}").`
      );
      return { rowNumber, status: "error", errors, record: null, preview };
    }
    if (!nombreText) errors.push("Falta la columna 'nombre'.");

    const subject = asignaturaText
      ? catalogs.subjects.find((s) => normalizeKey(s.name) === normalizeKey(asignaturaText))
      : undefined;
    const level = cursoText
      ? catalogs.levels.find((l) => normalizeKey(l.name) === normalizeKey(cursoText))
      : undefined;

    if (tipo === "eje") {
      if (!asignaturaText) errors.push("El eje requiere 'asignatura'.");
      else if (!subject) errors.push(`La asignatura "${asignaturaText}" no existe.`);
      if (errors.length > 0) {
        return { rowNumber, status: "error", errors, record: null, preview };
      }
      knownStrands.set(`${subject!.id}|${normalizeKey(nombreText)}`, true);
      const record: NormalizedStrand = {
        kind: "eje",
        subjectId: subject!.id,
        name: nombreText,
        description: descripcionText,
        orderIndex,
      };
      return { rowNumber, status: "valida", errors: [], record, preview };
    }

    if (tipo === "unidad") {
      if (!asignaturaText) errors.push("La unidad requiere 'asignatura'.");
      else if (!subject) errors.push(`La asignatura "${asignaturaText}" no existe.`);
      if (!ejeText) errors.push("La unidad requiere 'eje'.");
      if (subject && ejeText) {
        const strandKey = `${subject.id}|${normalizeKey(ejeText)}`;
        if (!knownStrands.has(strandKey)) {
          errors.push(
            `El eje "${ejeText}" no existe para "${asignaturaText}" (ni en el catálogo ni antes en este archivo).`
          );
        } else if (errors.length === 0) {
          knownUnits.set(`${strandKey}|${normalizeKey(nombreText)}`, true);
          const record: NormalizedUnit = {
            kind: "unidad",
            strandKey,
            name: nombreText,
            description: descripcionText,
            orderIndex,
          };
          return { rowNumber, status: "valida", errors: [], record, preview };
        }
      }
      return { rowNumber, status: "error", errors, record: null, preview };
    }

    if (tipo === "objetivo") {
      if (!asignaturaText) errors.push("El objetivo requiere 'asignatura'.");
      else if (!subject) errors.push(`La asignatura "${asignaturaText}" no existe.`);
      if (!cursoText) errors.push("El objetivo requiere 'curso'.");
      else if (!level) errors.push(`El curso "${cursoText}" no existe.`);
      if (!ejeText) errors.push("El objetivo requiere 'eje'.");
      if (!unidadText) errors.push("El objetivo requiere 'unidad'.");

      const priority = normalizeText(raw.prioridad).toLowerCase() || "media";
      if (!PRIORITIES.includes(priority as (typeof PRIORITIES)[number])) {
        errors.push(`Prioridad "${raw.prioridad}" no válida (usa baja, media o alta).`);
      }
      const status = normalizeText(raw.estado).toLowerCase() || "borrador";
      if (!STATUSES.includes(status as (typeof STATUSES)[number])) {
        errors.push(`Estado "${raw.estado}" no válido.`);
      }
      const referenceYearRaw = normalizeText(raw.anio_referencia);
      const referenceYear = referenceYearRaw ? Number(referenceYearRaw) : null;
      if (referenceYearRaw && !Number.isFinite(referenceYear)) {
        errors.push(`Año de referencia "${referenceYearRaw}" no es un número válido.`);
      }

      if (subject && ejeText && unidadText) {
        const strandKey = `${subject.id}|${normalizeKey(ejeText)}`;
        const unitKey = `${strandKey}|${normalizeKey(unidadText)}`;
        if (!knownUnits.has(unitKey)) {
          errors.push(
            `La unidad "${unidadText}" (eje "${ejeText}") no existe (ni en el catálogo ni antes en este archivo).`
          );
        } else if (errors.length === 0) {
          const record: NormalizedObjective = {
            kind: "objetivo",
            unitKey,
            levelId: level!.id,
            code: normalizeText(raw.codigo) || null,
            shortName: nombreText,
            description: descripcionText,
            priority,
            status,
            curricularSource: normalizeText(raw.fuente_curricular),
            referenceYear,
            orderIndex,
          };
          return { rowNumber, status: "valida", errors: [], record, preview };
        }
      }
      return { rowNumber, status: "error", errors, record: null, preview };
    }

    if (tipo === "gran_idea" || tipo === "conocimiento_esencial") {
      if (!asignaturaText) errors.push("Requiere 'asignatura'.");
      else if (!subject) errors.push(`La asignatura "${asignaturaText}" no existe.`);
      if (!cursoText) errors.push("Requiere 'curso'.");
      else if (!level) errors.push(`El curso "${cursoText}" no existe.`);

      const status = normalizeText(raw.estado).toLowerCase() || "borrador";
      if (!STATUSES.includes(status as (typeof STATUSES)[number])) {
        errors.push(`Estado "${raw.estado}" no válido.`);
      }
      const referenceYearRaw = normalizeText(raw.anio_referencia);
      const referenceYear = referenceYearRaw ? Number(referenceYearRaw) : null;
      if (referenceYearRaw && !Number.isFinite(referenceYear)) {
        errors.push(`Año de referencia "${referenceYearRaw}" no es un número válido.`);
      }

      if (errors.length === 0) {
        const record: NormalizedStatement = {
          kind: tipo,
          subjectId: subject!.id,
          levelId: level!.id,
          statement: nombreText,
          status,
          curricularSource: normalizeText(raw.fuente_curricular),
          referenceYear,
          orderIndex,
        };
        return { rowNumber, status: "valida", errors: [], record, preview };
      }
      return { rowNumber, status: "error", errors, record: null, preview };
    }

    // tipo === "leccion"
    if (!asignaturaText) errors.push("La lección requiere 'asignatura'.");
    else if (!subject) errors.push(`La asignatura "${asignaturaText}" no existe.`);
    if (!cursoText) errors.push("La lección requiere 'curso'.");
    else if (!level) errors.push(`El curso "${cursoText}" no existe.`);

    if (errors.length === 0) {
      const record: NormalizedLesson = {
        kind: "leccion",
        subjectId: subject!.id,
        levelId: level!.id,
        title: nombreText,
        content: descripcionText,
        orderIndex,
      };
      return { rowNumber, status: "valida", errors: [], record, preview };
    }
    return { rowNumber, status: "error", errors, record: null, preview };
  });
}

/** Serializa un valor para CSV, agregando comillas si es necesario. */
function csvEscape(value: string): string {
  if (value.includes(",") || value.includes("\n") || value.includes('"')) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}

/**
 * Genera la plantilla CSV de ejemplo (un eje → una unidad → un objetivo →
 * una gran idea → un conocimiento esencial → una lección, todos
 * encadenados), usando una asignatura y curso reales del catálogo vigente
 * para que la plantilla siempre importe sin error, sin importar qué
 * asignaturas/cursos existan hoy.
 */
export function buildSyllabusTemplateCsv(
  sampleSubjectName?: string,
  sampleLevelName?: string
): string {
  const subjectName = sampleSubjectName || "(reemplaza por una asignatura real)";
  const levelName = sampleLevelName || "(reemplaza por un curso real)";

  const rows: RawSyllabusRow[] = [
    {
      tipo: "eje",
      asignatura: subjectName,
      curso: "",
      eje: "",
      unidad: "",
      nombre: "Números y operaciones",
      descripcion: "Eje de ejemplo.",
      codigo: "",
      prioridad: "",
      estado: "",
      fuente_curricular: "",
      anio_referencia: "",
      orden: "0",
    },
    {
      tipo: "unidad",
      asignatura: subjectName,
      curso: "",
      eje: "Números y operaciones",
      unidad: "",
      nombre: "Fracciones",
      descripcion: "Unidad de ejemplo.",
      codigo: "",
      prioridad: "",
      estado: "",
      fuente_curricular: "",
      anio_referencia: "",
      orden: "0",
    },
    {
      tipo: "objetivo",
      asignatura: subjectName,
      curso: levelName,
      eje: "Números y operaciones",
      unidad: "Fracciones",
      nombre: "Compara fracciones con distinto denominador",
      descripcion: "Objetivo de ejemplo.",
      codigo: "OA01",
      prioridad: "media",
      estado: "borrador",
      fuente_curricular: "MINEDUC Bases Curriculares",
      anio_referencia: "2024",
      orden: "0",
    },
    {
      tipo: "gran_idea",
      asignatura: subjectName,
      curso: levelName,
      eje: "",
      unidad: "",
      nombre: "Los números permiten describir y comparar el mundo que nos rodea.",
      descripcion: "",
      codigo: "",
      prioridad: "",
      estado: "borrador",
      fuente_curricular: "MINEDUC Bases Curriculares",
      anio_referencia: "2024",
      orden: "0",
    },
    {
      tipo: "conocimiento_esencial",
      asignatura: subjectName,
      curso: levelName,
      eje: "",
      unidad: "",
      nombre: "Fracciones propias e impropias",
      descripcion: "",
      codigo: "",
      prioridad: "",
      estado: "borrador",
      fuente_curricular: "",
      anio_referencia: "",
      orden: "0",
    },
    {
      tipo: "leccion",
      asignatura: subjectName,
      curso: levelName,
      eje: "",
      unidad: "",
      nombre: "Introducción a las fracciones",
      descripcion: "Contenido de la lección de ejemplo.",
      codigo: "",
      prioridad: "",
      estado: "",
      fuente_curricular: "",
      anio_referencia: "",
      orden: "0",
    },
  ];

  const header = SYLLABUS_CSV_COLUMNS.join(",");
  const lines = rows.map((row) =>
    SYLLABUS_CSV_COLUMNS.map((col) => csvEscape(row[col] ?? "")).join(",")
  );
  return [header, ...lines].join("\n");
}
