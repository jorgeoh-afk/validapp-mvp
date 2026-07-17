"use client";

import { useActionState, useState } from "react";
import { AlertTriangle, Loader2 } from "lucide-react";
import { startEssayAttempt } from "@/lib/data/essay-attempts";
import { Button } from "@/components/ui/button";

/**
 * El inicio de un intento no es reversible (se congela el barajado de
 * alternativas y el reloj empieza a correr si el ensayo tiene tiempo
 * límite), así que se pide una confirmación explícita antes de crear el
 * intento en el servidor.
 */
export function StartEssayButton({ essayId }: { essayId: string }) {
  const [confirming, setConfirming] = useState(false);
  const [state, formAction, isPending] = useActionState(startEssayAttempt, null);

  if (!confirming) {
    return (
      <Button size="lg" className="w-full" onClick={() => setConfirming(true)}>
        Comenzar ensayo
      </Button>
    );
  }

  return (
    <form action={formAction} className="flex flex-col gap-3">
      <input type="hidden" name="essayId" value={essayId} />
      <div className="flex items-start gap-2 rounded-xl bg-warning/10 p-4 text-sm text-foreground">
        <AlertTriangle
          className="mt-0.5 size-4 shrink-0 text-warning"
          aria-hidden="true"
        />
        <p>
          Una vez que comiences, este intento quedará registrado y no podrás
          deshacerlo. ¿Listo para empezar?
        </p>
      </div>
      {state?.error && (
        <p className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
          {state.error}
        </p>
      )}
      <div className="flex gap-2">
        <Button
          type="button"
          variant="outline"
          className="flex-1"
          onClick={() => setConfirming(false)}
          disabled={isPending}
        >
          Cancelar
        </Button>
        <Button type="submit" className="flex-1" disabled={isPending}>
          {isPending ? (
            <>
              <Loader2 className="size-4 animate-spin" aria-hidden="true" />
              Comenzando...
            </>
          ) : (
            "Sí, comenzar"
          )}
        </Button>
      </div>
    </form>
  );
}
