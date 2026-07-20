-- ============================================================
-- Tabla: curriculum_frameworks (2 filas)
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
-- Columna curriculum_frameworks.verified_by SIEMPRE se inserta como NULL (columna de otro entorno / no migrada), sin importar el valor real en desarrollo.
-- ============================================================

insert into public.curriculum_frameworks (id, modality, certification_process, audience, purpose, name, decree_number, decree_year, exam_year, exam_period, valid_from, valid_until, status, source_name, source_url, source_domain, source_document_type, source_checksum, retrieved_at, verified_at, verified_by, created_at, updated_at)
values
  ('a24f304e-b37e-4c25-870a-befd98543938', 'EPJA', 'examen_libre', 'mayores_18', 'continuidad_estudios', 'Enseñanza Media EPJA — D.S. N.° 10 de 2022 (segundo período 2026, SIN temario de Media publicado)', '10', '2022', '2026', 'segundo_periodo', NULL, NULL, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-19 03:03:05.926181+00', '2026-07-19 03:03:05.926181+00'),
  ('b83f2d84-f278-4f26-af9d-317667f5d300', 'EPJA', 'examen_libre', 'mayores_18', 'continuidad_estudios', 'Enseñanza Media EPJA — D.S. N.° 257 de 2009 (primer período 2026)', '257', '2009', '2026', 'primer_periodo', NULL, NULL, 'verified', 'Temario Primer Nivel de Educación Media (Validación de Estudios Adultos, DS 257)', 'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM1_2025.pdf', 'epja.mineduc.cl', 'temario_oficial_pdf', '23f9ab4c1ef00563c381d7f16e81fbf0f8dbb94bf8d4c6275486905347e78f08', '2026-07-19 03:03:05.926181+00', '2026-07-19 03:03:05.926181+00', NULL, '2026-07-19 03:03:05.926181+00', '2026-07-19 03:03:05.926181+00')
on conflict (id) do nothing;
