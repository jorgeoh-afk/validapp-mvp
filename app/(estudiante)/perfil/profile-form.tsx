"use client";

import { useActionState } from "react";
import { AlertCircle, CheckCircle2 } from "lucide-react";
import { updateProfile } from "@/lib/data/profile-settings";
import { TARGET_LEVEL_OPTIONS } from "@/lib/data/target-levels";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const SELECT_CLASSNAME =
  "h-8 w-full min-w-0 rounded-lg border border-input bg-transparent px-2.5 py-1 text-base transition-colors outline-none placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 md:text-sm dark:bg-input/30";

export function ProfileForm({
  fullName,
  targetLevel,
}: {
  fullName: string;
  targetLevel: string;
}) {
  const [state, formAction, pending] = useActionState(updateProfile, null);

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

      <div className="flex flex-col gap-2">
        <Label htmlFor="targetLevel">Nivel que estás preparando</Label>
        <select
          id="targetLevel"
          name="targetLevel"
          defaultValue={targetLevel}
          className={SELECT_CLASSNAME}
        >
          <option value="">Sin definir</option>
          {TARGET_LEVEL_OPTIONS.map((level) => (
            <option key={level} value={level}>
              {level}
            </option>
          ))}
        </select>
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
            Guardamos tus datos. Ya están actualizados en toda la app.
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
