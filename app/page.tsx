import Link from "next/link";
import type { Metadata } from "next";
import {
  BookOpenCheck,
  Building2,
  ClipboardCheck,
  GraduationCap,
  HeartHandshake,
  Route,
  ShieldCheck,
  Sparkles,
  Target,
  TrendingUp,
} from "lucide-react";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SiteHeader } from "@/components/marketing/site-header";
import { SiteFooter } from "@/components/marketing/site-footer";
import { DashboardPreview } from "@/components/marketing/dashboard-preview";
import { ExperiencePreview } from "@/components/marketing/experience-preview";
import { LeadForm } from "@/components/marketing/lead-form";
import { cn } from "@/lib/utils";

export const metadata: Metadata = {
  title: "ValidApp | Prepara tus exámenes libres en Chile",
  description:
    "ValidApp es la plataforma chilena para preparar exámenes libres de validación de estudios: diagnóstico inicial, ruta de aprendizaje personalizada, práctica con retroalimentación inmediata y seguimiento de tu progreso.",
  keywords: [
    "exámenes libres",
    "validación de estudios",
    "MINEDUC",
    "educación de adultos",
    "ValidApp",
    "preparar examen libre Chile",
  ],
  openGraph: {
    title: "ValidApp | Prepara tus exámenes libres en Chile",
    description:
      "Diagnóstico inicial, ruta de aprendizaje personalizada y práctica guiada para rendir tu examen libre con confianza.",
    locale: "es_CL",
    type: "website",
  },
};

const PROBLEMAS = [
  {
    icon: Route,
    title: "Falta de orientación",
    description:
      "No siempre queda claro por dónde empezar ni qué contenidos rendirás.",
  },
  {
    icon: BookOpenCheck,
    title: "Contenidos dispersos",
    description:
      "El material para estudiar suele estar repartido en muchos lugares distintos.",
  },
  {
    icon: Sparkles,
    title: "Poca retroalimentación",
    description:
      "Practicar sin saber en qué te equivocas hace más lento tu avance.",
  },
];

const PASOS = [
  {
    icon: Target,
    title: "Realiza un diagnóstico",
    description: "Responde preguntas breves para conocer tu nivel actual.",
  },
  {
    icon: Route,
    title: "Obtén tu ruta personalizada",
    description: "Recibimos tus resultados y armamos un camino a tu medida.",
  },
  {
    icon: Sparkles,
    title: "Aprende y practica",
    description: "Avanza lección por lección con retroalimentación inmediata.",
  },
  {
    icon: TrendingUp,
    title: "Revisa tu progreso",
    description: "Sigue tu avance y prepárate con confianza para rendir.",
  },
];

const BENEFICIOS = [
  {
    icon: Target,
    title: "Diagnóstico inicial",
    description: "Conocemos tu punto de partida antes de armar tu ruta.",
  },
  {
    icon: Route,
    title: "Ruta adaptativa",
    description: "Tu camino de aprendizaje se ajusta a tu propio ritmo.",
  },
  {
    icon: BookOpenCheck,
    title: "Preguntas y explicaciones",
    description: "Cada pregunta viene con una explicación educativa clara.",
  },
  {
    icon: ClipboardCheck,
    title: "Simulaciones de examen",
    description: "Practica en un formato parecido al examen real.",
  },
  {
    icon: Sparkles,
    title: "Gamificación y motivación",
    description: "Puntos, rachas e insignias que acompañan tu esfuerzo.",
  },
  {
    icon: TrendingUp,
    title: "Seguimiento del progreso",
    description: "Visualiza tu avance por asignatura en todo momento.",
  },
  {
    icon: GraduationCap,
    title: "Contenidos especializados",
    description: "Desarrollados específicamente para exámenes libres.",
  },
];

const PUBLICOS = [
  {
    icon: GraduationCap,
    title: "Adultos",
    description: "Que quieren terminar sus estudios básicos o medios.",
  },
  {
    icon: BookOpenCheck,
    title: "Jóvenes",
    description: "Que se preparan para rendir un examen libre.",
  },
  {
    icon: HeartHandshake,
    title: "Padres y apoderados",
    description: "Que quieren acompañar el aprendizaje de sus hijos e hijas.",
  },
  {
    icon: Building2,
    title: "Instituciones educativas",
    description: "Que apoyan procesos de nivelación de sus estudiantes.",
  },
];

const FAQS = [
  {
    question: "¿Qué son los exámenes libres?",
    answer:
      "Son evaluaciones que permiten validar estudios de educación básica o media sin haber asistido de forma regular a un establecimiento educacional.",
  },
  {
    question: "¿Para qué niveles sirve ValidApp?",
    answer:
      "ValidApp está pensado para quienes rendirán exámenes libres de educación básica y educación media.",
  },
  {
    question: "¿Los contenidos están alineados con el MINEDUC?",
    answer:
      "Sí, los contenidos y preguntas se organizan según el currículum oficial del MINEDUC para exámenes libres.",
  },
  {
    question: "¿Necesito conocimientos previos?",
    answer:
      "No. El diagnóstico inicial identifica tu nivel actual y desde ahí se arma tu ruta de aprendizaje.",
  },
  {
    question: "¿Puedo usar la plataforma desde el celular?",
    answer:
      "Sí, ValidApp está diseñada primero para celular y funciona igual de bien en computador.",
  },
  {
    question: "¿Cómo puedo participar en la prueba del MVP?",
    answer:
      "Completa el formulario al final de esta página o crea tu cuenta directamente para comenzar a probarla.",
  },
];

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col bg-background text-foreground">
      <SiteHeader />

      <main className="flex flex-1 flex-col">
        {/* 2. Sección principal */}
        <section className="mx-auto grid w-full max-w-6xl gap-10 px-4 py-14 sm:px-6 sm:py-20 lg:grid-cols-2 lg:items-center lg:gap-16">
          <div className="flex flex-col gap-6">
            <span className="inline-flex w-fit items-center gap-1.5 rounded-full border border-primary/30 bg-primary/10 px-3 py-1 text-xs font-medium text-primary">
              <ShieldCheck className="size-3.5" aria-hidden="true" />
              Contenidos alineados con el currículum del MINEDUC
            </span>
            <h1 className="text-3xl font-semibold tracking-tight text-balance sm:text-4xl lg:text-5xl">
              Terminar tus estudios sí es posible
            </h1>
            <p className="max-w-lg text-base text-muted-foreground sm:text-lg">
              Prepárate para tus exámenes libres con una ruta de aprendizaje
              adaptada a tu nivel, práctica guiada y seguimiento de tu
              progreso.
            </p>
            <div className="flex flex-col gap-3 sm:flex-row">
              <Link
                href="/registro"
                className={cn(
                  buttonVariants({ variant: "default", size: "lg" }),
                  "w-full sm:w-auto"
                )}
              >
                Quiero probar ValidApp
              </Link>
              <a
                href="#como-funciona"
                className={cn(
                  buttonVariants({ variant: "outline", size: "lg" }),
                  "w-full sm:w-auto"
                )}
              >
                Conocer cómo funciona
              </a>
            </div>
          </div>

          <div className="flex justify-center lg:justify-end">
            <DashboardPreview />
          </div>
        </section>

        {/* 3. Problema y propuesta de valor */}
        <section className="bg-muted/40 py-14 sm:py-20">
          <div className="mx-auto flex w-full max-w-6xl flex-col gap-8 px-4 sm:px-6">
            <div className="flex flex-col gap-3 text-center">
              <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
                Preparar un examen libre no debería ser difícil de organizar
              </h2>
              <p className="mx-auto max-w-2xl text-muted-foreground">
                ValidApp es una plataforma especializada que organiza tu
                aprendizaje y acompaña tu progreso en cada paso.
              </p>
            </div>
            <div className="grid gap-4 sm:grid-cols-3">
              {PROBLEMAS.map(({ icon: Icon, title, description }) => (
                <Card key={title}>
                  <CardContent className="flex flex-col gap-3 pt-4">
                    <span
                      aria-hidden="true"
                      className="flex size-10 items-center justify-center rounded-full bg-primary/10 text-primary"
                    >
                      <Icon className="size-5" />
                    </span>
                    <p className="font-medium text-foreground">{title}</p>
                    <p className="text-sm text-muted-foreground">
                      {description}
                    </p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </section>

        {/* 4. Cómo funciona */}
        <section
          id="como-funciona"
          className="mx-auto w-full max-w-6xl scroll-mt-20 px-4 py-14 sm:px-6 sm:py-20"
        >
          <div className="flex flex-col gap-3 text-center">
            <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
              Cómo funciona ValidApp
            </h2>
            <p className="mx-auto max-w-2xl text-muted-foreground">
              Cuatro pasos simples para ordenar tu preparación.
            </p>
          </div>
          <ol className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {PASOS.map(({ icon: Icon, title, description }, index) => (
              <li key={title}>
                <Card className="h-full">
                  <CardContent className="flex flex-col gap-3 pt-4">
                    <div className="flex items-center gap-2">
                      <span
                        aria-hidden="true"
                        className="flex size-8 items-center justify-center rounded-full bg-primary text-sm font-semibold text-primary-foreground"
                      >
                        {index + 1}
                      </span>
                      <Icon className="size-5 text-primary" aria-hidden="true" />
                    </div>
                    <p className="font-medium text-foreground">{title}</p>
                    <p className="text-sm text-muted-foreground">
                      {description}
                    </p>
                  </CardContent>
                </Card>
              </li>
            ))}
          </ol>
        </section>

        {/* 5. Beneficios principales */}
        <section
          id="beneficios"
          className="scroll-mt-20 bg-muted/40 py-14 sm:py-20"
        >
          <div className="mx-auto w-full max-w-6xl px-4 sm:px-6">
            <div className="flex flex-col gap-3 text-center">
              <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
                Todo lo que necesitas para rendir con confianza
              </h2>
            </div>
            <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              {BENEFICIOS.map(({ icon: Icon, title, description }) => (
                <Card key={title}>
                  <CardContent className="flex flex-col gap-3 pt-4">
                    <span
                      aria-hidden="true"
                      className="flex size-10 items-center justify-center rounded-full bg-secondary/25 text-secondary-foreground"
                    >
                      <Icon className="size-5" />
                    </span>
                    <p className="font-medium text-foreground">{title}</p>
                    <p className="text-sm text-muted-foreground">
                      {description}
                    </p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </section>

        {/* 6. Demostración de la experiencia */}
        <section className="mx-auto w-full max-w-6xl px-4 py-14 sm:px-6 sm:py-20">
          <div className="flex flex-col gap-3 text-center">
            <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
              Así se ve aprender con ValidApp
            </h2>
            <p className="mx-auto max-w-2xl text-muted-foreground">
              Ejemplos ilustrativos de una pregunta de práctica y del
              resumen de avance por asignatura.
            </p>
          </div>
          <div className="mt-10">
            <ExperiencePreview />
          </div>
        </section>

        {/* 7. Público objetivo */}
        <section className="bg-muted/40 py-14 sm:py-20">
          <div className="mx-auto w-full max-w-6xl px-4 sm:px-6">
            <div className="flex flex-col gap-3 text-center">
              <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
                Pensado para toda la comunidad educativa
              </h2>
            </div>
            <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
              {PUBLICOS.map(({ icon: Icon, title, description }) => (
                <Card key={title}>
                  <CardContent className="flex flex-col items-center gap-3 pt-4 text-center">
                    <span
                      aria-hidden="true"
                      className="flex size-12 items-center justify-center rounded-full bg-primary/10 text-primary"
                    >
                      <Icon className="size-6" />
                    </span>
                    <p className="font-medium text-foreground">{title}</p>
                    <p className="text-sm text-muted-foreground">
                      {description}
                    </p>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </section>

        {/* 8. Confianza y experiencia */}
        <section className="mx-auto w-full max-w-6xl px-4 py-14 sm:px-6 sm:py-20">
          <Card className="bg-accent text-accent-foreground">
            <CardContent className="flex flex-col gap-6 pt-6 sm:flex-row sm:items-center sm:gap-10">
              <span
                aria-hidden="true"
                className="flex size-14 shrink-0 items-center justify-center rounded-2xl bg-accent-foreground/10"
              >
                <ShieldCheck className="size-7" />
              </span>
              <div className="flex flex-col gap-2">
                <h2 className="text-xl font-semibold sm:text-2xl">
                  Siete años preparando estudiantes para sus exámenes libres
                </h2>
                <p className="max-w-2xl text-sm text-accent-foreground/90">
                  ValidApp nace de esa experiencia. Nuestros contenidos están
                  desarrollados específicamente para exámenes libres,
                  alineados con el currículum del MINEDUC.
                </p>
              </div>
            </CardContent>
          </Card>

          {/* Espacio reservado para testimonios (contenido pendiente) */}
          <div className="mt-6 rounded-2xl border border-dashed border-border bg-muted/30 p-6 text-center text-sm text-muted-foreground">
            Próximamente: testimonios de estudiantes que se prepararon con
            ValidApp.
          </div>
        </section>

        {/* 9. Preguntas frecuentes */}
        <section
          id="preguntas-frecuentes"
          className="scroll-mt-20 bg-muted/40 py-14 sm:py-20"
        >
          <div className="mx-auto w-full max-w-3xl px-4 sm:px-6">
            <div className="flex flex-col gap-3 text-center">
              <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
                Preguntas frecuentes
              </h2>
            </div>
            <div className="mt-8 flex flex-col gap-3">
              {FAQS.map(({ question, answer }) => (
                <details
                  key={question}
                  className="group rounded-xl border border-border bg-card px-4 py-3 open:shadow-sm"
                >
                  <summary className="flex cursor-pointer list-none items-center justify-between gap-3 font-medium text-foreground marker:content-none">
                    {question}
                    <span
                      aria-hidden="true"
                      className="shrink-0 text-muted-foreground transition-transform group-open:rotate-45"
                    >
                      +
                    </span>
                  </summary>
                  <p className="mt-2 text-sm text-muted-foreground">
                    {answer}
                  </p>
                </details>
              ))}
            </div>
          </div>
        </section>

        {/* 10. Llamado final */}
        <section
          id="contacto"
          className="mx-auto w-full max-w-3xl scroll-mt-20 px-4 py-14 sm:px-6 sm:py-20"
        >
          <div className="flex flex-col gap-3 text-center">
            <h2 className="text-2xl font-semibold tracking-tight sm:text-3xl">
              Da el primer paso para terminar tus estudios
            </h2>
            <p className="mx-auto max-w-xl text-muted-foreground">
              Cuéntanos un poco de ti y te avisaremos apenas puedas probar
              ValidApp. También puedes crear tu cuenta ahora mismo.
            </p>
          </div>

          <div className="mt-4 flex justify-center">
            <Link
              href="/registro"
              className={buttonVariants({ variant: "default", size: "lg" })}
            >
              Quiero probar ValidApp
            </Link>
          </div>

          <Card className="mt-8">
            <CardHeader>
              <CardTitle className="text-base">
                Déjanos tus datos
              </CardTitle>
            </CardHeader>
            <CardContent>
              <LeadForm />
            </CardContent>
          </Card>
        </section>
      </main>

      <SiteFooter />
    </div>
  );
}
