"use client";

import { useActionState } from "react";
import { generateEssay } from "@/lib/data/essays";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export function GeneratePanel({ essayId }: { essayId: string }) {
  const [state, formAction, pending] = useActionState(generateEssay, null);

  return (
    <Card>
      <CardHeader className="flex-row items-center justify-between gap-2 space-y-0">
        <CardTitle>Generar selección automática</CardTitle>
        <form action={formAction}>
          <input type="hidden" name="essayId" value={essayId} />
          <Button type="submit" size="sm" disabled={pending}>
            {pending ? "Generando..." : "Generar ensayo"}
          </Button>
        </form>
      </CardHeader>
      <CardContent className="flex flex-col gap-3">
        <p className="text-xs text-muted-foreground">
          Aplica las distribuciones guardadas y selecciona preguntas
          aprobadas. Puedes volver a generar cuantas veces quieras antes de
          publicar el ensayo.
        </p>

        {state?.error && <p className="text-sm text-destructive">{state.error}</p>}

        {state?.generatedCount != null && (
          <p className="text-sm text-success">
            Se seleccionaron {state.generatedCount} preguntas.
          </p>
        )}

        {state?.missing && state.missing.length > 0 && (
          <div className="rounded-lg bg-warning/20 px-3 py-2 text-sm text-warning-foreground">
            <p className="font-medium">
              No se pudo cumplir completamente la distribución solicitada:
            </p>
            <ul className="mt-1 flex flex-col gap-1">
              {state.missing.map((m, i) => (
                <li key={i}>
                  {m.subjectName && `Asignatura: ${m.subjectName}. `}
                  {m.objectiveName && `Objetivo: ${m.objectiveName}. `}
                  {m.difficulty && `Dificultad: ${m.difficulty}. `}
                  Disponibles: {m.available}, faltan: {m.missing}.
                </li>
              ))}
            </ul>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
