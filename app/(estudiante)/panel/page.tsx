import Link from "next/link";
import {
  Award,
  BookOpenCheck,
  ChevronRight,
  ClipboardList,
  Flame,
  ListChecks,
  Rocket,
  Sparkles,
  Target,
  Timer,
  Trophy,
  UserRound,
} from "lucide-react";
import { getCurrentProfile } from "@/lib/data/profiles";
import { signOut } from "@/lib/data/auth";
import { getGamificationStats } from "@/lib/data/gamification";
import { getDashboardSummary } from "@/lib/data/progress";
import { BADGE_LABELS } from "@/lib/gamification-labels";
import { Button, buttonVariants } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ProgressBar } from "@/components/ui/progress-bar";
import { cn } from "@/lib/utils";

function nextGoalMessage(points: number, streak: number) {
  if (streak < 3) {
    const remaining = 3 - streak;
    return `Estudia ${remaining} día${remaining === 1 ? "" : "s"} más seguido${
      remaining === 1 ? "" : "s"
    } para ganar tu insignia de racha.`;
  }
  const nextTier = points < 100 ? 100 : points < 300 ? 300 : points + 100;
  if (points < nextTier) {
    return `Te faltan ${nextTier - points} puntos para llegar a ${nextTier}.`;
  }
  return "Vas muy bien. Define una nueva meta esta semana.";
}

export default async function PanelEstudiante() {
  const profile = await getCurrentProfile();

  if (!profile) {
    return (
      <main className="mx-auto flex min-h-screen w-full max-w-xl flex-col items-center justify-center gap-4 px-4 py-12 text-center">
        <Card className="w-full">
          <CardHeader>
            <CardTitle className="text-lg">
              No pudimos cargar tu panel
            </CardTitle>
            <CardDescription>
              Tu sesión pudo haber caducado. Inicia sesión de nuevo para
              continuar.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Link
              href="/login"
              className={cn(buttonVariants({ variant: "default" }), "w-full")}
            >
              Ir a iniciar sesión
            </Link>
          </CardContent>
        </Card>
      </main>
    );
  }

  const [stats, summary] = await Promise.all([
    getGamificationStats(profile.id),
    getDashboardSummary(),
  ]);

  const points = stats?.total_points ?? 0;
  const streak = stats?.current_streak ?? 0;
  const badges = stats?.badges ?? [];

  const isNewStudent =
    !summary?.hasAnyDiagnostic && (summary?.completedLessons ?? 0) === 0;

  const primaryAction = isNewStudent
    ? { href: "/diagnostico", label: "Rendir mi diagnóstico inicial" }
    : summary?.nextActivity
      ? {
          href: `/leccion/${summary.nextActivity.lessonId}`,
          label: "Continuar aprendiendo",
        }
      : { href: "/ruta", label: "Continuar aprendiendo" };

  const welcomeMessage = isNewStudent
    ? "Bienvenido a ValidApp. Empecemos por conocer tu nivel."
    : streak >= 3
      ? `Llevas ${streak} días seguidos estudiando. ¡Vas muy bien!`
      : "Cada lección te acerca a tu examen. Sigamos avanzando.";

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-6 bg-background px-4 py-8 text-foreground sm:px-6 sm:py-12">
      <div className="flex items-center justify-between">
        <span className="text-sm font-medium text-muted-foreground">
          ValidApp
        </span>
        <form action={signOut}>
          <Button type="submit" variant="link" size="sm" className="text-muted-foreground">
            Cerrar sesión
          </Button>
        </form>
      </div>

      {/* 1. Encabezado de bienvenida */}
      <Card>
        <CardHeader>
          <CardTitle className="text-xl">
            Hola, {profile.full_name || "estudiante"}
          </CardTitle>
          <CardDescription>{welcomeMessage}</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          {profile.target_level && (
            <span className="inline-flex w-fit items-center gap-1.5 rounded-full border border-primary/30 bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
              <Target className="size-3.5" aria-hidden="true" />
              Preparando: {profile.target_level}
            </span>
          )}
          <Link
            href={primaryAction.href}
            className={cn(
              buttonVariants({ variant: "default", size: "lg" }),
              "w-full sm:w-auto"
            )}
          >
            {primaryAction.label}
          </Link>
        </CardContent>
      </Card>

      {isNewStudent ? (
        <>
          {/* 8. Orientación inicial */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">
                Aún no tienes progreso registrado
              </CardTitle>
              <CardDescription>
                Sigue estos pasos para comenzar tu preparación.
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
              {[
                "Rinde tu diagnóstico inicial para conocer tu nivel actual.",
                "Recibirás una ruta educativa hecha a tu medida.",
                "Avanza lección por lección, a tu ritmo.",
              ].map((step, index) => (
                <div key={step} className="flex items-start gap-3">
                  <span
                    aria-hidden="true"
                    className="flex size-6 shrink-0 items-center justify-center rounded-full bg-primary/10 text-xs font-semibold text-primary"
                  >
                    {index + 1}
                  </span>
                  <p className="text-sm text-foreground/90">{step}</p>
                </div>
              ))}
              <Link
                href="/diagnostico"
                className={cn(
                  buttonVariants({ variant: "default" }),
                  "mt-1 w-full sm:w-auto"
                )}
              >
                Comenzar diagnóstico
              </Link>
            </CardContent>
          </Card>
        </>
      ) : (
        <>
          {/* 2. Resumen del progreso */}
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
            <Card size="sm">
              <CardContent className="flex flex-col gap-2">
                <span className="text-xs font-medium text-muted-foreground">
                  Avance general
                </span>
                <ProgressBar
                  value={summary?.overallPercent ?? 0}
                  showValue={false}
                  size="sm"
                />
                <span className="text-lg font-semibold">
                  {summary?.overallPercent ?? 0}%
                </span>
              </CardContent>
            </Card>
            <Card size="sm">
              <CardContent className="flex flex-col gap-1">
                <span className="text-xs font-medium text-muted-foreground">
                  Lecciones completadas
                </span>
                <span className="text-lg font-semibold">
                  {summary?.completedLessons ?? 0}
                  <span className="text-sm font-normal text-muted-foreground">
                    {" "}
                    / {summary?.totalLessons ?? 0}
                  </span>
                </span>
              </CardContent>
            </Card>
            <Card size="sm">
              <CardContent className="flex flex-col gap-1">
                <span className="text-xs font-medium text-muted-foreground">
                  Preguntas respondidas
                </span>
                <span className="text-lg font-semibold">
                  {summary?.questionsAnswered ?? 0}
                </span>
                <span className="text-xs text-muted-foreground">
                  {summary?.accuracyPercent !== null &&
                  summary?.accuracyPercent !== undefined
                    ? `${summary.accuracyPercent}% de aciertos`
                    : "Aún sin datos"}
                </span>
              </CardContent>
            </Card>
            <Card size="sm">
              <CardContent className="flex flex-col gap-1">
                <span className="text-xs font-medium text-muted-foreground">
                  Racha de estudio
                </span>
                <span className="flex items-center gap-1.5 text-lg font-semibold">
                  <Flame className="size-4 text-warning" aria-hidden="true" />
                  {streak} {streak === 1 ? "día" : "días"}
                </span>
              </CardContent>
            </Card>
          </div>

          {/* 3. Próxima actividad */}
          {summary?.nextActivity ? (
            <Card className="ring-2 ring-primary/20">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-base">
                  <Rocket className="size-4 text-primary" aria-hidden="true" />
                  Tu próxima actividad
                </CardTitle>
                <CardDescription>
                  {summary.nextActivity.subjectName}
                  {summary.nextActivity.levelName
                    ? ` · ${summary.nextActivity.levelName}`
                    : ""}
                </CardDescription>
              </CardHeader>
              <CardContent className="flex flex-col gap-3">
                <p className="text-sm font-medium text-foreground">
                  {summary.nextActivity.lessonTitle}
                </p>
                <div className="flex flex-wrap gap-2 text-xs text-muted-foreground">
                  <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
                    <Timer className="size-3.5" aria-hidden="true" />
                    ~{summary.nextActivity.estimatedMinutes} min
                  </span>
                  <span className="inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-1">
                    <ListChecks className="size-3.5" aria-hidden="true" />
                    {summary.nextActivity.questionCount} preguntas
                  </span>
                  <span className="inline-flex items-center gap-1 rounded-full border border-secondary/40 bg-secondary/15 px-2 py-1 text-foreground">
                    {summary.nextActivity.difficultyLabel}
                  </span>
                </div>
                <Link
                  href={`/leccion/${summary.nextActivity.lessonId}`}
                  className={cn(
                    buttonVariants({ variant: "default" }),
                    "w-full sm:w-auto"
                  )}
                >
                  Comenzar actividad
                </Link>
              </CardContent>
            </Card>
          ) : (
            <Card>
              <CardHeader>
                <CardTitle className="text-base">
                  ¡Completaste tus lecciones disponibles!
                </CardTitle>
                <CardDescription>
                  Rinde un nuevo diagnóstico para desbloquear otra asignatura
                  o revisa tu ruta.
                </CardDescription>
              </CardHeader>
            </Card>
          )}

          {/* 4. Progreso por asignatura */}
          <Card id="progreso-asignaturas">
            <CardHeader>
              <CardTitle className="text-base">
                Progreso por asignatura
              </CardTitle>
              <CardDescription>
                Entra a cada asignatura para ver tu ruta completa.
              </CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-3">
              {(summary?.subjects.length ?? 0) === 0 && (
                <p className="text-sm text-muted-foreground">
                  Aún no hay asignaturas disponibles.
                </p>
              )}
              {summary?.subjects.map((subject) => (
                <Link
                  key={subject.id}
                  href={`/ruta/${subject.id}`}
                  className="flex items-center gap-3 rounded-xl border border-border bg-card px-4 py-3 transition-colors hover:bg-muted"
                >
                  <span
                    aria-hidden="true"
                    className="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary/10 text-primary"
                  >
                    <BookOpenCheck className="size-5" />
                  </span>
                  <div className="flex min-w-0 flex-1 flex-col gap-1.5">
                    <div className="flex items-center justify-between gap-2">
                      <span className="truncate font-medium text-foreground">
                        {subject.name}
                      </span>
                      <span className="shrink-0 text-xs text-muted-foreground">
                        {subject.completedLessons}/{subject.totalLessons}
                      </span>
                    </div>
                    <ProgressBar
                      value={subject.percent}
                      showValue={false}
                      size="sm"
                    />
                  </div>
                  <ChevronRight
                    className="size-4 shrink-0 text-muted-foreground"
                    aria-hidden="true"
                  />
                </Link>
              ))}
            </CardContent>
          </Card>
        </>
      )}

      {/* 5. Información educativa */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">¿Cómo funciona ValidApp?</CardTitle>
          <CardDescription>
            Tus actividades están alineadas con los contenidos de los
            exámenes libres.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
            {[
              { label: "Aprende", icon: BookOpenCheck },
              { label: "Practica", icon: ListChecks },
              { label: "Retroalimentación", icon: Sparkles },
              { label: "Avanza", icon: Rocket },
            ].map(({ label, icon: Icon }) => (
              <div
                key={label}
                className="flex flex-col items-center gap-2 rounded-xl border border-border bg-muted/50 px-2 py-3 text-center"
              >
                <Icon className="size-5 text-primary" aria-hidden="true" />
                <span className="text-xs font-medium text-foreground">
                  {label}
                </span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* 6. Logros y motivación */}
      {stats && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Tus logros</CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col gap-3">
            <div className="flex flex-wrap gap-4">
              <div className="flex items-center gap-2">
                <span
                  aria-hidden="true"
                  className="flex size-8 items-center justify-center rounded-full bg-warning/15 text-warning"
                >
                  <Trophy className="size-4" />
                </span>
                <span className="text-sm">
                  <strong className="font-semibold">{points}</strong> puntos
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span
                  aria-hidden="true"
                  className="flex size-8 items-center justify-center rounded-full bg-secondary/20 text-secondary-foreground"
                >
                  <Flame className="size-4" />
                </span>
                <span className="text-sm">
                  Racha: <strong className="font-semibold">{streak}</strong>{" "}
                  días
                </span>
              </div>
            </div>

            {badges.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {badges.map((badge) => (
                  <span
                    key={badge}
                    className="inline-flex items-center gap-1 rounded-full border border-warning/30 bg-warning/10 px-3 py-1 text-xs"
                  >
                    <Award className="size-3.5" aria-hidden="true" />
                    {BADGE_LABELS[badge] ?? badge}
                  </span>
                ))}
              </div>
            )}

            <p className="text-xs text-muted-foreground">
              {nextGoalMessage(points, streak)}
            </p>
          </CardContent>
        </Card>
      )}

      {/* 7. Accesos rápidos */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Accesos rápidos</CardTitle>
        </CardHeader>
        <CardContent className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          <Link
            href={primaryAction.href}
            className="flex flex-col items-center gap-1.5 rounded-xl border border-border bg-card px-3 py-4 text-center text-xs font-medium transition-colors hover:bg-muted"
          >
            <Rocket className="size-5 text-primary" aria-hidden="true" />
            Continuar
          </Link>
          <Link
            href="/diagnostico"
            className="flex flex-col items-center gap-1.5 rounded-xl border border-border bg-card px-3 py-4 text-center text-xs font-medium transition-colors hover:bg-muted"
          >
            <Target className="size-5 text-primary" aria-hidden="true" />
            Diagnóstico
          </Link>
          <Link
            href="/ruta"
            className="flex flex-col items-center gap-1.5 rounded-xl border border-border bg-card px-3 py-4 text-center text-xs font-medium transition-colors hover:bg-muted"
          >
            <ListChecks className="size-5 text-primary" aria-hidden="true" />
            Practicar
          </Link>
          <Link
            href="/ensayos"
            className="flex flex-col items-center gap-1.5 rounded-xl border border-border bg-card px-3 py-4 text-center text-xs font-medium transition-colors hover:bg-muted"
          >
            <ClipboardList className="size-5 text-primary" aria-hidden="true" />
            Ensayos
          </Link>
          <span className="flex flex-col items-center gap-1.5 rounded-xl border border-dashed border-border bg-muted/40 px-3 py-4 text-center text-xs font-medium text-muted-foreground">
            <BookOpenCheck className="size-5" aria-hidden="true" />
            Revisar errores
            <span className="text-[0.65rem]">Próximamente</span>
          </span>
          <a
            href="#progreso-asignaturas"
            className="flex flex-col items-center gap-1.5 rounded-xl border border-border bg-card px-3 py-4 text-center text-xs font-medium transition-colors hover:bg-muted"
          >
            <Sparkles className="size-5 text-primary" aria-hidden="true" />
            Ver progreso
          </a>
          <Link
            href="/perfil"
            className="flex flex-col items-center gap-1.5 rounded-xl border border-border bg-card px-3 py-4 text-center text-xs font-medium transition-colors hover:bg-muted"
          >
            <UserRound className="size-5 text-primary" aria-hidden="true" />
            Mi perfil
          </Link>
        </CardContent>
      </Card>
    </main>
  );
}
