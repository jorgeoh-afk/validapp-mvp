"use server";

// Dominio: Autenticación y usuarios (tabla `profiles`).
// Server Action de esta capa: solo permite editar `full_name`. El correo
// vive en `auth.users` (no se edita aquí) y `target_level` queda de solo
// lectura hasta que se defina un flujo propio para cambiarlo.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type UpdateFullNameState =
  | { status: "error"; message: string }
  | { status: "success" }
  | null;

export async function updateFullName(
  _prevState: UpdateFullNameState,
  formData: FormData
): Promise<UpdateFullNameState> {
  const fullName = String(formData.get("fullName") ?? "").trim();

  if (!fullName) {
    return { status: "error", message: "Ingresa tu nombre completo." };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return {
      status: "error",
      message: "Tu sesión caducó. Inicia sesión de nuevo para guardar tus cambios.",
    };
  }

  // La política `profiles_update_own` (0015_fix_profiles_role_escalation.sql)
  // ya restringe esta actualización a la propia fila del estudiante.
  const { error } = await supabase
    .from("profiles")
    .update({ full_name: fullName })
    .eq("id", user.id);

  if (error) {
    return {
      status: "error",
      message: "No pudimos guardar tu nombre. Intenta de nuevo.",
    };
  }

  revalidatePath("/perfil");
  revalidatePath("/panel");

  return { status: "success" };
}
