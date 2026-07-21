import Link from "next/link";
import { ArrowLeft, Mail, ShieldAlert } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import { getCurrentProfile } from "@/lib/data/profiles";
import {
  listPrograms,
  listLevelsByProgram,
  type CurriculumLevelOption,
} from "@/lib/data/curriculum";
import { buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { ProfileForm, type ProgramOption } from "./profile-form";
import { PasswordForm } from "./password-form";

export default async function PerfilEstudiante({
  searchParams,
}: {
  searchParams: Promise<{ incompleto?: string }>;
}) {
  const [{ incompleto }, supabase] = await Promise.all([
    searchParams,
    createClient(),
  ]);
  const [profile, {
    data: { user },
  }, programs] = await Promise.all([
    getCurrentProfile(),
    supabase.auth.getUser(),
    listPrograms(),
  ]);

  if (!profile || !user) {
    return (
      <main className="mx-auto flex min-h-screen w-full max-w-xl flex-col items-center justify-center gap-4 px-4 py-12 text-center">
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-lg">
              No pudimos cargar tu perfil
            </CardTitle>
            <CardDescription>
              Tu sesión pudo haber caducado. Inicia sesión de nuevo para
              continuar.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link
              href="/login"
              className={cn(buttonVariants({ variant: "default" }), "w-full")}
            >
              Ir a iniciar sesión
            </Link>
          </CardContent>
        </Card>
      </main>
    );
  }

  // Cursos/niveles del programa que el estudiante ya tenía elegido (si
  // tiene uno), cargados en el servidor para que el paso 3 del formulario
  // parta con las opciones completas y no solo con el curso ya guardado.
  const initialLevels = profile.target_program_id
    ? await listLevelsByProgram(profile.target_program_id)
    : [];

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-xl flex-col gap-6 bg-background px-4 py-8 text-foreground sm:px-6 sm:py-12">
      <Link
        href="/panel"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Volver a mi panel
      </Link>

      {incompleto === "1" && (
        <div className="flex items-start gap-2 rounded-xl border border-warning/40 bg-warning/10 px-4 py-3 text-sm text-foreground">
          <ShieldAlert
            className="mt-0.5 size-4 shrink-0 text-warning-foreground"
            aria-hidden="true"
          />
          <p>
            Completa tu tipo de estudiante, programa y curso para acceder a
            tu ruta, lecciones, diagnóstico y ensayos.
          </p>
        </div>
      )}

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">Mi perfil</CardTitle>
          <CardDescription>
            Revisa y actualiza tus datos cuando lo necesites.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <div className="flex items-center gap-3 rounded-xl border border-border bg-muted/40 px-4 py-3">
            <Mail
              className="size-4 shrink-0 text-muted-foreground"
              aria-hidden="true"
            />
            <div className="flex min-w-0 flex-col">
              <span className="text-xs text-muted-foreground">Correo</span>
              <span className="truncate text-sm font-medium">
                {user.email}
              </span>
            </div>
          </div>

          <p className="text-xs text-muted-foreground">
            El correo se muestra solo como información. Si necesitas
            cambiarlo, escríbenos a soporte.
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Editar mis datos</CardTitle>
          <CardDescription>
            Tu nombre así te lo vamos a mostrar en tu panel y actividades. El
            tipo de estudiante, programa y curso son solo para que tengamos
            contexto de lo que estás preparando.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ProfileForm
            fullName={profile.full_name ?? ""}
            studentAgeGroup={profile.student_age_group ?? null}
            targetProgram={
              // El cliente de Supabase (sin esquema de tipos generado) infiere
              // este embed como arreglo por defecto; en runtime PostgREST
              // devuelve un objeto único porque la FK vive en `profiles`
              // (relación a-uno hacia `programs`).
              (profile.target_program as unknown as ProgramOption | null) ??
              null
            }
            targetLevel={
              (profile.target_level_detail as unknown as CurriculumLevelOption | null) ??
              null
            }
            initialLevels={initialLevels}
            regularProgram={
              programs.find(
                (p) => p.code === "regular_examenes_libres_menores"
              ) ?? null
            }
            epjaPrograms={programs.filter((p) => p.curriculum_type === "epja")}
          />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Seguridad de la cuenta</CardTitle>
          <CardDescription>
            Cambia tu contraseña. Vamos a pedirte la actual para confirmar
            que eres tú.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <PasswordForm />
        </CardContent>
      </Card>
    </main>
  );
}
