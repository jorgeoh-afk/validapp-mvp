"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { getLearningPath } from "@/lib/data/progress";
import { recordLessonCompleted } from "@/lib/data/gamification";

export async function getLesson(lessonId: string) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Restricción total por inscripción (mismo criterio que `getLearningPath`
  // en `lib/data/progress.ts`): un estudiante no debe poder VER el contenido
  // de una lección de otro nivel, aunque conozca su URL directamente. Si el
  // perfil todavía no tiene nivel objetivo asignado (no debería llegar aquí
  // -- el wizard de `/perfil` y el gate de UI lo exigen antes -- pero se es
  // defensivo), no se muestra ninguna lección.
  const { data: profile } = await supabase
    .from("profiles")
    .select("target_level_id")
    .eq("id", user.id)
    .maybeSingle();
  const targetLevelId = profile?.target_level_id ?? null;
  if (!targetLevelId) return null;

  const { data } = await supabase
    .from("lessons")
    .select("id, title, content, subject_id, level_id, levels(name)")
    .eq("id", lessonId)
    .single()
    .returns<{
      id: string;
      title: string;
      content: string;
      subject_id: string;
      level_id: string;
      levels: { name: string } | null;
    }>();

  if (!data) return null;
  // La página que consume esta función (`app/(estudiante)/leccion/[lessonId]/
  // page.tsx`) ya hace `if (!lesson) notFound();`: devolver `null` aquí basta
  // para que un intento de ver una lección de otro nivel resulte en 404, sin
  // necesidad de tocar ese archivo.
  if (data.level_id !== targetLevelId) return null;

  return data;
}

// ---------- Formas de retorno de las funciones RPC de la migración 0019 ----------
// El cliente de Supabase se crea sin un tipo `Database` generado (ver
// `lib/supabase/server.ts`), así que `.rpc(...)` no puede inferir la forma
// de la fila por sí solo. `.returns<>()`/`.overrideTypes<>()` no sirven aquí
// porque, sin schema de `Database`, esta versión de postgrest-js no puede
// determinar si el resultado de `.rpc()` es un arreglo o un solo objeto y
// devuelve un tipo de error de compilación en vez de inferir. Se usa en su
// lugar un cast explícito desde `unknown`.
type LessonQuestionRow = { id: string; prompt: string; choices: string[] };
type GradePracticeQuestionRow = { is_correct: boolean; correct_index: number };
type GradeLessonPracticeRow = {
  question_id: string;
  prompt: string;
  choices: string[];
  correct_index: number;
  is_correct: boolean;
};

function asRpcRows<T>(data: unknown): T[] | null {
  return (data as T[] | null) ?? null;
}
function asRpcRow<T>(data: unknown): T | null {
  return (data as T | null) ?? null;
}

export async function getLessonQuestions(lessonId: string) {
  const supabase = await createClient();
  // La lectura directa de `questions` está restringida a administradores
  // (migración 0019); esta función security-definer devuelve las preguntas
  // de práctica sin `correct_index`.
  const { data } = await supabase.rpc("get_lesson_questions", {
    p_lesson_id: lessonId,
  });
  return asRpcRows<LessonQuestionRow>(data) ?? [];
}

export type CheckPracticeAnswerResult =
  | { error: string }
  | { correct: boolean; correctIndex: number };

export async function checkPracticeAnswer(
  questionId: string,
  selectedIndex: number
): Promise<CheckPracticeAnswerResult> {
  const supabase = await createClient();
  // Compara internamente contra `correct_index` dentro de la base de datos
  // y solo devuelve el resultado, ya calificado.
  const { data: questionRaw, error } = await supabase
    .rpc("grade_practice_question", {
      p_question_id: questionId,
      p_selected_index: selectedIndex,
    })
    .maybeSingle();
  const question = asRpcRow<GradePracticeQuestionRow>(questionRaw);

  if (error || !question) return { error: "Pregunta no encontrada." };

  return {
    correct: question.is_correct,
    correctIndex: question.correct_index,
  };
}

export type PracticeResultQuestion = {
  id: string;
  prompt: string;
  choices: string[];
  selectedIndex: number;
  correctIndex: number;
  isCorrect: boolean;
};

export type PracticeState =
  | { error: string }
  | { score: number; total: number; results: PracticeResultQuestion[] }
  | null;

export async function submitLessonPractice(
  _prevState: PracticeState,
  formData: FormData
): Promise<PracticeState> {
  const lessonId = String(formData.get("lessonId") ?? "");
  const questionIds = String(formData.get("questionIds") ?? "")
    .split(",")
    .filter(Boolean);

  if (!lessonId) return { error: "Lección inválida." };

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Debes iniciar sesión." };

  const lesson = await getLesson(lessonId);
  if (!lesson) return { error: "Lección no encontrada." };

  // `getLearningPath` ahora filtra por el nivel inscrito del estudiante
  // (`profiles.target_level_id`, ver `lib/data/progress.ts`): una lección de
  // otro nivel ya NO aparece en `path` en absoluto, así que `status` queda
  // `undefined` en vez de "bloqueada". Si no se tratara ese caso aparte, la
  // guarda de abajo dejaría pasar la práctica de una lección fuera del nivel
  // inscrito (bug de seguridad introducido por el filtro de nivel, no
  // presente antes). Se bloquea igual que una lección bloqueada, sin
  // distinguir el motivo exacto (no pertenece a la asignatura, no existe, o
  // es de otro nivel) para no revelar más de lo necesario.
  const path = await getLearningPath(lesson.subject_id);
  const status = path.find((l) => l.id === lessonId)?.status;
  if (!status || status === "bloqueada") {
    return { error: "Esta lección todavía está bloqueada." };
  }

  const results: PracticeResultQuestion[] = [];
  let score = 0;

  if (questionIds.length > 0) {
    // `grade_lesson_practice_questions` compara internamente contra
    // `correct_index` y devuelve el detalle ya calificado (prompt/choices/
    // correct_index se revelan recién en esta respuesta, igual que antes).
    const { data: gradedRaw } = await supabase.rpc("grade_lesson_practice_questions", {
      p_question_ids: questionIds,
      p_selected_indexes: questionIds.map((id) => {
        const raw = formData.get(`answer_${id}`);
        return raw === null ? -1 : Number(raw);
      }),
    });
    const graded = asRpcRows<GradeLessonPracticeRow>(gradedRaw);

    for (const q of graded ?? []) {
      const selectedRaw = formData.get(`answer_${q.question_id}`);
      const selectedIndex = selectedRaw === null ? -1 : Number(selectedRaw);
      if (q.is_correct) score += 1;
      results.push({
        id: q.question_id,
        prompt: q.prompt,
        choices: q.choices,
        selectedIndex,
        correctIndex: q.correct_index,
        isCorrect: q.is_correct,
      });
    }
  }

  await supabase.from("lesson_progress").upsert(
    {
      student_id: user.id,
      lesson_id: lessonId,
      score,
      total_questions: results.length,
    },
    { onConflict: "student_id,lesson_id" }
  );

  if (status !== "completada") {
    await recordLessonCompleted(user.id, lesson.subject_id);
  }

  revalidatePath(`/ruta/${lesson.subject_id}`);
  revalidatePath("/panel");
  return { score, total: results.length, results };
}
