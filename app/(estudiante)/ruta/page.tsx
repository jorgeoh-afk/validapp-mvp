import Link from "next/link";
import { ArrowLeft, ChevronRight } from "lucide-react";
import { listSubjects } from "@/lib/data/content";
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default async function RutaSubjectsPage() {
  const subjects = await listSubjects();

  return (
    <main className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Link
        href="/panel"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        <ArrowLeft className="size-4" aria-hidden="true" />
        Mi panel
      </Link>

      <Card>
        <CardHeader>
          <CardTitle className="text-xl">Ruta educativa</CardTitle>
          <CardDescription>
            Elige una asignatura para ver tu ruta de lecciones.
          </CardDescription>
        </CardHeader>
      </Card>

      <ul className="flex flex-col gap-3">
        {subjects.map((subject) => (
          <li key={subject.id}>
            <Link
              href={`/ruta/${subject.id}`}
              className="flex items-center justify-between gap-4 rounded-xl border border-border bg-card px-4 py-4 text-sm font-medium text-foreground transition-colors hover:bg-muted"
            >
              {subject.name}
              <ChevronRight
                className="size-4 shrink-0 text-muted-foreground"
                aria-hidden="true"
              />
            </Link>
          </li>
        ))}
        {subjects.length === 0 && (
          <p className="text-sm text-muted-foreground">
            Aún no hay asignaturas disponibles.
          </p>
        )}
      </ul>
    </main>
  );
}
