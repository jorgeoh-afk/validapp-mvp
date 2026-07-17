import Link from "next/link";
import { AlertTriangle, Clock3 } from "lucide-react";
import { getCurrentProfile } from "@/lib/data/profiles";
import { getAdminDashboardSummary } from "@/lib/data/admin-dashboard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";

const REVIEW_STATUS_LABEL: Record<string, string> = {
  borrador: "Borrador",
  en_revision: "En revisión",
  aprobado: "Aprobado",
  archivado: "Archivado",
};

const REVIEW_STATUS_VARIANT: Record<
  string,
  "muted" | "warning" | "success" | "destructive"
> = {
  borrador: "muted",
  en_revision: "warning",
  aprobado: "success",
  archivado: "destructive",
};

const ADD_CONTENT_LINKS = [
  { href: "/admin/asignaturas", label: "Asignatura" },
  { href: "/admin/niveles", label: "Nivel" },
  { href: "/admin/lecciones", label: "Lección" },
  { href: "/admin/preguntas", label: "Pregunta" },
  { href: "/admin/ensayos", label: "Ensayo" },
];

const QUICK_ACTIONS = [
  { href: "/admin/asignaturas", label: "Crear asignatura" },
  { href: "/admin/niveles", label: "Crear nivel" },
  { href: "/admin/lecciones", label: "Crear lección" },
  { href: "/admin/preguntas", label: "Crear pregunta" },
  { href: "/admin/preguntas/importar", label: "Importar preguntas (CSV)" },
  { href: "/admin/ensayos", label: "Crear ensayo" },
  { href: "/admin/preguntas", label: "Revisar preguntas pendientes" },
  { href: "/admin/resultados", label: "Ver resultados" },
];

/** Tarjeta de estadística con fuente de datos y acción "ver detalle". */
function StatCard({
  title,
  value,
  description,
  source,
  detailHref,
  detailLabel = "Ver detalle",
  emptyMessage,
}: {
  title: string;
  value: number;
  description: string;
  source: string;
  detailHref: string;
  detailLabel?: string;
  emptyMessage?: string;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col gap-2">
        <p className="font-heading text-3xl font-semibold text-foreground">
          {value}
        </p>
        {value === 0 && emptyMessage ? (
          <p className="text-sm text-muted-foreground">{emptyMessage}</p>
        ) : (
          <p className="text-sm text-muted-foreground">{description}</p>
        )}
        <p className="text-xs text-muted-foreground">Fuente: {source}</p>
        <Link
          href={detailHref}
          className="mt-1 text-sm font-medium text-primary underline-offset-4 hover:underline"
        >
          {detailLabel}
        </Link>
      </CardContent>
    </Card>
  );
}

/** Tarjeta que representa un indicador que aún no se puede calcular. */
function PendingMetricCard({
  title,
  description,
}: {
  title: string;
  description: string;
}) {
  return (
    <Card className="border-2 border-dashed border-border bg-muted/30 ring-0">
      <CardHeader>
        <CardTitle className="text-muted-foreground">{title}</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col gap-2">
        <Badge variant="muted" className="w-fit">
          <Clock3 className="size-3.5" aria-hidden="true" />
          Dato pendiente de implementar
        </Badge>
        <p className="text-sm text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  );
}

export default async function PanelAdmin() {
  const [profile, summary] = await Promise.all([
    getCurrentProfile(),
    getAdminDashboardSummary(),
  ]);

  const generatedAt = new Intl.DateTimeFormat("es-CL", {
    dateStyle: "long",
    timeStyle: "short",
  }).format(new Date());

  const hasAnyContent =
    summary.subjectsCount > 0 ||
    summary.levelsCount > 0 ||
    summary.questionsTotal > 0;

  const alerts = [
    summary.questionsTotal > 0 && summary.questionsByStatus.aprobado === 0
      ? {
          key: "no-approved-questions",
          text: `Hay ${summary.questionsTotal} pregunta(s) en el banco, pero ninguna está en estado "Aprobado". Sin preguntas aprobadas no es posible generar ensayos.`,
          href: "/admin/preguntas",
          linkLabel: "Revisar y aprobar preguntas",
        }
      : null,
    summary.coverage.objectivesWithoutQuestionsCount > 0
      ? {
          key: "objectives-without-questions",
          text: `${summary.coverage.objectivesWithoutQuestionsCount} objetivo(s) de aprendizaje activos sin ninguna pregunta aprobada.`,
          href: "/admin/cobertura",
          linkLabel: "Ver cobertura curricular",
        }
      : null,
    summary.coverage.pendingReviewCount > 0
      ? {
          key: "pending-review",
          text: `${summary.coverage.pendingReviewCount} pregunta(s) esperando revisión antes de poder usarse en ensayos.`,
          href: "/admin/preguntas",
          linkLabel: "Revisar preguntas",
        }
      : null,
    summary.subjectsWithoutLessons.length > 0
      ? {
          key: "subjects-without-lessons",
          text: `${summary.subjectsWithoutLessons.length} asignatura(s) sin ninguna lección cargada: ${summary.subjectsWithoutLessons
            .map((s) => s.name)
            .join(", ")}.`,
          href: "/admin/lecciones",
          linkLabel: "Ir a lecciones",
        }
      : null,
  ].filter(Boolean) as { key: string; text: string; href: string; linkLabel: string }[];

  return (
    <div className="mx-auto flex max-w-5xl flex-col gap-8 pb-12">
      {/* 1. Encabezado */}
      <header className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h1 className="font-heading text-2xl font-semibold text-foreground">
            Panel administrativo
            {profile?.full_name ? ` — ${profile.full_name}` : ""}
          </h1>
          <p className="text-sm text-muted-foreground">
            Resumen del contenido y la actividad de ValidApp.
          </p>
          <p className="text-xs text-muted-foreground">
            Consultado el {generatedAt} (hora en que se generó esta página, no
            un evento en tiempo real).
          </p>
        </div>

        <div className="flex flex-col gap-1.5">
          <span className="text-xs font-semibold tracking-wide text-muted-foreground uppercase">
            Agregar contenido
          </span>
          <div className="flex flex-wrap gap-2">
            {ADD_CONTENT_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={cn(buttonVariants({ variant: "outline", size: "sm" }))}
              >
                {link.label}
              </Link>
            ))}
          </div>
        </div>
      </header>

      {/* Estado vacío general: aún no hay nada cargado */}
      {!hasAnyContent && (
        <Card>
          <CardContent className="flex flex-col items-start gap-2 pt-4">
            <p className="text-sm font-medium text-foreground">
              Todavía no hay contenido cargado en ValidApp.
            </p>
            <p className="text-sm text-muted-foreground">
              Empieza creando al menos una asignatura y un nivel; luego podrás
              agregar lecciones y preguntas.
            </p>
            <div className="mt-1 flex flex-wrap gap-2">
              <Link
                href="/admin/asignaturas"
                className={cn(buttonVariants({ variant: "default", size: "sm" }))}
              >
                Crear primera asignatura
              </Link>
              <Link
                href="/admin/niveles"
                className={cn(buttonVariants({ variant: "outline", size: "sm" }))}
              >
                Crear primer nivel
              </Link>
            </div>
          </CardContent>
        </Card>
      )}

      {/* 2. Tarjetas de estadísticas con datos reales */}
      <section aria-labelledby="resumen-datos" className="flex flex-col gap-3">
        <h2 id="resumen-datos" className="text-lg font-medium text-foreground">
          Datos generales
        </h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <StatCard
            title="Estudiantes registrados"
            value={summary.studentsRegistered}
            description="Cuentas con rol estudiante creadas en ValidApp."
            source="profiles"
            detailHref="/admin/resultados"
            emptyMessage="Aún no se ha registrado ningún estudiante."
          />
          <StatCard
            title="Asignaturas"
            value={summary.subjectsCount}
            description="Asignaturas disponibles para organizar contenido y preguntas."
            source="subjects"
            detailHref="/admin/asignaturas"
            emptyMessage="Aún no hay asignaturas creadas."
          />
          <StatCard
            title="Niveles"
            value={summary.levelsCount}
            description="Niveles/cursos disponibles en la estructura curricular."
            source="levels"
            detailHref="/admin/niveles"
            emptyMessage="Aún no hay niveles creados."
          />
          <StatCard
            title="Lecciones creadas"
            value={summary.lessonsCount}
            description="Lecciones cargadas y visibles para los estudiantes (no existe un estado de borrador para lecciones)."
            source="lessons"
            detailHref="/admin/lecciones"
            emptyMessage="Aún no hay lecciones creadas."
          />
          <StatCard
            title="Preguntas en el banco"
            value={summary.questionsTotal}
            description="Total de preguntas registradas, en cualquier estado de revisión."
            source="questions"
            detailHref="/admin/preguntas"
            emptyMessage="Aún no hay preguntas creadas."
          />
          <StatCard
            title="Diagnósticos completados"
            value={summary.diagnosticsCompleted}
            description="Diagnósticos rendidos por estudiantes en total (histórico)."
            source="diagnostics"
            detailHref="/admin/resultados"
            emptyMessage="Aún no se ha rendido ningún diagnóstico."
          />
          <StatCard
            title="Preguntas sin retroalimentación"
            value={summary.questionsMissingExplanation}
            description="Preguntas sin explicación escrita para el estudiante tras responder."
            source="questions.explanation"
            detailHref="/admin/preguntas"
            emptyMessage="Todas las preguntas tienen retroalimentación escrita."
          />
          <StatCard
            title="Preguntas sin objetivo de aprendizaje"
            value={summary.questionsMissingObjective}
            description="Preguntas no asociadas a un objetivo de aprendizaje, lo que afecta la cobertura curricular."
            source="questions.learning_objective_id"
            detailHref="/admin/objetivos-aprendizaje"
            emptyMessage="Todas las preguntas están asociadas a un objetivo de aprendizaje."
          />
        </div>
      </section>

      {/* 3. Indicadores aún no calculables */}
      <section aria-labelledby="resumen-pendientes" className="flex flex-col gap-3">
        <h2 id="resumen-pendientes" className="text-lg font-medium text-foreground">
          Indicadores en desarrollo
        </h2>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <PendingMetricCard
            title="Estudiantes activos"
            description="Aún no se registra la última actividad de cada estudiante, por lo que no es posible calcular quiénes están activos."
          />
          <PendingMetricCard
            title="Tendencias y comparaciones"
            description="Todavía no se guarda un historial por periodo, por lo que no es posible comparar contra semanas o meses anteriores."
          />
        </div>
      </section>

      {/* 4. Resúmenes compactos: cobertura, banco de preguntas y actividad */}
      <section
        aria-labelledby="resumen-secciones"
        className="grid grid-cols-1 gap-4 lg:grid-cols-3"
      >
        <h2 id="resumen-secciones" className="sr-only">
          Resúmenes por sección
        </h2>

        <Card>
          <CardHeader>
            <CardTitle>Cobertura curricular</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col gap-2">
            <p className="text-sm text-muted-foreground">
              {summary.coverage.objectivesWithoutQuestionsCount} objetivo(s) sin
              preguntas aprobadas · {summary.coverage.objectivesWithInsufficientCoverageCount}{" "}
              con cobertura insuficiente.
            </p>
            <Link
              href="/admin/cobertura"
              className="text-sm font-medium text-primary underline-offset-4 hover:underline"
            >
              Ver todo
            </Link>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Banco de preguntas</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col gap-2">
            {summary.questionsTotal === 0 ? (
              <p className="text-sm text-muted-foreground">
                Aún no hay preguntas cargadas.
              </p>
            ) : (
              <div className="flex flex-wrap gap-1.5">
                {(Object.keys(summary.questionsByStatus) as Array<
                  keyof typeof summary.questionsByStatus
                >).map((status) => (
                  <Badge key={status} variant={REVIEW_STATUS_VARIANT[status]}>
                    {REVIEW_STATUS_LABEL[status]}: {summary.questionsByStatus[status]}
                  </Badge>
                ))}
              </div>
            )}
            <Link
              href="/admin/preguntas"
              className="text-sm font-medium text-primary underline-offset-4 hover:underline"
            >
              Ver banco de preguntas
            </Link>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Actividad y resultados</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col gap-2">
            <p className="text-sm text-muted-foreground">
              {summary.studentsRegistered} estudiante(s) registrado(s) han
              completado {summary.diagnosticsCompleted} diagnóstico(s) en
              total. Datos agregados, sin información individual.
            </p>
            <div className="flex flex-wrap gap-x-4 gap-y-1">
              <Link
                href="/admin/resultados"
                className="text-sm font-medium text-primary underline-offset-4 hover:underline"
              >
                Ver resultados
              </Link>
              <Link
                href="/admin/estadisticas"
                className="text-sm font-medium text-primary underline-offset-4 hover:underline"
              >
                Ver estadísticas de preguntas
              </Link>
            </div>
          </CardContent>
        </Card>
      </section>

      {/* 5. Alertas administrativas */}
      <section aria-labelledby="resumen-alertas" className="flex flex-col gap-3">
        <h2 id="resumen-alertas" className="text-lg font-medium text-foreground">
          Alertas
        </h2>
        {alerts.length === 0 ? (
          <Card>
            <CardContent className="pt-4">
              <p className="text-sm text-muted-foreground">
                No hay alertas pendientes por ahora.
              </p>
            </CardContent>
          </Card>
        ) : (
          <ul className="flex flex-col gap-2">
            {alerts.map((alert) => (
              <li
                key={alert.key}
                className="flex flex-col gap-2 rounded-lg border border-warning/40 bg-warning/10 px-3 py-2.5 sm:flex-row sm:items-center sm:justify-between"
              >
                <div className="flex items-start gap-2">
                  <AlertTriangle
                    className="mt-0.5 size-4 shrink-0 text-warning-foreground"
                    aria-hidden="true"
                  />
                  <span className="text-sm text-foreground">{alert.text}</span>
                </div>
                <Link
                  href={alert.href}
                  className="shrink-0 text-sm font-medium text-primary underline-offset-4 hover:underline"
                >
                  {alert.linkLabel}
                </Link>
              </li>
            ))}
          </ul>
        )}
      </section>

      {/* 6. Acciones rápidas */}
      <section aria-labelledby="resumen-acciones" className="flex flex-col gap-3">
        <h2 id="resumen-acciones" className="text-lg font-medium text-foreground">
          Acciones rápidas
        </h2>
        <div className="flex flex-wrap gap-2">
          {QUICK_ACTIONS.map((action) => (
            <Link
              key={`${action.href}-${action.label}`}
              href={action.href}
              className={cn(buttonVariants({ variant: "outline", size: "sm" }))}
            >
              {action.label}
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
