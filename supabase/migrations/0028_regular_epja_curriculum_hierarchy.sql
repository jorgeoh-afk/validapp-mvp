-- Dominio: Contenido y preguntas (con columnas nuevas en `profiles`, dominio
-- Autenticación y usuarios — ver sección final de este archivo).
--
-- Fase 3 del rediseño curricular: distinguir formalmente en el esquema el
-- Currículum Regular (menores de 18, examen libre curso por curso, 1° a 8°
-- Básico y 1° a 4° Medio) del Currículum EPJA (mayores de 18, con 3
-- modalidades: EPJA Regular, EPJA Flexible, y Exámenes Libres EPJA
-- condensados en 5 niveles con equivalencia explícita a los cursos
-- regulares).
--
-- Estado real verificado en el proyecto dev (ljzdpkyxvehrjqtixbya) antes de
-- escribir esta migración (ver supabase/OBSOLETO-NO-USAR-prod-content-sync/
-- 01_programs.sql, 02_education_levels.sql, 04_levels.sql, dumps de solo
-- lectura, nunca ejecutados en prod):
--   - `programs`: 1 fila real, "EPJA - Modalidad Regular"
--     (6f48b690-7e91-4852-9625-d500ba3b5db9).
--   - `education_levels`: 1 fila real, "Educación Media"
--     (a3effdaf-e03b-42d2-8c13-9f765687593f).
--   - `levels`: 2 filas reales, "Primer Nivel Medio"
--     (cb7467bf-5407-40f6-953e-28ad17aae434) y "Segundo Nivel Medio"
--     (a62eb30a-79bc-4087-9b45-cb49482ce66e), ambas hoy clasificadas bajo el
--     programa "EPJA - Modalidad Regular" -- error semántico: son niveles de
--     *examen libre* de adultos, no de la modalidad "EPJA Regular". Se
--     corrige en el seed 0009 (re-apunta `program_id`, no en esta
--     migración, que es solo esquema). Verificado con grep en `lib/` y
--     `app/` que `levels.program_id`/`education_level_id` SOLO los lee el
--     CRUD admin (`lib/data/curriculum.ts`, `app/(admin)/admin/niveles`,
--     `app/(admin)/admin/programas`) -- nunca la lógica de diagnóstico,
--     generación de ensayos o selección de preguntas (usan `level_id` /
--     `subject_id` / `learning_objective_id` directo). Re-apuntar es seguro:
--     no afecta el pipeline EPJA ya verificado end-to-end (664 preguntas,
--     ensayos publicados, intentos rendidos).
--
-- Todo lo de este archivo es aditivo y reversible: columnas nuevas nullable,
-- ninguna columna existente se renombra ni se elimina, ninguna política RLS
-- existente se modifica (solo se agregan triggers de validación). Migración
-- solo local: no se ejecutó `supabase db push`.

-- =====================================================================
-- 1) programs: identificador estable + tipo de currículum
-- =====================================================================
--
-- Decisión de diseño (edad mínima/máxima y metadata libre): viven en
-- `programs`, NO en `levels`. La elegibilidad por edad es una propiedad de
-- la MODALIDAD/programa (Currículum Regular = menores de 18, las 3
-- modalidades EPJA = mayores de 18), no de cada curso individual -- ponerla
-- en `levels` obligaría a repetir el mismo par de valores en cada una de las
-- 17 filas de curso y arriesgaría inconsistencias (p. ej. un curso EPJA con
-- `maximum_age` distinto al resto de su programa). Un solo lugar basta.
-- `metadata` jsonb también se deja aquí por el mismo motivo: es información
-- de modalidad (p. ej. duración estimada, decreto marco de la modalidad),
-- no de curso.
alter table public.programs
  add column if not exists code text,
  add column if not exists curriculum_type text
    check (curriculum_type is null or curriculum_type in ('regular', 'epja')),
  add column if not exists minimum_age int,
  add column if not exists maximum_age int,
  add column if not exists metadata jsonb not null default '{}'::jsonb;

create unique index if not exists programs_code_key
  on public.programs (code)
  where code is not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'programs'
      and c.conname = 'programs_age_range_check'
  ) then
    alter table public.programs
      add constraint programs_age_range_check
      check (
        minimum_age is null or maximum_age is null or maximum_age >= minimum_age
      );
  end if;
end $$;

comment on column public.programs.code is
  'Identificador estable snake_case (p. ej. "epja_regular", "regular_examenes_libres_menores"), para referenciar el programa desde código/seeds sin depender del nombre legible.';
comment on column public.programs.curriculum_type is
  'regular = Currículum Regular chileno (examen libre por curso individual, menores de 18). epja = Educación de Personas Jóvenes y Adultas (cualquiera de sus 3 modalidades), mayores de 18. Nullable: no se retroactiva a filas que ya existan sin clasificar (no hay hoy, pero por si acaso).';
comment on column public.programs.minimum_age is
  'Edad mínima elegible para este programa/modalidad (p. ej. 18 para EPJA). Nullable: sin tope inferior conocido.';
comment on column public.programs.maximum_age is
  'Edad máxima elegible (p. ej. 17 para Currículum Regular). Nullable: sin tope superior conocido.';
comment on column public.programs.metadata is
  'Metadata libre de la modalidad (no del curso individual), sin esquema fijo aún. Default objeto vacío para no romper lecturas existentes que esperan un valor no nulo.';

-- =====================================================================
-- 1.5) education_levels: identificador estable
-- =====================================================================
alter table public.education_levels
  add column if not exists code text;

create unique index if not exists education_levels_code_key
  on public.education_levels (code)
  where code is not null;

comment on column public.education_levels.code is
  'Identificador estable snake_case (p. ej. "educacion_basica", "educacion_media"), para referenciar el nivel educativo desde código/seeds sin depender del nombre legible.';

-- =====================================================================
-- 2) levels: identificador estable, tipo de audiencia, y equivalencia
--    ESTRUCTURADA (no solo texto) con los cursos regulares
-- =====================================================================
--
-- Decisión de diseño (equivalencia estructurada): además de la columna de
-- texto `equivalence` (0022, que se mantiene intacta como metadato legible,
-- p. ej. "1° y 2° Medio"), se agregan dos columnas FK auto-referenciadas
-- nullable que apuntan a las filas REALES de curso regular (1°-8° Básico,
-- 1°-4° Medio) creadas en el seed 0009. Así la equivalencia queda explícita
-- en la base de datos -- consultable con un JOIN -- y no depende de que el
-- texto de `equivalence` coincida por convención con el nombre de otro
-- curso. Solo aplica (no nulo) a los niveles EPJA de adultos condensados;
-- para los 12 cursos regulares individuales estas dos columnas quedan null
-- (un curso regular ES la unidad, no "equivale a" otra cosa).
alter table public.levels
  add column if not exists code text,
  add column if not exists education_type text
    check (education_type is null or education_type in ('menor_18', 'mayor_18')),
  add column if not exists equivalent_grade_from_level_id uuid
    references public.levels (id) on delete set null,
  add column if not exists equivalent_grade_to_level_id uuid
    references public.levels (id) on delete set null;

create unique index if not exists levels_code_key
  on public.levels (code)
  where code is not null;

comment on column public.levels.code is
  'Identificador estable snake_case (p. ej. "regular_1_basico", "epja_adultos_nivel_medio_1"), para referenciar el curso desde código/seeds sin depender del nombre legible.';
comment on column public.levels.education_type is
  'menor_18 = curso del Currículum Regular (examen libre individual). mayor_18 = nivel condensado de alguna modalidad EPJA. Nullable: no se retroactiva a cursos ya clasificados sin este dato.';
comment on column public.levels.equivalent_grade_from_level_id is
  'Solo para niveles EPJA de adultos condensados: primer curso regular (public.levels) que este nivel cubre (p. ej. el nivel EPJA "Primer Nivel Básico" -> "1° Básico"). Null para cursos regulares individuales y para niveles sin equivalencia aún clasificada.';
comment on column public.levels.equivalent_grade_to_level_id is
  'Análogo a equivalent_grade_from_level_id: último curso regular que este nivel EPJA cubre (p. ej. "Primer Nivel Básico" -> "4° Básico"). Si el nivel EPJA equivale a un solo curso regular, puede repetirse el mismo id que equivalent_grade_from_level_id.';

-- ---------- Trigger: coherencia programa <-> curso ----------
-- No puede resolverse con un CHECK de columna (necesita leer otra tabla).
-- Impide que un curso `mayor_18` cuelgue de un programa `curriculum_type =
-- 'regular'`, y que un curso `menor_18` cuelgue de un programa
-- `curriculum_type = 'epja'`. Solo valida cuando AMBOS lados están
-- clasificados (program_id y education_type no nulos): no bloquea la
-- clasificación gradual de cursos existentes sin tocar, mismo criterio que
-- el resto de esta migración.
create or replace function public.check_level_program_curriculum_match()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_curriculum_type text;
begin
  if new.program_id is not null and new.education_type is not null then
    select curriculum_type into v_curriculum_type
    from public.programs
    where id = new.program_id;

    if v_curriculum_type = 'regular' and new.education_type <> 'menor_18' then
      raise exception
        'El curso "%" (education_type=%) no puede pertenecer a un programa de Currículum Regular, que exige education_type=menor_18.',
        new.name, new.education_type;
    elsif v_curriculum_type = 'epja' and new.education_type <> 'mayor_18' then
      raise exception
        'El curso "%" (education_type=%) no puede pertenecer a un programa EPJA, que exige education_type=mayor_18.',
        new.name, new.education_type;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists levels_program_curriculum_match on public.levels;
create trigger levels_program_curriculum_match
  before insert or update of program_id, education_type on public.levels
  for each row execute procedure public.check_level_program_curriculum_match();

-- =====================================================================
-- 3) profiles: columnas estructuradas de nivel objetivo + edad
-- =====================================================================
--
-- Decisión de diseño (target_level_id vs target_level texto): SE MANTIENEN
-- AMBAS, sincronizadas por trigger, en vez de elegir una sola. Motivo: la
-- migración 0026 documenta 4 lectores directos de la columna de texto
-- (`lib/data/profiles.ts`, `lib/data/progress.ts`, `lib/data/admin-results.ts`,
-- `app/(estudiante)/panel`, `app/(estudiante)/perfil`) y el único escritor
-- (`lib/data/profile-settings.ts` / `app/(estudiante)/perfil/profile-form.tsx`)
-- hoy solo envía `target_level` como texto libre validado contra
-- `TARGET_LEVEL_OPTIONS`. Reemplazar la columna de texto por la FK
-- obligaría a tocar los 5 lectores Y el formulario de estudiante (fuera del
-- alcance de este agente: cambios de UI van al agente/skill
-- `validapp-ui-designer`, ver CLAUDE.md) en el mismo movimiento que el
-- esquema. En cambio:
--   - `target_level_id` (FK a `levels`) y `target_program_id` (FK a
--     `programs`) son la fuente de verdad ESTRUCTURADA hacia adelante:
--     cualquier código nuevo (reportes admin, selección de contenido
--     personalizado) debería preferir hacer JOIN por estos ids en vez de
--     comparar el texto de `target_level`.
--   - El trigger `profiles_sync_target_level` (más abajo) mantiene
--     `target_level` (texto) sincronizado automáticamente a partir de
--     `target_level_id` cuando este se setea, y --a la inversa-- intenta
--     resolver `target_level_id`/`target_program_id` a partir del texto
--     cuando solo se recibe `target_level` (el flujo actual del formulario
--     de estudiante), buscando por coincidencia exacta de nombre en
--     `levels.name`. Es "best effort": si no encuentra un curso con ese
--     nombre exacto, deja las columnas estructuradas en null en vez de
--     fallar -- igual que 0026 normalizaba valores inválidos a null en vez
--     de bloquear.
--   - Ninguna columna nueva es NOT NULL: hoy existen perfiles con
--     `target_level` null (verificado en dev), y no se fuerza a definir un
--     nivel objetivo retroactivamente.
alter table public.profiles
  add column if not exists target_program_id uuid
    references public.programs (id) on delete set null,
  add column if not exists target_level_id uuid
    references public.levels (id) on delete set null,
  add column if not exists student_age_group text
    check (student_age_group is null or student_age_group in ('menor_18', 'mayor_18'));

comment on column public.profiles.target_program_id is
  'Programa/modalidad que el estudiante indica estar preparando. Mantenido en sincronía automática con target_level_id/target_level por el trigger profiles_sync_target_level -- no escribir manualmente sin pasar por target_level_id. Puramente informativo (mismo alcance que target_level, ver 0026): no alimenta personalización de contenido.';
comment on column public.profiles.target_level_id is
  'FK estructurada al curso (public.levels) que el estudiante indica estar preparando. Fuente de verdad preferida hacia adelante sobre target_level (texto libre histórico); ver profiles_sync_target_level para la sincronización bidireccional con el flujo actual del formulario de estudiante. Nullable: no se fuerza a perfiles existentes.';
comment on column public.profiles.student_age_group is
  'Clasificación gruesa de edad (menor_18 / mayor_18) declarada por el estudiante o su apoderado, usada para filtrar qué programas/niveles ofrecerle (ver programs.curriculum_type y levels.education_type, que usan el mismo par de valores). Nullable: no se solicita retroactivamente a perfiles existentes.';

-- ---------- Backfill defensivo ----------
-- Por si el estado real de algún entorno difiere de lo verificado en dev
-- (hoy todos los `target_level` son null): resuelve target_level_id /
-- target_program_id para cualquier fila existente que ya tenga texto de
-- `target_level` coincidente con un curso real, antes de que exista el
-- trigger (evita depender de que se dispare un UPDATE futuro).
update public.profiles p
set
  target_level_id = l.id,
  target_program_id = l.program_id
from public.levels l
where p.target_level = l.name
  and p.target_level_id is null;

-- ---------- Trigger: sincronización target_level <-> target_level_id ----------
create or replace function public.sync_profile_target_level()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_level record;
begin
  -- Caso 1: llega/cambia target_level_id (flujo estructurado nuevo) ->
  -- deriva el texto legible y el programa desde `levels`. Prioridad sobre
  -- cualquier texto que venga en el mismo UPDATE.
  if new.target_level_id is not null
     and (tg_op = 'INSERT' or new.target_level_id is distinct from old.target_level_id) then
    select id, name, program_id into v_level
    from public.levels
    where id = new.target_level_id;

    if v_level.id is null then
      raise exception 'target_level_id % no existe en public.levels.', new.target_level_id;
    end if;

    new.target_level := v_level.name;
    new.target_program_id := v_level.program_id;

  -- Caso 2: llega/cambia target_level como texto y NO viene target_level_id
  -- (flujo actual de lib/data/profile-settings.ts) -> intenta resolver el
  -- curso por nombre exacto. Best effort: si no hay coincidencia, no falla.
  elsif new.target_level_id is null
    and new.target_level is not null
    and (tg_op = 'INSERT' or new.target_level is distinct from old.target_level) then
    select id, program_id into v_level
    from public.levels
    where name = new.target_level
    limit 1;

    if v_level.id is not null then
      new.target_level_id := v_level.id;
      new.target_program_id := v_level.program_id;
    end if;

  -- Caso 3: el llamador limpia el nivel objetivo en ESTE mismo UPDATE (antes
  -- tenía target_level_id o target_level, ahora ambos quedan null) -> por
  -- defecto también limpia el programa derivado, salvo que el mismo UPDATE
  -- haya fijado explícitamente un target_program_id distinto del anterior
  -- (caso real: un estudiante mayor de 18 elige "EPJA Regular"/"EPJA
  -- Flexible", modalidades que hoy no tienen cursos propios cargados, así
  -- que nunca llega target_level_id/target_level, solo target_program_id).
  -- Guardado detrás de `tg_op = 'UPDATE'` porque OLD no existe en INSERT: en
  -- un INSERT nuevo con target_program_id ya fijado y sin nivel, este caso no
  -- debe aplicar en absoluto (no hay nada que "limpiar" todavía).
  elsif new.target_level_id is null and new.target_level is null
    and tg_op = 'UPDATE'
    and (old.target_level_id is not null or old.target_level is not null)
    and new.target_program_id is not distinct from old.target_program_id then
    new.target_program_id := null;
  end if;

  return new;
end;
$$;

drop trigger if exists profiles_sync_target_level on public.profiles;
create trigger profiles_sync_target_level
  before insert or update on public.profiles
  for each row execute procedure public.sync_profile_target_level();

-- ---------- CHECK de profiles.target_level: reemplaza el de 0026 ----------
-- 0026 dejaba escrito explícitamente: "Si se agregan niveles nuevos con
-- contenido real, se actualiza con una migración nueva, aditiva, que
-- reemplace este constraint." Esta es esa migración. Se amplía de 2 a 17
-- valores (12 cursos regulares + 5 niveles EPJA de adultos), reemplazando
-- el CHECK anterior (no se apila: un valor solo puede validar contra un
-- conjunto). Ver lib/data/target-levels.ts (TARGET_LEVEL_OPTIONS), que debe
-- mantenerse en sincronía manual con esta lista, igual que documentaba 0026.
update public.profiles
set target_level = null
where target_level is not null
  and target_level not in (
    '1° Básico', '2° Básico', '3° Básico', '4° Básico',
    '5° Básico', '6° Básico', '7° Básico', '8° Básico',
    '1° Medio', '2° Medio', '3° Medio', '4° Medio',
    'Primer Nivel Básico', 'Segundo Nivel Básico', 'Tercer Nivel Básico',
    'Primer Nivel Medio', 'Segundo Nivel Medio'
  );

alter table public.profiles
  drop constraint if exists profiles_target_level_check;

alter table public.profiles
  add constraint profiles_target_level_check
  check (target_level is null or target_level in (
    '1° Básico', '2° Básico', '3° Básico', '4° Básico',
    '5° Básico', '6° Básico', '7° Básico', '8° Básico',
    '1° Medio', '2° Medio', '3° Medio', '4° Medio',
    'Primer Nivel Básico', 'Segundo Nivel Básico', 'Tercer Nivel Básico',
    'Primer Nivel Medio', 'Segundo Nivel Medio'
  ));

comment on column public.profiles.target_level is
  'Nivel que el estudiante indica estar preparando (texto legible). Puramente informativo: no alimenta personalización de contenido (ver diagnostics.estimated_level_id para eso). Mantenido en sincronía automática con target_level_id por el trigger profiles_sync_target_level. Valores cerrados por profiles_target_level_check a los 17 cursos/niveles reales (12 Currículum Regular + 5 EPJA adultos, ver 0028_regular_epja_curriculum_hierarchy.sql). Si se agregan niveles nuevos con contenido real, actualizar este constraint y lib/data/target-levels.ts en una migración nueva.';

-- =====================================================================
-- Nota de RLS
-- =====================================================================
-- No se agregan políticas nuevas: todas las columnas de esta migración
-- viven en tablas que ya tienen RLS habilitada con el patrón "select para
-- cualquier autenticado, write solo admin" (`programs`/`levels`, 0010) o
-- "cada quien lee/edita su propia fila, admin lee todas" (`profiles`, 0001 +
-- 0003 + 0015). Las políticas existentes ya cubren columnas nuevas de forma
-- transparente (no son políticas column-level). No se modifica ninguna
-- política existente.
