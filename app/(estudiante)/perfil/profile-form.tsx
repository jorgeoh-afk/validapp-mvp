"use client";

import { useActionState, useState } from "react";
import { AlertCircle, CheckCircle2, Circle } from "lucide-react";
import { updateProfile } from "@/lib/data/profile-settings";
import {
  listLevelsByProgram,
  type CurriculumLevelOption,
} from "@/lib/data/curriculum";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export type ProgramOption = {
  id: string;
  name: string;
  code: string | null;
  curriculum_type: string | null;
};

const RADIO_CARD_CLASSNAME =
  "flex min-h-14 cursor-pointer items-start gap-3 rounded-xl border-2 border-border bg-card px-4 py-3 text-left text-sm font-medium text-foreground transition-all has-[:checked]:border-primary has-[:checked]:bg-primary/5 has-[:focus-visible]:ring-3 has-[:focus-visible]:ring-ring/50";

function RadioCard({
  name,
  value,
  checked,
  onChange,
  title,
  description,
}: {
  name: string;
  value: string;
  checked: boolean;
  onChange: () => void;
  title: string;
  description?: string;
}) {
  return (
    <label className={RADIO_CARD_CLASSNAME}>
      <input
        type="radio"
        name={name}
        value={value}
        checked={checked}
        onChange={onChange}
        className="peer sr-only"
      />
      <Circle
        className="mt-0.5 size-5 shrink-0 text-muted-foreground peer-checked:hidden"
        aria-hidden="true"
      />
      <CheckCircle2
        className="mt-0.5 hidden size-5 shrink-0 text-primary peer-checked:block"
        aria-hidden="true"
      />
      <span className="flex flex-col gap-0.5">
        <span>{title}</span>
        {description && (
          <span className="text-xs font-normal text-muted-foreground">
            {description}
          </span>
        )}
      </span>
    </label>
  );
}

export function ProfileForm({
  fullName,
  studentAgeGroup: initialStudentAgeGroup,
  targetProgram,
  targetLevel,
  initialLevels,
  regularProgram,
  epjaPrograms,
}: {
  fullName: string;
  studentAgeGroup: "menor_18" | "mayor_18" | null;
  targetProgram: ProgramOption | null;
  targetLevel: CurriculumLevelOption | null;
  /** Cursos/niveles del programa ya elegido por el estudiante (cargados en el
   * servidor junto al resto del perfil). Vacío si aún no tiene programa. */
  initialLevels: CurriculumLevelOption[];
  /** Único programa disponible para estudiantes menores de 18 años (Currículum
   * Regular - Exámenes Libres). Null solo si aún no está configurado. */
  regularProgram: ProgramOption | null;
  /** Las 3 modalidades EPJA (mayores de 18): Regular, Flexible, Exámenes Libres. */
  epjaPrograms: ProgramOption[];
}) {
  const [state, formAction, pending] = useActionState(updateProfile, null);

  // Si el perfil aún no tiene `student_age_group` explícito pero ya tiene un
  // curso EPJA/regular elegido (dato histórico previo a este rediseño), se
  // infiere el tipo de estudiante desde ese curso para no hacer retroceder
  // al estudiante al paso 1.
  const inferredAgeGroup: "" | "menor_18" | "mayor_18" =
    initialStudentAgeGroup ??
    (targetLevel?.education_type === "menor_18" ||
    targetLevel?.education_type === "mayor_18"
      ? targetLevel.education_type
      : "");

  const [studentAgeGroup, setStudentAgeGroup] = useState<
    "" | "menor_18" | "mayor_18"
  >(inferredAgeGroup);
  // `programId` solo registra la selección EPJA del estudiante (paso 2,
  // cuando es mayor de 18); para menor de 18 el programa se deriva
  // directamente del único disponible, sin necesidad de estado propio.
  const [programId, setProgramId] = useState(
    targetProgram?.curriculum_type === "epja" ? targetProgram.id : ""
  );
  const [levelId, setLevelId] = useState(targetLevel?.id ?? "");
  const [levels, setLevels] = useState<CurriculumLevelOption[]>(initialLevels);
  const [loadingLevels, setLoadingLevels] = useState(false);

  // Programa efectivo según el paso 1: para "menor de 18" siempre es el
  // único programa disponible; para "mayor de 18" es la selección EPJA del
  // estudiante, solo si sigue siendo una de las 3 modalidades disponibles.
  // Se calcula en cada render, no se sincroniza con un Effect (es un valor
  // derivado de otro estado, no un sistema externo).
  const effectiveProgramId =
    studentAgeGroup === "menor_18"
      ? (regularProgram?.id ?? "")
      : studentAgeGroup === "mayor_18" &&
          epjaPrograms.some((p) => p.id === programId)
        ? programId
        : "";

  // Carga los cursos/niveles de un programa recién elegido. Se llama directo
  // desde los manejadores de evento de los pasos 1 y 2 (no desde un Effect):
  // es trabajo async disparado por una interacción del estudiante, no una
  // sincronización con un sistema externo en respuesta a un cambio de estado.
  async function loadLevelsForProgram(newProgramId: string) {
    setLoadingLevels(true);
    try {
      const data = await listLevelsByProgram(newProgramId);
      setLevels(data);
      setLevelId((current) =>
        data.some((l) => l.id === current) ? current : ""
      );
    } finally {
      setLoadingLevels(false);
    }
  }

  return (
    <form action={formAction} className="flex flex-col gap-6">
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

      <fieldset className="flex flex-col gap-3">
        <legend className="mb-1 text-sm font-semibold text-foreground">
          Paso 1 · ¿Qué tipo de estudiante eres?
        </legend>
        <div
          role="radiogroup"
          aria-label="Tipo de estudiante"
          className="grid gap-2.5 sm:grid-cols-2"
        >
          <RadioCard
            name="studentAgeGroup"
            value="menor_18"
            checked={studentAgeGroup === "menor_18"}
            onChange={() => {
              setStudentAgeGroup("menor_18");
              if (regularProgram) void loadLevelsForProgram(regularProgram.id);
            }}
            title="Estudiante de exámenes libres menor de 18 años"
          />
          <RadioCard
            name="studentAgeGroup"
            value="mayor_18"
            checked={studentAgeGroup === "mayor_18"}
            onChange={() => setStudentAgeGroup("mayor_18")}
            title="Estudiante de exámenes libres mayor de 18 años"
          />
        </div>
      </fieldset>

      {studentAgeGroup && (
        <fieldset className="flex flex-col gap-3">
          <legend className="mb-1 text-sm font-semibold text-foreground">
            Paso 2 · Programa educativo
          </legend>
          {studentAgeGroup === "menor_18" ? (
            regularProgram ? (
              <>
                <p className="rounded-xl border border-border bg-muted/40 px-4 py-3 text-sm text-foreground">
                  <span className="font-medium">
                    Currículum Regular - Exámenes Libres.
                  </span>{" "}
                  Es el único programa disponible para estudiantes menores de
                  18 años.
                </p>
                <input
                  type="hidden"
                  name="targetProgramId"
                  value={regularProgram.id}
                />
              </>
            ) : (
              <p className="rounded-xl bg-warning/20 px-4 py-3 text-sm text-warning-foreground">
                Aún no está configurado el programa de Currículum Regular.
                Escríbenos a soporte para avisarte apenas esté listo.
              </p>
            )
          ) : (
            <div
              role="radiogroup"
              aria-label="Programa educativo"
              className="grid gap-2.5"
            >
              {epjaPrograms.map((program) => (
                <RadioCard
                  key={program.id}
                  name="targetProgramId"
                  value={program.id}
                  checked={programId === program.id}
                  onChange={() => {
                    setProgramId(program.id);
                    void loadLevelsForProgram(program.id);
                  }}
                  title={program.name}
                />
              ))}
              {epjaPrograms.length === 0 && (
                <p className="text-sm text-muted-foreground">
                  Aún no hay modalidades EPJA configuradas.
                </p>
              )}
            </div>
          )}
        </fieldset>
      )}

      {effectiveProgramId && (
        <fieldset className="flex flex-col gap-3">
          <legend className="mb-1 text-sm font-semibold text-foreground">
            Paso 3 · Curso o nivel
          </legend>
          {loadingLevels ? (
            <p className="text-sm text-muted-foreground">
              Cargando cursos disponibles...
            </p>
          ) : levels.length === 0 ? (
            <p className="rounded-xl border border-dashed border-border px-4 py-3 text-sm text-muted-foreground">
              Aún no hay cursos cargados para esta modalidad. Puedes guardar
              tu programa igual: te pediremos el curso más adelante, apenas
              esté disponible.
            </p>
          ) : (
            <div
              role="radiogroup"
              aria-label="Curso o nivel"
              className="grid gap-2.5"
            >
              <RadioCard
                name="targetLevelId"
                value=""
                checked={levelId === ""}
                onChange={() => setLevelId("")}
                title="Sin definir todavía"
              />
              {levels.map((level) => (
                <RadioCard
                  key={level.id}
                  name="targetLevelId"
                  value={level.id}
                  checked={levelId === level.id}
                  onChange={() => setLevelId(level.id)}
                  title={level.name}
                  description={
                    level.equivalence
                      ? `Equivale a ${level.equivalence}`
                      : undefined
                  }
                />
              ))}
            </div>
          )}
        </fieldset>
      )}

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
