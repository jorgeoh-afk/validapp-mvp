/**
 * Valores permitidos de `profiles.target_level`, en sincronía con el CHECK
 * constraint `profiles_target_level_check` (reemplazado en
 * `0028_regular_epja_curriculum_hierarchy.sql`, que amplió el conjunto de 2 a
 * 17 valores: los 12 cursos regulares -- 1° a 8° Básico, 1° a 4° Medio -- del
 * programa `regular_examenes_libres_menores`, y los 5 niveles EPJA de
 * adultos -- 3 de Educación Básica + 2 de Educación Media -- del programa
 * `epja_examenes_libres_adultos`. Ver el seed
 * `supabase/seed/0009_curriculum_programs_levels_seed.sql` para los `code`
 * estables de cada uno). Si se agrega un nivel nuevo con contenido real, hay
 * que actualizar el CHECK y este archivo a la vez.
 *
 * Decisión de diseño: sigue siendo una CONSTANTE ESTÁTICA, no una lectura en
 * vivo de `public.levels`. Motivos:
 *   - Vive en su propio archivo (sin `"use server"` ni imports de servidor)
 *     porque lo importan tanto código de servidor
 *     (`lib/data/profile-settings.ts`) como un Client Component
 *     (`app/(estudiante)/perfil/profile-form.tsx`); si importara
 *     `createClient` de `lib/supabase/server` (para leer `levels` en vivo),
 *     el bundle de cliente arrastraría código solo-servidor y el build
 *     fallaría -- la misma razón que ya documentaba la versión anterior de
 *     este archivo.
 *   - El CHECK constraint en base de datos (`profiles_target_level_check`)
 *     ya es la fuente de verdad autoritativa que impide guardar un valor
 *     fuera de este conjunto; esta constante es solo para poblar el `<select>`
 *     del formulario de estudiante sin una consulta adicional.
 *
 * `TARGET_LEVEL_OPTIONS` mantiene la forma plana (usada hoy por
 * `TARGET_LEVEL_OPTIONS.includes(...)` en `lib/data/profile-settings.ts` y
 * por el `<select>` de `profile-form.tsx`). `TARGET_LEVEL_GROUPS` expone la
 * misma lista agrupada por currículum/nivel educativo -- útil para una futura
 * revisión de `profile-form.tsx` que filtre las opciones según
 * `profiles.student_age_group` (menor_18 -> solo cursos regulares; mayor_18
 * -> solo niveles EPJA), sin romper el uso plano actual. Ningún componente
 * usa `TARGET_LEVEL_GROUPS` todavía.
 */
export const TARGET_LEVEL_OPTIONS = [
  // Currículum Regular - Exámenes Libres (menores de 18)
  "1° Básico",
  "2° Básico",
  "3° Básico",
  "4° Básico",
  "5° Básico",
  "6° Básico",
  "7° Básico",
  "8° Básico",
  "1° Medio",
  "2° Medio",
  "3° Medio",
  "4° Medio",
  // EPJA - Exámenes Libres (mayores de 18)
  "Primer Nivel Básico",
  "Segundo Nivel Básico",
  "Tercer Nivel Básico",
  "Primer Nivel Medio",
  "Segundo Nivel Medio",
] as const;

export type TargetLevelOption = (typeof TARGET_LEVEL_OPTIONS)[number];

export const TARGET_LEVEL_GROUPS = [
  {
    label: "Currículum Regular (menores de 18 años)",
    studentAgeGroup: "menor_18",
    options: [
      "1° Básico",
      "2° Básico",
      "3° Básico",
      "4° Básico",
      "5° Básico",
      "6° Básico",
      "7° Básico",
      "8° Básico",
      "1° Medio",
      "2° Medio",
      "3° Medio",
      "4° Medio",
    ],
  },
  {
    label: "EPJA - Exámenes Libres (mayores de 18 años)",
    studentAgeGroup: "mayor_18",
    options: [
      "Primer Nivel Básico",
      "Segundo Nivel Básico",
      "Tercer Nivel Básico",
      "Primer Nivel Medio",
      "Segundo Nivel Medio",
    ],
  },
] as const satisfies readonly {
  label: string;
  studentAgeGroup: "menor_18" | "mayor_18";
  options: readonly TargetLevelOption[];
}[];
