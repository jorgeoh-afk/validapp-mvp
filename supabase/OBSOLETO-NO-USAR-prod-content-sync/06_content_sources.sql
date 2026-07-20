-- ============================================================
-- Tabla: content_sources (2 filas)
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
--
-- Columna content_sources.verified_by SIEMPRE se inserta como NULL (columna de otro entorno / no migrada), sin importar el valor real en desarrollo.
-- ============================================================

insert into public.content_sources (id, source_name, source_url, source_domain, source_document_type, source_year, source_decree, source_page, source_section, source_checksum, retrieved_at, verified_at, verified_by, created_at)
values
  ('f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', 'Temario Primer Nivel de Educación Media (Validación de Estudios Adultos, DS 257)', 'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM1_2025.pdf', 'epja.mineduc.cl', 'temario_oficial_pdf', '2025', 'DS 257/2009', NULL, NULL, '23f9ab4c1ef00563c381d7f16e81fbf0f8dbb94bf8d4c6275486905347e78f08', '2026-07-19 03:03:05.926181+00', NULL, NULL, '2026-07-19 03:03:05.926181+00'),
  ('61662a55-c547-4f03-b4fb-43cc0459640b', 'Temario Segundo Nivel de Educación Media (Validación de Estudios Adultos, DS 257)', 'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM2_2025.pdf', 'epja.mineduc.cl', 'temario_oficial_pdf', '2025', 'DS 257/2009', NULL, NULL, 'b4a5a4aef18070e239573f53094de21c04548814c475c42c543410703b528252', '2026-07-19 03:03:06.383185+00', NULL, NULL, '2026-07-19 03:03:06.383185+00')
on conflict (id) do nothing;
