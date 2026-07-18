"use server";

// Dominio: Contenido y preguntas — Server Action de la carga masiva de
// temario completo. Vuelve a validar todo contra un catálogo fresco (nunca
// confía en lo que ya validó el cliente), e inserta en el orden en que
// vienen las filas para poder resolver eje→unidad→objetivo dentro del mismo
// archivo, tal como se documenta en syllabus-import-shared.ts.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import {
  validateSyllabusRows,
  type RawSyllabusRow,
  type SyllabusCatalogs,
} from "./syllabus-import-shared";

export type SyllabusImportState =
  | { error: string }
  | {
      insertedCount: number;
      errorCount: number;
      byType: Record<string, number>;
      failures: { rowNumber: number; reason: string }[];
    }
  | null;

export async function importSyllabus(
  _prevState: SyllabusImportState,
  formData: FormData
): Promise<SyllabusImportState> {
  const rowsRaw = String(formData.get("rows") ?? "");
  let rows: RawSyllabusRow[];
  try {
    rows = JSON.parse(rowsRaw);
  } catch {
    return { error: "No se pudo leer el archivo enviado." };
  }
  if (!Array.isArray(rows) || rows.length === 0) {
    return { error: "No hay filas para importar." };
  }

  const supabase = await createClient();

  const [{ data: subjects }, { data: levels }, { data: strands }, { data: units }] =
    await Promise.all([
      supabase.from("subjects").select("id, name"),
      supabase.from("levels").select("id, name"),
      supabase.from("strands").select("id, name, subject_id"),
      supabase.from("units").select("id, name, strand_id"),
    ]);

  const catalogs: SyllabusCatalogs = {
    subjects: subjects ?? [],
    levels: levels ?? [],
    strands: strands ?? [],
    units: units ?? [],
  };

  const validated = validateSyllabusRows(rows, catalogs);

  // Sembrado con el catálogo real, ampliado a medida que se insertan nuevas
  // filas eje/unidad de este mismo request.
  const strandIdByKey = new Map<string, string>();
  for (const s of catalogs.strands) {
    strandIdByKey.set(`${s.subject_id}|${s.name.trim().toLowerCase()}`, s.id);
  }
  const unitIdByKey = new Map<string, string>();
  for (const u of catalogs.units) {
    const strand = catalogs.strands.find((s) => s.id === u.strand_id);
    if (!strand) continue;
    unitIdByKey.set(
      `${strand.subject_id}|${strand.name.trim().toLowerCase()}|${u.name.trim().toLowerCase()}`,
      u.id
    );
  }

  const byType: Record<string, number> = {};
  const failures: { rowNumber: number; reason: string }[] = [];
  let insertedCount = 0;

  for (const row of validated) {
    if (row.status !== "valida" || !row.record) {
      failures.push({
        rowNumber: row.rowNumber,
        reason: row.errors.join(" "),
      });
      continue;
    }
    const record = row.record;
    try {
      if (record.kind === "eje") {
        const { data, error } = await supabase
          .from("strands")
          .insert({
            subject_id: record.subjectId,
            name: record.name,
            description: record.description,
            order_index: record.orderIndex,
          })
          .select("id")
          .single();
        if (error || !data) throw new Error(error?.message ?? "sin id devuelto");
        strandIdByKey.set(
          `${record.subjectId}|${record.name.trim().toLowerCase()}`,
          data.id
        );
      } else if (record.kind === "unidad") {
        const strandId = strandIdByKey.get(record.strandKey);
        if (!strandId) throw new Error("el eje referenciado no se pudo resolver");
        const { data, error } = await supabase
          .from("units")
          .insert({
            strand_id: strandId,
            name: record.name,
            description: record.description,
            order_index: record.orderIndex,
          })
          .select("id")
          .single();
        if (error || !data) throw new Error(error?.message ?? "sin id devuelto");
        unitIdByKey.set(
          `${record.strandKey}|${record.name.trim().toLowerCase()}`,
          data.id
        );
      } else if (record.kind === "objetivo") {
        const unitId = unitIdByKey.get(record.unitKey);
        if (!unitId) throw new Error("la unidad referenciada no se pudo resolver");
        const { error } = await supabase.from("learning_objectives").insert({
          unit_id: unitId,
          level_id: record.levelId,
          code: record.code,
          short_name: record.shortName,
          description: record.description,
          priority: record.priority,
          status: record.status,
          curricular_source: record.curricularSource,
          reference_year: record.referenceYear,
          order_index: record.orderIndex,
        });
        if (error) throw new Error(error.message);
      } else if (record.kind === "gran_idea" || record.kind === "conocimiento_esencial") {
        const table = record.kind === "gran_idea" ? "big_ideas" : "essential_knowledge";
        const { error } = await supabase.from(table).insert({
          subject_id: record.subjectId,
          level_id: record.levelId,
          statement: record.statement,
          status: record.status,
          curricular_source: record.curricularSource,
          reference_year: record.referenceYear,
          order_index: record.orderIndex,
        });
        if (error) throw new Error(error.message);
      } else if (record.kind === "leccion") {
        const { error } = await supabase.from("lessons").insert({
          subject_id: record.subjectId,
          level_id: record.levelId,
          title: record.title,
          content: record.content,
          order_index: record.orderIndex,
        });
        if (error) throw new Error(error.message);
      }
      insertedCount += 1;
      byType[record.kind] = (byType[record.kind] ?? 0) + 1;
    } catch (err) {
      failures.push({
        rowNumber: row.rowNumber,
        reason: err instanceof Error ? err.message : "error desconocido",
      });
    }
  }

  revalidatePath("/admin/ejes");
  revalidatePath("/admin/unidades");
  revalidatePath("/admin/objetivos-aprendizaje");
  revalidatePath("/admin/grandes-ideas");
  revalidatePath("/admin/conocimientos-esenciales");
  revalidatePath("/admin/lecciones");

  return { insertedCount, errorCount: failures.length, byType, failures };
}
