"use client";

import { useActionState } from "react";
import { AlertCircle, CheckCircle2 } from "lucide-react";
import { updateFullName } from "@/lib/data/profile-settings";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function ProfileForm({ fullName }: { fullName: string }) {
  const [state, formAction, pending] = useActionState(updateFullName, null);

  return (
    <form action={formAction} className="flex flex-col gap-4">
      <div className="flex flex-col gap-2">
        <Label htmlFor="fullName">Nombre completo</Label>
        <Input
          id="fullName"
          name="fullName"
          type="text"
          defaultValue={fullName}
          required
        />
      </div>

      <div aria-live="polite">
        {state?.status === "error" && (
          <p className="flex items-center gap-2 rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
            <AlertCircle className="size-4 shrink-0" aria-hidden="true" />
            {state.message}
          </p>
        )}
        {state?.status === "success" && (
          <p className="flex items-center gap-2 rounded-xl bg-success/10 p-3 text-sm text-success">
            <CheckCircle2 className="size-4 shrink-0" aria-hidden="true" />
            Guardamos tu nombre. Ya está actualizado en toda la app.
          </p>
        )}
      </div>

      <Button
        type="submit"
        disabled={pending}
        size="lg"
        className="w-full sm:w-fit"
      >
        {pending ? "Guardando..." : "Guardar cambios"}
      </Button>
    </form>
  );
}
