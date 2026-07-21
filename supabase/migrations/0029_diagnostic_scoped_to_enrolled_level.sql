-- Dominio: Contenido y preguntas (consume `profiles.target_level_id`, del
-- dominio Autenticación y usuarios, agregado en 0028 -- ver nota de alcance
-- más abajo).
--
-- Contexto (decisión explícita del usuario, misma sesión que separó
-- Currículum Regular vs EPJA en 0028_regular_epja_curriculum_hierarchy.sql):
-- se restringe TOTALMENTE el contenido que ve un estudiante a su
-- inscripción (`profiles.target_program_id` / `profiles.target_level_id`),
-- incluyendo el diagnóstico inicial. Antes de este cambio,
-- `get_diagnostic_questions(p_subject_id uuid)` (0019, redefinida en 0024
-- para sumar el filtro de `validation_status`) trae a propósito preguntas de
-- TODAS las niveles de una asignatura: el diagnóstico usaba ese pool amplio
-- para ESTIMAR en qué nivel debería estar el estudiante
-- (`diagnostics.estimated_level_id`, ver `lib/data/progress.ts`), sin asumir
-- de antemano cuál es su nivel real.
--
-- CAMBIO DE COMPORTAMIENTO REAL (no solo aditivo, se documenta explícito en
-- vez de esconderlo): al restringir también el diagnóstico al nivel
-- inscrito, el diagnóstico DEJA DE ESTIMAR nivel y pasa a ser una prueba fija
-- del nivel en el que el estudiante ya está inscrito. El usuario fue avisado
-- de esta consecuencia y decidió aceptarla explícitamente como parte de la
-- restricción total de contenido por inscripción. Este archivo NO toca
-- `diagnostics.estimated_level_id` ni ninguna lógica de cálculo de nivel
-- estimado -- ese campo puede quedar en desuso o redefinirse en una
-- migración/tarea aparte; está fuera del alcance de este cambio, que es
-- puramente el filtro de preguntas de la función RPC.
--
-- Por qué `drop function` y no solo `create or replace`: se agrega un
-- parámetro nuevo (`p_level_id uuid`), lo que cambia la firma de la función
-- (`get_diagnostic_questions(uuid)` -> `get_diagnostic_questions(uuid,
-- uuid)`). Postgres identifica una función por nombre + tipos de argumentos,
-- así que `create or replace` sobre la firma vieja NO la reemplaza: dejaría
-- DOS funciones sobrepuestas (`get_diagnostic_questions(uuid)` intacta y
-- `get_diagnostic_questions(uuid, uuid)` nueva), y cualquier código que siga
-- llamando con un solo argumento seguiría funcionando contra la versión
-- vieja sin restricción de nivel -- exactamente el bug de seguridad/negocio
-- que se busca cerrar. Por eso se elimina primero la firma vieja.
--
-- Se revisó (grep de `get_diagnostic_questions` en `supabase/migrations/` y
-- `supabase/seed/`) si algo más dependía de la firma vieja antes de escribir
-- esta migración:
--   - `0019_questions_rls_hardening.sql`: define la firma vieja
--     `get_diagnostic_questions(uuid)` por primera vez.
--   - `0024_diagnostic_lesson_review_gate.sql`: la redefine con
--     `create or replace` (misma firma vieja) para sumar el filtro de
--     `validation_status`/`is_active`. Ese filtro se preserva íntegro en la
--     nueva versión de abajo.
--   - Ningún archivo de `supabase/seed/` invoca la función (los seeds solo
--     insertan filas de `questions`/`levels`/etc., no llaman RPC).
--   - El único llamador real es `lib/data/diagnostics.ts` (código
--     TypeScript, vía `supabase.rpc("get_diagnostic_questions", ...)`) y su
--     test `lib/data/diagnostics.test.ts`. Ambos quedan FUERA del alcance de
--     esta migración a propósito: los actualiza en paralelo el agente
--     `validapp-assessment-engineer` para pasar el nuevo `p_level_id`. Ver el
--     bloque final de este archivo para la firma exacta que debe usar.
--
-- `grade_diagnostic_questions` (misma familia, 0019 líneas 236+) NO cambia:
-- solo califica por ids de pregunta ya elegidos (recibidos desde
-- `get_diagnostic_questions`), nunca necesitó saber el nivel para calificar.
--
-- Reversibilidad: si se necesita revertir, la migración correctiva sería
-- simétrica (drop de la firma de 2 argumentos + recrear la firma de 1
-- argumento con el cuerpo de 0024) -- no se modifica ningún archivo
-- histórico. Migración solo local: no se ejecutó `supabase db push` ni
-- ningún SQL de escritura contra un proyecto remoto (dev o prod).

drop function if exists public.get_diagnostic_questions(uuid);

create or replace function public.get_diagnostic_questions(
  p_subject_id uuid,
  p_level_id uuid
)
returns table (id uuid, prompt text, choices jsonb, level_id uuid)
language sql
security definer
set search_path = public
stable
as $$
  select q.id, q.prompt, q.choices, q.level_id
  from public.questions q
  where q.subject_id = p_subject_id
    and q.level_id = p_level_id
    and q.lesson_id is null
    and q.is_active = true
    and q.validation_status = 'approved_for_exam';
$$;

revoke all on function public.get_diagnostic_questions(uuid, uuid) from public;
grant execute on function public.get_diagnostic_questions(uuid, uuid) to authenticated;

-- ============================================================
-- NOTA PARA EL AGENTE `validapp-assessment-engineer` (o cualquier otro
-- código que invoque esta función vía `supabase.rpc(...)`):
--
--   Firma nueva exacta:
--     get_diagnostic_questions(p_subject_id uuid, p_level_id uuid)
--     returns table (id uuid, prompt text, choices jsonb, level_id uuid)
--
--   La firma vieja get_diagnostic_questions(p_subject_id uuid) YA NO EXISTE
--   (fue eliminada por el `drop function` de arriba): cualquier llamada que
--   invoque el RPC con un solo argumento fallará con un error de Postgres
--   ("function ... does not exist"), no con un resultado vacío. Actualizar
--   `lib/data/diagnostics.ts` para enviar también `p_level_id` (típicamente
--   `profile.target_level_id` del estudiante autenticado) antes de que este
--   cambio llegue a cualquier entorno donde se aplique.
-- ============================================================
