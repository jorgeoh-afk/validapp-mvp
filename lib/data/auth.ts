"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { STUDENT_PREFIXES } from "@/lib/supabase/middleware";

export type AuthFormState = { error: string } | null;

export type SignUpFormState =
  | { error: string }
  | { status: "confirm-email" }
  | null;

// El middleware agrega `?next=<ruta>` al redirigir a `/login` desde una ruta
// de estudiante protegida (ver `updateSession`). Se valida que empiece con
// uno de los prefijos de estudiante conocidos para evitar un "open redirect"
// (que `next` apunte a un dominio externo o a una ruta de administrador).
function resolveStudentRedirect(next: string | null): string | null {
  if (!next || !next.startsWith("/")) return null;
  if (next.startsWith("//")) return null; // "//evil.com" también es absoluto
  return STUDENT_PREFIXES.some((prefix) => next.startsWith(prefix)) ? next : null;
}

export async function signUp(
  _prevState: SignUpFormState,
  formData: FormData
): Promise<SignUpFormState> {
  const fullName = String(formData.get("fullName") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!fullName || !email || !password) {
    return { error: "Completa tu nombre, correo y contraseña." };
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { data: { full_name: fullName } },
  });

  if (error) {
    return { error: error.message };
  }

  // Con "Confirm email" activo en el proyecto de Supabase, signUp no crea
  // sesión de inmediato: el usuario debe abrir el enlace que le llega por
  // correo antes de poder iniciar sesión. Sin esta comprobación, redirect
  // ("/panel") mandaría al estudiante a una ruta protegida sin sesión, y el
  // middleware lo rebotaría de vuelta a /login sin ninguna explicación.
  if (!data.session) {
    return { status: "confirm-email" };
  }

  redirect("/panel");
}

export async function signIn(
  _prevState: AuthFormState,
  formData: FormData
): Promise<AuthFormState> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return { error: "Ingresa tu correo y contraseña." };
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    if (error.code === "email_not_confirmed") {
      return {
        error:
          "Todavía no confirmas tu correo. Revisa tu bandeja de entrada (y spam) y haz clic en el enlace que te enviamos.",
      };
    }
    return { error: "Correo o contraseña incorrectos." };
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", data.user.id)
    .maybeSingle();

  if (profile?.role === "administrador") {
    redirect("/admin");
  }

  const next = resolveStudentRedirect(String(formData.get("next") ?? ""));
  redirect(next ?? "/panel");
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  revalidatePath("/", "layout");
  redirect("/login");
}
