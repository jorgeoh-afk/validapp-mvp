-- Dominio: Autenticación y usuarios
-- Tabla de perfiles, 1:1 con auth.users, con el rol de cada cuenta.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  role text not null default 'estudiante' check (role in ('estudiante', 'administrador')),
  target_level text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Un estudiante o administrador puede leer y actualizar su propio perfil.
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);

-- Los administradores pueden leer todos los perfiles (necesario para el panel admin).
create policy "profiles_select_admin"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'administrador'
    )
  );

-- Crea automáticamente el perfil (rol estudiante por defecto) al registrarse en auth.users.
-- El nombre viaja en raw_user_meta_data desde el formulario de registro.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
