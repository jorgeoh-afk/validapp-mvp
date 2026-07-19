-- Dominio: Contenido y preguntas
-- Fase EPJA 2: doble estado de calidad para el banco de preguntas y
-- trazabilidad a versión curricular / fuente.
--
-- `questions.review_status` (0011) ya cubre el ciclo editorial
-- (borrador/en_revision/aprobado/archivado). Falta un segundo eje,
-- independiente: `validation_status`, que responde "¿esta pregunta puede
-- usarse en un ensayo publicado?" — una pregunta puede estar `aprobado`
-- editorialmente pero todavía no `approved_for_exam` (p. ej. pendiente de
-- verificación contra la fuente oficial). Solo la combinación
-- review_status='aprobado' + validation_status='approved_for_exam' +
-- is_active=true habilita el uso en ensayos publicados (regla aplicada en
-- `lib/data/essay-coverage.ts`, no como constraint de BD).
--
-- También se completa la deuda explícita de 0011: `question_usage_stats`
-- tenía estructura y RLS pero ningún trigger que la actualizara.
--
-- Todo es aditivo y reversible: columnas nuevas nullable/con default,
-- función y trigger nuevos. Migración solo local: no se ejecutó
-- `supabase db push`.

alter table public.questions
  add column if not exists validation_status text not null default 'unverified'
    check (validation_status in (
      'unverified', 'pedagogically_reviewed', 'source_verified', 'approved_for_exam'
    )),
  add column if not exists is_active boolean not null default true,
  add column if not exists framework_id uuid
    references public.curriculum_frameworks (id) on delete restrict,
  add column if not exists source_id uuid
    references public.content_sources (id) on delete set null,
  add column if not exists source_type text not null default 'validapp_original'
    check (source_type in ('mineduc_official', 'validapp_original', 'adapted'));

-- ---------- Trigger: estadísticas de uso por pregunta ----------
-- Se dispara al insertar una respuesta de un intento de ensayo
-- (`essay_attempt_answers`). Solo cuenta cuando la respuesta ya fue
-- calificada (answered_at/is_correct no nulos) — al iniciar un intento se
-- insertan filas "vacías" (snapshot) que todavía no son una respuesta real.
--
-- `security definer`: el estudiante que responde no tiene (ni debe tener)
-- permiso de escritura directo en `question_usage_stats`
-- (`question_usage_stats_write_admin` es admin-only, 0011). Igual que
-- `public.is_admin()` (0003), el trigger corre con los privilegios de su
-- dueño para poder actualizar la estadística agregada sin darle al
-- estudiante acceso de escritura a la tabla.
create or replace function public.bump_question_usage_stats()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.answered_at is null or new.is_correct is null then
    return new;
  end if;
  -- Evita contar dos veces si una respuesta se corrige (update posterior).
  if tg_op = 'UPDATE'
     and old.answered_at is not null
     and old.is_correct is not null then
    return new;
  end if;

  insert into public.question_usage_stats (question_id, times_used, correct_count, total_answers, updated_at)
  values (new.question_id, 1, case when new.is_correct then 1 else 0 end, 1, now())
  on conflict (question_id) do update
    set times_used = public.question_usage_stats.times_used + 1,
        correct_count = public.question_usage_stats.correct_count
          + case when new.is_correct then 1 else 0 end,
        total_answers = public.question_usage_stats.total_answers + 1,
        updated_at = now();

  return new;
end;
$$;

drop trigger if exists essay_attempt_answers_bump_usage_stats on public.essay_attempt_answers;
create trigger essay_attempt_answers_bump_usage_stats
  after insert or update on public.essay_attempt_answers
  for each row execute procedure public.bump_question_usage_stats();
