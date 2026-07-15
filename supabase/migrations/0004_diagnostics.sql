-- Dominio: Resultados y progreso
-- Diagnósticos rendidos por los estudiantes y sus respuestas.

create table if not exists public.diagnostics (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles (id) on delete cascade,
  subject_id uuid not null references public.subjects (id) on delete cascade,
  estimated_level_id uuid references public.levels (id) on delete set null,
  score int not null,
  total_questions int not null,
  completed_at timestamptz not null default now()
);

create table if not exists public.diagnostic_answers (
  id uuid primary key default gen_random_uuid(),
  diagnostic_id uuid not null references public.diagnostics (id) on delete cascade,
  question_id uuid not null references public.questions (id) on delete cascade,
  selected_index int not null,
  is_correct boolean not null
);

alter table public.diagnostics enable row level security;
alter table public.diagnostic_answers enable row level security;

-- El estudiante solo ve y crea sus propios diagnósticos.
create policy "diagnostics_select_own" on public.diagnostics for select
  using (auth.uid() = student_id);

create policy "diagnostics_insert_own" on public.diagnostics for insert
  with check (auth.uid() = student_id);

-- El administrador puede leer todos los diagnósticos (resultados agregados).
create policy "diagnostics_select_admin" on public.diagnostics for select
  using (public.is_admin());

-- Las respuestas heredan la visibilidad del diagnóstico al que pertenecen.
create policy "diagnostic_answers_select_own" on public.diagnostic_answers for select
  using (
    exists (
      select 1 from public.diagnostics d
      where d.id = diagnostic_answers.diagnostic_id and d.student_id = auth.uid()
    )
  );

create policy "diagnostic_answers_insert_own" on public.diagnostic_answers for insert
  with check (
    exists (
      select 1 from public.diagnostics d
      where d.id = diagnostic_answers.diagnostic_id and d.student_id = auth.uid()
    )
  );

create policy "diagnostic_answers_select_admin" on public.diagnostic_answers for select
  using (public.is_admin());
