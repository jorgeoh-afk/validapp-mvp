"use server";

// Dominio: Autenticación y usuarios (tabla `profiles`).
// Server Action de esta capa: permite editar `full_name` y `target_level`.
// El correo vive en `auth.users` y no se edita aquí (ver
// `lib/data/account-security.ts` para la contraseña, que tampoco toca
// `profiles`).

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { TARGET_LEVEL_OPTIONS } from "@/lib/data/target-levels";

export type UpdateProfileState =
  | { status: "error"; message: string }
  | { status: "success" }
  | null;

export async function updateProfile(
  _prevState: UpdateProfileState,
  formData: FormData
): Promise<UpdateProfileState> {
  const fullName = String(formData.get("fullName") ?? "").trim();
  const targetLevelRaw = String(formData.get("targetLevel") ?? "").trim();

  if (!fullName) {
    return { status: "error", message: "Ingresa tu nombre completo." };
  }

  // Vacío = "Sin definir" (null). Cualquier otro valor debe ser una de las
  // opciones cerradas — mismo conjunto que valida el CHECK constraint
  // `profiles_target_level_check` (0026), así que esto es una validación
  // temprana en el servidor, no la única defensa.
  const targetLevel = targetLevelRaw === "" ? null : targetLevelRaw;
  if (
    targetLevel !== null &&
    !TARGET_LEVEL_OPTIONS.includes(targetLevel as (typeof TARGET_LEVEL_OPTIONS)[number])
  ) {
    return { status: "error", message: "Elige un nivel válido de la lista." };
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
    .update({ full_name: fullName, target_level: targetLevel })
    .eq("id", user.id);

  if (error) {
    return {
      status: "error",
      message: "No pudimos guardar tus cambios. Intenta de nuevo.",
    };
  }

  revalidatePath("/perfil");
  revalidatePath("/panel");

  return { status: "success" };
}
