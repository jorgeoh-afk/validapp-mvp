import Link from "next/link";
import { listLevels, deleteLevel } from "@/lib/data/content";
import { listPrograms, listEducationLevels } from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { LevelForm } from "./level-form";
import { LevelClassifyForm } from "./level-classify-form";

export default async function NivelesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [levels, programs, educationLevels] = await Promise.all([
    listLevels(),
    listPrograms(),
    listEducationLevels(),
  ]);
  const editing = edit ? levels.find((l) => l.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Niveles (cursos)</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Cada curso puede clasificarse dentro de un{" "}
        <Link href="/admin/programas" className="underline">
          programa
        </Link>{" "}
        y un{" "}
        <Link href="/admin/niveles-educativos" className="underline">
          nivel educativo
        </Link>{" "}
        (opcional).
      </p>

      {programs.length === 0 || educationLevels.length === 0 ? (
        <p className="mt-6 text-sm text-zinc-600 dark:text-zinc-400">
          Primero crea al menos un{" "}
          <Link href="/admin/programas" className="underline">
            programa
          </Link>{" "}
          y un{" "}
          <Link href="/admin/niveles-educativos" className="underline">
            nivel educativo
          </Link>{" "}
          para poder clasificar los cursos al crearlos.
        </p>
      ) : (
        <div className="mt-6">
          <LevelForm
            editing={editing}
            programs={programs}
            educationLevels={educationLevels}
          />
        </div>
      )}

      <ul className="mt-6 flex flex-col gap-2">
        {levels.map((level) => (
          <li
            key={level.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2"
          >
            <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4">
              <span>
                {level.name}{" "}
                <span className="text-zinc-500">
                  (orden {level.order_index})
                </span>
              </span>
              <div className="flex items-center gap-2">
                <Link
                  href={`/admin/niveles?edit=${level.id}`}
                  className="text-sm underline"
                >
                  Editar
                </Link>
                <form action={deleteLevel}>
                  <input type="hidden" name="id" value={level.id} />
                  <Button type="submit" variant="ghost" size="sm">
                    Eliminar
                  </Button>
                </form>
              </div>
            </div>
            <LevelClassifyForm
              levelId={level.id}
              programId={level.program_id}
              educationLevelId={level.education_level_id}
              programs={programs}
              educationLevels={educationLevels}
            />
          </li>
        ))}
        {levels.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay niveles.</p>
        )}
      </ul>
    </main>
  );
}
