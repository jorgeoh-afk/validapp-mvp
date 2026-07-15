-- Dominio: Resultados y progreso
-- Registro de lecciones completadas por cada estudiante.
-- El estado "bloqueada"/"disponible" se calcula en la aplicación a partir
-- del orden de las lecciones y de qué filas existen aquí; esta tabla solo
-- guarda el hecho consumado de "completada".

create table if not exists public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id uuid not null references public.lessons (id) on delete cascade,
  completed_at timestamptz not null default now(),
  unique (student_id, lesson_id)
);

alter table public.lesson_progress enable row level security;

create policy "lesson_progress_select_own" on public.lesson_progress for select
  using (auth.uid() = student_id);

create policy "lesson_progress_insert_own" on public.lesson_progress for insert
  with check (auth.uid() = student_id);

create policy "lesson_progress_select_admin" on public.lesson_progress for select
  using (public.is_admin());
