"use server";

import { createClient } from "@/lib/supabase/server";

export type LessonStatus = "bloqueada" | "disponible" | "completada";

export type PathLesson = {
  id: string;
  title: string;
  order_index: number;
  levels: { name: string; order_index: number } | null;
  status: LessonStatus;
};

export async function getLearningPath(
  subjectId: string
): Promise<PathLesson[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const { data: lessons } = await supabase
    .from("lessons")
    .select("id, title, order_index, levels(name, order_index)")
    .eq("subject_id", subjectId)
    .returns<
      {
        id: string;
        title: string;
        order_index: number;
        levels: { name: string; order_index: number } | null;
      }[]
    >();

  const sortedLessons = (lessons ?? []).slice().sort((a, b) => {
    const levelDiff = (a.levels?.order_index ?? 0) - (b.levels?.order_index ?? 0);
    return levelDiff !== 0 ? levelDiff : a.order_index - b.order_index;
  });

  const { data: progressRows } = await supabase
    .from("lesson_progress")
    .select("lesson_id")
    .eq("student_id", user.id);
  const completedIds = new Set((progressRows ?? []).map((r) => r.lesson_id));

  const { data: diagnostic } = await supabase
    .from("diagnostics")
    .select("estimated_level:levels!estimated_level_id(order_index)")
    .eq("student_id", user.id)
    .eq("subject_id", subjectId)
    .order("completed_at", { ascending: false })
    .limit(1)
    .maybeSingle()
    .returns<{ estimated_level: { order_index: number } | null }>();

  const estimatedOrder = diagnostic?.estimated_level?.order_index;

  let startIndex = 0;
  if (typeof estimatedOrder === "number") {
    const idx = sortedLessons.findIndex(
      (l) => (l.levels?.order_index ?? 0) >= estimatedOrder
    );
    startIndex = idx === -1 ? sortedLessons.length : idx;
  }

  let previousUnlocked = true;
  return sortedLessons.map((lesson, index) => {
    let status: LessonStatus;
    if (completedIds.has(lesson.id)) {
      status = "completada";
    } else if (index < startIndex) {
      status = "completada";
    } else if (previousUnlocked) {
      status = "disponible";
    } else {
      status = "bloqueada";
    }
    previousUnlocked = status === "completada" || status === "disponible";
    return { ...lesson, status };
  });
}

// ---------- Resumen para el panel del estudiante ----------

export type SubjectSummary = {
  id: string;
  name: string;
  totalLessons: number;
  completedLessons: number;
  percent: number;
  nextLessonId: string | null;
  nextLessonTitle: string | null;
};

export type NextActivity = {
  subjectId: string;
  subjectName: string;
  lessonId: string;
  lessonTitle: string;
  levelName: string | null;
  questionCount: number;
  /**
   * Duración y dificultad son estimaciones calculadas en el cliente a partir
   * de la cantidad de preguntas de la lección. El modelo de datos aún no
   * guarda estos valores; conectar cuando `lessons` incorpore campos reales
   * de duración/dificultad.
   */
  estimatedMinutes: number;
  difficultyLabel: "Introductorio" | "Intermedio" | "Avanzado";
} | null;

export type DashboardSummary = {
  studentName: string | null;
  targetLevel: string | null;
  subjects: SubjectSummary[];
  totalLessons: number;
  completedLessons: number;
  overallPercent: number;
  questionsAnswered: number;
  correctAnswers: number;
  accuracyPercent: number | null;
  diagnosticsCount: number;
  hasAnyDiagnostic: boolean;
  nextActivity: NextActivity;
};

export async function getDashboardSummary(): Promise<DashboardSummary | null> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, target_level")
    .eq("id", user.id)
    .maybeSingle();

  const { data: subjects } = await supabase
    .from("subjects")
    .select("id, name")
    .order("name");

  const { data: diagnostics, count: diagnosticsCount } = await supabase
    .from("diagnostics")
    .select("id", { count: "exact" })
    .eq("student_id", user.id);

  const { data: lessonProgressRows } = await supabase
    .from("lesson_progress")
    .select("score, total_questions")
    .eq("student_id", user.id);

  const questionsAnswered = (lessonProgressRows ?? []).reduce(
    (sum, row) => sum + (row.total_questions ?? 0),
    0
  );
  const correctAnswers = (lessonProgressRows ?? []).reduce(
    (sum, row) => sum + (row.score ?? 0),
    0
  );

  const subjectPaths = await Promise.all(
    (subjects ?? []).map(async (subject) => {
      const path = await getLearningPath(subject.id);
      return { subject, path };
    })
  );

  const subjectSummaries: SubjectSummary[] = subjectPaths.map(
    ({ subject, path }) => {
      const totalLessons = path.length;
      const completedLessons = path.filter(
        (l) => l.status === "completada"
      ).length;
      const nextLesson = path.find((l) => l.status === "disponible") ?? null;
      return {
        id: subject.id,
        name: subject.name,
        totalLessons,
        completedLessons,
        percent:
          totalLessons > 0
            ? Math.round((completedLessons / totalLessons) * 100)
            : 0,
        nextLessonId: nextLesson?.id ?? null,
        nextLessonTitle: nextLesson?.title ?? null,
      };
    }
  );

  const totalLessons = subjectSummaries.reduce(
    (sum, s) => sum + s.totalLessons,
    0
  );
  const completedLessons = subjectSummaries.reduce(
    (sum, s) => sum + s.completedLessons,
    0
  );

  const nextSubjectWithActivity = subjectPaths.find(
    ({ path }) => path.some((l) => l.status === "disponible")
  );
  let nextActivity: NextActivity = null;
  if (nextSubjectWithActivity) {
    const lesson = nextSubjectWithActivity.path.find(
      (l) => l.status === "disponible"
    )!;
    // La lectura directa de `questions` está restringida a administradores
    // (migración 0019, endurecimiento de RLS): se reutiliza la función
    // security-definer `get_lesson_questions` (misma que usa
    // `lib/data/lessons.ts` para la práctica) solo para contar cuántas
    // preguntas tiene la próxima lección disponible.
    // El cliente de Supabase no tiene un tipo `Database` generado, así que
    // `.rpc(...)` no infiere la forma de la fila por sí solo; se castea
    // desde `unknown` (solo se necesita `.length`, no el contenido).
    const { data: nextLessonQuestionsRaw } = await supabase.rpc("get_lesson_questions", {
      p_lesson_id: lesson.id,
    });
    const nextLessonQuestions = nextLessonQuestionsRaw as unknown[] | null;
    const total = nextLessonQuestions?.length ?? 0;
    nextActivity = {
      subjectId: nextSubjectWithActivity.subject.id,
      subjectName: nextSubjectWithActivity.subject.name,
      lessonId: lesson.id,
      lessonTitle: lesson.title,
      levelName: lesson.levels?.name ?? null,
      questionCount: total,
      estimatedMinutes: Math.max(5, total * 2 + 3),
      difficultyLabel:
        (lesson.levels?.order_index ?? 0) <= 0
          ? "Introductorio"
          : (lesson.levels?.order_index ?? 0) === 1
            ? "Intermedio"
            : "Avanzado",
    };
  }

  return {
    studentName: profile?.full_name ?? null,
    targetLevel: profile?.target_level ?? null,
    subjects: subjectSummaries,
    totalLessons,
    completedLessons,
    overallPercent:
      totalLessons > 0
        ? Math.round((completedLessons / totalLessons) * 100)
        : 0,
    questionsAnswered,
    correctAnswers,
    accuracyPercent:
      questionsAnswered > 0
        ? Math.round((correctAnswers / questionsAnswered) * 100)
        : null,
    diagnosticsCount: diagnosticsCount ?? diagnostics?.length ?? 0,
    hasAnyDiagnostic: (diagnosticsCount ?? 0) > 0,
    nextActivity,
  };
}
