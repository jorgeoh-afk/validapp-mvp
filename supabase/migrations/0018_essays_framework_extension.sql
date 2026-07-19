-- Dominio: Contenido y preguntas
-- Fase EPJA 3: extender el motor de ensayos ya existente (no duplicarlo)
-- para que pueda ligarse a una versión curricular y expresar cuotas por eje
-- y por mínimo/máximo (no solo cantidad exacta).
--
-- Decisión de diseño (confirmada con el usuario): se extienden
-- `essays`/`essay_objectives` y se agrega `essay_strand_distribution` en vez
-- de crear un esquema paralelo `exam_blueprints`/`exam_attempts`. El motor
-- ya resuelve selección por distribución, snapshot inmutable por intento,
-- barajado y cálculo de score (`0012`/`0013`); duplicarlo solo para
-- renombrar tablas sería repetir lógica ya probada.
--
-- Todo es aditivo y reversible. Migración solo local: no se ejecutó
-- `supabase db push`.

alter table public.essays
  add column if not exists framework_id uuid
    references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists coverage_status text
    check (coverage_status in (
      'not_ready', 'insufficient_questions', 'incomplete_coverage', 'ready', 'published'
    )),
  add column if not exists coverage_checked_at timestamptz,
  add column if not exists target_student_id uuid
    references public.profiles (id) on delete cascade;

-- `target_student_id`: los tipos `practica_errores` y `refuerzo_objetivos`
-- (declarados desde 0012, sin lógica de selección hasta esta fase) son por
-- naturaleza personalizados al historial de UN estudiante, a diferencia del
-- resto de los tipos de ensayo, donde `essay_questions` es un set congelado
-- compartido por todos los intentos (0013). En vez de rediseñar el motor
-- para generar la selección al vuelo por intento, se mantiene el mismo
-- modelo "un essay = una selección congelada" y se agrega esta columna
-- nullable: el administrador crea un ensayo de práctica/refuerzo dirigido a
-- un estudiante puntual, y `generateEssay` (lib/data/essays.ts) usa el
-- historial de ESE estudiante para construir los requisitos por objetivo.
-- Nulo para todos los tipos de ensayo existentes (comportamiento idéntico a
-- hoy). Ver política de lectura más abajo: un ensayo con
-- `target_student_id` solo lo puede ver ese estudiante (y el administrador),
-- no "cualquier autenticado" como el resto de `essays` — de lo contrario se
-- filtraría a otros estudiantes qué compañero tiene más errores en qué
-- objetivo.
comment on column public.essays.target_student_id is
  'Solo aplica a essay_type practica_errores/refuerzo_objetivos: estudiante para quien se generó la selección personalizada.';

-- `question_count`/`question_percent` (0012) siguen siendo la cuota EXACTA
-- solicitada. `minimum_questions`/`maximum_questions` son opcionales y
-- conviven con la cuota exacta para poder expresar rangos ("al menos 3, a lo
-- más 6") sin romper `essay_objectives_count_or_percent`.
alter table public.essay_objectives
  add column if not exists minimum_questions int,
  add column if not exists maximum_questions int,
  add column if not exists is_required boolean not null default false;

-- ---------- Distribución solicitada por eje temático ----------
-- Mismo patrón que `essay_difficulty_distribution` (0012): cuota por eje sin
-- tocar `essay_subjects`/`essay_objectives`.
create table if not exists public.essay_strand_distribution (
  id uuid primary key default gen_random_uuid(),
  essay_id uuid not null references public.essays (id) on delete cascade,
  strand_id uuid not null references public.strands (id) on delete cascade,
  question_count int,
  question_percent numeric,
  is_required boolean not null default false,
  constraint essay_strand_distribution_count_or_percent check (
    question_count is not null or question_percent is not null
  ),
  unique (essay_id, strand_id)
);

alter table public.essay_strand_distribution enable row level security;

drop policy if exists "essay_strand_distribution_select_authenticated" on public.essay_strand_distribution;
create policy "essay_strand_distribution_select_authenticated" on public.essay_strand_distribution
  for select to authenticated using (true);

drop policy if exists "essay_strand_distribution_write_admin" on public.essay_strand_distribution;
create policy "essay_strand_distribution_write_admin" on public.essay_strand_distribution
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------- RLS: restringir lectura de ensayos personalizados ----------
-- `essays_select_authenticated` (0012) es `using (true)`: cualquier
-- autenticado ve cualquier ensayo. Eso es correcto para los tipos de ensayo
-- existentes (todos comparten el mismo `essay_questions`, no revelan nada
-- individual), pero un ensayo con `target_student_id` no nulo (práctica de
-- errores / refuerzo de un estudiante puntual) sí revela información
-- individual: que ESE estudiante tiene errores en ESE objetivo. Se
-- reemplaza la política para excluir esos ensayos salvo para su propio
-- estudiante o un administrador. No cambia nada para las filas existentes
-- (todas tienen `target_student_id` nulo hoy).
drop policy if exists "essays_select_authenticated" on public.essays;
create policy "essays_select_own_or_general" on public.essays for select
  to authenticated
  using (
    target_student_id is null
    or target_student_id = auth.uid()
    or public.is_admin()
  );
