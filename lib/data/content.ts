"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type FormState = { error: string } | null;

// ---------- Asignaturas ----------

export async function listSubjects() {
  const supabase = await createClient();
  const { data } = await supabase.from("subjects").select("*").order("name");
  return data ?? [];
}

export async function upsertSubject(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  if (!name) return { error: "El nombre es obligatorio." };

  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("subjects").update({ name }).eq("id", id)
    : await supabase.from("subjects").insert({ name });

  if (error) return { error: error.message };
  revalidatePath("/admin/asignaturas");
  return null;
}

export async function deleteSubject(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("subjects").delete().eq("id", id);
  revalidatePath("/admin/asignaturas");
}

// ---------- Niveles ----------

export async function listLevels() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("levels")
    .select("*, programs(name), education_levels(name)")
    .order("order_index");
  return data ?? [];
}

export async function upsertLevel(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const name = String(formData.get("name") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);
  if (!name) return { error: "El nombre es obligatorio." };

  const supabase = await createClient();
  const { error } = id
    ? await supabase
        .from("levels")
        .update({ name, order_index: orderIndex })
        .eq("id", id)
    : await supabase.from("levels").insert({ name, order_index: orderIndex });

  if (error) return { error: error.message };
  revalidatePath("/admin/niveles");
  return null;
}

export async function deleteLevel(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("levels").delete().eq("id", id);
  revalidatePath("/admin/niveles");
}

// ---------- Lecciones ----------

export async function listLessons() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("lessons")
    .select("*, subjects(name), levels(name)")
    .order("order_index");
  return data ?? [];
}

export async function upsertLesson(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  const title = String(formData.get("title") ?? "").trim();
  const content = String(formData.get("content") ?? "").trim();
  const orderIndex = Number(formData.get("orderIndex") ?? 0);

  if (!subjectId || !levelId || !title) {
    return { error: "Asignatura, nivel y título son obligatorios." };
  }

  const record = {
    subject_id: subjectId,
    level_id: levelId,
    title,
    content,
    order_index: orderIndex,
  };

  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("lessons").update(record).eq("id", id)
    : await supabase.from("lessons").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/lecciones");
  return null;
}

export async function deleteLesson(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("lessons").delete().eq("id", id);
  revalidatePath("/admin/lecciones");
}

// ---------- Preguntas ----------

export async function listQuestions() {
  const supabase = await createClient();
  const { data } = await supabase
    .from("questions")
    .select("*, subjects(name), levels(name), lessons(title)")
    .order("created_at", { ascending: false });
  return data ?? [];
}

export async function upsertQuestion(
  _prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const id = String(formData.get("id") ?? "");
  const subjectId = String(formData.get("subjectId") ?? "");
  const levelId = String(formData.get("levelId") ?? "");
  const lessonId = String(formData.get("lessonId") ?? "");
  const prompt = String(formData.get("prompt") ?? "").trim();
  const choicesRaw = String(formData.get("choices") ?? "");
  const correctIndex = Number(formData.get("correctIndex") ?? 0);

  const choices = choicesRaw
    .split("\n")
    .map((c) => c.trim())
    .filter(Boolean);

  if (!subjectId || !levelId || !prompt || choices.length < 2) {
    return {
      error:
        "Asignatura, nivel, pregunta y al menos 2 alternativas son obligatorios.",
    };
  }
  if (correctIndex < 0 || correctIndex >= choices.length) {
    return { error: "El índice de la respuesta correcta no es válido." };
  }

  const record = {
    subject_id: subjectId,
    level_id: levelId,
    lesson_id: lessonId || null,
    prompt,
    choices,
    correct_index: correctIndex,
  };

  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("questions").update(record).eq("id", id)
    : await supabase.from("questions").insert(record);

  if (error) return { error: error.message };
  revalidatePath("/admin/preguntas");
  return null;
}

export async function deleteQuestion(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("questions").delete().eq("id", id);
  revalidatePath("/admin/preguntas");
}
