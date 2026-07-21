import { redirect } from "next/navigation";
import { getCurrentProfile } from "@/lib/data/profiles";

type StudentProfile = NonNullable<Awaited<ReturnType<typeof getCurrentProfile>>>;

/**
 * Un estudiante recién registrado puede no haber terminado el asistente de
 * "Mi perfil" (tipo de estudiante, programa y curso objetivo). Mientras eso
 * no esté completo no tenemos cómo filtrar contenido por su nivel, así que
 * no debe ver rutas, lecciones, ensayos ni diagnóstico todavía.
 */
export function isEnrollmentComplete(
  profile: Pick<StudentProfile, "target_program_id" | "target_level_id">
): boolean {
  return Boolean(profile.target_program_id && profile.target_level_id);
}

/**
 * Gate de acceso a contenido para páginas de estudiante que todavía no
 * necesitan el perfil por otro motivo: obtiene el perfil actual y redirige
 * a completar la inscripción si falta programa o curso objetivo. Si no hay
 * sesión, el middleware ya debería haber redirigido a /login antes de
 * llegar aquí; como respaldo, este helper también redirige a /login.
 */
export async function requireEnrolledProfile(): Promise<StudentProfile> {
  const profile = await getCurrentProfile();

  if (!profile) {
    redirect("/login");
  }

  if (!isEnrollmentComplete(profile)) {
    redirect("/perfil?incompleto=1");
  }

  return profile;
}
