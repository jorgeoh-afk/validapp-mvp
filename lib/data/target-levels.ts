/**
 * Valores permitidos de `profiles.target_level`, en sincronía con el CHECK
 * constraint `profiles_target_level_check` (migración
 * `0026_profiles_target_level_check.sql`). Si se agrega un nivel nuevo con
 * contenido real, hay que actualizar los dos a la vez.
 *
 * Vive en su propio archivo (sin `"use server"` ni imports de servidor)
 * porque lo importan tanto código de servidor (`lib/data/profile-settings.ts`)
 * como un Client Component (`app/(estudiante)/perfil/profile-form.tsx`); si
 * viviera en `lib/data/profiles.ts` (que importa `createClient` de
 * `lib/supabase/server`), el bundle de cliente arrastraría código
 * solo-servidor y el build fallaría.
 */
export const TARGET_LEVEL_OPTIONS = [
  "Primer Nivel Medio",
  "Segundo Nivel Medio",
] as const;
