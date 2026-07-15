-- Dominio: Resultados y progreso
-- Tabla agregada de gamificación, derivada de diagnostics/lesson_progress.
-- No es la fuente de verdad del progreso, solo un resumen para motivar
-- al estudiante (puntos, racha de días activos, insignias).

create table if not exists public.gamification_stats (
  student_id uuid primary key references public.profiles (id) on delete cascade,
  total_points int not null default 0,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  last_activity_date date,
  badges jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.gamification_stats enable row level security;

create policy "gamification_stats_select_own" on public.gamification_stats for select
  using (auth.uid() = student_id);

create policy "gamification_stats_insert_own" on public.gamification_stats for insert
  with check (auth.uid() = student_id);

create policy "gamification_stats_update_own" on public.gamification_stats for update
  using (auth.uid() = student_id);

create policy "gamification_stats_select_admin" on public.gamification_stats for select
  using (public.is_admin());
