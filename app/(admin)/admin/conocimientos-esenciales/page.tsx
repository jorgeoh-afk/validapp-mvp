import Link from "next/link";
import { listSubjects, listLevels } from "@/lib/data/content";
import {
  listEssentialKnowledge,
  upsertEssentialKnowledge,
  deleteEssentialKnowledge,
} from "@/lib/data/big-ideas";
import { Badge } from "@/components/ui/badge";
import { StatementForm } from "@/components/admin/statement-form";
import { DeleteButton } from "@/components/admin/delete-button";

const STATUS_LABEL: Record<string, string> = {
  borrador: "Borrador",
  en_revision: "En revisión",
  aprobado: "Aprobado",
  archivado: "Archivado",
};

const STATUS_VARIANT: Record<
  string,
  "muted" | "warning" | "success" | "destructive"
> = {
  borrador: "muted",
  en_revision: "warning",
  aprobado: "success",
  archivado: "destructive",
};

export default async function ConocimientosEsencialesPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string }>;
}) {
  const { edit } = await searchParams;
  const [items, subjects, levels] = await Promise.all([
    listEssentialKnowledge(),
    listSubjects(),
    listLevels(),
  ]);
  const editing = edit ? (items.find((i) => i.id === edit) ?? null) : null;

  return (
    <main className="mx-auto max-w-3xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Conocimientos esenciales</h1>
      <p className="mt-1 text-sm text-muted-foreground">
        Lista abierta de temas/contenidos por asignatura y curso. No siempre
        están vinculados a un eje temático específico ni a un objetivo de
        aprendizaje puntual.
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
          <StatementForm
            key={editing?.id ?? "new"}
            action={upsertEssentialKnowledge}
            editing={editing}
            subjects={subjects}
            levels={levels}
            itemLabel="conocimiento esencial"
            statementLabel="Conocimiento esencial"
          />
        </div>
      )}

      <ul className="mt-6 flex flex-col gap-2">
        {items.map((item) => (
          <li
            key={item.id}
            className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-start sm:justify-between sm:gap-4"
          >
            <div className="flex flex-col gap-1.5">
              <span>
                {item.statement}{" "}
                <span className="text-muted-foreground">
                  ({item.subjects?.name} · {item.levels?.name})
                </span>
              </span>
              <Badge variant={STATUS_VARIANT[item.status ?? "borrador"]}>
                {STATUS_LABEL[item.status ?? "borrador"]}
              </Badge>
            </div>
            <div className="flex items-center gap-2 self-start">
              <Link
                href={`/admin/conocimientos-esenciales?edit=${item.id}`}
                className="text-sm underline"
              >
                Editar
              </Link>
              <DeleteButton id={item.id} action={deleteEssentialKnowledge} />
            </div>
          </li>
        ))}
        {items.length === 0 && (
          <p className="text-sm text-muted-foreground">
            Aún no hay conocimientos esenciales registrados.
          </p>
        )}
      </ul>
    </main>
  );
}
