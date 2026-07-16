import Link from "next/link";
import { listPrograms, deleteProgram } from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { ProgramForm } from "./program-form";

export default async function ProgramasPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const programs = await listPrograms();
  const editing = edit ? programs.find((p) => p.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Programas educativos</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Modalidad bajo la que se agrupan los cursos (p. ej. educación de
        adultos, científico-humanista, examen libre).
      </p>

      <div className="mt-6">
        <ProgramForm editing={editing} />
      </div>

      <ul className="mt-6 flex flex-col gap-2">
        {programs.map((program) => (
          <li
            key={program.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {program.name}{" "}
              <span className="text-zinc-500">
                (orden {program.order_index}
                {program.active ? "" : " · inactivo"})
              </span>
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/programas?edit=${program.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <form action={deleteProgram}>
                <input type="hidden" name="id" value={program.id} />
                <Button type="submit" variant="ghost" size="sm">
                  Eliminar
                </Button>
              </form>
            </div>
          </li>
        ))}
        {programs.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay programas.</p>
        )}
      </ul>
    </main>
  );
}
