import { CheckCircle2, Flame, Sparkles, Trophy } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ProgressBar } from "@/components/ui/progress-bar";

/**
 * Representación ilustrativa del panel del estudiante.
 * Contenido de ejemplo (temporal), no corresponde a datos reales.
 */
export function DashboardPreview() {
  return (
    <Card className="w-full max-w-sm shadow-lg ring-1 ring-border">
      <CardHeader className="flex flex-row items-center justify-between gap-2 border-b border-border pb-4">
        <div>
          <CardTitle className="text-base">Hola, Camila</CardTitle>
          <p className="text-xs text-muted-foreground">
            Preparando: Educación Media
          </p>
        </div>
        <span
          aria-hidden="true"
          className="flex items-center gap-1 rounded-full bg-warning/15 px-2.5 py-1 text-xs font-semibold text-warning-foreground"
        >
          <Flame className="size-3.5 text-warning" />
          5
        </span>
      </CardHeader>
      <CardContent className="flex flex-col gap-4 pt-4">
        <div className="flex flex-col gap-1.5">
          <ProgressBar value={68} label="Avance general" size="sm" />
        </div>

        <div className="flex flex-col gap-2 rounded-xl border border-primary/20 bg-primary/5 p-3">
          <span className="text-xs font-medium text-primary">
            Próxima actividad
          </span>
          <p className="text-sm font-medium text-foreground">
            Lenguaje: comprensión de textos
          </p>
          <span className="text-xs text-muted-foreground">
            ~10 min · 8 preguntas
          </span>
        </div>

        <div className="flex items-center justify-between rounded-xl border border-success/25 bg-success/10 p-3">
          <span className="flex items-center gap-2 text-sm text-foreground">
            <CheckCircle2 className="size-4 text-success" aria-hidden="true" />
            Respuesta correcta
          </span>
          <span className="flex items-center gap-1 text-xs font-semibold text-warning-foreground">
            <Trophy className="size-3.5 text-warning" aria-hidden="true" />
            +10 pts
          </span>
        </div>

        <div className="flex items-center gap-2 text-xs text-muted-foreground">
          <Sparkles className="size-3.5 text-secondary-foreground" aria-hidden="true" />
          Vista ilustrativa de la plataforma
        </div>
      </CardContent>
    </Card>
  );
}
