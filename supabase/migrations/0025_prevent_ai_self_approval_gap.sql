-- Dominio: Contenido y preguntas
-- Corrige un hallazgo de QA (defensa en profundidad, no explotable hoy: la
-- política RLS "questions_write_admin" ya exige is_admin() para CUALQUIER
-- escritura en questions, así que esto nunca se pudo saltar en la práctica).
--
-- El trigger `prevent_ai_self_approval` (0023) solo revisaba la transición
-- que parte de `ai_generated_review_required`:
--   (tg_op = 'INSERT' or old.validation_status = 'ai_generated_review_required')
-- pero el propio comentario de 0023 dice que también debe bloquear el salto
-- desde `automatically_validated` sin ser admin. Se amplía la condición
-- para que el trigger cumpla lo que ya prometía.

create or replace function public.prevent_ai_self_approval()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.source_type = 'validapp_original'
     and new.generated_by is not null
     and new.validation_status in ('pedagogically_reviewed', 'source_verified', 'approved_for_exam')
     and (
       tg_op = 'INSERT'
       or old.validation_status in ('ai_generated_review_required', 'automatically_validated')
     )
     and not public.is_admin() then
    raise exception 'Una pregunta generada por IA no puede pasar a % sin revisión humana previa (automatically_validated primero, y el cambio a revisión humana solo lo puede hacer un administrador).', new.validation_status;
  end if;
  return new;
end;
$$;
