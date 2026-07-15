import Link from "next/link";
import { listSubjects, deleteSubject } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { SubjectForm } from "./subject-form";

export default async function AsignaturasPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const subjects = await listSubjects();
  const editing = edit ? subjects.find((s) => s.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Asignaturas</h1>

      <div className="mt-6">
        <SubjectForm editing={editing} />
      </div>

      <ul className="mt-6 flex flex-col gap-2">
        {subjects.map((subject) => (
          <li
            key={subject.id}
            className="flex items-center justify-between gap-4 rounded-lg border border-border px-3 py-2"
          >
            <span>{subject.name}</span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/asignaturas?edit=${subject.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <form action={deleteSubject}>
                <input type="hidden" name="id" value={subject.id} />
                <Button type="submit" variant="ghost" size="sm">
                  Eliminar
                </Button>
              </form>
            </div>
          </li>
        ))}
        {subjects.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay asignaturas.</p>
        )}
      </ul>
    </main>
  );
}
