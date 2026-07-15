import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { Button } from "@/components/ui/button";

export default async function PanelEstudiante() {
  const profile = await getCurrentProfile();

  return (
    <main className="flex min-h-screen flex-col items-center gap-4 bg-zinc-50 px-6 py-16 text-center dark:bg-black">
      <h1 className="text-2xl font-semibold text-black dark:text-zinc-50">
        Hola, {profile?.full_name || "estudiante"}
      </h1>
      <p className="max-w-sm text-zinc-600 dark:text-zinc-400">
        Aquí verás tu diagnóstico, tu ruta educativa y tu progreso. Esta
        sección se construirá en las próximas etapas.
      </p>
      <form action={signOut}>
        <Button type="submit" variant="outline">
          Cerrar sesión
        </Button>
      </form>
    </main>
  );
}
