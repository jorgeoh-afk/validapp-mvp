"use server";

// Dominio: Contenido y preguntas — carga masiva de preguntas vía CSV (Fase 4).
//
// El cliente ya parseó el CSV y mostró una vista previa validada con
// `validateImportRows` (lib/data/question-import-shared.ts). Aquí se recibe
// el arreglo de filas TAL CUAL como texto (sin ids resueltos por el
// cliente) y se vuelve a validar todo contra el catálogo vigente en la
// base de datos: nunca se confía en la validación del cliente.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { resolveTagIds } from "@/lib/data/content";
import {
  validateImportRows,
  type RawImportRow,
} from "@/lib/data/question-import-shared";

export type ImportState =
  | { error: string }
  | {
      insertedCount: number;
      errorCount: number;
      skippedDuplicateCount: number;
    }
  | null;

export async function importQuestions(
  _prevState: ImportState,
  formData: FormData
): Promise<ImportState> {
  const rowsRaw = String(formData.get("rows") ?? "");
  const includeDuplicates = formData.get("includeDuplicates") === "on";

  let rows: RawImportRow[];
  try {
    rows = JSON.parse(rowsRaw);
    if (!Array.isArray(rows)) throw new Error("formato inválido");
  } catch {
    return { error: "No se pudo leer el archivo enviado. Vuelve a intentarlo." };
  }
  if (rows.length === 0) {
    return { error: "El archivo no tiene filas para importar." };
  }

  const supabase = await createClient();

  // Se vuelve a consultar el catálogo completo desde el servidor: no se
  // reutiliza nada de lo que el cliente haya calculado.
  const [{ data: subjects }, { data: levels }, { data: learningObjectives }, { data: existingQuestions }] =
    await Promise.all([
      supabase.from("subjects").select("id, name"),
      supabase.from("levels").select("id, name"),
      supabase.from("learning_objectives").select("id, short_name, level_id"),
      supabase.from("questions").select("subject_id, prompt"),
    ]);

  const validated = validateImportRows(rows, {
    subjects: subjects ?? [],
    levels: levels ?? [],
    learningObjectives: learningObjectives ?? [],
    existingPrompts: existingQuestions ?? [],
  });

  const toInsert = validated.filter(
    (row) =>
      row.record &&
      (row.status === "valida" || (row.status === "advertencia" && includeDuplicates))
  );

  const errorCount = validated.filter((row) => row.status === "error").length;
  const skippedDuplicateCount = validated.filter(
    (row) => row.status === "advertencia" && !includeDuplicates
  ).length;

  if (toInsert.length === 0) {
    return {
      error:
        "No hay filas válidas para importar. Corrige los errores marcados en la vista previa.",
    };
  }

  // Resuelve (o crea) todas las etiquetas necesarias en un solo paso.
  const allTagNames = toInsert.flatMap((row) => row.record?.tags ?? []);
  const uniqueTagNames = Array.from(
    new Set(allTagNames.map((t) => t.trim().toLowerCase()).filter(Boolean))
  );
  const { error: tagsError } = await resolveTagIds(supabase, uniqueTagNames);
  if (tagsError) return { error: tagsError };

  // resolveTagIds no expone el mapeo nombre->id, así que se vuelve a
  // consultar la tabla ya con todas las etiquetas garantizadas (existentes o
  // recién creadas) para construir el mapa nombre -> id.
  const tagIdByName = new Map<string, string>();
  if (uniqueTagNames.length > 0) {
    const { data: tagRows } = await supabase
      .from("question_tags")
      .select("id, name")
      .in("name", uniqueTagNames);
    for (const tag of tagRows ?? []) {
      tagIdByName.set(tag.name, tag.id);
    }
  }

  let insertedCount = 0;
  for (const row of toInsert) {
    const record = row.record!;
    const { data: inserted, error } = await supabase
      .from("questions")
      .insert({
        subject_id: record.subject_id,
        level_id: record.level_id,
        learning_objective_id: record.learning_objective_id,
        prompt: record.prompt,
        choices: record.choices,
        correct_index: record.correct_index,
        explanation: record.explanation,
        difficulty: record.difficulty,
        points: record.points,
        estimated_seconds: record.estimated_seconds,
        source: record.source,
        review_status: "borrador",
      })
      .select("id")
      .single();

    if (error || !inserted) {
      // No se detiene toda la importación por una fila puntual que falle al
      // insertar (por ejemplo, una condición de carrera de FK); se cuenta
      // como error y se continúa con el resto.
      continue;
    }

    const tagIds = record.tags
      .map((t) => tagIdByName.get(t))
      .filter((id): id is string => Boolean(id));
    if (tagIds.length > 0) {
      await supabase
        .from("question_tag_assignments")
        .insert(tagIds.map((tagId) => ({ question_id: inserted.id, tag_id: tagId })));
    }
    insertedCount += 1;
  }

  revalidatePath("/admin/preguntas");
  return {
    insertedCount,
    errorCount,
    skippedDuplicateCount,
  };
}
