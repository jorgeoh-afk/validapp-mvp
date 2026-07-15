import Link from "next/link";
import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { getGamificationStats } from "@/lib/data/gamification";
import { BADGE_LABELS } from "@/lib/gamification-labels";
import { Button, buttonVariants } from "@/components/ui/button";

export default async function PanelEstudiante() {
  const profile = await getCurrentProfile();
  const stats = profile ? await getGamificationStats(profile.id) : null;

  return (
    <main className="flex min-h-screen flex-col items-center gap-4 bg-zinc-50 px-6 py-16 text-center dark:bg-black">
      <h1 className="text-2xl font-semibold text-black dark:text-zinc-50">
        Hola, {profile?.full_name || "estudiante"}
      </h1>
      <p className="max-w-sm text-zinc-600 dark:text-zinc-400">
        Aquí verás tu ruta educativa y tu progreso.
      </p>

      {stats && (
        <div className="flex flex-col items-center gap-2">
          <div className="flex gap-4 text-sm">
            <span>🏆 {stats.total_points} puntos</span>
            <span>🔥 Racha: {stats.current_streak} días</span>
          </div>
          {stats.badges.length > 0 && (
            <div className="flex flex-wrap justify-center gap-2">
              {stats.badges.map((badge) => (
                <span
                  key={badge}
                  className="rounded-full border border-border px-3 py-1 text-xs"
                >
                  🎖️ {BADGE_LABELS[badge] ?? badge}
                </span>
              ))}
            </div>
          )}
        </div>
      )}

      <div className="flex gap-3">
        <Link href="/diagnostico" className={buttonVariants({ variant: "default" })}>
          Rendir diagnóstico
        </Link>
        <Link href="/ruta" className={buttonVariants({ variant: "outline" })}>
          Mi ruta educativa
        </Link>
      </div>
      <form action={signOut}>
        <Button type="submit" variant="outline">
          Cerrar sesión
        </Button>
      </form>
    </main>
  );
}
