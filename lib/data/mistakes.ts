"use server";

// Dominio: Resultados y progreso. Preguntas que el estudiante falló en
// diagnósticos y ensayos, para la pantalla "Revisar errores" (/errores).
// Ver la migración `0027_student_mistakes.sql` para el porqué de la función
// RPC `get_student_mistakes` (RLS de `questions` no permite lectura directa
// desde una sesión de estudiante desde la migración 0019).

import { createClient } from "@/lib/supabase/server";

// El cliente de Supabase se crea sin un tipo `Database` generado (ver
// `lib/supabase/server.ts`), así que `.rpc(...)` no puede inferir la forma
// de la fila; se castea explícitamente, mismo criterio que
// `lib/data/essay-attempts.ts`.
function asRpcRows<T>(data: unknown): T[] | null {
  return (data as T[] | null) ?? null;
}

type StudentMistakeRow = {
  source: "diagnostico" | "ensayo";
  source_id: string;
  answered_at: string;
  subject_id: string;
  subject_name: string;
  question_id: string;
  prompt: string;
  choices: string[];
  selected_index: number | null;
  correct_index: number;
  explanation: string | null;
};

export type StudentMistake = {
  source: "diagnostico" | "ensayo";
  sourceId: string;
  answeredAt: string;
  subjectId: string;
  subjectName: string;
  questionId: string;
  prompt: string;
  choices: string[];
  selectedIndex: number | null;
  correctIndex: number;
  explanation: string | null;
};

export async function getStudentMistakes(): Promise<StudentMistake[]> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return [];

  const { data, error } = await supabase.rpc("get_student_mistakes");
  if (error) {
    console.error("getStudentMistakes falló:", error.message);
    return [];
  }

  const rows = asRpcRows<StudentMistakeRow>(data) ?? [];
  return rows.map((row) => ({
    source: row.source,
    sourceId: row.source_id,
    answeredAt: row.answered_at,
    subjectId: row.subject_id,
    subjectName: row.subject_name,
    questionId: row.question_id,
    prompt: row.prompt,
    choices: row.choices,
    selectedIndex: row.selected_index,
    correctIndex: row.correct_index,
    explanation: row.explanation,
  }));
}
