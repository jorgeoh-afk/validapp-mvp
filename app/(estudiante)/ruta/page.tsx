import Link from "next/link";
import { listSubjects } from "@/lib/data/content";
import { buttonVariants } from "@/components/ui/button";

export default async function RutaSubjectsPage() {
  const subjects = await listSubjects();

  return (
    <main className="mx-auto max-w-xl px-6 py-12">
      <Link href="/panel" className="text-sm underline">
        ← Mi panel
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Ruta educativa</h1>
      <p className="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
        Elige una asignatura para ver tu ruta de lecciones.
      </p>

      <ul className="mt-6 flex flex-col gap-2">
        {subjects.map((subject) => (
          <li
            key={subject.id}
            className="flex items-center justify-between gap-4 rounded-lg border border-border px-3 py-2"
          >
            <span>{subject.name}</span>
            <Link
              href={`/ruta/${subject.id}`}
              className={buttonVariants({ variant: "default", size: "sm" })}
            >
              Ver ruta
            </Link>
          </li>
        ))}
        {subjects.length === 0 && (
          <p className="text-sm text-zinc-500">
            Aún no hay asignaturas disponibles.
          </p>
        )}
      </ul>
    </main>
  );
}
