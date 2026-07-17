-- Dominio: Contenido y preguntas
-- Fase 3 del rediseño del módulo administrativo de contenido educativo.
--
-- Objetivo: agregar dos conceptos curriculares nuevos, presentes en las Bases
-- Curriculares MINEDUC pero sin un lugar en el esquema hasta ahora:
--   - "Grandes ideas": 2-6 enunciados de propósito formativo por asignatura y
--     nivel (curso), sin eje temático asociado.
--   - "Conocimientos esenciales": lista abierta de temas/contenidos por
--     asignatura y nivel, que la fuente a veces (no siempre) vincula
--     explícitamente a uno o más Objetivos de Aprendizaje.
--
-- Decisión de diseño (Opción B, confirmada por el usuario tras evaluar 3
-- alternativas -- ver ValidApp/verificacion_produccion_y_esquema_pendiente.md,
-- sección 2):
--   - Se crean dos tablas normalizadas, fila por ítem, en vez de guardar
--     texto libre en `units` o en un único campo JSON por asignatura+nivel:
--     `big_ideas` y `essential_knowledge`, con la misma granularidad y ciclo
--     de vida (`status`) que `learning_objectives`.
--   - NOTA (actualizada tras la sección 1.7 de
--     ValidApp/verificacion_produccion_y_esquema_pendiente.md): la primera
--     versión de este comentario asumía duplicar cada "gran idea"/
--     "conocimiento esencial" por año individual (Opción B). Esa decisión
--     fue reemplazada por la Opción A: `levels` para Media son bloques EPJA
--     completos ("Nivel 1 Medio", "Nivel 2 Medio"), sin curso individual, y
--     cada fila se inserta una sola vez por bloque -- sin duplicar. Esto no
--     cambia la estructura de las tablas de esta migración (`subject_id` +
--     `level_id` siguen siendo FKs genéricas), solo cuántas filas de
--     `levels` existen y cuántas veces se referencia cada una.
--
-- `essential_knowledge_learning_objectives` es la tabla puente opcional para
-- el vínculo explícito conocimiento-esencial <-> OA. Se crea vacía a
-- propósito: la fuente disponible para las 5 asignaturas de Formación
-- General de Educación Media (extraccion_bases_curriculares_media.md) NO
-- incluye anotaciones explícitas tipo "(Se asocia con los OA 1, 2 y 3)" para
-- este set de datos -- esas anotaciones existen en el PDF original solo en
-- una sección distinta (ejemplos de integración de Educación Básica).
-- Poblar esta tabla para Media a partir de una inferencia propia sería
-- fabricar un vínculo que el MINEDUC no especificó explícitamente, lo cual
-- está fuera de lo permitido. Queda como tarea pendiente de revisión
-- pedagógica humana si más adelante se quiere completar manualmente.
--
-- Además, esta migración corrige un gap detectado en la verificación previa
-- del esquema: `learning_objectives` no tenía ninguna restricción que
-- impidiera insertar el mismo OA (mismo `unit_id` + `level_id` + `code`) dos
-- veces por error en un reintento de carga. Se agrega un índice único
-- parcial para prevenirlo.
--
-- Todos los cambios son aditivos y reversibles: tablas nuevas + un índice
-- único nuevo sobre una tabla existente. No se modifica ni elimina ninguna
-- columna existente. Esta migración es solo un archivo local: no se aplicó
-- contra Supabase remoto (no se ejecutó `supabase db push`).

-- ---------- Grandes ideas ----------
-- Enunciados de propósito formativo por asignatura y nivel (curso), sin eje
-- temático asociado. P. ej.: "Los estudiantes reconocen la lectura como una
-- herramienta para participar críticamente en la vida social".
create table if not exists public.big_ideas (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  statement text not null,
  order_index int not null default 0,
  status text not null default 'borrador'
    check (status in ('borrador', 'en_revision', 'aprobado', 'archivado')),
  curricular_source text not null default '',
  reference_year int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- Conocimientos esenciales ----------
-- Lista abierta de temas/contenidos por asignatura y nivel (curso). La
-- fuente no siempre los asocia a un eje temático específico; cuando sí los
-- vincula explícitamente a uno o más OA, ese vínculo se registra en
-- `essential_knowledge_learning_objectives` (ver más abajo).
create table if not exists public.essential_knowledge (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  statement text not null,
  order_index int not null default 0,
  status text not null default 'borrador'
    check (status in ('borrador', 'en_revision', 'aprobado', 'archivado')),
  curricular_source text not null default '',
  reference_year int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- Vínculo conocimiento esencial <-> objetivo de aprendizaje ----------
-- Tabla puente opcional: un conocimiento esencial puede asociarse a uno o
-- más OA cuando la fuente curricular lo indica explícitamente. Se crea
-- vacía a propósito para el set de datos de Educación Media EPJA (ver
-- comentario superior) -- no se infieren vínculos no declarados por el
-- MINEDUC. Un futuro proceso de carga distinto (u otra fuente que sí incluya
-- esas anotaciones) puede poblarla sin requerir otra migración.
create table if not exists public.essential_knowledge_learning_objectives (
  essential_knowledge_id uuid not null references public.essential_knowledge (id) on delete cascade,
  learning_objective_id uuid not null references public.learning_objectives (id) on delete cascade,
  primary key (essential_knowledge_id, learning_objective_id)
);

-- ---------- Corrección: evitar OA duplicados por accidente en reintentos ----------
-- `learning_objectives` no tenía ninguna restricción que impidiera insertar
-- la misma fila (mismo unit_id + level_id + code) dos veces. Esto es
-- distinto de la duplicación intencional entre años de un mismo bloque EPJA
-- (esa duplicación usa un `level_id` distinto a propósito, p. ej. 1° Medio y
-- 2° Medio comparten texto pero no level_id). Se usa un índice único PARCIAL
-- (excluye filas con `code` nulo, ya que `code` es una columna opcional en
-- el esquema original de 0010) para no romper filas legítimas sin `code`.
--
-- ADVERTENCIA antes de aplicar esta migración contra Supabase remoto: si ya
-- existen en producción filas de `learning_objectives` con `code` no nulo
-- que coincidan en (unit_id, level_id, code), esta sentencia fallará al
-- ejecutar `supabase db push`. Se recomienda verificar duplicados existentes
-- antes de aplicar, por ejemplo:
--   select unit_id, level_id, code, count(*)
--   from public.learning_objectives
--   where code is not null
--   group by unit_id, level_id, code
--   having count(*) > 1;
create unique index if not exists learning_objectives_unit_level_code_key
  on public.learning_objectives (unit_id, level_id, code)
  where code is not null;

-- ---------- Row Level Security ----------
-- Mismo patrón que el resto del dominio "Contenido y preguntas": lectura
-- para cualquier usuario autenticado, escritura solo para administradores.
alter table public.big_ideas enable row level security;
alter table public.essential_knowledge enable row level security;
alter table public.essential_knowledge_learning_objectives enable row level security;

-- Nota de idempotencia: a diferencia de `create table if not exists` y
-- `create unique index if not exists`, PostgreSQL no soporta
-- `create policy if not exists`. Para que esta migración se pueda pegar y
-- ejecutar más de una vez sin error (p. ej. dentro de un script de carga
-- consolidado que un usuario podría reintentar), cada política se antecede
-- de `drop policy if exists`. Esto no cambia el comportamiento de RLS: el
-- resultado final es el mismo, solo se vuelve seguro de reintentar.
drop policy if exists "big_ideas_select_authenticated" on public.big_ideas;
create policy "big_ideas_select_authenticated" on public.big_ideas for select to authenticated using (true);

drop policy if exists "essential_knowledge_select_authenticated" on public.essential_knowledge;
create policy "essential_knowledge_select_authenticated" on public.essential_knowledge for select to authenticated using (true);

drop policy if exists "essential_knowledge_learning_objectives_select_authenticated" on public.essential_knowledge_learning_objectives;
create policy "essential_knowledge_learning_objectives_select_authenticated" on public.essential_knowledge_learning_objectives for select to authenticated using (true);

drop policy if exists "big_ideas_write_admin" on public.big_ideas;
create policy "big_ideas_write_admin" on public.big_ideas for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

drop policy if exists "essential_knowledge_write_admin" on public.essential_knowledge;
create policy "essential_knowledge_write_admin" on public.essential_knowledge for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

drop policy if exists "essential_knowledge_learning_objectives_write_admin" on public.essential_knowledge_learning_objectives;
create policy "essential_knowledge_learning_objectives_write_admin" on public.essential_knowledge_learning_objectives for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));
