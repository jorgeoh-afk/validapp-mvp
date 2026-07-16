import Link from "next/link";
import { listStrands, deleteStrand } from "@/lib/data/curriculum";
import { listSubjects } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { StrandForm } from "./strand-form";

export default async function EjesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [strands, subjects] = await Promise.all([
    listStrands(),
    listSubjects(),
  ]);
  const editing = edit ? strands.find((s) => s.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Ejes temáticos</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Cada eje pertenece a una asignatura (p. ej. Números, Lectura,
        Geometría).
      </p>

      {subjects.length === 0 ? (
        <p className="mt-6 text-sm text-zinc-600 dark:text-zinc-400">
          Primero crea al menos una{" "}
          <Link href="/admin/asignaturas" className="underline">
            asignatura
          </Link>
          .
        </p>
      ) : (
        <div className="mt-6">
          <StrandForm editing={editing} subjects={subjects} />
        </div>
      )}

      <ul className="mt-6 flex flex-col gap-2">
        {strands.map((strand) => (
          <li
            key={strand.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {strand.name}{" "}
              <span className="text-zinc-500">
                ({strand.subjects?.name} · orden {strand.order_index}
                {strand.active ? "" : " · inactivo"})
              </span>
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/ejes?edit=${strand.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <form action={deleteStrand}>
                <input type="hidden" name="id" value={strand.id} />
                <Button type="submit" variant="ghost" size="sm">
                  Eliminar
                </Button>
              </form>
            </div>
          </li>
        ))}
        {strands.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay ejes temáticos.</p>
        )}
      </ul>
    </main>
  );
}
