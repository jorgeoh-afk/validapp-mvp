-- Dominio: Contenido y preguntas.
-- Seed idempotente para la tabla puente `public.program_levels`
-- (esquema agregado en supabase/migrations/0031_program_levels_bridge.sql).
--
-- Qué resuelve: hasta ahora, `levels.program_id` (0010/0028) solo permite que
-- un nivel/curso pertenezca a UN programa. Este seed refleja explícitamente
-- en `program_levels` esa misma relación canónica para los 17 niveles ya
-- existentes (12 cursos del Currículum Regular + 5 niveles EPJA condensados
-- de "EPJA - Exámenes Libres"), y AGREGA la disponibilidad nueva: esos mismos
-- 5 niveles EPJA también quedan disponibles bajo "EPJA - Modalidad Regular"
-- y "EPJA - Modalidad Flexible" (programas ya existentes en `programs`, sin
-- niveles propios hasta ahora), sin duplicar ninguna fila de `levels` ni el
-- contenido (664 preguntas/ensayos/objetivos de aprendizaje) que cuelga de
-- esos `level_id`.
--
-- Incertidumbre normativa (heredada de la migración 0031 y del análisis de
-- `/validapp-content`): se asume que las 3 modalidades EPJA comparten la
-- misma estructura de 5 niveles condensados del D.S. 257/2009, pero no está
-- confirmado que ese decreto siga vigente sin cambios posteriores. La rama
-- Técnico-Profesional de Educación Media EPJA NO se incluye a propósito
-- (pendiente de verificación normativa), solo la rama Humanístico-Científica
-- ya cargada en `levels.track` (0022).
--
-- Idempotencia: la llave primaria de `program_levels` es
-- `(program_id, level_id)`, así que cada INSERT usa
-- `on conflict (program_id, level_id) do nothing` -- correr este seed más de
-- una vez no duplica filas ni falla. Todas las referencias a programas y
-- niveles se resuelven por `code` (nunca por id hardcodeado), porque los ids
-- reales difieren entre dev y producción (ver advertencia de 0028). Si algún
-- `code` no existe todavía en el entorno donde se corre (p. ej. un proyecto
-- vacío sin el seed 0009 aplicado), el INSERT correspondiente simplemente no
-- inserta filas -- no falla.
--
-- Seed SOLO local: no se ha ejecutado contra ningún proyecto Supabase.

-- =====================================================================
-- 1) Currículum Regular - Exámenes Libres -> sus propios 12 cursos
-- =====================================================================
insert into public.program_levels (program_id, level_id)
select p.id, l.id
from public.programs p
join public.levels l on l.code = any (array[
  'regular_1_basico', 'regular_2_basico', 'regular_3_basico', 'regular_4_basico',
  'regular_5_basico', 'regular_6_basico', 'regular_7_basico', 'regular_8_basico',
  'regular_1_medio', 'regular_2_medio', 'regular_3_medio', 'regular_4_medio'
])
where p.code = 'regular_examenes_libres_menores'
on conflict (program_id, level_id) do nothing;

-- =====================================================================
-- 2) EPJA - Exámenes Libres (Mayores de 18 años) -> sus propios 5 niveles
-- =====================================================================
insert into public.program_levels (program_id, level_id)
select p.id, l.id
from public.programs p
join public.levels l on l.code = any (array[
  'epja_adultos_nivel_basico_1', 'epja_adultos_nivel_basico_2', 'epja_adultos_nivel_basico_3',
  'epja_adultos_nivel_medio_1', 'epja_adultos_nivel_medio_2'
])
where p.code = 'epja_examenes_libres_adultos'
on conflict (program_id, level_id) do nothing;

-- =====================================================================
-- 3) EPJA - Modalidad Regular -> los mismos 5 niveles EPJA (NUEVO)
-- =====================================================================
insert into public.program_levels (program_id, level_id)
select p.id, l.id
from public.programs p
join public.levels l on l.code = any (array[
  'epja_adultos_nivel_basico_1', 'epja_adultos_nivel_basico_2', 'epja_adultos_nivel_basico_3',
  'epja_adultos_nivel_medio_1', 'epja_adultos_nivel_medio_2'
])
where p.code = 'epja_regular'
on conflict (program_id, level_id) do nothing;

-- =====================================================================
-- 4) EPJA - Modalidad Flexible -> los mismos 5 niveles EPJA (NUEVO)
-- =====================================================================
insert into public.program_levels (program_id, level_id)
select p.id, l.id
from public.programs p
join public.levels l on l.code = any (array[
  'epja_adultos_nivel_basico_1', 'epja_adultos_nivel_basico_2', 'epja_adultos_nivel_basico_3',
  'epja_adultos_nivel_medio_1', 'epja_adultos_nivel_medio_2'
])
where p.code = 'epja_flexible'
on conflict (program_id, level_id) do nothing;
