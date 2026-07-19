import Link from "next/link";
import { ArrowLeft, Mail } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import { getCurrentProfile } from "@/lib/data/profiles";
import { buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { ProfileForm } from "./profile-form";
import { PasswordForm } from "./password-form";

export default async function PerfilEstudiante() {
  const supabase = await createClient();
  const [profile, {
    data: { user },
  }] = await Promise.all([getCurrentProfile(), supabase.auth.getUser()]);

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

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-xl flex-col gap-6 bg-background px-4 py-8 text-foreground sm:px-6 sm:py-12">
      <Link
        href="/panel"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Volver a mi panel
      </Link>

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
            nivel es solo para que tengamos contexto de lo que estás
            preparando.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <ProfileForm
            fullName={profile.full_name ?? ""}
            targetLevel={profile.target_level ?? ""}
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
