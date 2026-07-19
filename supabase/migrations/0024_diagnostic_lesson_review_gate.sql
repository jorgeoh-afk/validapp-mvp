-- Dominio: Contenido y preguntas
-- Corrige un hallazgo real de QA (revisión post-despliegue del currículum
-- EPJA): `get_diagnostic_questions` y `get_lesson_questions` (migración
-- 0019) no filtraban por estado de revisión -- cualquier pregunta con
-- `lesson_id is null` entraba al pool de Diagnóstico de su asignatura sin
-- pasar por `/admin/revision-preguntas`, contradiciendo la regla central
-- de esta sesión ("nunca contenido generado por IA sin revisión humana").
-- Esto no era explotable antes de esta sesión (no existía contenido en
-- `ai_generated_review_required`/`automatically_validated`), pero las 664
-- preguntas EPJA importadas sí quedan en ese estado.
--
-- Mismo criterio que ya usa `essays.ts`/`essay-selection.ts` para publicar
-- un ensayo: `is_active = true` y `validation_status = 'approved_for_exam'`.
-- Preguntas antiguas sin `validation_status` explícito (`unverified`, el
-- default histórico de contenido creado a mano antes de la migración 0017)
-- quedan EXCLUIDAS por este cambio -- ver nota abajo sobre cómo destrabar
-- contenido preexistente si corresponde.

create or replace function public.get_diagnostic_questions(p_subject_id uuid)
returns table (id uuid, prompt text, choices jsonb, level_id uuid)
language sql
security definer
set search_path = public
stable
as $$
  select q.id, q.prompt, q.choices, q.level_id
  from public.questions q
  where q.subject_id = p_subject_id
    and q.lesson_id is null
    and q.is_active = true
    and q.validation_status = 'approved_for_exam';
$$;

create or replace function public.get_lesson_questions(p_lesson_id uuid)
returns table (id uuid, prompt text, choices jsonb)
language sql
security definer
set search_path = public
stable
as $$
  select q.id, q.prompt, q.choices
  from public.questions q
  where q.lesson_id = p_lesson_id
    and q.is_active = true
    and q.validation_status = 'approved_for_exam';
$$;

-- Nota operativa: si esto deja SIN preguntas un diagnóstico/lección que
-- antes funcionaba (contenido antiguo creado a mano, nunca pasó por el
-- pipeline de `validation_status` introducido en 0017), la corrección no es
-- revertir este filtro sino marcar ese contenido como
-- `validation_status = 'approved_for_exam'` explícitamente -- que es
-- justamente la revisión humana que esta regla busca forzar a que ocurra a
-- propósito, no por default.
