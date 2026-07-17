-- Dominio: Resultados y progreso — Fase 6 del rediseño del módulo de
-- contenido/evaluación (experiencia del estudiante rindiendo un ensayo).
--
-- Nota de dominio: a diferencia de 0012_essays.sql (dominio "Contenido y
-- preguntas": configuración y selección automática de preguntas, que es
-- igual para todos los estudiantes), esta migración registra el AVANCE
-- individual de cada estudiante al rendir un ensayo. Por eso cae en el
-- dominio "Resultados y progreso", igual que `diagnostics` y
-- `lesson_progress`, aunque haga referencia a `essays`. No se modifica
-- ninguna tabla de esas fases anteriores.
--
-- Decisión de diseño — barajado de alternativas por intento: `essays.sql`
-- dejó documentado que el orden de las alternativas de cada pregunta debía
-- calcularse recién cuando existiera el concepto de "intento" individual.
-- Aquí se resuelve: `essay_attempt_answers.shuffled_choice_order` guarda,
-- por cada pregunta y cada intento, una permutación de los índices
-- ORIGINALES de `questions.choices` (calculada una sola vez al iniciar el
-- intento, en `startEssayAttempt`). Al responder, `selected_index` guarda el
-- índice ORIGINAL (no la posición visual), para poder compararlo
-- directamente con `questions.correct_index` sin traducir en cada lectura.
--
-- Decisión de diseño — orden de las preguntas por intento: `essays.order_mode`
-- ('fijo' | 'aleatorio') se interpreta aquí como el orden de PRESENTACIÓN de
-- las preguntas al estudiante (no solo de las alternativas). Por eso se
-- agrega `essay_attempt_answers.display_position`: si `order_mode` es
-- 'fijo', se copia `essay_questions.position`; si es 'aleatorio', se baraja
-- una vez por intento. Esto evita crear una tabla adicional solo para el
-- orden de preguntas.
--
-- Decisión de diseño — `allow_repeat_questions` y reintentos: esta columna
-- de `essays` se usó en la Fase 5 para decidir si la GENERACIÓN automática
-- puede reutilizar preguntas ya usadas en otros ensayos. Las preguntas de un
-- ensayo ya generado quedan congeladas en `essay_questions`, así que no hay
-- "preguntas a repetir" dentro de un mismo ensayo: todos los intentos de un
-- mismo ensayo usan siempre el mismo set de preguntas (solo cambia el orden
-- y el barajado de alternativas, calculado por intento). Por lo tanto,
-- `allow_repeat_questions` NO se vuelve a evaluar aquí; lo único que limita
-- cuántas veces puede rendir un estudiante el mismo ensayo es
-- `essays.max_attempts`, contando únicamente los intentos ya cerrados
-- (status 'enviado' o 'expirado' en `essay_attempts`) — un intento 'en_curso'
-- no cuenta como intento consumido.

create table if not exists public.essay_attempts (
  id uuid primary key default gen_random_uuid(),
  essay_id uuid not null references public.essays (id) on delete cascade,
  student_id uuid not null references public.profiles (id) on delete cascade,
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  status text not null default 'en_curso'
    check (status in ('en_curso', 'enviado', 'expirado')),
  score int,
  total_points int,
  time_spent_seconds int,
  created_at timestamptz not null default now()
);

create table if not exists public.essay_attempt_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.essay_attempts (id) on delete cascade,
  question_id uuid not null references public.questions (id) on delete cascade,
  display_position int not null default 0,
  shuffled_choice_order int[] not null default '{}',
  selected_index int,
  is_correct boolean,
  answered_at timestamptz,
  unique (attempt_id, question_id)
);

create index if not exists essay_attempts_essay_student_idx
  on public.essay_attempts (essay_id, student_id);
create index if not exists essay_attempts_student_idx
  on public.essay_attempts (student_id);
create index if not exists essay_attempt_answers_attempt_idx
  on public.essay_attempt_answers (attempt_id);

-- ---------- Row Level Security ----------
-- Mismo patrón que `diagnostics`/`diagnostic_answers`: el estudiante solo ve
-- y crea sus propios intentos y respuestas; el administrador puede leer
-- todos (deja lista la política para el panel de resultados de una fase
-- posterior, que no se implementa aquí).
alter table public.essay_attempts enable row level security;
alter table public.essay_attempt_answers enable row level security;

create policy "essay_attempts_select_own" on public.essay_attempts for select
  using (auth.uid() = student_id);

create policy "essay_attempts_insert_own" on public.essay_attempts for insert
  with check (auth.uid() = student_id);

create policy "essay_attempts_update_own" on public.essay_attempts for update
  using (auth.uid() = student_id)
  with check (auth.uid() = student_id);

create policy "essay_attempts_select_admin" on public.essay_attempts for select
  using (public.is_admin());

create policy "essay_attempt_answers_select_own" on public.essay_attempt_answers for select
  using (
    exists (
      select 1 from public.essay_attempts a
      where a.id = essay_attempt_answers.attempt_id and a.student_id = auth.uid()
    )
  );

create policy "essay_attempt_answers_insert_own" on public.essay_attempt_answers for insert
  with check (
    exists (
      select 1 from public.essay_attempts a
      where a.id = essay_attempt_answers.attempt_id and a.student_id = auth.uid()
    )
  );

create policy "essay_attempt_answers_update_own" on public.essay_attempt_answers for update
  using (
    exists (
      select 1 from public.essay_attempts a
      where a.id = essay_attempt_answers.attempt_id and a.student_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.essay_attempts a
      where a.id = essay_attempt_answers.attempt_id and a.student_id = auth.uid()
    )
  );

create policy "essay_attempt_answers_select_admin" on public.essay_attempt_answers for select
  using (public.is_admin());
