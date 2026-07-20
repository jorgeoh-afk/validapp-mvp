"use server";

// Dominio: Contenido y preguntas — jerarquía curricular (Fase 2).
// Programas > niveles educativos > cursos (levels) > ejes > unidades >
// objetivos de aprendizaje > habilidades.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import type { DeleteImpact } from "@/lib/data/content";

export type FormState = { error: string } | null;

// ---------- Programas ----------

export async function listPrograms() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("programs")
    .select("*")
    .order("order_index");
  if (error) console.error("listPrograms falló:", error.message);
  return data ?? [];
}

const CURRICULUM_TYPES = ["regular", "epja"] as const;

export async function upsertProgram(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  const active = formData.get("active") === "on";
  const code = String(formData.get("code") ?? "").trim();
  const curriculumTypeRaw = String(formData.get("curriculumType") ?? "").trim();
  const minimumAgeRaw = String(formData.get("minimumAge") ?? "").trim();
  const maximumAgeRaw = String(formData.get("maximumAge") ?? "").trim();
  if (!name) return { error: "El nombre es obligatorio." };

  if (
    curriculumTypeRaw &&
    !CURRICULUM_TYPES.includes(curriculumTypeRaw as (typeof CURRICULUM_TYPES)[number])
  ) {
    return { error: "Tipo de currículum no válido." };
  }
  const minimumAge = minimumAgeRaw ? Number(minimumAgeRaw) : null;
  const maximumAge = maximumAgeRaw ? Number(maximumAgeRaw) : null;
  if (minimumAge !== null && Number.isNaN(minimumAge)) {
    return { error: "La edad mínima debe ser un número." };
  }
  if (maximumAge !== null && Number.isNaN(maximumAge)) {
    return { error: "La edad máxima debe ser un número." };
  }
  if (minimumAge !== null && maximumAge !== null && maximumAge < minimumAge) {
    return { error: "La edad máxima no puede ser menor que la edad mínima." };
  }

  const record = {
    name,
    description,
    order_index: orderIndex,
    active,
    code: code || null,
    curriculum_type: curriculumTypeRaw || null,
    minimum_age: minimumAge,
    maximum_age: maximumAge,
  };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("programs").update(record).eq("id", id)
    : await supabase.from("programs").insert(record);

  if (error) {
    if (error.code === "23505") {
      return {
        error: `Ya existe un programa con el código "${code}". Elige uno distinto.`,
      };
    }
    return { error: error.message };
  }
  revalidatePath("/admin/programas");
  return null;
}

/**
 * `levels.program_id` (0010) es `on delete set null`, no `cascade`: eliminar
 * un programa NO borra los cursos clasificados en él, solo los deja sin
 * programa asignado. Por eso `counts` queda vacío (nada se elimina de
 * verdad) y el conteo de cursos afectados se muestra como `note`
 * informativo, no como parte de la lista "esto también eliminará".
 */
export async function getProgramDeleteImpact(
  programId: string
): Promise<DeleteImpact> {
  const supabase = await createClient();
  const { count } = await supabase
    .from("levels")
    .select("id", { count: "exact", head: true })
    .eq("program_id", programId);
  const affected = count ?? 0;

  return {
    counts: [],
    note:
      affected > 0
        ? `${affected} curso(s) actualmente clasificados en este programa quedarán sin programa asignado (no se eliminan).`
        : null,
  };
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
  const { data, error } = await supabase
    .from("education_levels")
    .select("*")
    .order("order_index");
  if (error) console.error("listEducationLevels falló:", error.message);
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

/**
 * Mismo caso que `getProgramDeleteImpact`: `levels.education_level_id`
 * (0010) es `on delete set null`, no `cascade`.
 */
export async function getEducationLevelDeleteImpact(
  educationLevelId: string
): Promise<DeleteImpact> {
  const supabase = await createClient();
  const { count } = await supabase
    .from("levels")
    .select("id", { count: "exact", head: true })
    .eq("education_level_id", educationLevelId);
  const affected = count ?? 0;

  return {
    counts: [],
    note:
      affected > 0
        ? `${affected} curso(s) actualmente clasificados en este nivel educativo quedarán sin nivel educativo asignado (no se eliminan).`
        : null,
  };
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

/**
 * Cursos/niveles de un programa específico (p. ej. los 5 niveles EPJA de
 * adultos de "Exámenes Libres", o los 12 cursos regulares). Usado por el
 * flujo progresivo de "Mi perfil" del estudiante (paso 3): la nota de
 * equivalencia (`equivalence`) solo aplica a los niveles EPJA de adultos
 * condensados, viene null en los 12 cursos regulares individuales.
 */
export type CurriculumLevelOption = {
  id: string;
  name: string;
  code: string | null;
  education_type: "menor_18" | "mayor_18" | null;
  equivalence: string | null;
  track: string | null;
  order_index: number;
};

export async function listLevelsByProgram(
  programId: string
): Promise<CurriculumLevelOption[]> {
  if (!programId) return [];
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("levels")
    .select("id, name, code, education_type, equivalence, track, order_index")
    .eq("program_id", programId)
    .order("order_index");
  if (error) {
    console.error("listLevelsByProgram falló:", error.message);
    return [];
  }
  return data ?? [];
}

/**
 * Valida en servidor -antes de que el trigger `levels_program_curriculum_match`
 * de la base de datos rechace la combinación con una excepción cruda- que el
 * `education_type` del curso sea compatible con el `curriculum_type` del
 * programa elegido. Se usa tanto al clasificar un curso existente
 * (`classifyLevel`) como al crear/editar uno (`upsertLevel`, en
 * `lib/data/content.ts`).
 */
export async function assertProgramCourseCompatibility(
  supabase: Awaited<ReturnType<typeof createClient>>,
  programId: string,
  educationType: string | null
): Promise<string | null> {
  if (!educationType) return null;
  const { data: program } = await supabase
    .from("programs")
    .select("curriculum_type")
    .eq("id", programId)
    .single();

  if (!program?.curriculum_type) return null;
  if (program.curriculum_type === "regular" && educationType !== "menor_18") {
    return 'Este programa es de Currículum Regular: solo admite cursos de "Estudiantes de exámenes libres menores de 18 años".';
  }
  if (program.curriculum_type === "epja" && educationType !== "mayor_18") {
    return 'Este programa es EPJA: solo admite cursos de "Estudiantes de exámenes libres mayores de 18 años".';
  }
  return null;
}

export async function classifyLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const programId = String(formData.get("programId") ?? "");
  const educationLevelId = String(formData.get("educationLevelId") ?? "");
  if (!id) return { error: "Falta el curso a clasificar." };

  const supabase = await createClient();

  if (programId) {
    const { data: level } = await supabase
      .from("levels")
      .select("education_type")
      .eq("id", id)
      .single();
    const compatibilityError = await assertProgramCourseCompatibility(
      supabase,
      programId,
      level?.education_type ?? null
    );
    if (compatibilityError) return { error: compatibilityError };
  }

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
  const { data, error } = await supabase
    .from("strands")
    .select("*, subjects(name)")
    .order("order_index");
  if (error) console.error("listStrands falló:", error.message);
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

/**
 * `units.strand_id` (0010) es `on delete cascade`, y a su vez
 * `learning_objectives.unit_id` (0010) también es `cascade`: eliminar un eje
 * borra en cadena sus unidades y los objetivos de aprendizaje de esas
 * unidades. `essay_strand_distribution.strand_id` (0016) también es
 * `cascade` directo sobre el eje (borra la cuota configurada en ensayos, NO
 * los `essay_questions`/`essay_attempts` ya generados/rendidos, que
 * referencian `question_id`, no `strand_id`).
 *
 * `questions.learning_objective_id` (0011) es `on delete set null`: las
 * preguntas de los objetivos borrados NO se eliminan, solo pierden ese
 * vínculo. Se informa aparte como `note`.
 */
export async function getStrandDeleteImpact(
  strandId: string
): Promise<DeleteImpact> {
  const supabase = await createClient();
  const { data: units } = await supabase
    .from("units")
    .select("id")
    .eq("strand_id", strandId);
  const unitIds = (units ?? []).map((u) => u.id);

  let objectiveIds: string[] = [];
  if (unitIds.length > 0) {
    const { data: objectives } = await supabase
      .from("learning_objectives")
      .select("id")
      .in("unit_id", unitIds);
    objectiveIds = (objectives ?? []).map((o) => o.id);
  }

  const [essayStrandDist, unlinkedQuestions] = await Promise.all([
    supabase
      .from("essay_strand_distribution")
      .select("id", { count: "exact", head: true })
      .eq("strand_id", strandId),
    objectiveIds.length > 0
      ? supabase
          .from("questions")
          .select("id", { count: "exact", head: true })
          .in("learning_objective_id", objectiveIds)
      : Promise.resolve({ count: 0 }),
  ]);

  const unlinkedQuestionsCount = unlinkedQuestions.count ?? 0;

  return {
    counts: [
      { label: "unidades", value: unitIds.length },
      { label: "objetivos de aprendizaje", value: objectiveIds.length },
      {
        label: "distribuciones de ensayo por eje configuradas",
        value: essayStrandDist.count ?? 0,
      },
    ],
    note:
      unlinkedQuestionsCount > 0
        ? `Además, ${unlinkedQuestionsCount} pregunta(s) quedarán sin objetivo de aprendizaje asociado (no se eliminan).`
        : null,
  };
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
  const { data, error } = await supabase
    .from("units")
    .select("*, strands(name, subjects(name))")
    .order("order_index");
  if (error) console.error("listUnits falló:", error.message);
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

/**
 * `learning_objectives.unit_id` (0010) es `on delete cascade`. Igual que en
 * `getStrandDeleteImpact`, las preguntas que apuntaban a esos objetivos solo
 * pierden el vínculo (`questions.learning_objective_id` es `set null`,
 * 0011), no se eliminan.
 */
export async function getUnitDeleteImpact(unitId: string): Promise<DeleteImpact> {
  const supabase = await createClient();
  const { data: objectives } = await supabase
    .from("learning_objectives")
    .select("id")
    .eq("unit_id", unitId);
  const objectiveIds = (objectives ?? []).map((o) => o.id);

  let unlinkedQuestionsCount = 0;
  if (objectiveIds.length > 0) {
    const { count } = await supabase
      .from("questions")
      .select("id", { count: "exact", head: true })
      .in("learning_objective_id", objectiveIds);
    unlinkedQuestionsCount = count ?? 0;
  }

  return {
    counts: [
      { label: "objetivos de aprendizaje", value: objectiveIds.length },
    ],
    note:
      unlinkedQuestionsCount > 0
        ? `Además, ${unlinkedQuestionsCount} pregunta(s) quedarán sin objetivo de aprendizaje asociado (no se eliminan).`
        : null,
  };
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
  const { data, error } = await supabase
    .from("skills")
    .select("*")
    .order("name");
  if (error) console.error("listSkills falló:", error.message);
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

/**
 * `learning_objective_skills.skill_id` (0010) es `on delete cascade`: borra
 * la asociación (fila puente), no el objetivo de aprendizaje en sí.
 * `questions.skill_id` (0011) es `on delete set null`: las preguntas que
 * usan esta habilidad solo pierden el vínculo, no se eliminan.
 */
export async function getSkillDeleteImpact(skillId: string): Promise<DeleteImpact> {
  const supabase = await createClient();
  const [links, unlinkedQuestions] = await Promise.all([
    supabase
      .from("learning_objective_skills")
      .select("learning_objective_id", { count: "exact", head: true })
      .eq("skill_id", skillId),
    supabase
      .from("questions")
      .select("id", { count: "exact", head: true })
      .eq("skill_id", skillId),
  ]);
  const unlinkedQuestionsCount = unlinkedQuestions.count ?? 0;

  return {
    counts: [
      {
        label: "vínculos con objetivos de aprendizaje",
        value: links.count ?? 0,
      },
    ],
    note:
      unlinkedQuestionsCount > 0
        ? `Además, ${unlinkedQuestionsCount} pregunta(s) quedarán sin esta habilidad asociada (no se eliminan).`
        : null,
  };
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
  const { data, error } = await supabase
    .from("learning_objectives")
    .select(
      "*, units(name, strands(name, subjects(name))), levels(name, education_type, programs(code, curriculum_type)), learning_objective_skills(skill_id, skills(name))"
    )
    .order("order_index");
  if (error) console.error("listLearningObjectives falló:", error.message);
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

/**
 * Tres tablas cascada real sobre un objetivo de aprendizaje:
 * `learning_objective_skills.learning_objective_id` (0010, borra el
 * vínculo con habilidades), `essay_objectives.learning_objective_id` (0012,
 * borra la CUOTA configurada en un ensayo para este objetivo — no borra
 * `essay_questions` ni `essay_attempts`, que no referencian objetivos
 * directamente) y `essential_knowledge_learning_objectives.learning_objective_id`
 * (0014, borra el vínculo con conocimientos esenciales).
 * `questions.learning_objective_id` (0011) es `on delete set null`: las
 * preguntas que usan este objetivo solo pierden el vínculo.
 */
export async function getLearningObjectiveDeleteImpact(
  objectiveId: string
): Promise<DeleteImpact> {
  const supabase = await createClient();
  const [skillLinks, essayObjectives, essentialKnowledgeLinks, unlinkedQuestions] =
    await Promise.all([
      supabase
        .from("learning_objective_skills")
        .select("skill_id", { count: "exact", head: true })
        .eq("learning_objective_id", objectiveId),
      supabase
        .from("essay_objectives")
        .select("id", { count: "exact", head: true })
        .eq("learning_objective_id", objectiveId),
      supabase
        .from("essential_knowledge_learning_objectives")
        .select("essential_knowledge_id", { count: "exact", head: true })
        .eq("learning_objective_id", objectiveId),
      supabase
        .from("questions")
        .select("id", { count: "exact", head: true })
        .eq("learning_objective_id", objectiveId),
    ]);
  const unlinkedQuestionsCount = unlinkedQuestions.count ?? 0;

  return {
    counts: [
      { label: "vínculos con habilidades", value: skillLinks.count ?? 0 },
      {
        label: "configuraciones de distribución en ensayos",
        value: essayObjectives.count ?? 0,
      },
      {
        label: "vínculos con conocimientos esenciales",
        value: essentialKnowledgeLinks.count ?? 0,
      },
    ],
    note:
      unlinkedQuestionsCount > 0
        ? `Además, ${unlinkedQuestionsCount} pregunta(s) quedarán sin este objetivo de aprendizaje asociado (no se eliminan).`
        : null,
  };
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
