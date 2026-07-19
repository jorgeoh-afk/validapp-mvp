-- Dominio: Autenticación y usuarios (con referencia informativa al dominio
-- Contenido y preguntas: los valores permitidos son los nombres actuales de
-- public.levels).
--
-- Cierra `profiles.target_level` (texto libre desde 0001_profiles.sql) a un
-- conjunto de valores validado, para evitar variantes/errores de tipeo y
-- permitir reportes consistentes en /admin/resultados.
--
-- Decisión de esquema: CHECK constraint con valores fijos, NO foreign key a
-- `levels.id`. Motivos:
--   - `target_level` es puramente informativo: no alimenta ninguna lógica de
--     contenido o personalización (eso lo hace `diagnostics.estimated_level_id`,
--     un campo distinto). No se cambia esa separación de responsabilidades.
--   - Hoy existen solo 2 niveles reales con contenido cargado en `levels`:
--     "Primer Nivel Medio" y "Segundo Nivel Medio" (ver 0010_curriculum_structure.sql
--     y 0022_levels_epja_metadata.sql).
--   - Una FK acoplaría un campo de solo lectura del dominio "Autenticación y
--     usuarios" al ciclo de vida (altas/renombres) de una tabla del dominio
--     "Contenido y preguntas", y obligaría a todos los lectores existentes
--     (lib/data/profiles.ts, lib/data/progress.ts, lib/data/admin-results.ts,
--     app/(estudiante)/panel, app/(estudiante)/perfil) a resolver un join
--     solo para mostrar un texto que hoy leen directo como columna.
--   - Un CHECK constraint logra la misma validación cerrada sin ese
--     acoplamiento. Si en el futuro se agregan niveles nuevos con contenido
--     real (p. ej. Educación Básica), se actualiza con una migración nueva,
--     aditiva, que reemplace este constraint.
--
-- Verificado en el proyecto dev (ljzdpkyxvehrjqtixbya) antes de escribir esta
-- migración: las filas existentes de `profiles` tienen target_level = null
-- hoy (no hay texto libre que migrar). Por robustez, esta migración igual
-- normaliza a null cualquier valor que no calce con el conjunto permitido en
-- vez de fallar o borrar filas, por si el estado real difiere del verificado.

update public.profiles
set target_level = null
where target_level is not null
  and target_level not in ('Primer Nivel Medio', 'Segundo Nivel Medio');

alter table public.profiles
  add constraint profiles_target_level_check
  check (target_level is null or target_level in ('Primer Nivel Medio', 'Segundo Nivel Medio'));

comment on column public.profiles.target_level is
  'Nivel que el estudiante indica estar preparando. Puramente informativo: no alimenta personalización de contenido (ver diagnostics.estimated_level_id para eso). Valores cerrados por profiles_target_level_check a los nombres actuales de public.levels ("Primer Nivel Medio", "Segundo Nivel Medio"). Si se agregan niveles nuevos con contenido real, actualizar este constraint en una migración nueva.';
