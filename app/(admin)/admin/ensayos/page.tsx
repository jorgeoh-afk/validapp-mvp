import Link from "next/link";
import { listEssays, deleteEssay } from "@/lib/data/essays";
import { listLevels } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { EssayForm } from "./essay-form";

const STATUS_LABEL: Record<string, string> = {
  borrador: "Borrador",
  en_revision: "En revisión",
  programado: "Programado",
  publicado: "Publicado",
  finalizado: "Finalizado",
  archivado: "Archivado",
};

const STATUS_VARIANT: Record<
  string,
  "muted" | "warning" | "success" | "destructive" | "default"
> = {
  borrador: "muted",
  en_revision: "warning",
  programado: "default",
  publicado: "success",
  finalizado: "muted",
  archivado: "destructive",
};

export default async function EnsayosPage() {
  const [essays, levels] = await Promise.all([listEssays(), listLevels()]);

  return (
    <main className="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-12">
      <header className="flex flex-col gap-1">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <h1 className="font-heading text-xl font-semibold text-foreground">
            Ensayos
          </h1>
          <Link
            href="/admin/cobertura"
            className="text-sm font-medium text-primary underline-offset-4 hover:underline"
          >
            Ver cobertura curricular
          </Link>
        </div>
        <p className="text-sm text-muted-foreground">
          Crea la configuración base de un ensayo. Luego podrás definir su
          distribución por asignatura, objetivo y dificultad, y generar la
          selección automática de preguntas.
        </p>
      </header>

      {levels.length === 0 ? (
        <Card>
          <CardContent className="pt-4">
            <p className="text-sm text-muted-foreground">
              Primero crea al menos un{" "}
              <Link href="/admin/niveles" className="underline">
                nivel
              </Link>
              .
            </p>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardHeader>
            <CardTitle>Nuevo ensayo</CardTitle>
          </CardHeader>
          <CardContent>
            <EssayForm levels={levels} />
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Ensayos existentes</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="flex flex-col gap-2">
            {essays.map((essay) => (
              <li
                key={essay.id}
                className="flex flex-col gap-2 rounded-lg border border-border px-3 py-2 sm:flex-row sm:items-center sm:justify-between"
              >
                <div className="flex flex-col gap-1.5">
                  <span className="font-medium">
                    {essay.name}{" "}
                    <span className="text-muted-foreground font-normal">
                      ({essay.levels?.name ?? "—"})
                    </span>
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    <Badge variant={STATUS_VARIANT[essay.status] ?? "muted"}>
                      {STATUS_LABEL[essay.status] ?? essay.status}
                    </Badge>
                    <Badge variant="outline">
                      {(essay.essay_questions ?? []).length}/{essay.total_questions}{" "}
                      preguntas
                    </Badge>
                  </div>
                </div>
                <div className="flex items-center gap-2 self-start">
                  <Link
                    href={`/admin/ensayos/${essay.id}`}
                    className="text-sm font-medium text-primary underline-offset-4 hover:underline"
                  >
                    Configurar
                  </Link>
                  <form action={deleteEssay}>
                    <input type="hidden" name="id" value={essay.id} />
                    <Button type="submit" variant="ghost" size="sm">
                      Eliminar
                    </Button>
                  </form>
                </div>
              </li>
            ))}
            {essays.length === 0 && (
              <p className="text-sm text-muted-foreground">Aún no hay ensayos.</p>
            )}
          </ul>
        </CardContent>
      </Card>
    </main>
  );
}
