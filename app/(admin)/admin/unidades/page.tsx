import Link from "next/link";
import { listUnits, listStrands, deleteUnit } from "@/lib/data/curriculum";
import { DeleteButton } from "@/components/admin/delete-button";
import { UnitForm } from "./unit-form";

export default async function UnidadesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [units, strands] = await Promise.all([listUnits(), listStrands()]);
  const editing = edit ? units.find((u) => u.id === edit) ?? null : null;

  const strandOptions = strands.map((s) => ({
    id: s.id,
    name: s.name,
    subjectName: s.subjects?.name,
  }));

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Unidades</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Cada unidad pertenece a un eje temático.
      </p>

      {strands.length === 0 ? (
        <p className="mt-6 text-sm text-zinc-600 dark:text-zinc-400">
          Primero crea al menos un{" "}
          <Link href="/admin/ejes" className="underline">
            eje temático
          </Link>
          .
        </p>
      ) : (
        <div className="mt-6">
          <UnitForm editing={editing} strands={strandOptions} />
        </div>
      )}

      <ul className="mt-6 flex flex-col gap-2">
        {units.map((unit) => (
          <li
            key={unit.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {unit.name}{" "}
              <span className="text-zinc-500">
                ({unit.strands?.subjects?.name} · {unit.strands?.name} · orden{" "}
                {unit.order_index}
                {unit.active ? "" : " · inactivo"})
              </span>
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/unidades?edit=${unit.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <DeleteButton id={unit.id} action={deleteUnit} />
            </div>
          </li>
        ))}
        {units.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay unidades.</p>
        )}
      </ul>
    </main>
  );
}
