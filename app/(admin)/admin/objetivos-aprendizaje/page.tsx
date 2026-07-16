import Link from "next/link";
import {
  listLearningObjectives,
  listUnits,
  listSkills,
  deleteLearningObjective,
} from "@/lib/data/curriculum";
import { listLevels } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { LearningObjectiveForm } from "./learning-objective-form";

const STATUS_LABEL: Record<string, string> = {
  borrador: "Borrador",
  en_revision: "En revisión",
  aprobado: "Aprobado",
  archivado: "Archivado",
};

const PRIORITY_LABEL: Record<string, string> = {
  baja: "Baja",
  media: "Media",
  alta: "Alta",
};

export default async function ObjetivosAprendizajePage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [objectives, units, levels, skills] = await Promise.all([
    listLearningObjectives(),
    listUnits(),
    listLevels(),
    listSkills(),
  ]);

  const raw = edit ? objectives.find((o) => o.id === edit) ?? null : null;
  const editing = raw
    ? {
        ...raw,
        skillIds: (raw.learning_objective_skills ?? []).map(
          (s: { skill_id: string }) => s.skill_id
        ),
      }
    : null;

  const unitOptions = units.map((u) => ({
    id: u.id,
    label: `${u.strands?.subjects?.name ?? "—"} · ${u.strands?.name ?? "—"} · ${u.name}`,
  }));

  return (
    <main className="mx-auto max-w-3xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Objetivos de aprendizaje</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Cada objetivo cuelga de una unidad (asignatura · eje · unidad) y de un
        curso. No se asume un único currículo: cada objetivo puede guardar su
        propia fuente y año de referencia, para convivir con distintas
        versiones curriculares.
      </p>

      {units.length === 0 || levels.length === 0 ? (
        <p className="mt-6 text-sm text-zinc-600 dark:text-zinc-400">
          Primero crea al menos una{" "}
          <Link href="/admin/unidades" className="underline">
            unidad
          </Link>{" "}
          y un{" "}
          <Link href="/admin/niveles" className="underline">
            curso
          </Link>
          .
        </p>
      ) : (
        <div className="mt-6">
          <LearningObjectiveForm
            editing={editing}
            units={unitOptions}
            levels={levels}
            skills={skills}
          />
        </div>
      )}

      <ul className="mt-6 flex flex-col gap-2">
        {objectives.map((objective) => (
          <li
            key={objective.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {objective.code ? `${objective.code} — ` : ""}
              {objective.short_name}{" "}
              <span className="text-zinc-500">
                ({objective.units?.strands?.subjects?.name} ·{" "}
                {objective.units?.strands?.name} · {objective.units?.name} ·{" "}
                {objective.levels?.name} · {STATUS_LABEL[objective.status]} ·
                prioridad {PRIORITY_LABEL[objective.priority]}
                {objective.active ? "" : " · inactivo"})
              </span>
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/objetivos-aprendizaje?edit=${objective.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <form action={deleteLearningObjective}>
                <input type="hidden" name="id" value={objective.id} />
                <Button type="submit" variant="ghost" size="sm">
                  Eliminar
                </Button>
              </form>
            </div>
          </li>
        ))}
        {objectives.length === 0 && (
          <p className="text-sm text-zinc-500">
            Aún no hay objetivos de aprendizaje.
          </p>
        )}
      </ul>
    </main>
  );
}
