-- ============================================================
-- Tabla: programs (1 filas)
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

insert into public.programs (id, name, description, order_index, active, created_at)
values
  ('6f48b690-7e91-4852-9625-d500ba3b5db9', 'EPJA - Modalidad Regular', 'Educación de Personas Jóvenes y Adultas, modalidad regular.', '0', 'true', '2026-07-19 03:03:05.926181+00')
on conflict (id) do nothing;
