"use server";

// Dominio: Contenido y preguntas — importador de bancos de preguntas EPJA
// generados (data/epja/exams/<framework>/<level>/<subject>/question-bank.json)
// hacia `questions`. Reutiliza los mismos validadores que
// data/epja/exams/question-banks.test.ts (lib/data/question-validators.ts)
// para no duplicar criterio de calidad entre el test y el importador real.
//
// Idempotente: antes de insertar cada pregunta, calcula su content_hash y
// la compara contra las ya existentes en `questions` para esa combinación
// subject+level+framework -- si ya existe (exacta), la omite. Transaccional
// "best effort": Supabase-JS no expone transacciones multi-fila desde el
// cliente, así que cada pregunta se inserta de forma independiente y los
// errores se acumulan por fila en vez de abortar todo el lote.
//
// Estado inicial obligatorio (regla del usuario, ver 0023): NUNCA
// `approved_for_exam` ni `pedagogically_reviewed` -- una pregunta recién
// generada por IA entra como `ai_generated_review_required` (si tuvo algún
// warning) o `automatically_validated` (si no tuvo ningún issue), y el
// trigger `questions_prevent_ai_self_approval` (0023) bloquea a nivel de
// base de datos cualquier intento de saltar directo a un estado de
// revisión humana.

import { readFileSync } from "node:fs";
import path from "node:path";
import { createClient } from "@/lib/supabase/server";
import {
  validateQuestion,
  computeContentHash,
  findDuplicate,
  type ValidatableQuestion,
} from "./question-validators";
import { isWellFormedBankQuestion, type EpjaBankQuestion } from "./epja-question-bank-schema";

export type ImportQuestionBankParams = {
  /** Ruta relativa desde la raíz del repo, p. ej. "data/epja/exams/ds-257-2009/primer-nivel-medio/matematica/question-bank.json". */
  filePath: string;
  decreeNumber: string;
  decreeYear: number;
  examYear: number;
  examPeriod: "primer_periodo" | "segundo_periodo";
  levelName: string;
  subjectName: string;
  dryRun: boolean;
};

export type ImportQuestionBankResult = {
  dryRun: boolean;
  total: number;
  wouldInsert: number;
  inserted: number;
  skippedDuplicate: number;
  failed: { localId: string; reason: string }[];
  markedAutomaticallyValidated: number;
  markedReviewRequired: number;
};

export async function importEpjaQuestionBank(
  params: ImportQuestionBankParams
): Promise<ImportQuestionBankResult> {
  const supabase = await createClient();

  const raw = JSON.parse(readFileSync(path.resolve(process.cwd(), params.filePath), "utf8"));
  if (!Array.isArray(raw)) {
    throw new Error(`${params.filePath} no contiene un arreglo de preguntas.`);
  }
  const bankQuestions = raw.filter(isWellFormedBankQuestion) as EpjaBankQuestion[];
  if (bankQuestions.length !== raw.length) {
    throw new Error(
      `${params.filePath}: ${raw.length - bankQuestions.length} fila(s) no tienen la forma esperada de EpjaBankQuestion.`
    );
  }

  const { data: framework } = await supabase
    .from("curriculum_frameworks")
    .select("id")
    .eq("decree_number", params.decreeNumber)
    .eq("decree_year", params.decreeYear)
    .eq("exam_year", params.examYear)
    .eq("exam_period", params.examPeriod)
    .single();
  if (!framework) {
    throw new Error(
      `No se encontró curriculum_frameworks para D.S. ${params.decreeNumber}/${params.decreeYear}, ${params.examYear} ${params.examPeriod}.`
    );
  }

  const { data: level } = await supabase
    .from("levels")
    .select("id")
    .eq("name", params.levelName)
    .single();
  if (!level) throw new Error(`No se encontró el nivel "${params.levelName}".`);

  const { data: subject } = await supabase
    .from("subjects")
    .select("id")
    .eq("name", params.subjectName)
    .single();
  if (!subject) throw new Error(`No se encontró la asignatura "${params.subjectName}".`);

  // Objetivos de aprendizaje disponibles para resolver objectiveShortName ->
  // learning_objective_id, acotados a este framework+nivel+asignatura.
  const { data: objectives } = await supabase
    .from("learning_objectives")
    .select("id, short_name, units(strand_id, strands(name, subject_id))")
    .eq("level_id", level.id)
    .eq("framework_id", framework.id);

  type ObjectiveRow = {
    id: string;
    short_name: string;
    units: { strand_id: string; strands: { name: string; subject_id: string } | null } | null;
  };
  const objectiveByKey = new Map<string, string>();
  for (const o of (objectives ?? []) as unknown as ObjectiveRow[]) {
    const strand = o.units?.strands ?? null;
    if (!strand || strand.subject_id !== subject.id) continue;
    objectiveByKey.set(`${strand.name}::${o.short_name}`, o.id);
  }

  // Preguntas ya existentes de esta combinación, para detectar duplicados
  // exactos/casi-exactos antes de insertar (idempotencia real, no solo "no
  // truena si se reintenta" -- evita duplicar contenido real).
  const { data: existingQuestions } = await supabase
    .from("questions")
    .select("id, prompt, content_hash")
    .eq("subject_id", subject.id)
    .eq("level_id", level.id)
    .eq("framework_id", framework.id);
  const existingForDedup = (existingQuestions ?? []).map((q) => ({
    id: q.id,
    prompt: q.prompt,
    contentHash: q.content_hash ?? computeContentHash(q.prompt),
  }));

  const result: ImportQuestionBankResult = {
    dryRun: params.dryRun,
    total: bankQuestions.length,
    wouldInsert: 0,
    inserted: 0,
    skippedDuplicate: 0,
    failed: [],
    markedAutomaticallyValidated: 0,
    markedReviewRequired: 0,
  };

  for (const q of bankQuestions) {
    const objectiveId = objectiveByKey.get(`${q.strandName}::${q.objectiveShortName}`);
    if (!objectiveId) {
      result.failed.push({
        localId: q.localId,
        reason: `No se pudo resolver el objetivo "${q.objectiveShortName}" del eje "${q.strandName}" para esta combinación (¿el seed curricular ya se aplicó?).`,
      });
      continue;
    }

    const validatable: ValidatableQuestion = {
      prompt: q.prompt,
      questionType: q.questionType,
      choices: q.choices ?? null,
      correctIndex: q.correctIndex ?? null,
      answerKey: q.answerKey ?? null,
      rubric: q.rubric ?? null,
      learningObjectiveId: objectiveId,
      subjectId: subject.id,
      levelId: level.id,
      frameworkId: framework.id,
    };
    const validation = validateQuestion(validatable);
    if (!validation.valid) {
      result.failed.push({
        localId: q.localId,
        reason: `Falló validación: ${validation.issues.map((i) => i.code).join(", ")}`,
      });
      continue;
    }

    const dup = findDuplicate(q.prompt, existingForDedup);
    if (dup?.kind === "exact") {
      result.skippedDuplicate += 1;
      continue;
    }
    // dup?.kind === "near": no se omite (podría ser una variante legítima
    // del mismo objetivo con distintos números), pero SÍ fuerza
    // ai_generated_review_required aunque no tenga otros warnings.
    const hasWarnings = validation.issues.length > 0 || dup?.kind === "near";

    result.wouldInsert += 1;
    if (params.dryRun) {
      if (hasWarnings) result.markedReviewRequired += 1;
      else result.markedAutomaticallyValidated += 1;
      continue;
    }

    const { error } = await supabase.from("questions").insert({
      subject_id: subject.id,
      level_id: level.id,
      prompt: q.prompt,
      choices: q.choices ?? null,
      correct_index: q.correctIndex ?? null,
      answer_key: q.answerKey ?? null,
      rubric: q.rubric ?? null,
      explanation: q.explanation,
      learning_objective_id: objectiveId,
      difficulty: q.difficulty,
      question_type: q.questionType,
      points: q.points ?? 1,
      estimated_seconds: q.estimatedSeconds ?? null,
      review_status: "en_revision",
      validation_status: hasWarnings ? "ai_generated_review_required" : "automatically_validated",
      is_active: true,
      framework_id: framework.id,
      source_type: "validapp_original",
      content_hash: computeContentHash(q.prompt),
      generated_at: new Date().toISOString(),
      generated_by: "claude-sonnet-5",
    });

    if (error) {
      result.failed.push({ localId: q.localId, reason: error.message });
      continue;
    }
    result.inserted += 1;
    if (hasWarnings) result.markedReviewRequired += 1;
    else result.markedAutomaticallyValidated += 1;
    // Se agrega al pool de dedup en memoria para detectar duplicados DENTRO
    // del mismo lote, no solo contra lo que ya había en la base.
    existingForDedup.push({ id: q.localId, prompt: q.prompt, contentHash: computeContentHash(q.prompt) });
  }

  return result;
}
