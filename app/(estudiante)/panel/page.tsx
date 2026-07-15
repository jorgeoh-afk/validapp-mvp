import Link from "next/link";
import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { getGamificationStats } from "@/lib/data/gamification";
import { BADGE_LABELS } from "@/lib/gamification-labels";
import { Button, buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";

export default async function PanelEstudiante() {
  const profile = await getCurrentProfile();
  const stats = profile ? await getGamificationStats(profile.id) : null;
  const hasDiagnostic = stats?.badges.includes("primer_diagnostico") ?? false;

  const primaryAction = hasDiagnostic
    ? { href: "/ruta", label: "Continuar aprendiendo" }
    : { href: "/diagnostico", label: "Rendir diagnóstico" };
  const secondaryAction = hasDiagnostic
    ? { href: "/diagnostico", label: "Rendir otro diagnóstico" }
    : { href: "/ruta", label: "Mi ruta educativa" };

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-xl flex-col gap-6 bg-background px-4 py-8 text-foreground sm:px-6 sm:py-12">
      <div className="flex justify-end">
        <form action={signOut}>
          <Button type="submit" variant="link" size="sm" className="text-muted-foreground">
            Cerrar sesión
          </Button>
        </form>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">
            Hola, {profile?.full_name || "estudiante"}
          </CardTitle>
          <CardDescription>
            Aquí verás tu ruta educativa y tu progreso.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-2 sm:flex-row">
          <Link
            href={primaryAction.href}
            className={cn(buttonVariants({ variant: "default", size: "lg" }), "w-full sm:w-auto")}
          >
            {primaryAction.label}
          </Link>
          <Link
            href={secondaryAction.href}
            className={cn(buttonVariants({ variant: "outline" }), "w-full sm:w-auto")}
          >
            {secondaryAction.label}
          </Link>
        </CardContent>
      </Card>

      {stats && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Tu progreso</CardTitle>
          </CardHeader>
          <CardContent className="flex gap-6">
            <div className="flex items-center gap-2">
              <span
                aria-hidden="true"
                className="flex size-8 items-center justify-center rounded-full bg-warning/15 text-base"
              >
                🏆
              </span>
              <span className="text-sm">
                <strong className="font-semibold">{stats.total_points}</strong>{" "}
                puntos
              </span>
            </div>
            <div className="flex items-center gap-2">
              <span
                aria-hidden="true"
                className="flex size-8 items-center justify-center rounded-full bg-secondary/20 text-base"
              >
                🔥
              </span>
              <span className="text-sm">
                Racha:{" "}
                <strong className="font-semibold">{stats.current_streak}</strong>{" "}
                días
              </span>
            </div>
          </CardContent>
        </Card>
      )}

      {stats && stats.badges.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Tus insignias</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-wrap gap-2">
            {stats.badges.map((badge) => (
              <span
                key={badge}
                className="rounded-full border border-warning/30 bg-warning/10 px-3 py-1 text-xs"
              >
                <span aria-hidden="true">🎖️</span>{" "}
                {BADGE_LABELS[badge] ?? badge}
              </span>
            ))}
          </CardContent>
        </Card>
      )}
    </main>
  );
}
