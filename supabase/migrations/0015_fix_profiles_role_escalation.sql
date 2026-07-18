-- Dominio: Autenticación y usuarios
-- Corrige un hallazgo CRÍTICO de seguridad detectado en auditoría: la
-- política "profiles_update_own" (0001_profiles.sql) no tenía `with check`.
-- En Postgres, una política `for update` sin `with check` reutiliza la
-- expresión de `using` (solo `auth.uid() = id`) también para validar la fila
-- resultante, sin restringir qué columnas se pueden cambiar. Esto permitía
-- que cualquier estudiante autenticado ejecutara, directamente desde el
-- cliente Supabase en el navegador (sin pasar por ninguna Server Action de
-- la app, usando solo la anon key pública del bundle):
--
--   supabase.from('profiles').update({ role: 'administrador' }).eq('id', miPropioId)
--
-- y auto-promoverse a administrador, saltándose por completo el middleware
-- de la aplicación (que solo confía en profiles.role).
--
-- Arreglo: un trigger BEFORE UPDATE que impide cambiar `role` a menos que
-- quien ejecuta la actualización ya sea administrador (via `is_admin()`,
-- función security definer creada en 0003). Se usa un trigger en vez de
-- resolverlo solo con RLS porque `with check` en una política UPDATE no
-- puede comparar el valor anterior de una columna contra el nuevo de forma
-- confiable dentro de la misma expresión.
--
-- También se declara `with check` explícito en la política, como defensa
-- adicional (redundante con el trigger, pero buena práctica y sin costo).

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create or replace function public.prevent_role_self_escalation()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.role is distinct from old.role and not public.is_admin() then
    raise exception 'No tienes permiso para cambiar tu propio rol.';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_prevent_role_escalation on public.profiles;
create trigger profiles_prevent_role_escalation
  before update on public.profiles
  for each row execute procedure public.prevent_role_self_escalation();
