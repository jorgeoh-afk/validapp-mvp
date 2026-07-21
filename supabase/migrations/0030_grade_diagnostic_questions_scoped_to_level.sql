-- Dominio: Contenido y preguntas.
--
-- Contexto (gap identificado y aprobado por el usuario para cerrar ahora,
-- inmediatamente después de 0029_diagnostic_scoped_to_enrolled_level.sql):
-- 0029 restringió `get_diagnostic_questions` para que solo entregue preguntas
-- del nivel inscrito del estudiante (`profiles.target_level_id`). Sin
-- embargo, `grade_diagnostic_questions(p_question_ids uuid[],
-- p_selected_indexes int[])` (0019_questions_rls_hardening.sql, líneas
-- 236-251) califica CUALQUIER `question_id` que llegue desde el cliente
-- (`submitDiagnostic` en `lib/data/diagnostics.ts` arma `questionIds` a partir
-- de un campo oculto del formulario) sin validar que esas preguntas
-- pertenezcan al nivel inscrito del estudiante. Un request manipulado (POST
-- directo sin pasar por la UI) podría intentar colar ids de preguntas de
-- OTRO nivel -- que sí existen en `questions` y sí tienen `correct_index` --
-- y la función las calificaría igual, contaminando el resultado del
-- diagnóstico y el cálculo de `levelStats`/errores guardados (dominio
-- Resultados y progreso, ver `lib/data/diagnostics.ts` y
-- `lib/data/gamification.ts`).
--
-- Solución: se agrega un tercer parámetro `p_level_id uuid` y se filtra el
-- join contra `questions` también por `q.level_id = p_level_id`, ADEMÁS del
-- emparejamiento posicional por `unnest(...) with ordinality` que ya existía
-- (ese emparejamiento sigue igual: solo cambia qué filas de `questions`
-- pueden hacer match). Cualquier `question_id` que no pertenezca a
-- `p_level_id` simplemente no aparece en el resultado -- mismo
-- comportamiento defensivo que ya tenía la función para ids inexistentes (no
-- se lanza error, la fila desaparece), para no revelar por un mensaje de
-- error si el id existe en otro nivel.
--
-- Las columnas devueltas NO cambian: siguen siendo exactamente
-- `question_id uuid, level_id uuid, is_correct boolean` (mismas que 0019
-- líneas 240 y 246-250), para no romper `GradeDiagnosticQuestionRow` en
-- `lib/data/diagnostics.ts` más que en la firma de invocación (que sí cambia,
-- ver nota final).
--
-- Por qué `drop function` y no solo `create or replace`: se agrega un
-- parámetro nuevo, lo que cambia la firma
-- (`grade_diagnostic_questions(uuid[], int[])` ->
-- `grade_diagnostic_questions(uuid[], int[], uuid)`). Postgres identifica una
-- función por nombre + tipos de argumentos, así que `create or replace` sobre
-- la firma vieja NO la reemplaza: dejaría DOS funciones sobrepuestas, y
-- cualquier código que siga llamando con dos argumentos seguiría
-- funcionando contra la versión vieja sin filtro de nivel -- exactamente el
-- gap que se busca cerrar. Mismo patrón que 0029 usó para
-- `get_diagnostic_questions`.
--
-- Se revisó (grep de `grade_diagnostic_questions` en todo el repo) si algo
-- más dependía de la firma vieja antes de escribir esta migración:
--   - `0019_questions_rls_hardening.sql`: define la firma vieja
--     `grade_diagnostic_questions(uuid[], int[])` por primera vez (líneas
--     236-254). No hay ninguna otra migración que la redefina ni la invoque
--     (0024 no la toca; 0027_student_mistakes.sql solo la menciona en un
--     comentario explicativo, no la llama ni la redefine; 0029 la nombra
--     explícitamente como "NO cambia" -- este archivo actualiza esa
--     afirmación, ya que el gap fue detectado después).
--   - `lib/data/diagnostics.ts` (línea ~99, función `submitDiagnostic`) y su
--     test `lib/data/diagnostics.test.ts` son el único llamador real, vía
--     `supabase.rpc("grade_diagnostic_questions", ...)`. Ambos quedan FUERA
--     del alcance de esta migración a propósito: los actualiza en paralelo
--     el agente `validapp-assessment-engineer` para pasar el nuevo
--     `p_level_id` (típicamente `profile.target_level_id`, el mismo valor ya
--     usado para llamar a `get_diagnostic_questions` en la misma función).
--     Ver el bloque final de este archivo para la firma exacta que debe
--     usar.
--   - Ningún archivo de `supabase/seed/` invoca la función (los seeds solo
--     insertan filas de `questions`/`levels`/etc., no llaman RPC).
--
-- `get_diagnostic_questions` (misma familia, redefinida en 0029) NO cambia
-- en este archivo: ya quedó restringida a `p_level_id` en 0029.
--
-- Reversibilidad: si se necesita revertir, la migración correctiva sería
-- simétrica (drop de la firma de 3 argumentos + recrear la firma de 2
-- argumentos con el cuerpo de 0019) -- no se modifica ningún archivo
-- histórico. Migración solo local: no se ejecutó `supabase db push` ni
-- ningún SQL de escritura contra un proyecto remoto (dev o prod).

drop function if exists public.grade_diagnostic_questions(uuid[], int[]);

create or replace function public.grade_diagnostic_questions(
  p_question_ids uuid[],
  p_selected_indexes int[],
  p_level_id uuid
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
  join public.questions q
    on q.id = sel.question_id
    and q.level_id = p_level_id
  order by sel.ord;
$$;

revoke all on function public.grade_diagnostic_questions(uuid[], int[], uuid) from public;
grant execute on function public.grade_diagnostic_questions(uuid[], int[], uuid) to authenticated;

-- ============================================================
-- NOTA PARA EL AGENTE `validapp-assessment-engineer` (o cualquier otro
-- código que invoque esta función vía `supabase.rpc(...)`):
--
--   Firma nueva exacta:
--     grade_diagnostic_questions(
--       p_question_ids uuid[],
--       p_selected_indexes int[],
--       p_level_id uuid
--     )
--     returns table (question_id uuid, level_id uuid, is_correct boolean)
--
--   La firma vieja grade_diagnostic_questions(uuid[], int[]) YA NO EXISTE
--   (fue eliminada por el `drop function` de arriba): cualquier llamada que
--   invoque el RPC con solo `p_question_ids`/`p_selected_indexes` fallará con
--   un error de Postgres ("function ... does not exist"), no con un
--   resultado vacío. Actualizar `lib/data/diagnostics.ts`
--   (`submitDiagnostic`) para enviar también `p_level_id` -- el mismo
--   `profile.target_level_id` que ya se usa unas líneas antes para llamar a
--   `get_diagnostic_questions` -- antes de que este cambio llegue a
--   cualquier entorno donde se aplique. Las columnas de retorno
--   (`question_id`, `level_id`, `is_correct`) no cambiaron, así que
--   `GradeDiagnosticQuestionRow` en TypeScript no necesita modificarse.
-- ============================================================
