-- ============================================================
-- Tabla: subjects (5 filas)
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

insert into public.subjects (id, name, created_at, canonical_code)
values
  ('30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Matemática', '2026-07-19 03:03:05.926181+00', 'mathematics'),
  ('4c8eb815-32e1-4201-b31d-85e21467627b', 'Idioma Extranjero: Inglés', '2026-07-19 03:03:06.383185+00', 'english'),
  ('6ffd5df7-d59d-4ed8-b83a-8fb57ca3bdbb', 'Estudios Sociales', '2026-07-19 03:03:06.383185+00', 'social_sciences'),
  ('84d729e1-faeb-43b9-802c-cc6cc5b6b251', 'Lengua Castellana y Comunicación', '2026-07-19 03:03:06.383185+00', 'language'),
  ('9e370682-12df-4ea6-89e6-9aa124f540a3', 'Ciencias Naturales', '2026-07-19 03:03:06.383185+00', 'natural_sciences')
on conflict (id) do nothing;
