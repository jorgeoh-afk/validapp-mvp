"use client";

import { useState, type FormEvent } from "react";
import { CheckCircle2, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const REGIONES = [
  "Arica y Parinacota",
  "Tarapacá",
  "Antofagasta",
  "Atacama",
  "Coquimbo",
  "Valparaíso",
  "Metropolitana de Santiago",
  "Libertador General Bernardo O'Higgins",
  "Maule",
  "Ñuble",
  "Biobío",
  "La Araucanía",
  "Los Ríos",
  "Los Lagos",
  "Aysén",
  "Magallanes y de la Antártica Chilena",
];

const NIVELES = [
  "Educación Básica",
  "Educación Media",
  "Aún no estoy seguro/a",
];

type Status = "idle" | "submitting" | "success" | "error";

/**
 * Formulario de interés para el MVP.
 * NOTA (temporal): por ahora solo simula el envío en el cliente.
 * Falta conectarlo a una tabla de leads en Supabase; no se debe
 * habilitar esa conexión sin autorización explícita.
 */
export function LeadForm() {
  const [status, setStatus] = useState<Status>("idle");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus("submitting");

    try {
      // TODO: reemplazar por un server action que guarde el interesado
      // en la tabla de leads de Supabase, previa autorización.
      await new Promise((resolve) => setTimeout(resolve, 700));
      setStatus("success");
    } catch {
      setStatus("error");
    }
  }

  if (status === "success") {
    return (
      <div
        role="status"
        className="flex flex-col items-center gap-3 rounded-2xl border border-success/30 bg-success/10 px-6 py-10 text-center"
      >
        <CheckCircle2 className="size-10 text-success" aria-hidden="true" />
        <p className="text-base font-semibold text-foreground">
          ¡Listo! Recibimos tus datos.
        </p>
        <p className="max-w-sm text-sm text-muted-foreground">
          Te contactaremos pronto para invitarte a probar ValidApp. Mientras
          tanto, puedes crear tu cuenta y empezar ahora mismo.
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4">
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="flex flex-col gap-2">
          <Label htmlFor="lead-name">Nombre</Label>
          <Input id="lead-name" name="name" type="text" autoComplete="name" required />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="lead-age">Edad</Label>
          <Input
            id="lead-age"
            name="age"
            type="number"
            min={12}
            max={99}
            inputMode="numeric"
            required
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="lead-email">Correo</Label>
          <Input id="lead-email" name="email" type="email" autoComplete="email" required />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="lead-phone">Teléfono</Label>
          <Input
            id="lead-phone"
            name="phone"
            type="tel"
            autoComplete="tel"
            placeholder="+56 9 1234 5678"
            required
          />
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="lead-region">Región</Label>
          <select
            id="lead-region"
            name="region"
            required
            defaultValue=""
            className="h-8 w-full min-w-0 rounded-lg border border-input bg-transparent px-2.5 py-1 text-base outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 md:text-sm dark:bg-input/30"
          >
            <option value="" disabled>
              Selecciona tu región
            </option>
            {REGIONES.map((region) => (
              <option key={region} value={region}>
                {region}
              </option>
            ))}
          </select>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor="lead-level">Nivel que quieres validar</Label>
          <select
            id="lead-level"
            name="level"
            required
            defaultValue=""
            className="h-8 w-full min-w-0 rounded-lg border border-input bg-transparent px-2.5 py-1 text-base outline-none focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 md:text-sm dark:bg-input/30"
          >
            <option value="" disabled>
              Selecciona un nivel
            </option>
            {NIVELES.map((nivel) => (
              <option key={nivel} value={nivel}>
                {nivel}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="flex flex-col gap-3 rounded-xl border border-border bg-muted/40 p-3">
        <label className="flex items-start gap-2 text-xs text-muted-foreground">
          <input
            type="checkbox"
            name="consent-data"
            required
            className="mt-0.5 size-4 shrink-0 rounded border-input"
          />
          Autorizo el uso de mis datos para que ValidApp me contacte sobre la
          preparación de mi examen libre.
        </label>
        <label className="flex items-start gap-2 text-xs text-muted-foreground">
          <input
            type="checkbox"
            name="consent-guardian"
            required
            className="mt-0.5 size-4 shrink-0 rounded border-input"
          />
          Declaro ser mayor de edad o contar con la autorización de mi madre,
          padre o apoderado para completar este formulario.
        </label>
      </div>

      {status === "error" && (
        <p role="alert" className="text-sm text-destructive">
          No pudimos enviar tus datos. Intenta nuevamente en unos minutos.
        </p>
      )}

      <Button
        type="submit"
        size="lg"
        disabled={status === "submitting"}
        className="w-full sm:w-auto"
      >
        {status === "submitting" ? (
          <>
            <Loader2 className="size-4 animate-spin" aria-hidden="true" />
            Enviando...
          </>
        ) : (
          "Quiero probar ValidApp"
        )}
      </Button>
    </form>
  );
}
