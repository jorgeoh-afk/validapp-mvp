-- Dominio: Contenido y preguntas
-- Asignaturas, niveles, lecciones y banco de preguntas (diagnóstico y práctica).

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.levels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  order_index int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  title text not null,
  content text not null default '',
  order_index int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  lesson_id uuid references public.lessons (id) on delete set null,
  prompt text not null,
  choices jsonb not null,
  correct_index int not null,
  created_at timestamptz not null default now()
);

alter table public.subjects enable row level security;
alter table public.levels enable row level security;
alter table public.lessons enable row level security;
alter table public.questions enable row level security;

-- Cualquier usuario autenticado (estudiante o administrador) puede leer el contenido.
create policy "subjects_select_authenticated" on public.subjects for select to authenticated using (true);
create policy "levels_select_authenticated" on public.levels for select to authenticated using (true);
create policy "lessons_select_authenticated" on public.lessons for select to authenticated using (true);
create policy "questions_select_authenticated" on public.questions for select to authenticated using (true);

-- Solo administradores pueden crear, editar o eliminar contenido.
create policy "subjects_write_admin" on public.subjects for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "levels_write_admin" on public.levels for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "lessons_write_admin" on public.lessons for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "questions_write_admin" on public.questions for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));
