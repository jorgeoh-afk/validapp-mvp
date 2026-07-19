import Link from "next/link";
import {
  listSubjects,
  deleteSubject,
  getSubjectDeleteImpact,
} from "@/lib/data/content";
import { ConfirmDeleteDialog } from "@/components/admin/confirm-delete-dialog";
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
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>{subject.name}</span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/asignaturas?edit=${subject.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <ConfirmDeleteDialog
                id={subject.id}
                itemLabel={`la asignatura "${subject.name}"`}
                action={deleteSubject}
                loadImpact={getSubjectDeleteImpact}
              />
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
