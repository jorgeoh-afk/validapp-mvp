import Link from "next/link";
import { PartyPopper, XCircle } from "lucide-react";
import { getStudentMistakes } from "@/lib/data/mistakes";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { requireEnrolledProfile } from "../_lib/enrollment";

const SOURCE_LABEL: Record<string, string> = {
  diagnostico: "Diagnóstico",
  ensayo: "Ensayo",
};

export default async function RevisarErroresPage() {
  await requireEnrolledProfile();
  const mistakes = await getStudentMistakes();

  const bySubject = new Map<string, { subjectName: string; items: typeof mistakes }>();
  for (const mistake of mistakes) {
    const group = bySubject.get(mistake.subjectId);
    if (group) {
      group.items.push(mistake);
    } else {
      bySubject.set(mistake.subjectId, {
        subjectName: mistake.subjectName,
        items: [mistake],
      });
    }
  }

  return (
    <main className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12">
      <Link
        href="/panel"
        className="flex w-fit items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:underline"
      >
        ← Mi panel
      </Link>

      <div className="flex flex-col gap-1.5">
        <h1 className="text-xl font-semibold text-foreground">
          Revisar errores
        </h1>
        <p className="text-sm text-muted-foreground">
          Las preguntas que fallaste en tus diagnósticos y ensayos, para que
          repases por qué y no se te vuelvan a escapar.
        </p>
      </div>

      {mistakes.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center gap-2 py-8 text-center">
            <PartyPopper
              className="size-8 text-warning"
              aria-hidden="true"
            />
            <p className="text-sm font-medium text-foreground">
              ¡Vas muy bien!
            </p>
            <p className="text-sm text-muted-foreground">
              Todavía no tienes errores para repasar. Cuando rindas un
              diagnóstico o un ensayo, las preguntas que falles van a
              aparecer aquí.
            </p>
          </CardContent>
        </Card>
      ) : (
        Array.from(bySubject.values()).map((group) => (
          <div key={group.subjectName} className="flex flex-col gap-3">
            <h2 className="text-sm font-semibold text-foreground">
              {group.subjectName}
            </h2>
            {group.items.map((mistake) => (
              <div
                key={`${mistake.source}-${mistake.sourceId}-${mistake.questionId}`}
                className="rounded-xl border border-destructive/30 bg-destructive/5 p-4"
              >
                <p className="flex items-start gap-2 text-sm font-medium text-foreground">
                  <XCircle
                    className="mt-0.5 size-4 shrink-0 text-destructive"
                    aria-hidden="true"
                  />
                  <span>{mistake.prompt}</span>
                </p>
                <p className="mt-2 pl-6 text-sm text-muted-foreground">
                  Tu respuesta:{" "}
                  {mistake.selectedIndex != null
                    ? mistake.choices[mistake.selectedIndex]
                    : "(sin responder)"}
                </p>
                <p className="pl-6 text-sm text-muted-foreground">
                  Respuesta correcta: {mistake.choices[mistake.correctIndex]}
                </p>
                {mistake.explanation && (
                  <p className="mt-1 pl-6 text-sm text-muted-foreground">
                    {mistake.explanation}
                  </p>
                )}
                <p className="mt-2 pl-6 text-xs text-muted-foreground">
                  {SOURCE_LABEL[mistake.source] ?? mistake.source}
                </p>
              </div>
            ))}
          </div>
        ))
      )}

      <Link
        href="/panel"
        className={cn(buttonVariants({ variant: "default", size: "lg" }), "w-full sm:w-fit")}
      >
        Volver a mi panel
      </Link>
    </main>
  );
}
