-- Corrige recursión infinita en las políticas RLS que verifican el rol
-- administrador: al consultar public.profiles dentro de su propia política,
-- Postgres vuelve a evaluar esa misma política indefinidamente.
--
-- Solución estándar: una función security definer, cuyo dueño (el rol que
-- posee la tabla) no queda sujeto a RLS al ejecutar la consulta interna.

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'administrador'
  );
$$;

drop policy if exists "profiles_select_admin" on public.profiles;
create policy "profiles_select_admin"
  on public.profiles for select
  using (public.is_admin());

drop policy if exists "subjects_write_admin" on public.subjects;
create policy "subjects_write_admin" on public.subjects for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "levels_write_admin" on public.levels;
create policy "levels_write_admin" on public.levels for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "lessons_write_admin" on public.lessons;
create policy "lessons_write_admin" on public.lessons for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "questions_write_admin" on public.questions;
create policy "questions_write_admin" on public.questions for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
