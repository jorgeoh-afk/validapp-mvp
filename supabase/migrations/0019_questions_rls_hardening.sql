-- Dominio: Contenido y preguntas
-- Endurecimiento de RLS — hallazgo de auditoría de seguridad (no solo
-- limpieza): `questions_select_authenticated` (0002_content.sql) usaba
-- `using (true)`, permitiendo a CUALQUIER usuario autenticado leer
-- `correct_index` y `explanation` de TODAS las preguntas directamente desde
-- el navegador con la anon key, sin pasar por ninguna Server Action.
--
-- Se confirmó que `lib/supabase/server.ts` (`createClient()`, usado por
-- todas las Server Actions de `essay-attempts.ts`, `diagnostics.ts` y
-- `lessons.ts`) crea el cliente con la anon key + cookies de sesión del
-- usuario, NUNCA con `service_role`. Es decir, hoy no existe ningún cliente
-- "de confianza" que se salte RLS: restringir sin más `questions` a
-- `is_admin()` habría roto en producción los 3 flujos de estudiante que leen
-- esa tabla directamente (rendir ensayos, diagnóstico, práctica de lección).
--
-- Solución: 1) el SELECT directo de la tabla base `questions` queda limitado
-- a `is_admin()` (mismo patrón que el resto de escrituras admin del
-- dominio). 2) Se agregan funciones `security definer` (mismo patrón que
-- `public.is_admin()` de 0003 y `public.bump_question_usage_stats()` de
-- 0017) que son la ÚNICA forma en que un estudiante accede a datos de
-- `questions` desde ahora. Cada función:
--   - Replica en SQL la misma comprobación de pertenencia/ownership que hoy
--     hacen las Server Actions en TypeScript (intento propio, intento en
--     curso, etc.) — `security definer` por sí solo NO basta como control de
--     acceso, la función debe seguir validando quién pregunta.
--   - Nunca devuelve `correct_index`/`explanation` en los flujos de "traer
--     pregunta para responder"; sólo los devuelve DESPUÉS de calificar (o
--     para un intento ya cerrado), igual que hace hoy el código TypeScript.
--   - Se ejecuta con `set search_path = public` (evita ataques de
--     "search_path hijacking" sobre funciones security definer).
--   - Se revoca el `execute` por defecto de `public` (que en Postgres
--     incluye a `anon`) y se otorga solo a `authenticated`: un usuario no
--     autenticado no puede invocar ninguna de estas funciones vía RPC.
--
-- Se agrupan en dos familias, una por cada necesidad transversal a los 3
-- flujos (ensayos, diagnóstico, lección), en vez de una función gigante
-- parametrizada por "tipo de flujo": se prefiere una función específica por
-- tabla de resultados porque cada una tiene una regla de ownership distinta
-- (intento propio y en curso vs. sin concepto de "intento" previo), y así
-- cada función queda más simple de auditar.
--
-- Todo es aditivo y reversible: no se elimina ninguna tabla, columna ni
-- función existente. Migración solo local: no se ejecutó `supabase db push`.

-- ---------- 1) SELECT directo de `questions`: solo administradores ----------
drop policy if exists "questions_select_authenticated" on public.questions;
drop policy if exists "questions_select_admin" on public.questions;
create policy "questions_select_admin" on public.questions for select
  to authenticated using (public.is_admin());

-- ============================================================
-- Familia 1 — Ensayos (`essay_attempts` / `essay_attempt_answers`)
-- ============================================================

-- ---------- get_attempt_question_choices ----------
-- Devuelve `id (question_id), position, prompt, choices, resource_url,
-- points` de las preguntas de un intento — SIN `correct_index` ni
-- `explanation` — solo si el intento pertenece al usuario autenticado
-- (`essay_attempts.student_id = auth.uid()`). No exige que el intento esté
-- `en_curso`: se reutiliza para iniciar el intento (`startEssayAttempt`,
-- antes de que existan filas en `essay_attempt_answers`), para renderizar la
-- pregunta mientras se responde (`getAttemptView`) y para calcular el
-- puntaje total al cerrar el intento (`submitEssayAttempt`, que solo
-- necesita `points`). Si el intento no existe o no es del usuario, el filtro
-- `a.student_id = auth.uid()` simplemente no devuelve filas (no se revela
-- con un error si el intento existe o no, evitando enumeración).
create or replace function public.get_attempt_question_choices(p_attempt_id uuid)
returns table (
  question_id uuid,
  position int,
  prompt text,
  choices jsonb,
  resource_url text,
  points int
)
language sql
security definer
set search_path = public
stable
as $$
  select q.id, eq.position, q.prompt, q.choices, q.resource_url, q.points
  from public.essay_attempts a
  join public.essay_questions eq on eq.essay_id = a.essay_id
  join public.questions q on q.id = eq.question_id
  where a.id = p_attempt_id
    and a.student_id = auth.uid()
  order by eq.position;
$$;

revoke all on function public.get_attempt_question_choices(uuid) from public;
grant execute on function public.get_attempt_question_choices(uuid) to authenticated;

-- ---------- grade_essay_answer ----------
-- Califica UNA respuesta de un intento propio. Verifica: 1) el intento
-- pertenece al usuario autenticado, 2) el intento está `en_curso` (no se
-- puede recalificar un intento ya cerrado), 3) la pregunta pertenece a ese
-- intento (existe la fila en `essay_attempt_answers`). Compara internamente
-- contra `correct_index` (que nunca sale de la función hacia el cliente
-- salvo en el valor de retorno, DESPUÉS de calificar — mismo contrato que
-- hoy expone `submitEssayAnswer` en TypeScript), actualiza
-- `essay_attempt_answers` y devuelve `is_correct`, `correct_index` y
-- `explanation`.
create or replace function public.grade_essay_answer(
  p_attempt_id uuid,
  p_question_id uuid,
  p_selected_original_index int
)
returns table (is_correct boolean, correct_index int, explanation text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status text;
  v_correct_index int;
  v_explanation text;
  v_is_correct boolean;
begin
  select a.status into v_status
  from public.essay_attempts a
  where a.id = p_attempt_id and a.student_id = auth.uid();

  if v_status is null then
    raise exception 'Intento no encontrado.';
  end if;
  if v_status <> 'en_curso' then
    raise exception 'Este intento ya fue cerrado.';
  end if;

  select q.correct_index, q.explanation into v_correct_index, v_explanation
  from public.questions q
  where q.id = p_question_id;

  if v_correct_index is null then
    raise exception 'Pregunta no encontrada en este intento.';
  end if;

  v_is_correct := (p_selected_original_index = v_correct_index);

  update public.essay_attempt_answers
    set selected_index = p_selected_original_index,
        is_correct = v_is_correct,
        answered_at = now()
    where attempt_id = p_attempt_id and question_id = p_question_id;

  if not found then
    raise exception 'Pregunta no encontrada en este intento.';
  end if;

  return query select v_is_correct, v_correct_index, v_explanation;
end;
$$;

revoke all on function public.grade_essay_answer(uuid, uuid, int) from public;
grant execute on function public.grade_essay_answer(uuid, uuid, int) to authenticated;

-- ---------- get_attempt_result_answers ----------
-- Detalle completo (incluye `correct_index`/`explanation`) de las respuestas
-- de un intento YA CERRADO (`status <> 'en_curso'`) del propio usuario. Un
-- intento en curso nunca puede leer esto por esta vía (evita que el
-- estudiante consulte las respuestas correctas de preguntas que todavía no
-- respondió, saltándose `grade_essay_answer`).
create or replace function public.get_attempt_result_answers(p_attempt_id uuid)
returns table (
  question_id uuid,
  display_position int,
  shuffled_choice_order int[],
  selected_index int,
  is_correct boolean,
  prompt text,
  choices jsonb,
  correct_index int,
  explanation text,
  points int
)
language sql
security definer
set search_path = public
stable
as $$
  select
    ans.question_id, ans.display_position, ans.shuffled_choice_order,
    ans.selected_index, ans.is_correct,
    q.prompt, q.choices, q.correct_index, q.explanation, q.points
  from public.essay_attempt_answers ans
  join public.essay_attempts a on a.id = ans.attempt_id
  join public.questions q on q.id = ans.question_id
  where ans.attempt_id = p_attempt_id
    and a.student_id = auth.uid()
    and a.status <> 'en_curso'
  order by ans.display_position;
$$;

revoke all on function public.get_attempt_result_answers(uuid) from public;
grant execute on function public.get_attempt_result_answers(uuid) to authenticated;

-- ============================================================
-- Familia 2 — Diagnóstico (`diagnostics` / `diagnostic_answers`)
-- ============================================================

-- ---------- get_diagnostic_questions ----------
-- Preguntas de un diagnóstico por asignatura, sin `correct_index`. No hay
-- concepto de "diagnóstico propio" en este punto (el diagnóstico todavía no
-- existe: se crea recién al calificar), así que el único control es que el
-- rol invocador sea `authenticated` (aplicado vía `grant`/`revoke` más
-- abajo, igual que hoy cualquier autenticado podía leer preguntas).
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
    and q.lesson_id is null;
$$;

revoke all on function public.get_diagnostic_questions(uuid) from public;
grant execute on function public.get_diagnostic_questions(uuid) to authenticated;

-- ---------- grade_diagnostic_questions ----------
-- Califica en bloque las respuestas de un diagnóstico (arreglo de ids de
-- pregunta + arreglo paralelo de índices seleccionados, mismo orden).
-- `unnest(a, b) with ordinality` empareja ambos arreglos por posición antes
-- de unirlos con `questions`; si algún id no existe, esa fila simplemente no
-- aparece en el resultado (mismo comportamiento defensivo que el `.in(...)`
-- que usaba el código anterior). No hay ownership que validar aquí (todavía
-- no existe fila de `diagnostics`): la Server Action crea el diagnóstico
-- DESPUÉS de calificar, usando el resultado de esta función.
create or replace function public.grade_diagnostic_questions(
  p_question_ids uuid[],
  p_selected_indexes int[]
)
returns table (question_id uuid, level_id uuid, is_correct boolean)
language sql
security definer
set search_path = public
stable
as $$
  select q.id, q.level_id, (sel.selected_index = q.correct_index) as is_correct
  from unnest(p_question_ids, p_selected_indexes)
    with ordinality as sel(question_id, selected_index, ord)
  join public.questions q on q.id = sel.question_id
  order by sel.ord;
$$;

revoke all on function public.grade_diagnostic_questions(uuid[], int[]) from public;
grant execute on function public.grade_diagnostic_questions(uuid[], int[]) to authenticated;

-- ============================================================
-- Familia 3 — Práctica de lección (`lessons` / `lesson_progress`)
-- ============================================================

-- ---------- get_lesson_questions ----------
-- Preguntas de práctica de una lección, sin `correct_index`. `lesson_progress`
-- solo guarda el puntaje agregado del intento de práctica (no hay fila por
-- pregunta), así que no hay "intento" al que atar un ownership check; el
-- control de acceso real (lección bloqueada/disponible) ya lo aplica
-- `submitLessonPractice` en TypeScript antes de llamar a esta función,
-- exactamente igual que antes de este cambio.
create or replace function public.get_lesson_questions(p_lesson_id uuid)
returns table (id uuid, prompt text, choices jsonb)
language sql
security definer
set search_path = public
stable
as $$
  select q.id, q.prompt, q.choices
  from public.questions q
  where q.lesson_id = p_lesson_id;
$$;

revoke all on function public.get_lesson_questions(uuid) from public;
grant execute on function public.get_lesson_questions(uuid) to authenticated;

-- ---------- grade_practice_question ----------
-- Califica UNA pregunta de práctica suelta (usada por `checkPracticeAnswer`,
-- invocada desde el cliente antes de enviar el formulario completo). Sin
-- persistencia: solo compara y devuelve el resultado, igual que la versión
-- anterior en TypeScript.
create or replace function public.grade_practice_question(
  p_question_id uuid,
  p_selected_index int
)
returns table (is_correct boolean, correct_index int)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_correct_index int;
begin
  select q.correct_index into v_correct_index
  from public.questions q
  where q.id = p_question_id;

  if v_correct_index is null then
    raise exception 'Pregunta no encontrada.';
  end if;

  return query select (p_selected_index = v_correct_index), v_correct_index;
end;
$$;

revoke all on function public.grade_practice_question(uuid, int) from public;
grant execute on function public.grade_practice_question(uuid, int) to authenticated;

-- ---------- grade_lesson_practice_questions ----------
-- Igual que `grade_diagnostic_questions` pero para la práctica completa de
-- una lección (`submitLessonPractice`): califica en bloque y además
-- devuelve `prompt`/`choices`/`correct_index` porque `PracticeResultQuestion`
-- los muestra en la pantalla de resultado (revelados DESPUÉS de calificar,
-- mismo contrato que antes).
create or replace function public.grade_lesson_practice_questions(
  p_question_ids uuid[],
  p_selected_indexes int[]
)
returns table (
  question_id uuid,
  prompt text,
  choices jsonb,
  correct_index int,
  is_correct boolean
)
language sql
security definer
set search_path = public
stable
as $$
  select q.id, q.prompt, q.choices, q.correct_index,
    (sel.selected_index = q.correct_index) as is_correct
  from unnest(p_question_ids, p_selected_indexes)
    with ordinality as sel(question_id, selected_index, ord)
  join public.questions q on q.id = sel.question_id
  order by sel.ord;
$$;

revoke all on function public.grade_lesson_practice_questions(uuid[], int[]) from public;
grant execute on function public.grade_lesson_practice_questions(uuid[], int[]) to authenticated;
