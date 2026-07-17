import Link from "next/link";
import { listQuestions, listSubjects, listLevels } from "@/lib/data/content";
import { listLearningObjectives } from "@/lib/data/curriculum";
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
    <main className="mx-auto max-w-4xl px-6 py-12">
      <Link href="/admin/preguntas" className="text-sm underline">
        ← Preguntas
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Importar preguntas desde CSV</h1>
      <p className="mt-1 text-sm text-muted-foreground">
        Carga varias preguntas a la vez usando la plantilla. Podrás revisar
        cada fila antes de guardar nada: nada se importa sin tu confirmación.
      </p>

      {subjects.length === 0 || levels.length === 0 ? (
        <p className="mt-6 text-sm text-muted-foreground">
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
      ) : (
        <div className="mt-6">
          <ImportForm catalogs={catalogs} />
        </div>
      )}
    </main>
  );
}
