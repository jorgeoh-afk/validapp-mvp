-- Dominio: Leads e interesados (captación pública, previa a la cuenta de estudiante)
-- Formulario de interés de la landing page. Se completa sin sesión iniciada.

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  age int not null,
  email text not null,
  phone text not null,
  region text not null,
  level text not null,
  consent_data boolean not null default false,
  consent_guardian boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.leads enable row level security;

-- Cualquier visitante (con o sin sesión) puede registrar su interés,
-- siempre que haya aceptado ambos consentimientos.
create policy "leads_insert_public" on public.leads for insert
  to anon, authenticated
  with check (consent_data = true and consent_guardian = true);

-- Solo el administrador puede revisar los interesados.
create policy "leads_select_admin" on public.leads for select
  using (public.is_admin());
