import Link from "next/link";
import { listLevels, deleteLevel } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { LevelForm } from "./level-form";

export default async function NivelesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const levels = await listLevels();
  const editing = edit ? levels.find((l) => l.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Niveles</h1>

      <div className="mt-6">
        <LevelForm editing={editing} />
      </div>

      <ul className="mt-6 flex flex-col gap-2">
        {levels.map((level) => (
          <li
            key={level.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {level.name}{" "}
              <span className="text-zinc-500">(orden {level.order_index})</span>
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
          </li>
        ))}
        {levels.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay niveles.</p>
        )}
      </ul>
    </main>
  );
}
