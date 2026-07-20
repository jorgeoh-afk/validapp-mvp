-- ============================================================
-- Tabla: levels (2 filas)
-- Generado automáticamente en modo SOLO LECTURA desde el proyecto Supabase
-- de DESARROLLO (ref ljzdpkyxvehrjqtixbya) hacia el proyecto de PRODUCCIÓN
-- (ref plvxlfdcaycnsslbfqov, validapp-mvp).
--
-- ESTE ARCHIVO NO SE HA EJECUTADO CONTRA PRODUCCIÓN. Es una PROPUESTA para
-- revisión conjunta. Pégalo en el SQL Editor del dashboard de Supabase de
-- PRODUCCIÓN solo después de autorizarlo explícitamente.
--
-- Idempotencia: cada INSERT usa `on conflict (id) do nothing`, por lo que
-- es seguro volver a pegar y ejecutar este mismo archivo más de una vez sin
-- duplicar filas (por ejemplo si algo falla a mitad de camino).
-- ============================================================

insert into public.levels (id, name, order_index, created_at, program_id, education_level_id, equivalence, track)
values
  ('cb7467bf-5407-40f6-953e-28ad17aae434', 'Primer Nivel Medio', '10', '2026-07-19 03:03:05.926181+00', '6f48b690-7e91-4852-9625-d500ba3b5db9', 'a3effdaf-e03b-42d2-8c13-9f765687593f', '1° y 2° Medio', 'humanistico_cientifico'),
  ('a62eb30a-79bc-4087-9b45-cb49482ce66e', 'Segundo Nivel Medio', '20', '2026-07-19 03:03:06.383185+00', '6f48b690-7e91-4852-9625-d500ba3b5db9', 'a3effdaf-e03b-42d2-8c13-9f765687593f', '3° y 4° Medio', 'humanistico_cientifico')
on conflict (id) do nothing;
