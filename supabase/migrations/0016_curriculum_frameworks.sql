-- Dominio: Contenido y preguntas
-- Fase EPJA 1: modelo de "versión curricular" (currículum framework).
--
-- Problema que resuelve: hoy `learning_objectives`/`big_ideas`/
-- `essential_knowledge` solo tienen columnas de texto libre
-- (`curricular_source`, `reference_year`) para indicar de dónde viene el
-- contenido. Eso no alcanza para Enseñanza Media EPJA, donde en el mismo año
-- (2026) conviven dos decretos distintos según nivel y período de
-- examinación (D.S. N.° 257 de 2009 y D.S. N.° 10 de 2022), y donde una
-- misma asignatura canónica puede tener nombre oficial distinto según la
-- versión curricular ("Lengua y Literatura" vs "Lengua Castellana y
-- Comunicación").
--
-- Decisión de diseño: se agrega un modelo de versión curricular
-- (`curriculum_frameworks` + `framework_subjects`) y una tabla única de
-- trazabilidad a fuente oficial (`content_sources`), en vez de repetir 10
-- columnas de fuente en cada tabla curricular. Se reutiliza `levels` tal
-- cual (ya representa "Primer/Segundo Nivel Medio" como bloques EPJA
-- completos, decisión documentada en 0014) y `subjects` tal cual (catálogo
-- canónico) — no se duplican esos conceptos.
--
-- Todo es aditivo y reversible: tablas nuevas + columnas nuevas nullable en
-- tablas existentes. No se modifica ni elimina ninguna columna existente.
-- Migración solo local: no se ejecutó `supabase db push`.

-- ---------- Versión curricular ----------
create table if not exists public.curriculum_frameworks (
  id uuid primary key default gen_random_uuid(),
  modality text not null default 'EPJA',
  certification_process text not null default 'examen_libre',
  audience text not null default 'mayores_18',
  purpose text not null default 'continuidad_estudios',
  name text not null,
  decree_number text not null,
  decree_year int not null,
  exam_year int not null,
  exam_period text not null
    check (exam_period in ('primer_periodo', 'segundo_periodo')),
  valid_from date,
  valid_until date,
  status text not null default 'draft'
    check (status in ('draft', 'verified', 'active', 'archived', 'superseded')),
  source_name text,
  source_url text,
  source_domain text,
  source_document_type text,
  source_checksum text,
  retrieved_at timestamptz,
  verified_at timestamptz,
  verified_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (decree_number, decree_year, exam_year, exam_period)
);

-- ---------- Nombre oficial de una asignatura dentro de una versión curricular ----------
-- Resuelve la denominación oficial variable por decreto sin tocar `subjects`
-- (que sigue siendo el catálogo canónico usado por lecciones/preguntas hoy).
create table if not exists public.framework_subjects (
  id uuid primary key default gen_random_uuid(),
  framework_id uuid not null references public.curriculum_frameworks (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  subject_id uuid not null references public.subjects (id) on delete cascade,
  official_name text not null,
  official_code text,
  is_examined boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  unique (framework_id, level_id, subject_id)
);

-- ---------- Trazabilidad a fuente oficial ----------
-- Tabla única en vez de repetir columnas de fuente en cada tabla curricular
-- (`strands`, `units`, `learning_objectives`, `big_ideas`,
-- `essential_knowledge`, `lessons`, `questions`).
create table if not exists public.content_sources (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  source_url text not null,
  source_domain text not null,
  source_document_type text,
  source_year int,
  source_decree text,
  source_page text,
  source_section text,
  source_checksum text,
  retrieved_at timestamptz not null default now(),
  verified_at timestamptz,
  verified_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

-- ---------- Vínculo de contenido curricular a versión y fuente ----------
-- Nullable: el contenido existente de Educación Básica no tiene versión
-- curricular EPJA ni fuente MINEDUC formal todavía, y sigue funcionando sin
-- cambios hasta que se clasifique.
alter table public.strands
  add column if not exists framework_id uuid references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists source_id uuid references public.content_sources (id) on delete set null,
  add column if not exists official_text text;

alter table public.units
  add column if not exists framework_id uuid references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists source_id uuid references public.content_sources (id) on delete set null,
  add column if not exists official_text text;

alter table public.learning_objectives
  add column if not exists framework_id uuid references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists source_id uuid references public.content_sources (id) on delete set null,
  add column if not exists official_text text;

alter table public.big_ideas
  add column if not exists framework_id uuid references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists source_id uuid references public.content_sources (id) on delete set null,
  add column if not exists official_text text;

alter table public.essential_knowledge
  add column if not exists framework_id uuid references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists source_id uuid references public.content_sources (id) on delete set null,
  add column if not exists official_text text;

alter table public.lessons
  add column if not exists framework_id uuid references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists source_id uuid references public.content_sources (id) on delete set null;

-- ---------- Código canónico de asignatura ----------
-- Mapeo canónico↔nombre oficial por versión curricular (ver
-- `framework_subjects.official_name`). Nullable + único: no obliga a
-- clasificar de inmediato las asignaturas de Educación Básica existentes.
alter table public.subjects
  add column if not exists canonical_code text;

create unique index if not exists subjects_canonical_code_key
  on public.subjects (canonical_code)
  where canonical_code is not null;

-- ---------- Row Level Security ----------
alter table public.curriculum_frameworks enable row level security;
alter table public.framework_subjects enable row level security;
alter table public.content_sources enable row level security;

-- Lectura: cualquier autenticado ve frameworks activos/verificados; el
-- administrador ve todos los estados (incluye draft/archived/superseded),
-- necesario para el panel de administración de currículum.
drop policy if exists "curriculum_frameworks_select_active" on public.curriculum_frameworks;
create policy "curriculum_frameworks_select_active" on public.curriculum_frameworks for select
  to authenticated
  using (status in ('active', 'verified') or public.is_admin());

drop policy if exists "curriculum_frameworks_write_admin" on public.curriculum_frameworks;
create policy "curriculum_frameworks_write_admin" on public.curriculum_frameworks for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "framework_subjects_select_authenticated" on public.framework_subjects;
create policy "framework_subjects_select_authenticated" on public.framework_subjects for select
  to authenticated using (true);

drop policy if exists "framework_subjects_write_admin" on public.framework_subjects;
create policy "framework_subjects_write_admin" on public.framework_subjects for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- `content_sources` solo la necesita el panel admin (trazabilidad); no hay
-- caso de uso de estudiante leyéndola directamente.
drop policy if exists "content_sources_select_admin" on public.content_sources;
create policy "content_sources_select_admin" on public.content_sources for select
  to authenticated using (public.is_admin());

drop policy if exists "content_sources_write_admin" on public.content_sources;
create policy "content_sources_write_admin" on public.content_sources for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());
