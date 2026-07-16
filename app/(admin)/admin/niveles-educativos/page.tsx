import Link from "next/link";
import { listEducationLevels, deleteEducationLevel } from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { EducationLevelForm } from "./education-level-form";

export default async function NivelesEducativosPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const educationLevels = await listEducationLevels();
  const editing = edit
    ? educationLevels.find((l) => l.id === edit) ?? null
    : null;

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Niveles educativos</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Nivel educativo general (p. ej. Educación Básica, Educación Media). Los
        cursos se clasifican dentro de un nivel educativo desde{" "}
        <Link href="/admin/niveles" className="underline">
          Niveles (cursos)
        </Link>
        .
      </p>

      <div className="mt-6">
        <EducationLevelForm editing={editing} />
      </div>

      <ul className="mt-6 flex flex-col gap-2">
        {educationLevels.map((level) => (
          <li
            key={level.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {level.name}{" "}
              <span className="text-zinc-500">
                (orden {level.order_index}
                {level.active ? "" : " · inactivo"})
              </span>
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/niveles-educativos?edit=${level.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <form action={deleteEducationLevel}>
                <input type="hidden" name="id" value={level.id} />
                <Button type="submit" variant="ghost" size="sm">
                  Eliminar
                </Button>
              </form>
            </div>
          </li>
        ))}
        {educationLevels.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay niveles educativos.</p>
        )}
      </ul>
    </main>
  );
}
