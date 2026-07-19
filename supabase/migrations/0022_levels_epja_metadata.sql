-- Dominio: Contenido y preguntas
-- Fase EPJA 6: metadatos de equivalencia y rama formativa para `levels`.
--
-- La spec EPJA pide que "Primer Nivel Medio"/"Segundo Nivel Medio" (los
-- bloques EPJA ya modelados en `levels` desde la decisión de 0014) guarden
-- su equivalencia con la educación regular ("1° y 2° Medio") como METADATO
-- informativo, no como el nombre principal — y que la rama formativa
-- (Humanístico-Científica para el MVP; Técnico-Profesional queda fuera de
-- alcance) quede registrada sin mezclarla con el nombre del curso.
--
-- Aditivo y reversible: columnas nullable en `levels`. Migración solo
-- local: no se ejecutó `supabase db push`.

alter table public.levels
  add column if not exists equivalence text,
  add column if not exists track text;

comment on column public.levels.equivalence is
  'Metadato informativo de equivalencia con la educación regular (p. ej. "1° y 2° Medio" para el bloque EPJA "Primer Nivel Medio"). No reemplaza levels.name.';
comment on column public.levels.track is
  'Rama formativa (p. ej. "humanistico_cientifico", "tecnico_profesional"). Nullable: no aplica a Educación Básica.';
