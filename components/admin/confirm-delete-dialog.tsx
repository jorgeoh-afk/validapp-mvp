"use client";

import { useActionState, useState, useTransition } from "react";
import { AlertCircle, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";

type FormState = { error: string } | null;

export type DeleteImpact = {
  counts: { label: string; value: number }[];
  blockedReason?: string | null;
  /**
   * Efecto informativo NO destructivo (p. ej. una fila que queda con una
   * columna en `null` por un `on delete set null`, en vez de eliminarse).
   * Se muestra en tono neutro, separado de `counts` (que asume borrado real
   * vía `on delete cascade`) para no decir "esto eliminará" sobre algo que
   * en realidad solo pierde una referencia.
   */
  note?: string | null;
};

/**
 * Diálogo de confirmación reutilizable para las 5 entidades de alto riesgo
 * (asignaturas, niveles, lecciones, preguntas, ensayos): antes de eliminar,
 * consulta cuántas filas dependientes se perderían (`loadImpact`, llamado
 * solo al abrir el diálogo para no pagar esa consulta extra en cada fila de
 * la lista) y las muestra. Si `loadImpact` devuelve `blockedReason`, oculta
 * el botón de confirmar y explica por qué no se puede borrar (por ejemplo,
 * una pregunta ya usada en un ensayo generado, o un ensayo ya con intentos).
 * El servidor vuelve a verificar el mismo bloqueo de forma independiente
 * (ver `deleteQuestion`/`deleteEssay`), así que esto es una ayuda de UX, no
 * el único control.
 */
export function ConfirmDeleteDialog({
  id,
  itemLabel,
  action,
  loadImpact,
}: {
  id: string;
  itemLabel: string;
  action: (prevState: FormState, formData: FormData) => Promise<FormState>;
  loadImpact: (id: string) => Promise<DeleteImpact>;
}) {
  const [open, setOpen] = useState(false);
  const [impact, setImpact] = useState<DeleteImpact | null>(null);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [loading, startLoading] = useTransition();
  const [state, formAction, pending] = useActionState(action, null);

  function handleOpenChange(next: boolean) {
    setOpen(next);
    if (next && !impact && !loading) {
      setLoadError(null);
      startLoading(async () => {
        try {
          const result = await loadImpact(id);
          setImpact(result);
        } catch {
          setLoadError(
            "No se pudo calcular el impacto de este borrado. Intenta de nuevo."
          );
        }
      });
    }
  }

  const visibleCounts = impact?.counts.filter((c) => c.value > 0) ?? [];

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogTrigger
        render={<Button type="button" variant="ghost" size="sm" />}
      >
        Eliminar
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>¿Eliminar {itemLabel}?</DialogTitle>
          <DialogDescription>
            {loading && (
              <span className="flex items-center gap-2">
                <Loader2 className="size-4 animate-spin" aria-hidden="true" />
                Revisando qué se vería afectado...
              </span>
            )}
            {!loading && loadError && (
              <span className="flex items-center gap-1.5 text-destructive">
                <AlertCircle className="size-4 shrink-0" aria-hidden="true" />
                {loadError}
              </span>
            )}
            {!loading && !loadError && impact && !impact.blockedReason && (
              <>
                Esta acción no se puede deshacer.
                {visibleCounts.length > 0 && (
                  <>
                    {" "}
                    Esto también eliminará:
                    <ul className="mt-1 list-disc pl-5">
                      {visibleCounts.map((c) => (
                        <li key={c.label}>
                          {c.value} {c.label}
                        </li>
                      ))}
                    </ul>
                  </>
                )}
              </>
            )}
          </DialogDescription>
        </DialogHeader>

        {!loading && impact?.blockedReason && (
          <p
            role="alert"
            aria-live="polite"
            className="flex items-start gap-2 rounded-lg bg-destructive/10 p-3 text-sm text-destructive"
          >
            <AlertCircle className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
            {impact.blockedReason}
          </p>
        )}

        {!loading && !impact?.blockedReason && impact?.note && (
          <p className="rounded-lg bg-muted p-3 text-sm text-muted-foreground">
            {impact.note}
          </p>
        )}

        <div aria-live="polite">
          {state?.error && (
            <p className="flex items-center gap-1.5 text-sm text-destructive">
              <AlertCircle className="size-4 shrink-0" aria-hidden="true" />
              {state.error}
            </p>
          )}
        </div>

        <DialogFooter>
          <Button
            type="button"
            variant="outline"
            onClick={() => handleOpenChange(false)}
          >
            Cancelar
          </Button>
          {!impact?.blockedReason && (
            <form action={formAction}>
              <input type="hidden" name="id" value={id} />
              <Button
                type="submit"
                variant="destructive"
                disabled={pending || loading || Boolean(loadError)}
              >
                {pending ? "Eliminando..." : "Eliminar definitivamente"}
              </Button>
            </form>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
