-- Dominio: Contenido y preguntas
-- Fase EPJA 7: soporte para generación masiva de preguntas originales
-- ValidApp (ensayos A/B/C + banco de reserva por combinación nivel×
-- asignatura×framework).
--
-- Reutiliza lo existente en vez de duplicar: `questions.validation_status`
-- (0017) ya modela "¿puede usarse en un ensayo publicado?" — se AMPLÍA su
-- check (no se reemplaza) con dos estados intermedios que el flujo de
-- generación por IA necesita y que hoy no existen:
--   - `ai_generated_review_required`: recién generada, nadie la ha
--     revisado todavía. Estado inicial obligatorio de toda pregunta con
--     `source_type='validapp_original'` generada por un agente.
--   - `automatically_validated`: superó los validadores automáticos
--     (lib/data/question-validators.ts: respuesta única, sin duplicados
--     exactos, vínculo curricular correcto, alternativas válidas) pero
--     SIGUE sin revisión humana. Un trigger impide que salte directo a
--     `approved_for_exam` sin pasar por `pedagogically_reviewed` o
--     `source_verified` primero (ver más abajo) — así se cumple la regla
--     de que ninguna IA puede autoasignarse "revisión humana".
--
-- Aditivo y reversible. Migración solo local: no se ejecutó
-- `supabase db push`.

alter table public.questions
  drop constraint if exists questions_validation_status_check;
alter table public.questions
  add constraint questions_validation_status_check check (validation_status in (
    'unverified', 'ai_generated_review_required', 'automatically_validated',
    'pedagogically_reviewed', 'source_verified', 'approved_for_exam'
  ));

-- `question_type` (0011) no tenía check todavía (quedó como texto libre con
-- default). Se formaliza ahora que el generador necesita distinguir tipos
-- reales de pregunta para aplicar reglas distintas (alternativas vs.
-- pauta/rúbrica).
alter table public.questions
  drop constraint if exists questions_question_type_check;
alter table public.questions
  add constraint questions_question_type_check check (question_type in (
    'seleccion_multiple', 'respuesta_abierta_breve', 'respuesta_abierta_extensa'
  ));

alter table public.questions
  add column if not exists answer_key text,
  add column if not exists rubric jsonb,
  add column if not exists sample_answers jsonb,
  add column if not exists content_hash text,
  add column if not exists stimulus_id uuid,
  add column if not exists secondary_curriculum_node_ids uuid[] not null default '{}',
  add column if not exists generated_at timestamptz,
  add column if not exists generated_by text;

comment on column public.questions.answer_key is
  'Respuesta esperada / modelo, solo para respuesta_abierta_breve|extensa. Null en selección múltiple (usa correct_index).';
comment on column public.questions.rubric is
  'Criterios de logro estructurados para preguntas abiertas: [{criterio, puntaje_maximo, descripcion}]. Null en selección múltiple.';
comment on column public.questions.content_hash is
  'Hash normalizado del enunciado (lib/data/question-validators.ts), usado para detectar duplicados exactos antes de insertar.';
comment on column public.questions.secondary_curriculum_node_ids is
  'Objetivos de aprendizaje adicionales que la pregunta también evalúa, además del principal (learning_objective_id).';
comment on column public.questions.generated_by is
  'Identificador del modelo/agente generador (p. ej. "claude-sonnet-5"), solo cuando source_type=validapp_original.';

create index if not exists questions_content_hash_idx on public.questions (content_hash);

-- ---------- Estímulos compartidos (bloques de lectura, tablas, gráficos, mapas) ----------
-- Varias preguntas pueden compartir un mismo estímulo (p. ej. un texto de
-- comprensión lectora con 4 preguntas). Tabla separada en vez de repetir el
-- estímulo en cada fila de `questions`.
create table if not exists public.question_stimuli (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  framework_id uuid references public.curriculum_frameworks (id) on delete restrict,
  stimulus_type text not null default 'texto'
    check (stimulus_type in ('texto', 'tabla', 'grafico', 'mapa', 'imagen')),
  title text,
  body text not null,
  source_type text not null default 'validapp_original'
    check (source_type in ('validapp_original', 'dominio_publico', 'mineduc_official', 'adapted')),
  attribution text,
  created_at timestamptz not null default now()
);

alter table public.questions
  add constraint questions_stimulus_id_fkey foreign key (stimulus_id)
    references public.question_stimuli (id) on delete set null;

alter table public.question_stimuli enable row level security;

-- A diferencia de `questions` (0019, RLS admin-only + RPC), un estímulo NO
-- contiene ninguna respuesta correcta -- es el texto/tabla/gráfico de apoyo
-- que antecede a la pregunta. No hay nada que ocultar antes de responder,
-- así que puede seguir el patrón general "select para cualquier
-- autenticado" del resto del dominio de contenido.
drop policy if exists "question_stimuli_select_authenticated" on public.question_stimuli;
create policy "question_stimuli_select_authenticated" on public.question_stimuli
  for select to authenticated using (true);

drop policy if exists "question_stimuli_write_admin" on public.question_stimuli;
create policy "question_stimuli_write_admin" on public.question_stimuli
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------- Trigger: ninguna IA puede autoasignarse revisión humana ----------
-- Refuerza en la base de datos la regla de negocio (no solo en el código
-- TypeScript del generador): una pregunta no puede pasar a
-- `pedagogically_reviewed`, `source_verified` ni `approved_for_exam` en el
-- mismo movimiento en que se inserta o se marca como generada por IA sin
-- haber pasado antes por `automatically_validated`. No sustituye la
-- revisión humana real (eso solo puede hacerlo un administrador desde el
-- panel), pero bloquea el salto directo "generada por IA -> aprobada".
create or replace function public.prevent_ai_self_approval()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.source_type = 'validapp_original'
     and new.generated_by is not null
     and new.validation_status in ('pedagogically_reviewed', 'source_verified', 'approved_for_exam')
     and (tg_op = 'INSERT' or old.validation_status = 'ai_generated_review_required')
     and not public.is_admin() then
    raise exception 'Una pregunta generada por IA no puede pasar a % sin revisión humana previa (automatically_validated primero, y el cambio a revisión humana solo lo puede hacer un administrador).', new.validation_status;
  end if;
  return new;
end;
$$;

drop trigger if exists questions_prevent_ai_self_approval on public.questions;
create trigger questions_prevent_ai_self_approval
  before insert or update on public.questions
  for each row execute procedure public.prevent_ai_self_approval();

-- ---------- Ensayos: formato oficial vs. interno, criterio de aprobación ----------
alter table public.essays
  add column if not exists is_official_format boolean not null default false,
  add column if not exists passing_percent numeric,
  add column if not exists variant_label text check (variant_label in ('A', 'B', 'C'));

comment on column public.essays.is_official_format is
  'true solo cuando question_count/duración están respaldados por una fuente MINEDUC verificada (ver essays.framework_id -> curriculum_frameworks.source_url). Si es false, la UI debe mostrar "Ensayo de preparación ValidApp", nunca "Examen oficial".';
comment on column public.essays.variant_label is
  'A/B/C: identifica cuál de los 3 ensayos paralelos de una misma combinación nivel×asignatura×framework es este (mismo temario y matriz, preguntas distintas, sin repetir entre variantes).';
