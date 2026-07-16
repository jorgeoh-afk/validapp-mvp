-- Dominio: Contenido y preguntas
-- Fase 2 del rediseño del módulo administrativo de contenido educativo.
--
-- Objetivo: introducir una jerarquía curricular real (programa > nivel educativo >
-- curso > eje temático > unidad > objetivo de aprendizaje > habilidades), sin tocar
-- de forma destructiva las tablas existentes `subjects`, `levels`, `lessons` y
-- `questions`. Todos los cambios son aditivos y reversibles:
--   - Tablas nuevas.
--   - Columnas nuevas en `levels`, opcionales (nullable), con FK "on delete set null".
--
-- Decisión de diseño: `levels` sigue representando el "curso" (p. ej. "1° Medio"),
-- tal como hoy. No se crea una tabla nueva de "curso" para no duplicar el concepto.
-- En su lugar, `levels` gana dos columnas opcionales para poder clasificar cada
-- curso dentro de un `program_id` (modalidad/programa educativo, p. ej. "Educación
-- de Adultos") y un `education_level_id` (nivel educativo, p. ej. "Educación Media").
-- Como son nullable, los cursos existentes siguen funcionando sin cambios hasta que
-- un administrador los clasifique.

-- ---------- Programas educativos ----------
-- Modalidad o programa bajo el cual se agrupan los cursos (p. ej. "Educación Básica
-- de Adultos", "Educación Media Científico-Humanista", "Examen Libre").
create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text not null default '',
  order_index int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------- Niveles educativos ----------
-- Nivel educativo general (p. ej. "Educación Básica", "Educación Media").
create table if not exists public.education_levels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text not null default '',
  order_index int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- `levels` (curso) se relaciona opcionalmente con programa y nivel educativo.
alter table public.levels
  add column if not exists program_id uuid references public.programs (id) on delete set null,
  add column if not exists education_level_id uuid references public.education_levels (id) on delete set null;

-- ---------- Ejes temáticos ----------
-- Eje temático de una asignatura (p. ej. "Números", "Lectura", "Geometría").
create table if not exists public.strands (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  name text not null,
  description text not null default '',
  order_index int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (subject_id, name)
);

-- ---------- Unidades ----------
-- Unidad o tema dentro de un eje temático.
create table if not exists public.units (
  id uuid primary key default gen_random_uuid(),
  strand_id uuid not null references public.strands (id) on delete cascade,
  name text not null,
  description text not null default '',
  order_index int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (strand_id, name)
);

-- ---------- Habilidades ----------
-- Catálogo de habilidades cognitivas/procedimentales (p. ej. "Analizar",
-- "Resolver problemas", "Interpretar información").
create table if not exists public.skills (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text not null default '',
  category text not null default '',
  created_at timestamptz not null default now()
);

-- ---------- Objetivos de aprendizaje ----------
-- No se asume un único currículo: cada objetivo referencia una unidad (que a su
-- vez cuelga de un eje y una asignatura), un curso (`levels`), y guarda fuente
-- curricular + año de referencia para poder convivir varias versiones/programas.
create table if not exists public.learning_objectives (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.units (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  code text,
  short_name text not null,
  description text not null default '',
  priority text not null default 'media'
    check (priority in ('baja', 'media', 'alta')),
  min_recommended_questions int not null default 5,
  status text not null default 'borrador'
    check (status in ('borrador', 'en_revision', 'aprobado', 'archivado')),
  curricular_source text not null default '',
  reference_year int,
  pedagogical_notes text not null default '',
  order_index int not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Tabla puente: un objetivo de aprendizaje puede asociarse a varias habilidades.
create table if not exists public.learning_objective_skills (
  learning_objective_id uuid not null references public.learning_objectives (id) on delete cascade,
  skill_id uuid not null references public.skills (id) on delete cascade,
  primary key (learning_objective_id, skill_id)
);

-- ---------- Row Level Security ----------
-- Mismo patrón que el resto del dominio "Contenido y preguntas": lectura para
-- cualquier usuario autenticado, escritura solo para administradores.
alter table public.programs enable row level security;
alter table public.education_levels enable row level security;
alter table public.strands enable row level security;
alter table public.units enable row level security;
alter table public.skills enable row level security;
alter table public.learning_objectives enable row level security;
alter table public.learning_objective_skills enable row level security;

create policy "programs_select_authenticated" on public.programs for select to authenticated using (true);
create policy "education_levels_select_authenticated" on public.education_levels for select to authenticated using (true);
create policy "strands_select_authenticated" on public.strands for select to authenticated using (true);
create policy "units_select_authenticated" on public.units for select to authenticated using (true);
create policy "skills_select_authenticated" on public.skills for select to authenticated using (true);
create policy "learning_objectives_select_authenticated" on public.learning_objectives for select to authenticated using (true);
create policy "learning_objective_skills_select_authenticated" on public.learning_objective_skills for select to authenticated using (true);

create policy "programs_write_admin" on public.programs for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "education_levels_write_admin" on public.education_levels for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "strands_write_admin" on public.strands for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "units_write_admin" on public.units for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "skills_write_admin" on public.skills for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "learning_objectives_write_admin" on public.learning_objectives for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "learning_objective_skills_write_admin" on public.learning_objective_skills for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));
