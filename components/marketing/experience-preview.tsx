import { Check, X } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ProgressBar } from "@/components/ui/progress-bar";
import { cn } from "@/lib/utils";

/**
 * Vistas ilustrativas de una pregunta y de un resumen por asignatura.
 * Contenido de ejemplo (temporal), no corresponde a preguntas reales
 * del banco de contenidos.
 */
export function ExperiencePreview() {
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <Card className="shadow-sm">
        <CardHeader className="pb-2">
          <CardTitle className="text-sm font-medium text-muted-foreground">
            Matemática · Pregunta 4 de 8
          </CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3 pt-2">
          <p className="text-sm font-medium text-foreground">
            ¿Cuál es el resultado de resolver 3x + 6 = 18?
          </p>
          <div className="flex flex-col gap-2">
            <span className="flex items-center justify-between rounded-lg border border-success/40 bg-success/10 px-3 py-2 text-sm text-foreground">
              x = 4
              <Check className="size-4 text-success" aria-hidden="true" />
            </span>
            <span className="flex items-center justify-between rounded-lg border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-muted-foreground">
              x = 8
              <X className="size-4 text-destructive" aria-hidden="true" />
            </span>
          </div>
          <p className="rounded-lg bg-muted px-3 py-2 text-xs text-muted-foreground">
            ¡Correcto! Para despejar x, resta 6 a ambos lados y luego divide
            por 3.
          </p>
        </CardContent>
      </Card>

      <Card className="shadow-sm">
        <CardHeader className="pb-2">
          <CardTitle className="text-sm font-medium text-muted-foreground">
            Resumen por asignatura
          </CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3 pt-2">
          {[
            { name: "Lenguaje", percent: 82 },
            { name: "Matemática", percent: 55 },
            { name: "Ciencias", percent: 30 },
          ].map((subject) => (
            <div key={subject.name} className="flex flex-col gap-1">
              <div className="flex items-center justify-between text-sm">
                <span className={cn("font-medium text-foreground")}>
                  {subject.name}
                </span>
                <span className="text-xs text-muted-foreground">
                  {subject.percent}%
                </span>
              </div>
              <ProgressBar value={subject.percent} showValue={false} size="sm" />
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}
