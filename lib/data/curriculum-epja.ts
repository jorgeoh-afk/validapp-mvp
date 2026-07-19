"use server";

// Dominio: Contenido y preguntas — panel admin mínimo de currículum EPJA
// (Etapa 1: solo lectura + "marcar verificado"). Reutiliza
// `checkEssayAvailability` (lib/data/essay-coverage.ts) para la cobertura de
// ensayos; aquí se agrega la vista de versiones curriculares y trazabilidad
// que antes no existía en ningún panel admin.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type CurriculumFramework = {
  id: string;
  name: string;
  decree_number: string;
  decree_year: number;
  exam_year: number;
  exam_period: string;
  status: string;
  source_name: string | null;
  source_url: string | null;
  verified_at: string | null;
};

export async function listCurriculumFrameworks(): Promise<CurriculumFramework[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("curriculum_frameworks")
    .select(
      "id, name, decree_number, decree_year, exam_year, exam_period, status, source_name, source_url, verified_at"
    )
    .order("exam_year", { ascending: false })
    .order("exam_period");
  return data ?? [];
}

export type FrameworkSubjectRow = {
  id: string;
  official_name: string;
  is_examined: boolean;
  levels: { name: string } | null;
  subjects: { name: string } | null;
};

export async function listFrameworkSubjects(
  frameworkId: string
): Promise<FrameworkSubjectRow[]> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("framework_subjects")
    .select("id, official_name, is_examined, levels(name), subjects(name)")
    .eq("framework_id", frameworkId)
    .order("sort_order");
  return (data ?? []) as unknown as FrameworkSubjectRow[];
}

export type FrameworkCoverage = {
  strandsCount: number;
  unitsCount: number;
  objectivesCount: number;
  objectivesWithSourceCount: number;
  questionsCount: number;
  questionsApprovedForExamCount: number;
};

/**
 * Cobertura de trazabilidad de una versión curricular: cuántos nodos tienen
 * fuente registrada y cuántas preguntas están realmente listas para
 * publicarse (approved_for_exam + is_active), sin repetir la lógica de
 * `checkEssayAvailability` (que es por ensayo, no por versión curricular).
 */
export async function getFrameworkCoverage(
  frameworkId: string
): Promise<FrameworkCoverage> {
  const supabase = await createClient();
  const [strands, units, objectives, questions] = await Promise.all([
    supabase
      .from("strands")
      .select("id", { count: "exact", head: true })
      .eq("framework_id", frameworkId),
    supabase
      .from("units")
      .select("id", { count: "exact", head: true })
      .eq("framework_id", frameworkId),
    supabase
      .from("learning_objectives")
      .select("id, source_id", { count: "exact" })
      .eq("framework_id", frameworkId),
    supabase
      .from("questions")
      .select("id, validation_status, is_active", { count: "exact" })
      .eq("framework_id", frameworkId),
  ]);

  const objectiveRows = objectives.data ?? [];
  const questionRows = questions.data ?? [];

  return {
    strandsCount: strands.count ?? 0,
    unitsCount: units.count ?? 0,
    objectivesCount: objectives.count ?? 0,
    objectivesWithSourceCount: objectiveRows.filter((o) => o.source_id != null).length,
    questionsCount: questions.count ?? 0,
    questionsApprovedForExamCount: questionRows.filter(
      (q) => q.validation_status === "approved_for_exam" && q.is_active
    ).length,
  };
}

/**
 * Marca una versión curricular como `verified`. El cambio de `status` ya
 * queda auditado automáticamente por el trigger `curriculum_frameworks_audit`
 * (0020), así que esta acción no necesita insertar en `audit_log` a mano.
 * Mismo patrón que `updateEssayStatus`/`deleteEssay` (essays.ts): form action
 * simple sin `useActionState`, sin estado de error propio.
 */
export async function markFrameworkVerified(formData: FormData): Promise<void> {
  const id = String(formData.get("id") ?? "");
  if (!id) return;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return;

  await supabase
    .from("curriculum_frameworks")
    .update({ status: "verified", verified_at: new Date().toISOString(), verified_by: user.id })
    .eq("id", id);

  revalidatePath("/admin/curriculum-epja");
}
