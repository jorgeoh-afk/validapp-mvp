"use server";

// Dominio: agregación de solo lectura para el "Resumen" del panel
// administrativo (Etapa 2 del rediseño del dashboard admin). Esta función NO
// ejecuta consultas nuevas por su cuenta: combina y resume los datos que ya
// exponen los módulos de datos existentes (contenido, cobertura curricular y
// resultados), evitando duplicar lógica de queries. Es de solo lectura y no
// modifica ningún dato.

import {
  listSubjects,
  listLevels,
  listLessons,
  listQuestions,
} from "@/lib/data/content";
import { getCoverageReport } from "@/lib/data/essays";
import { getStudentResults } from "@/lib/data/admin-results";

const QUESTION_REVIEW_STATUSES = [
  "borrador",
  "en_revision",
  "aprobado",
  "archivado",
] as const;

export type QuestionReviewStatus = (typeof QUESTION_REVIEW_STATUSES)[number];

export type AdminDashboardSummary = {
  studentsRegistered: number;
  subjectsCount: number;
  levelsCount: number;
  lessonsCount: number;
  /** Asignaturas que todavía no tienen ninguna lección cargada. */
  subjectsWithoutLessons: { id: string; name: string }[];
  questionsTotal: number;
  questionsByStatus: Record<QuestionReviewStatus, number>;
  /** Preguntas sin retroalimentación escrita para el estudiante. */
  questionsMissingExplanation: number;
  /** Preguntas sin objetivo de aprendizaje asociado (afectan la cobertura). */
  questionsMissingObjective: number;
  /** Suma de diagnósticos rendidos por todos los estudiantes (histórico). */
  diagnosticsCompleted: number;
  coverage: {
    objectivesWithoutQuestionsCount: number;
    objectivesWithInsufficientCoverageCount: number;
    pendingReviewCount: number;
  };
};

export async function getAdminDashboardSummary(): Promise<AdminDashboardSummary> {
  const [subjects, levels, lessons, questions, coverage, students] =
    await Promise.all([
      listSubjects(),
      listLevels(),
      listLessons(),
      listQuestions(),
      getCoverageReport(),
      getStudentResults(),
    ]);

  const questionsByStatus = QUESTION_REVIEW_STATUSES.reduce(
    (acc, status) => {
      acc[status] = 0;
      return acc;
    },
    {} as Record<QuestionReviewStatus, number>
  );

  let questionsMissingExplanation = 0;
  let questionsMissingObjective = 0;
  for (const q of questions) {
    const status = (q.review_status ?? "borrador") as QuestionReviewStatus;
    if (status in questionsByStatus) questionsByStatus[status] += 1;
    if (!q.explanation || !q.explanation.trim()) {
      questionsMissingExplanation += 1;
    }
    if (!q.learning_objective_id) questionsMissingObjective += 1;
  }

  const subjectIdsWithLessons = new Set(lessons.map((l) => l.subject_id));
  const subjectsWithoutLessons = subjects
    .filter((s) => !subjectIdsWithLessons.has(s.id))
    .map((s) => ({ id: s.id, name: s.name }));

  const diagnosticsCompleted = students.reduce(
    (sum, s) => sum + s.diagnosticsCount,
    0
  );

  return {
    studentsRegistered: students.length,
    subjectsCount: subjects.length,
    levelsCount: levels.length,
    lessonsCount: lessons.length,
    subjectsWithoutLessons,
    questionsTotal: questions.length,
    questionsByStatus,
    questionsMissingExplanation,
    questionsMissingObjective,
    diagnosticsCompleted,
    coverage: {
      objectivesWithoutQuestionsCount:
        coverage.objectivesWithoutQuestions.length,
      objectivesWithInsufficientCoverageCount:
        coverage.objectivesWithInsufficientCoverage.length,
      pendingReviewCount: coverage.pendingReviewCount,
    },
  };
}
