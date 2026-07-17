import Link from "next/link";
import { listQuestions, listSubjects, listLevels } from "@/lib/data/content";
import { listLearningObjectives } from "@/lib/data/curriculum";
import { Card, CardContent } from "@/components/ui/card";
import { ImportForm } from "./import-form";

export default async function ImportarPreguntasPage() {
  const [questions, subjects, levels, learningObjectives] = await Promise.all([
    listQuestions(),
    listSubjects(),
    listLevels(),
    listLearningObjectives(),
  ]);

  const catalogs = {
    subjects: subjects.map((s) => ({ id: s.id, name: s.name })),
    levels: levels.map((l) => ({ id: l.id, name: l.name })),
    learningObjectives: learningObjectives.map((o) => ({
      id: o.id,
      short_name: o.short_name,
      level_id: o.level_id,
    })),
    existingPrompts: questions.map((q) => ({
      subject_id: q.subject_id,
      prompt: q.prompt,
    })),
  };

  return (
    <main className="mx-auto flex max-w-4xl flex-col gap-6 px-6 py-12">
      <header className="flex flex-col gap-1">
        <h1 className="font-heading text-xl font-semibold text-foreground">
          Importar preguntas desde CSV
        </h1>
        <p className="text-sm text-muted-foreground">
          Carga varias preguntas a la vez usando la plantilla. Podrás revisar
          cada fila antes de guardar nada: nada se importa sin tu confirmación.
        </p>
      </header>

      {subjects.length === 0 || levels.length === 0 ? (
        <Card>
          <CardContent className="pt-4">
            <p className="text-sm text-muted-foreground">
              Primero crea al menos una{" "}
              <Link href="/admin/asignaturas" className="underline">
                asignatura
              </Link>{" "}
              y un{" "}
              <Link href="/admin/niveles" className="underline">
                nivel
              </Link>
              .
            </p>
          </CardContent>
        </Card>
      ) : (
        <ImportForm catalogs={catalogs} />
      )}
    </main>
  );
}
