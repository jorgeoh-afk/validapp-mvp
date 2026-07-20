"use server";

// Dominio: Autenticación y usuarios (tabla `profiles`).
// Server Action de esta capa: permite editar `full_name` y la jerarquía
// curricular objetivo del estudiante (tipo de estudiante, programa y
// curso/nivel). El correo vive en `auth.users` y no se edita aquí (ver
// `lib/data/account-security.ts` para la contraseña, que tampoco toca
// `profiles`).
//
// `target_level` (texto legible histórico) y `target_program_id` derivado
// desde el nivel NO se escriben directo acá: los deriva automáticamente el
// trigger `profiles_sync_target_level` (0028) a partir de `target_level_id`.
// Ver ese trigger para el detalle de sincronización bidireccional.

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type UpdateProfileState =
  | { status: "error"; message: string }
  | { status: "success" }
  | null;

const STUDENT_AGE_GROUPS = ["menor_18", "mayor_18"] as const;
type StudentAgeGroup = (typeof STUDENT_AGE_GROUPS)[number];

export async function updateProfile(
  _prevState: UpdateProfileState,
  formData: FormData
): Promise<UpdateProfileState> {
  const fullName = String(formData.get("fullName") ?? "").trim();
  const studentAgeGroupRaw = String(formData.get("studentAgeGroup") ?? "").trim();
  const targetProgramIdRaw = String(formData.get("targetProgramId") ?? "").trim();
  const targetLevelIdRaw = String(formData.get("targetLevelId") ?? "").trim();

  if (!fullName) {
    return { status: "error", message: "Ingresa tu nombre completo." };
  }

  const studentAgeGroup = studentAgeGroupRaw === "" ? null : studentAgeGroupRaw;
  if (
    studentAgeGroup !== null &&
    !STUDENT_AGE_GROUPS.includes(studentAgeGroup as StudentAgeGroup)
  ) {
    return { status: "error", message: "Elige un tipo de estudiante válido." };
  }

  const targetProgramId = targetProgramIdRaw === "" ? null : targetProgramIdRaw;
  const targetLevelId = targetLevelIdRaw === "" ? null : targetLevelIdRaw;

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

  // Validación en servidor -no confiar solo en lo que mostró el cliente-:
  // si viene un programa, debe existir y su `curriculum_type` debe
  // corresponder con el tipo de estudiante elegido (regular = menor de 18,
  // epja = mayor de 18). Mismo criterio que el trigger
  // `levels_program_curriculum_match` aplica a `levels`, validado acá antes
  // para dar un mensaje amigable en vez del error crudo de la base de datos.
  if (targetProgramId) {
    const { data: program, error: programError } = await supabase
      .from("programs")
      .select("id, curriculum_type")
      .eq("id", targetProgramId)
      .single();

    if (programError || !program) {
      return { status: "error", message: "El programa elegido no existe." };
    }

    const expectedCurriculumType: "regular" | "epja" | null =
      studentAgeGroup === "menor_18"
        ? "regular"
        : studentAgeGroup === "mayor_18"
          ? "epja"
          : null;
    if (
      expectedCurriculumType &&
      program.curriculum_type &&
      program.curriculum_type !== expectedCurriculumType
    ) {
      return {
        status: "error",
        message:
          "El programa elegido no corresponde con el tipo de estudiante seleccionado.",
      };
    }
  }

  // Si viene un curso/nivel, debe pertenecer de verdad al programa elegido
  // (no confiar en que el cliente ya haya filtrado bien la lista).
  if (targetLevelId) {
    if (!targetProgramId) {
      return {
        status: "error",
        message: "Elige primero un programa educativo antes que un curso.",
      };
    }
    const { data: level, error: levelError } = await supabase
      .from("levels")
      .select("id, program_id")
      .eq("id", targetLevelId)
      .single();

    if (levelError || !level) {
      return { status: "error", message: "El curso elegido no existe." };
    }
    if (level.program_id !== targetProgramId) {
      return {
        status: "error",
        message: "El curso elegido no pertenece al programa seleccionado.",
      };
    }
  }

  // La política `profiles_update_own` (0015_fix_profiles_role_escalation.sql)
  // ya restringe esta actualización a la propia fila del estudiante.
  //
  // Cuando no viene `targetLevelId` (programa sin cursos propios todavía, ej.
  // "EPJA Regular"/"EPJA Flexible"), se envía `target_level: null` explícito
  // en el mismo UPDATE: si no se hace, Postgres conserva el texto legado de
  // un curso elegido antes (`target_level` no está en el SET, así que
  // mantiene su valor anterior), y el trigger `profiles_sync_target_level`
  // (0028) nunca detecta que hay que limpiar `target_program_id` derivado
  // porque ve `new.target_level` todavía no-nulo. Cuando sí viene
  // `targetLevelId`, se omite `target_level` a propósito: el trigger lo
  // deriva siempre desde el curso real (fuente de verdad), no hace falta
  // mandarlo desde acá.
  const { error } = await supabase
    .from("profiles")
    .update({
      full_name: fullName,
      student_age_group: studentAgeGroup,
      target_program_id: targetProgramId,
      target_level_id: targetLevelId,
      ...(targetLevelId ? {} : { target_level: null }),
    })
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
