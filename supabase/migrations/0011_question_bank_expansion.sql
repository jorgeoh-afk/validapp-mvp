-- Dominio: Contenido y preguntas
-- Fase 3 del rediseño del módulo administrativo de contenido educativo.
--
-- Objetivo: ampliar el banco de preguntas (`questions`) con metadatos
-- pedagógicos y de gestión (recurso asociado, explicación, objetivo de
-- aprendizaje, habilidad, dificultad, tipo, puntaje, tiempo estimado, fuente
-- y estado de revisión), además de un catálogo de etiquetas y una tabla
-- preparada para estadísticas de uso.
--
-- Todo es aditivo y reversible:
--   - Columnas nuevas en `questions`, todas nullable o con default, sin
--     alterar el significado de `prompt`, `choices`, `correct_index`,
--     `lesson_id`, `subject_id`, `level_id` existentes.
--   - Tablas nuevas: `question_tags`, `question_tag_assignments`,
--     `question_usage_stats`.
--
-- Decisión de diseño: `question_usage_stats` queda preparada (estructura +
-- RLS) pero sin trigger automático todavía. Conectarla a
-- `diagnostic_answers` / `lesson_progress` implica decidir cómo
-- des-duplicar reintentos y recalcular históricos; se deja para una fase de
-- estadísticas posterior, para no ampliar el alcance de esta fase.

-- ---------- Columnas nuevas en `questions` ----------
alter table public.questions
  add column if not exists resource_url text,
  add column if not exists explanation text,
  add column if not exists learning_objective_id uuid
    references public.learning_objectives (id) on delete set null,
  add column if not exists skill_id uuid
    references public.skills (id) on delete set null,
  add column if not exists difficulty text not null default 'intermedia'
    check (difficulty in ('inicial', 'intermedia', 'avanzada')),
  add column if not exists question_type text not null default 'seleccion_multiple',
  add column if not exists points int not null default 1,
  add column if not exists estimated_seconds int,
  add column if not exists source text,
  add column if not exists review_status text not null default 'borrador'
    check (review_status in ('borrador', 'en_revision', 'aprobado', 'archivado')),
  add column if not exists updated_at timestamptz not null default now();

-- ---------- Etiquetas ----------
create table if not exists public.question_tags (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.question_tag_assignments (
  question_id uuid not null references public.questions (id) on delete cascade,
  tag_id uuid not null references public.question_tags (id) on delete cascade,
  primary key (question_id, tag_id)
);

-- ---------- Estadísticas de uso (estructura lista, sin trigger todavía) ----------
create table if not exists public.question_usage_stats (
  question_id uuid primary key references public.questions (id) on delete cascade,
  times_used int not null default 0,
  correct_count int not null default 0,
  total_answers int not null default 0,
  updated_at timestamptz not null default now()
);

-- ---------- Row Level Security ----------
alter table public.question_tags enable row level security;
alter table public.question_tag_assignments enable row level security;
alter table public.question_usage_stats enable row level security;

create policy "question_tags_select_authenticated" on public.question_tags for select to authenticated using (true);
create policy "question_tag_assignments_select_authenticated" on public.question_tag_assignments for select to authenticated using (true);
create policy "question_usage_stats_select_authenticated" on public.question_usage_stats for select to authenticated using (true);

create policy "question_tags_write_admin" on public.question_tags for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "question_tag_assignments_write_admin" on public.question_tag_assignments for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));

create policy "question_usage_stats_write_admin" on public.question_usage_stats for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));
