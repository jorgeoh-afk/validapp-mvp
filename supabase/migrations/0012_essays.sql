-- Dominio: Contenido y preguntas — Fase 5 del rediseño del módulo administrativo.
--
-- Objetivo: generador automático de ensayos. Introduce la configuración de un
-- ensayo (curso, tipo, distribución solicitada por asignatura/objetivo/
-- dificultad, reglas de tiempo/intentos/feedback) y el resultado de la
-- selección automática de preguntas (`essay_questions`), congelado al momento
-- de generar. Todo es aditivo: no toca `questions`, `subjects`, `levels`,
-- `learning_objectives` ni las tablas de resultados existentes
-- (`diagnostics`, `lesson_progress`, `gamification_stats`).
--
-- Fuera de alcance de esta fase (queda para la Fase 6, experiencia de rendir
-- el ensayo): `essay_attempts` / `essay_attempt_answers`. Se anticipan aquí
-- solo como comentario para dejar registro de la decisión de diseño: el
-- orden barajado de alternativas de cada pregunta (cuando `order_mode` es
-- 'aleatorio') se calculará y guardará a nivel de intento individual del
-- estudiante (una tabla `essay_attempt_answers` con una columna tipo
-- `shuffled_choice_order int[]`), no aquí en `essay_questions` ni en
-- `questions`. Razón: si el orden se barajara una sola vez por ensayo, todos
-- los estudiantes verían las alternativas en el mismo orden (reduciendo el
-- valor anti-copia de barajar) y además no existe todavía in esta fase el
-- concepto de "intento" para guardarlo con la granularidad correcta.

-- ---------- Ensayos ----------
create table if not exists public.essays (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  level_id uuid not null references public.levels (id) on delete cascade,
  essay_type text not null default 'general_curso'
    check (essay_type in (
      'general_curso', 'por_asignatura', 'por_objetivo', 'diagnostico',
      'personalizado', 'practica_errores', 'refuerzo_objetivos'
    )),
  total_questions int not null default 10,
  time_limit_minutes int,
  total_points int,
  order_mode text not null default 'aleatorio'
    check (order_mode in ('fijo', 'aleatorio')),
  allow_repeat_questions boolean not null default false,
  available_from timestamptz,
  max_attempts int,
  feedback_mode text not null default 'al_finalizar'
    check (feedback_mode in ('inmediata', 'al_finalizar')),
  status text not null default 'borrador'
    check (status in (
      'borrador', 'en_revision', 'programado', 'publicado', 'finalizado', 'archivado'
    )),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------- Distribución solicitada por asignatura ----------
create table if not exists public.essay_subjects (
  id uuid primary key default gen_random_uuid(),
  essay_id uuid not null references public.essays (id) on delete cascade,
  subject_id uuid not null references public.subjects (id) on delete cascade,
  question_count int,
  question_percent numeric,
  constraint essay_subjects_count_or_percent check (
    question_count is not null or question_percent is not null
  ),
  unique (essay_id, subject_id)
);

-- ---------- Distribución solicitada por objetivo de aprendizaje ----------
create table if not exists public.essay_objectives (
  id uuid primary key default gen_random_uuid(),
  essay_id uuid not null references public.essays (id) on delete cascade,
  learning_objective_id uuid not null references public.learning_objectives (id) on delete cascade,
  question_count int,
  question_percent numeric,
  constraint essay_objectives_count_or_percent check (
    question_count is not null or question_percent is not null
  ),
  unique (essay_id, learning_objective_id)
);

-- ---------- Distribución solicitada por dificultad ----------
create table if not exists public.essay_difficulty_distribution (
  id uuid primary key default gen_random_uuid(),
  essay_id uuid not null references public.essays (id) on delete cascade,
  difficulty text not null check (difficulty in ('inicial', 'intermedia', 'avanzada')),
  question_count int,
  question_percent numeric,
  constraint essay_difficulty_count_or_percent check (
    question_count is not null or question_percent is not null
  ),
  unique (essay_id, difficulty)
);

-- ---------- Resultado de la selección automática (congelado) ----------
create table if not exists public.essay_questions (
  id uuid primary key default gen_random_uuid(),
  essay_id uuid not null references public.essays (id) on delete cascade,
  question_id uuid not null references public.questions (id) on delete cascade,
  position int not null default 0,
  created_at timestamptz not null default now(),
  unique (essay_id, question_id)
);

-- ---------- Row Level Security ----------
-- Mismo patrón que el resto del dominio "Contenido y preguntas": lectura para
-- cualquier usuario autenticado, escritura solo para administradores.
alter table public.essays enable row level security;
alter table public.essay_subjects enable row level security;
alter table public.essay_objectives enable row level security;
alter table public.essay_difficulty_distribution enable row level security;
alter table public.essay_questions enable row level security;

create policy "essays_select_authenticated" on public.essays for select to authenticated using (true);
create policy "essay_subjects_select_authenticated" on public.essay_subjects for select to authenticated using (true);
create policy "essay_objectives_select_authenticated" on public.essay_objectives for select to authenticated using (true);
create policy "essay_difficulty_distribution_select_authenticated" on public.essay_difficulty_distribution for select to authenticated using (true);
create policy "essay_questions_select_authenticated" on public.essay_questions for select to authenticated using (true);

create policy "essays_write_admin" on public.essays for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "essay_subjects_write_admin" on public.essay_subjects for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "essay_objectives_write_admin" on public.essay_objectives for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "essay_difficulty_distribution_write_admin" on public.essay_difficulty_distribution for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "essay_questions_write_admin" on public.essay_questions for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));
