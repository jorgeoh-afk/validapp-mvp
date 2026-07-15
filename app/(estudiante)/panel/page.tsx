import Link from "next/link";
import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { Button, buttonVariants } from "@/components/ui/button";

export default async function PanelEstudiante() {
  const profile = await getCurrentProfile();

  return (
    <main className="flex min-h-screen flex-col items-center gap-4 bg-zinc-50 px-6 py-16 text-center dark:bg-black">
      <h1 className="text-2xl font-semibold text-black dark:text-zinc-50">
        Hola, {profile?.full_name || "estudiante"}
      </h1>
      <p className="max-w-sm text-zinc-600 dark:text-zinc-400">
        Aquí verás tu ruta educativa y tu progreso. Esta sección se seguirá
        construyendo en las próximas etapas.
      </p>
      <Link href="/diagnostico" className={buttonVariants({ variant: "default" })}>
        Rendir diagnóstico
      </Link>
      <form action={signOut}>
        <Button type="submit" variant="outline">
          Cerrar sesión
        </Button>
      </form>
    </main>
  );
}
