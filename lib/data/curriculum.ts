"use server";

// Dominio: Contenido y preguntas — jerarquía curricular (Fase 2).
// Programas > niveles educativos > cursos (levels) > ejes > unidades >
// objetivos de aprendizaje > habilidades.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type FormState = { error: string } | null;

// ---------- Programas ----------

export async function listPrograms() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("programs")
    .select("*")
    .order("order_index");
  return data ?? [];
}

export async function upsertProgram(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const active = formData.get("active") === "on";
  if (!name) return { error: "El nombre es obligatorio." };

  const record = { name, description, order_index: orderIndex, active };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("programs").update(record).eq("id", id)
    : await supabase.from("programs").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/programas");
  return null;
}

export async function deleteProgram(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.from("programs").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/programas");
  return null;
}

// ---------- Niveles educativos ----------

export async function listEducationLevels() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("education_levels")
    .select("*")
    .order("order_index");
  return data ?? [];
}

export async function upsertEducationLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const active = formData.get("active") === "on";
  if (!name) return { error: "El nombre es obligatorio." };

  const record = { name, description, order_index: orderIndex, active };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("education_levels").update(record).eq("id", id)
    : await supabase.from("education_levels").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/niveles-educativos");
  return null;
}

export async function deleteEducationLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase
    .from("education_levels")
    .delete()
    .eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/niveles-educativos");
  return null;
}

// ---------- Clasificación de cursos (levels) ----------
// Reutiliza la tabla `levels` existente ("curso"); solo agrega la clasificación
// opcional dentro de programa y nivel educativo.

export async function classifyLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const programId = String(formData.get("programId") ?? "");
  const educationLevelId = String(formData.get("educationLevelId") ?? "");
  if (!id) return { error: "Falta el curso a clasificar." };

  const supabase = await createClient();
  const { error } = await supabase
    .from("levels")
    .update({
      program_id: programId || null,
      education_level_id: educationLevelId || null,
    })
    .eq("id", id);

  if (error) return { error: error.message };
  revalidatePath("/admin/niveles");
  return null;
}

// ---------- Ejes temáticos ----------

export async function listStrands() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("strands")
    .select("*, subjects(name)")
    .order("order_index");
  return data ?? [];
}

export async function upsertStrand(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const subjectId = String(formData.get("subjectId") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const active = formData.get("active") === "on";

  if (!subjectId || !name) {
    return { error: "Asignatura y nombre son obligatorios." };
  }

  const record = {
    subject_id: subjectId,
    name,
    description,
    order_index: orderIndex,
    active,
  };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("strands").update(record).eq("id", id)
    : await supabase.from("strands").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/ejes");
  return null;
}

export async function deleteStrand(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.from("strands").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/ejes");
  return null;
}

// ---------- Unidades ----------

export async function listUnits() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("units")
    .select("*, strands(name, subjects(name))")
    .order("order_index");
  return data ?? [];
}

export async function upsertUnit(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const strandId = String(formData.get("strandId") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const active = formData.get("active") === "on";

  if (!strandId || !name) {
    return { error: "Eje temático y nombre son obligatorios." };
  }

  const record = {
    strand_id: strandId,
    name,
    description,
    order_index: orderIndex,
    active,
  };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("units").update(record).eq("id", id)
    : await supabase.from("units").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/unidades");
  return null;
}

export async function deleteUnit(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.from("units").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/unidades");
  return null;
}

// ---------- Habilidades ----------

export async function listSkills() {
  const supabase = await createClient();
  const { data } = await supabase.from("skills").select("*").order("name");
  return data ?? [];
}

export async function upsertSkill(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const category = String(formData.get("category") ?? "").trim();
  if (!name) return { error: "El nombre es obligatorio." };

  const record = { name, description, category };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("skills").update(record).eq("id", id)
    : await supabase.from("skills").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/habilidades");
  return null;
}

export async function deleteSkill(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.from("skills").delete().eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/habilidades");
  return null;
}

// ---------- Objetivos de aprendizaje ----------

export async function listLearningObjectives() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("learning_objectives")
    .select(
      "*, units(name, strands(name, subjects(name))), levels(name), learning_objective_skills(skill_id, skills(name))"
    )
    .order("order_index");
  return data ?? [];
}

export async function upsertLearningObjective(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const unitId = String(formData.get("unitId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  const code = String(formData.get("code") ?? "").trim();
  const shortName = String(formData.get("shortName") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const priority = String(formData.get("priority") ?? "media");
  const minRecommendedQuestions = Number(
    formData.get("minRecommendedQuestions") ?? 5
  );
  const status = String(formData.get("status") ?? "borrador");
  const curricularSource = String(
    formData.get("curricularSource") ?? ""
  ).trim();
  const referenceYearRaw = String(formData.get("referenceYear") ?? "").trim();
  const referenceYear = referenceYearRaw ? Number(referenceYearRaw) : null;
  const pedagogicalNotes = String(
    formData.get("pedagogicalNotes") ?? ""
  ).trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const active = formData.get("active") === "on";
  const skillIds = formData.getAll("skillIds").map(String).filter(Boolean);

  if (!unitId || !levelId || !shortName) {
    return {
      error: "Unidad, curso y nombre corto son obligatorios.",
    };
  }
  const validPriorities = ["baja", "media", "alta"];
  const validStatuses = ["borrador", "en_revision", "aprobado", "archivado"];
  if (!validPriorities.includes(priority)) {
    return { error: "Prioridad no válida." };
  }
  if (!validStatuses.includes(status)) {
    return { error: "Estado no válido." };
  }

  const record = {
    unit_id: unitId,
    level_id: levelId,
    code: code || null,
    short_name: shortName,
    description,
    priority,
    min_recommended_questions: minRecommendedQuestions,
    status,
    curricular_source: curricularSource,
    reference_year: referenceYear,
    pedagogical_notes: pedagogicalNotes,
    order_index: orderIndex,
    active,
    updated_at: new Date().toISOString(),
  };

  const supabase = await createClient();
  let objectiveId = id;
  if (id) {
    const { error } = await supabase
      .from("learning_objectives")
      .update(record)
      .eq("id", id);
    if (error) return { error: error.message };
  } else {
    const { data, error } = await supabase
      .from("learning_objectives")
      .insert(record)
      .select("id")
      .single();
    if (error) return { error: error.message };
    objectiveId = data.id;
  }

  // Sincroniza las habilidades asociadas (borra y reinserta el set completo).
  await supabase
    .from("learning_objective_skills")
    .delete()
    .eq("learning_objective_id", objectiveId);
  if (skillIds.length > 0) {
    const { error: skillsError } = await supabase
      .from("learning_objective_skills")
      .insert(
        skillIds.map((skillId) => ({
          learning_objective_id: objectiveId,
          skill_id: skillId,
        }))
      );
    if (skillsError) return { error: skillsError.message };
  }

  revalidatePath("/admin/objetivos-aprendizaje");
  return null;
}

export async function deleteLearningObjective(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  const { error } = await supabase
    .from("learning_objectives")
    .delete()
    .eq("id", id);
  if (error) return { error: error.message };
  revalidatePath("/admin/objetivos-aprendizaje");
  return null;
}
