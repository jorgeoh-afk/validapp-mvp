import Link from "next/link";
import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { Button, buttonVariants } from "@/components/ui/button";

export default async function PanelAdmin() {
  const profile = await getCurrentProfile();

  return (
    <main className="mx-auto flex min-h-screen max-w-xl flex-col items-center gap-4 px-6 py-16 text-center">
      <h1 className="text-2xl font-semibold text-black dark:text-zinc-50">
        Panel administrativo — {profile?.full_name}
      </h1>
      <p className="max-w-sm text-zinc-600 dark:text-zinc-400">
        Gestiona el contenido de ValidApp.
      </p>
      <div className="flex flex-wrap justify-center gap-3">
        <Link href="/admin/asignaturas" className={buttonVariants({ variant: "outline" })}>
          Asignaturas
        </Link>
        <Link href="/admin/niveles" className={buttonVariants({ variant: "outline" })}>
          Niveles
        </Link>
        <Link href="/admin/lecciones" className={buttonVariants({ variant: "outline" })}>
          Lecciones
        </Link>
        <Link href="/admin/preguntas" className={buttonVariants({ variant: "outline" })}>
          Preguntas
        </Link>
        <Link href="/admin/resultados" className={buttonVariants({ variant: "outline" })}>
          Resultados
        </Link>
      </div>
      <form action={signOut}>
        <Button type="submit" variant="ghost">
          Cerrar sesión
        </Button>
      </form>
    </main>
  );
}
