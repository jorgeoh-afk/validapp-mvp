-- Dominio: Contenido y preguntas
-- Seed idempotente para la jerarquía curricular completa Currículum Regular
-- vs EPJA (esquema agregado en supabase/migrations/0028_regular_epja_curriculum_hierarchy.sql).
--
-- Idempotencia: `programs.name`, `education_levels.name` y `levels.name` ya
-- son UNIQUE desde 0002/0010, así que cada INSERT usa
-- `on conflict (name) do update` limitado SOLO a las columnas nuevas de esta
-- fase (code, curriculum_type, education_type, equivalence, track, FKs de
-- equivalencia) -- nunca pisa `description`/`order_index`/`active` en un
-- reintento, por si un administrador ya los editó desde el panel. Seguro de
-- correr más de una vez.
--
-- Las 2 filas EPJA de nivel medio existentes en dev
-- (cb7467bf-5407-40f6-953e-28ad17aae434, a62eb30a-79bc-4087-9b45-cb49482ce66e,
-- ver auditoría en la migración 0028) se actualizan por id fijo, NO se
-- insertan de nuevo -- ya tienen contenido real colgando (strands, units,
-- learning_objectives, big_ideas, essential_knowledge, questions, essays)
-- vía learning_objective_id/level_id, que este seed NO toca. Si estos ids no
-- existen en el entorno donde se corre este seed (p. ej. un proyecto vacío
-- nuevo), el UPDATE simplemente afecta 0 filas -- no falla, pero tampoco
-- crea esos 2 niveles EPJA de nivel medio (este seed asume el estado real de
-- dev documentado en la migración 0028, igual que el resto de
-- supabase/seed/ es contenido específico de dev, no un bootstrap genérico).
--
-- Seed SOLO local: no se ha ejecutado contra ningún proyecto Supabase.

-- =====================================================================
-- 1) Programas
-- =====================================================================

-- Reutiliza/actualiza la fila EPJA Regular real existente.
insert into public.programs (name, description, order_index, active, code, curriculum_type, minimum_age)
values (
  'EPJA - Modalidad Regular',
  'Educación de Personas Jóvenes y Adultas, modalidad regular.',
  0, true,
  'epja_regular', 'epja', 18
)
on conflict (name) do update set
  code = excluded.code,
  curriculum_type = excluded.curriculum_type,
  minimum_age = excluded.minimum_age;

insert into public.programs (name, description, order_index, active, code, curriculum_type, maximum_age)
values (
  'Currículum Regular - Exámenes Libres',
  'Currículum regular chileno (1° a 8° Básico, 1° a 4° Medio), rendido como examen libre curso por curso. Menores de 18 años.',
  1, true,
  'regular_examenes_libres_menores', 'regular', 17
)
on conflict (name) do update set
  code = excluded.code,
  curriculum_type = excluded.curriculum_type,
  maximum_age = excluded.maximum_age;

insert into public.programs (name, description, order_index, active, code, curriculum_type, minimum_age)
values (
  'EPJA - Modalidad Flexible',
  'Educación de Personas Jóvenes y Adultas, modalidad flexible.',
  2, true,
  'epja_flexible', 'epja', 18
)
on conflict (name) do update set
  code = excluded.code,
  curriculum_type = excluded.curriculum_type,
  minimum_age = excluded.minimum_age;

insert into public.programs (name, description, order_index, active, code, curriculum_type, minimum_age)
values (
  'EPJA - Exámenes Libres (Mayores de 18 años)',
  'Educación de Personas Jóvenes y Adultas, exámenes libres condensados en 5 niveles con equivalencia explícita al currículum regular. Mayores de 18 años.',
  3, true,
  'epja_examenes_libres_adultos', 'epja', 18
)
on conflict (name) do update set
  code = excluded.code,
  curriculum_type = excluded.curriculum_type,
  minimum_age = excluded.minimum_age;

-- =====================================================================
-- 2) Niveles educativos
-- =====================================================================

insert into public.education_levels (name, description, order_index, active, code)
values (
  'Educación Media',
  'Enseñanza Media (EPJA y regular).',
  0, true,
  'educacion_media'
)
on conflict (name) do update set
  code = excluded.code;

insert into public.education_levels (name, description, order_index, active, code)
values (
  'Educación Básica',
  'Enseñanza Básica (EPJA y regular).',
  1, true,
  'educacion_basica'
)
on conflict (name) do update set
  code = excluded.code;

-- =====================================================================
-- 3) Cursos regulares (1° a 8° Básico, 1° a 4° Medio)
-- =====================================================================

insert into public.levels (name, order_index, code, program_id, education_level_id, education_type)
values
  ('1° Básico', 101, 'regular_1_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('2° Básico', 102, 'regular_2_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('3° Básico', 103, 'regular_3_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('4° Básico', 104, 'regular_4_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('5° Básico', 105, 'regular_5_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('6° Básico', 106, 'regular_6_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('7° Básico', 107, 'regular_7_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('8° Básico', 108, 'regular_8_basico',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'menor_18'),
  ('1° Medio', 109, 'regular_1_medio',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_media'),
    'menor_18'),
  ('2° Medio', 110, 'regular_2_medio',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_media'),
    'menor_18'),
  ('3° Medio', 111, 'regular_3_medio',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_media'),
    'menor_18'),
  ('4° Medio', 112, 'regular_4_medio',
    (select id from public.programs where code = 'regular_examenes_libres_menores'),
    (select id from public.education_levels where code = 'educacion_media'),
    'menor_18')
on conflict (name) do update set
  code = excluded.code,
  program_id = excluded.program_id,
  education_level_id = excluded.education_level_id,
  education_type = excluded.education_type;

-- =====================================================================
-- 4) Niveles EPJA de adultos -- Educación Básica (3 nuevos, condensados)
-- =====================================================================
-- `track` queda null: la rama formativa (Humanístico-Científica /
-- Técnico-Profesional) solo aplica a Educación Media (ver comentario de
-- 0022_levels_epja_metadata.sql), no a Educación Básica.

insert into public.levels (
  name, order_index, code, program_id, education_level_id, education_type,
  equivalence, track, equivalent_grade_from_level_id, equivalent_grade_to_level_id
)
values
  ('Primer Nivel Básico', 1, 'epja_adultos_nivel_basico_1',
    (select id from public.programs where code = 'epja_examenes_libres_adultos'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'mayor_18',
    '1° a 4° Básico', null,
    (select id from public.levels where name = '1° Básico'),
    (select id from public.levels where name = '4° Básico')),
  ('Segundo Nivel Básico', 2, 'epja_adultos_nivel_basico_2',
    (select id from public.programs where code = 'epja_examenes_libres_adultos'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'mayor_18',
    '5° y 6° Básico', null,
    (select id from public.levels where name = '5° Básico'),
    (select id from public.levels where name = '6° Básico')),
  ('Tercer Nivel Básico', 3, 'epja_adultos_nivel_basico_3',
    (select id from public.programs where code = 'epja_examenes_libres_adultos'),
    (select id from public.education_levels where code = 'educacion_basica'),
    'mayor_18',
    '7° y 8° Básico', null,
    (select id from public.levels where name = '7° Básico'),
    (select id from public.levels where name = '8° Básico'))
on conflict (name) do update set
  code = excluded.code,
  program_id = excluded.program_id,
  education_level_id = excluded.education_level_id,
  education_type = excluded.education_type,
  equivalence = excluded.equivalence,
  track = excluded.track,
  equivalent_grade_from_level_id = excluded.equivalent_grade_from_level_id,
  equivalent_grade_to_level_id = excluded.equivalent_grade_to_level_id;

-- =====================================================================
-- 5) Niveles EPJA de adultos -- Educación Media (2 EXISTENTES, re-apuntar)
-- =====================================================================
-- UPDATE por id fijo (NO insert): estas 2 filas ya existen en dev con
-- contenido real colgando. Se re-apuntan de "EPJA - Modalidad Regular" (mal
-- clasificadas hoy) a "EPJA - Exámenes Libres (Mayores de 18 años)" (su
-- programa correcto), y se completan code/education_type/equivalencia
-- estructurada. `name`, `description`, `order_index`, `equivalence` (texto,
-- ya seteado por 0022) y `track` (ya seteado por 0022) NO se tocan.

update public.levels
set
  code = 'epja_adultos_nivel_medio_1',
  program_id = (select id from public.programs where code = 'epja_examenes_libres_adultos'),
  education_level_id = (select id from public.education_levels where code = 'educacion_media'),
  education_type = 'mayor_18',
  equivalent_grade_from_level_id = (select id from public.levels where name = '1° Medio'),
  equivalent_grade_to_level_id = (select id from public.levels where name = '2° Medio')
where id = 'cb7467bf-5407-40f6-953e-28ad17aae434';

update public.levels
set
  code = 'epja_adultos_nivel_medio_2',
  program_id = (select id from public.programs where code = 'epja_examenes_libres_adultos'),
  education_level_id = (select id from public.education_levels where code = 'educacion_media'),
  education_type = 'mayor_18',
  equivalent_grade_from_level_id = (select id from public.levels where name = '3° Medio'),
  equivalent_grade_to_level_id = (select id from public.levels where name = '4° Medio')
where id = 'a62eb30a-79bc-4087-9b45-cb49482ce66e';
