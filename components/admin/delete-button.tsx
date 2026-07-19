"use client";

import { useActionState } from "react";
import { AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";

type FormState = { error: string } | null;

/**
 * Botón "Eliminar" reutilizable para las entidades de estructura curricular
 * de menor riesgo (programas, niveles educativos, ejes, unidades,
 * habilidades, objetivos de aprendizaje, grandes ideas, conocimientos
 * esenciales): no bloquean ni piden conteo de dependientes (ver
 * `ConfirmDeleteDialog` para las 5 entidades de alto riesgo), pero sí
 * capturan y muestran el error de Supabase en vez de ignorarlo en silencio.
 */
export function DeleteButton({
  id,
  action,
}: {
  id: string;
  action: (prevState: FormState, formData: FormData) => Promise<FormState>;
}) {
  const [state, formAction, pending] = useActionState(action, null);

  return (
    <form action={formAction} className="flex flex-col items-end gap-1">
      <input type="hidden" name="id" value={id} />
      <Button type="submit" variant="ghost" size="sm" disabled={pending}>
        {pending ? "Eliminando..." : "Eliminar"}
      </Button>
      <div aria-live="polite">
        {state?.error && (
          <p className="flex items-center gap-1.5 text-xs text-destructive">
            <AlertCircle className="size-3.5 shrink-0" aria-hidden="true" />
            {state.error}
          </p>
        )}
      </div>
    </form>
  );
}
