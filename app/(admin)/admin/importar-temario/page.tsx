import Link from "next/link";
import { listSubjects, listLevels } from "@/lib/data/content";
import { listStrands, listUnits } from "@/lib/data/curriculum";
import { SyllabusImportForm } from "./syllabus-import-form";

export default async function ImportarTemarioPage() {
  const [subjects, levels, strands, units] = await Promise.all([
    listSubjects(),
    listLevels(),
    listStrands(),
    listUnits(),
  ]);

  const catalogs = {
    subjects: subjects.map((s) => ({ id: s.id, name: s.name })),
    levels: levels.map((l) => ({ id: l.id, name: l.name })),
    strands: strands.map((s) => ({
      id: s.id,
      name: s.name,
      subject_id: s.subject_id,
    })),
    units: units.map((u) => ({ id: u.id, name: u.name, strand_id: u.strand_id })),
  };

  return (
    <main className="mx-auto max-w-3xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Importar temario completo</h1>
      <p className="mt-1 text-sm text-muted-foreground">
        Carga de una sola vez ejes, unidades, objetivos de aprendizaje,
        grandes ideas, conocimientos esenciales y lecciones de una
        asignatura y curso, usando un solo archivo CSV.
      </p>

      {subjects.length === 0 || levels.length === 0 ? (
        <p className="mt-6 text-sm text-muted-foreground">
          Primero crea al menos una{" "}
          <Link href="/admin/asignaturas" className="underline">
            asignatura
          </Link>{" "}
          y un{" "}
          <Link href="/admin/niveles" className="underline">
            curso
          </Link>
          .
        </p>
      ) : (
        <div className="mt-6">
          <SyllabusImportForm catalogs={catalogs} />
        </div>
      )}
    </main>
  );
}
