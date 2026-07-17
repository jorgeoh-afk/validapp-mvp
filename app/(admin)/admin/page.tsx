import Link from "next/link";
import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { Button, buttonVariants } from "@/components/ui/button";

export default async function PanelAdmin() {
  const profile = await getCurrentProfile();

  return (
    <main className="mx-auto flex min-h-screen max-w-xl flex-col items-center gap-4 px-6 py-16 text-center">
      <h1 className="text-2xl font-semibold text-black dark:text-zinc-50">
        Panel administrativo
        {profile?.full_name ? ` — ${profile.full_name}` : ""}
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
        <Link href="/admin/ensayos" className={buttonVariants({ variant: "outline" })}>
          Ensayos
        </Link>
        <Link href="/admin/cobertura" className={buttonVariants({ variant: "outline" })}>
          Cobertura curricular
        </Link>
      </div>

      <h2 className="mt-4 text-sm font-medium text-zinc-500">
        Estructura curricular
      </h2>
      <div className="flex flex-wrap justify-center gap-3">
        <Link href="/admin/programas" className={buttonVariants({ variant: "outline" })}>
          Programas
        </Link>
        <Link href="/admin/niveles-educativos" className={buttonVariants({ variant: "outline" })}>
          Niveles educativos
        </Link>
        <Link href="/admin/ejes" className={buttonVariants({ variant: "outline" })}>
          Ejes temáticos
        </Link>
        <Link href="/admin/unidades" className={buttonVariants({ variant: "outline" })}>
          Unidades
        </Link>
        <Link href="/admin/habilidades" className={buttonVariants({ variant: "outline" })}>
          Habilidades
        </Link>
        <Link href="/admin/objetivos-aprendizaje" className={buttonVariants({ variant: "outline" })}>
          Objetivos de aprendizaje
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
