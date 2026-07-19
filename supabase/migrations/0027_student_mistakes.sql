-- Dominio: Resultados y progreso (con lectura de Contenido y preguntas para
-- mostrar el detalle de cada pregunta fallada).
--
-- Función para la pantalla "Revisar errores" (/errores): junta las preguntas
-- que el estudiante autenticado falló en diagnósticos y en ensayos, con el
-- detalle necesario para mostrarlas (enunciado, alternativas, cuál marcó,
-- cuál era la correcta, explicación).
--
-- Por qué hace falta una función SECURITY DEFINER en vez de una query directa
-- desde la app: la migración 0019_questions_rls_hardening.sql endureció la
-- RLS de `public.questions` -- solo `is_admin()` puede hacer
-- `select` directo sobre esa tabla ahora. Un estudiante nunca podría leer
-- `prompt`/`choices`/`correct_index`/`explanation` con su propia sesión sin
-- pasar por una función como esta (mismo patrón que
-- `get_attempt_result_answers`, que ya resuelve el mismo problema para el
-- resultado de un intento de ensayo).
--
-- Ownership: NO se recibe ningún id de estudiante como parámetro -- se usa
-- `auth.uid()` directamente adentro de la función, así que no hay forma de
-- pedir los errores de otro estudiante llamando a esta función con otro id.
-- Para ensayos, se exige además `a.status <> 'en_curso'` (mismo criterio que
-- `get_attempt_result_answers`): un intento todavía en curso nunca expone
-- `correct_index`/`explanation` por esta vía. Los diagnósticos no tienen ese
-- problema: la fila de `diagnostics` recién se crea DESPUÉS de calificar
-- (ver `grade_diagnostic_questions`), así que si existe la fila, ya está
-- completo.
--
-- No cubre la práctica de lecciones: `grade_practice_question`/
-- `grade_lesson_practice_questions` (0019) califican al vuelo sin persistir
-- el detalle por pregunta, así que no hay datos históricos de qué preguntas
-- de lección falló un estudiante. Si se quiere cubrir eso en el futuro, hace
-- falta agregar esa persistencia primero (tarea de esquema aparte).

create or replace function public.get_student_mistakes()
returns table (
  source text,
  source_id uuid,
  answered_at timestamptz,
  subject_id uuid,
  subject_name text,
  question_id uuid,
  prompt text,
  choices jsonb,
  selected_index int,
  correct_index int,
  explanation text
)
language sql
security definer
set search_path = public
stable
as $$
  select
    'diagnostico' as source,
    d.id as source_id,
    d.completed_at as answered_at,
    q.subject_id,
    s.name as subject_name,
    q.id as question_id,
    q.prompt,
    q.choices,
    da.selected_index,
    q.correct_index,
    q.explanation
  from public.diagnostic_answers da
  join public.diagnostics d on d.id = da.diagnostic_id
  join public.questions q on q.id = da.question_id
  join public.subjects s on s.id = q.subject_id
  where d.student_id = auth.uid()
    and da.is_correct = false

  union all

  select
    'ensayo' as source,
    a.id as source_id,
    a.submitted_at as answered_at,
    q.subject_id,
    s.name as subject_name,
    q.id as question_id,
    q.prompt,
    q.choices,
    ans.selected_index,
    q.correct_index,
    q.explanation
  from public.essay_attempt_answers ans
  join public.essay_attempts a on a.id = ans.attempt_id
  join public.questions q on q.id = ans.question_id
  join public.subjects s on s.id = q.subject_id
  where a.student_id = auth.uid()
    and a.status <> 'en_curso'
    and ans.is_correct = false

  order by answered_at desc;
$$;

revoke all on function public.get_student_mistakes() from public;
grant execute on function public.get_student_mistakes() to authenticated;
