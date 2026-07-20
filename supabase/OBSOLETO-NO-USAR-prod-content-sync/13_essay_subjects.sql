-- ============================================================
-- Tabla: essay_subjects (1 filas)
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

insert into public.essay_subjects (id, essay_id, subject_id, question_count, question_percent)
values
  ('70f81ea2-6740-4aaf-a7a8-e9bc6d6f8b46', '5d582723-e425-4d6b-b2b5-14912598ef77', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', '5', NULL)
on conflict (id) do nothing;
