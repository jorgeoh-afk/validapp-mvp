"use server";

// Dominio: Contenido y preguntas — grandes ideas y conocimientos esenciales
// (migración 0014). Ambas tablas comparten la misma forma: enunciado por
// asignatura y nivel (curso), con ciclo de vida editorial y trazabilidad a
// fuente curricular, igual que learning_objectives.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type FormState = { error: string } | null;

const STATUSES = ["borrador", "en_revision", "aprobado", "archivado"] as const;

type ParsedRecord =
  | { error: string }
  | {
      record: {
        subject_id: string;
        level_id: string;
        statement: string;
        order_index: number;
        status: string;
        curricular_source: string;
        reference_year: number | null;
        updated_at: string;
      };
    };

function parseRecord(formData: FormData): ParsedRecord {
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  const statement = String(formData.get("statement") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const status = String(formData.get("status") ?? "borrador");
  const curricularSource = String(formData.get("curricularSource") ?? "").trim();
  const referenceYearRaw = String(formData.get("referenceYear") ?? "").trim();
  const referenceYear = referenceYearRaw ? Number(referenceYearRaw) : null;

  if (!subjectId || !levelId || !statement) {
    return { error: "Asignatura, curso y enunciado son obligatorios." };
  }
  if (!STATUSES.includes(status as (typeof STATUSES)[number])) {
    return { error: "Estado no válido." };
  }

  return {
    record: {
      subject_id: subjectId,
      level_id: levelId,
      statement,
      order_index: orderIndex,
      status,
      curricular_source: curricularSource,
      reference_year: referenceYear,
      updated_at: new Date().toISOString(),
    },
  };
}

// ---------- Grandes ideas ----------

export async function listBigIdeas() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("big_ideas")
    .select("*, subjects(name), levels(name)")
    .order("order_index");
  return data ?? [];
}

export async function upsertBigIdea(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const parsed = parseRecord(formData);
  if ("error" in parsed) return { error: parsed.error };

  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("big_ideas").update(parsed.record).eq("id", id)
    : await supabase.from("big_ideas").insert(parsed.record);

  if (error) return { error: error.message };
  revalidatePath("/admin/grandes-ideas");
  return null;
}

export async function deleteBigIdea(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("big_ideas").delete().eq("id", id);
  revalidatePath("/admin/grandes-ideas");
}

// ---------- Conocimientos esenciales ----------

export async function listEssentialKnowledge() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("essential_knowledge")
    .select("*, subjects(name), levels(name)")
    .order("order_index");
  return data ?? [];
}

export async function upsertEssentialKnowledge(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const parsed = parseRecord(formData);
  if ("error" in parsed) return { error: parsed.error };

  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("essential_knowledge").update(parsed.record).eq("id", id)
    : await supabase.from("essential_knowledge").insert(parsed.record);

  if (error) return { error: error.message };
  revalidatePath("/admin/conocimientos-esenciales");
  return null;
}

export async function deleteEssentialKnowledge(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("essential_knowledge").delete().eq("id", id);
  revalidatePath("/admin/conocimientos-esenciales");
}
