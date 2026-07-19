"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { AlertCircle, CheckCircle2 } from "lucide-react";
import { updatePassword } from "@/lib/data/account-security";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function PasswordForm() {
  const [state, formAction, pending] = useActionState(updatePassword, null);
  const formRef = useRef<HTMLFormElement>(null);
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  // Validación en el cliente: evita el viaje al servidor si las dos
  // contraseñas nuevas no coinciden. El servidor vuelve a validar esto
  // (y todo lo demás) por si acaso, así que esto es solo para mejor UX.
  const mismatch = confirmPassword.length > 0 && newPassword !== confirmPassword;

  // Ajuste de estado durante el render (no dentro de un efecto): cuando el
  // envío termina en éxito, se limpian los campos controlados. Es el mismo
  // patrón que React recomienda para "ajustar estado cuando cambia una
  // prop", en vez de llamar a setState desde un efecto.
  const [lastHandledState, setLastHandledState] = useState(state);
  if (state !== lastHandledState) {
    setLastHandledState(state);
    if (state?.status === "success") {
      setNewPassword("");
      setConfirmPassword("");
    }
  }

  // El campo de contraseña actual no es controlado (no necesita estado
  // para la validación de coincidencia), así que se limpia vía DOM en un
  // efecto que no llama a setState.
  useEffect(() => {
    if (state?.status === "success") {
      formRef.current?.reset();
    }
  }, [state]);

  return (
    <form
      ref={formRef}
      action={formAction}
      className="flex flex-col gap-4"
      onSubmit={(event) => {
        if (newPassword !== confirmPassword) {
          event.preventDefault();
        }
      }}
    >
      <div className="flex flex-col gap-2">
        <Label htmlFor="currentPassword">Contraseña actual</Label>
        <Input
          id="currentPassword"
          name="currentPassword"
          type="password"
          autoComplete="current-password"
          required
        />
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="newPassword">Nueva contraseña</Label>
        <Input
          id="newPassword"
          name="newPassword"
          type="password"
          autoComplete="new-password"
          minLength={6}
          required
          value={newPassword}
          onChange={(event) => setNewPassword(event.target.value)}
        />
      </div>

      <div className="flex flex-col gap-2">
        <Label htmlFor="confirmPassword">Confirma tu nueva contraseña</Label>
        <Input
          id="confirmPassword"
          name="confirmPassword"
          type="password"
          autoComplete="new-password"
          minLength={6}
          required
          value={confirmPassword}
          onChange={(event) => setConfirmPassword(event.target.value)}
        />
      </div>

      <div aria-live="polite">
        {mismatch && (
          <p className="flex items-center gap-2 rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
            <AlertCircle className="size-4 shrink-0" aria-hidden="true" />
            La nueva contraseña y su confirmación no coinciden.
          </p>
        )}
        {!mismatch && state?.status === "error" && (
          <p className="flex items-center gap-2 rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
            <AlertCircle className="size-4 shrink-0" aria-hidden="true" />
            {state.message}
          </p>
        )}
        {!mismatch && state?.status === "success" && (
          <p className="flex items-center gap-2 rounded-xl bg-success/10 p-3 text-sm text-success">
            <CheckCircle2 className="size-4 shrink-0" aria-hidden="true" />
            Listo, tu contraseña quedó actualizada. Cerramos tu sesión en
            otros dispositivos por seguridad.
          </p>
        )}
      </div>

      <Button
        type="submit"
        disabled={pending || mismatch}
        size="lg"
        className="w-full sm:w-fit"
      >
        {pending ? "Actualizando..." : "Actualizar contraseña"}
      </Button>
    </form>
  );
}
