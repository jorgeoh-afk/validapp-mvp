-- Dominio: Autenticación y usuarios (registro transversal de auditoría)
-- Fase EPJA 4: bitácora de cambios sobre entidades sensibles del currículum
-- EPJA. Antes de esta migración el repo no tenía ninguna tabla de auditoría
-- (`audit_log`/`activity_log`/etc.) — cambios de texto oficial, estado de
-- validación de preguntas o publicación de ensayos no dejaban rastro de
-- quién los hizo ni qué valor tenían antes.
--
-- Decisión de diseño: una sola tabla genérica (`entity_type` + `entity_id`)
-- en vez de una tabla de auditoría por entidad, siguiendo el mismo criterio
-- de "no duplicar estructura" del resto de estas migraciones. Un trigger
-- genérico (`log_audit_change`) se reutiliza en las 3 tablas que esta etapa
-- considera sensibles: `curriculum_frameworks`, `questions` (solo cuando
-- cambia review_status/validation_status/is_active — no en cada
-- `updated_at`) y `essays` (solo cuando cambia `status`). No se audita
-- INSERT/DELETE en esta fase (alcance: detectar ediciones silenciosas de
-- contenido/estado ya existente, no todo el ciclo de vida) — queda anotado
-- como posible ampliación futura.
--
-- Todo es aditivo y reversible. Migración solo local: no se ejecutó
-- `supabase db push`.

create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid not null,
  previous_value jsonb,
  new_value jsonb,
  created_at timestamptz not null default now()
);

create index if not exists audit_log_entity_idx
  on public.audit_log (entity_type, entity_id);

alter table public.audit_log enable row level security;

drop policy if exists "audit_log_select_admin" on public.audit_log;
create policy "audit_log_select_admin" on public.audit_log for select
  to authenticated using (public.is_admin());

-- Sin política de insert: solo el trigger `security definer` escribe en
-- esta tabla (ver más abajo), nunca el cliente directamente.

-- ---------- Trigger genérico ----------
create or replace function public.log_audit_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  watched_columns text[] := string_to_array(tg_argv[0], ',');
  col text;
  changed boolean := false;
begin
  foreach col in array watched_columns loop
    if to_jsonb(new) -> col is distinct from to_jsonb(old) -> col then
      changed := true;
    end if;
  end loop;

  if not changed then
    return new;
  end if;

  insert into public.audit_log (user_id, action, entity_type, entity_id, previous_value, new_value)
  values (auth.uid(), tg_op, tg_table_name, new.id, to_jsonb(old), to_jsonb(new));

  return new;
end;
$$;

drop trigger if exists curriculum_frameworks_audit on public.curriculum_frameworks;
create trigger curriculum_frameworks_audit
  after update on public.curriculum_frameworks
  for each row execute procedure public.log_audit_change('status,decree_number,decree_year,source_url,verified_at');

drop trigger if exists questions_audit on public.questions;
create trigger questions_audit
  after update on public.questions
  for each row execute procedure public.log_audit_change('review_status,validation_status,is_active');

drop trigger if exists essays_audit on public.essays;
create trigger essays_audit
  after update on public.essays
  for each row execute procedure public.log_audit_change('status');
