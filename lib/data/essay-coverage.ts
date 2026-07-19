"use server";

// Dominio: Contenido y preguntas — validación de disponibilidad del banco de
// preguntas antes de publicar un ensayo (EPJA, Etapa 1).
//
// No reimplementa la selección: corre `selectEssayQuestions` en modo "en
// seco" (no persiste nada en `essay_questions`) contra el MISMO pool
// filtrado que debería usarse para un ensayo publicado —
// `is_active=true` + `validation_status='approved_for_exam'` +
// `review_status='aprobado'` (este último ya lo filtra
// `selectEssayQuestions`) + la versión curricular del ensayo, si tiene una
// asignada — para saber si HOY hay banco suficiente, sin consumir ninguna
// pregunta real. `generateEssay` (lib/data/essays.ts) sigue usando el pool
// amplio (incluye preguntas en revisión) porque ahí el admin sí quiere ver
// qué pasaría con el estado actual del banco, no solo con lo publicable.

import { createClient } from "@/lib/supabase/server";
import { selectEssayQuestions, type MissingRequirement } from "./essay-selection";
import {
  buildCandidatePool,
  buildNameMaps,
  resolveEssayRequirements,
  type EssayRow,
} from "./essays";

export type EssayCoverageStatus =
  | "not_ready"
  | "insufficient_questions"
  | "incomplete_coverage"
  | "ready"
  | "published";

export type EssayCoverageReport = {
  status: EssayCoverageStatus;
  totalRequired: number;
  totalAvailable: number;
  missing: MissingRequirement[];
  reason?: string;
};

/**
 * Calcula si un ensayo tiene banco suficiente para publicarse HOY. No
 * modifica nada (ni `essay_questions` ni `essays.coverage_status`) — quien
 * llama decide si cachear el resultado (ver `updateEssayStatus` en
 * `essays.ts`, que sí lo persiste al intentar publicar).
 */
export async function checkEssayAvailability(
  essayId: string
): Promise<EssayCoverageReport> {
  const supabase = await createClient();
  const { data: essay } = await supabase
    .from("essays")
    .select("id, level_id, essay_type, total_questions, framework_id, target_student_id, status")
    .eq("id", essayId)
    .single();

  if (!essay || !essay.level_id || !essay.total_questions || essay.total_questions <= 0) {
    return {
      status: "not_ready",
      totalRequired: essay?.total_questions ?? 0,
      totalAvailable: 0,
      missing: [],
      reason: "El ensayo no tiene curso o cantidad de preguntas configurada.",
    };
  }

  const essayRow: EssayRow = {
    id: essay.id,
    level_id: essay.level_id,
    essay_type: essay.essay_type,
    total_questions: essay.total_questions,
    framework_id: essay.framework_id,
    target_student_id: essay.target_student_id,
  };

  const requirements = await resolveEssayRequirements(essayRow);
  if (requirements.error !== null) {
    return {
      status: "not_ready",
      totalRequired: essay.total_questions,
      totalAvailable: 0,
      missing: [],
      reason: requirements.error,
    };
  }

  const [candidates, names] = await Promise.all([
    buildCandidatePool(essay.level_id, {
      requirePublishable: true,
      frameworkId: essay.framework_id,
    }),
    buildNameMaps(essayId),
  ]);

  const result = selectEssayQuestions({
    candidates,
    totalQuestions: essay.total_questions,
    subjectRequirements: requirements.subjectRequirements,
    strandRequirements: requirements.strandRequirements,
    objectiveRequirements: requirements.objectiveRequirements,
    difficultyRequirements: requirements.difficultyRequirements,
    subjectNames: names.subjectNames,
    strandNames: names.strandNames,
    objectiveNames: names.objectiveNames,
  });

  const totalAvailable = candidates.length;

  let status: EssayCoverageStatus;
  if (result.selected.length < essay.total_questions) {
    status = "insufficient_questions";
  } else if (result.missing.length > 0) {
    status = "incomplete_coverage";
  } else if (essay.status === "publicado") {
    status = "published";
  } else {
    status = "ready";
  }

  return {
    status,
    totalRequired: essay.total_questions,
    totalAvailable,
    missing: result.missing,
  };
}
