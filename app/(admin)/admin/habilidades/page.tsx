import Link from "next/link";
import {
  listSkills,
  deleteSkill,
  getSkillDeleteImpact,
} from "@/lib/data/curriculum";
import { ConfirmDeleteDialog } from "@/components/admin/confirm-delete-dialog";
import { SkillForm } from "./skill-form";

export default async function HabilidadesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const skills = await listSkills();
  const editing = edit ? skills.find((s) => s.id === edit) ?? null : null;

  return (
    <main className="mx-auto max-w-2xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Habilidades</h1>
      <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
        Catálogo de habilidades que se pueden asociar a un objetivo de
        aprendizaje (p. ej. analizar, resolver problemas, interpretar
        información).
      </p>

      <div className="mt-6">
        <SkillForm editing={editing} />
      </div>

      <ul className="mt-6 flex flex-col gap-2">
        {skills.map((skill) => (
          <li
            key={skill.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between sm:gap-4"
          >
            <span>
              {skill.name}{" "}
              {skill.category && (
                <span className="text-zinc-500">({skill.category})</span>
              )}
            </span>
            <div className="flex items-center gap-2">
              <Link
                href={`/admin/habilidades?edit=${skill.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <ConfirmDeleteDialog
                id={skill.id}
                itemLabel={`la habilidad "${skill.name}"`}
                action={deleteSkill}
                loadImpact={getSkillDeleteImpact}
              />
            </div>
          </li>
        ))}
        {skills.length === 0 && (
          <p className="text-sm text-zinc-500">Aún no hay habilidades.</p>
        )}
      </ul>
    </main>
  );
}
