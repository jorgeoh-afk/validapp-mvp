-- ============================================================
-- Tabla: units (14 filas)
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

insert into public.units (id, strand_id, name, description, order_index, active, created_at, framework_id, source_id, official_text)
values
  ('0bda60e3-124e-4fd1-9613-dbd01db4b146', 'd00b0fda-b590-45f2-a36b-45b7fa08d623', 'Objetivos evaluados — Probabilidad y Estadística', '', '0', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('51e4c32b-e156-4879-b04d-add4f1bc9fb2', '47a8b070-5796-4ea3-b7d3-b3579ddfb3f3', 'Objetivos evaluados — Álgebra y Funciones', '', '0', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('d78d8f62-7392-49d7-91f9-06d941722157', '3291dad2-cdea-46ad-9ee9-4a06c7d13153', 'Objetivos evaluados — Números', '', '0', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('db5f296f-d182-4a47-8d01-f50e725318d6', '78a31128-00da-4d87-89ba-4aa8fc8c65bb', 'Objetivos evaluados — Geometría', '', '0', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('02087091-8700-4792-9821-4d2ea2919f97', '1990a42d-c2c6-4498-a75a-4b60fdc6ce5e', 'Objetivos evaluados — Comprensión Lectora en Inglés', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('3f58a461-e14c-460b-8e87-93c9d5dc6572', '75087f8b-26d0-45d5-88bf-78c2b6b6024a', 'Objetivos evaluados — Ciencias Químicas', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('533aa35f-77e6-4bfd-a2be-e677b69fb788', 'cdb2bc78-ca28-4906-89b6-9d1280789a1f', 'Objetivos evaluados — Ciencias Físicas', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('54a707fd-667c-4dce-876a-e50109a9f241', '88237dce-744d-4b62-894b-1ede49357d30', 'Objetivos evaluados — Dimensión Geográfica y Económica', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', '61662a55-c547-4f03-b4fb-43cc0459640b', NULL),
  ('7a5bc2d9-3abf-49db-ab9c-f2b059e95ca2', '8b76a0aa-32fa-47c8-ae9c-18830e894da7', 'Objetivos evaluados — Funciones y Ecuaciones', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', '61662a55-c547-4f03-b4fb-43cc0459640b', NULL),
  ('7ad3054a-e366-4603-89c2-faea55a1257b', 'c3674772-3838-4017-8f53-71f8df479790', 'Objetivos evaluados — Comprensión Lectora', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('8d1fff41-84b9-47cd-8e40-fda1b7d693e9', 'b763d2b9-96cc-45f3-ac2d-020d541f101a', 'Objetivos evaluados — Ciencias Biológicas', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('93c52b43-4a84-4e0e-b901-897b222ae248', 'b8c8cffb-c705-4330-bf57-125da9d73fa1', 'Objetivos evaluados — Geometría y Trigonometría', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', '61662a55-c547-4f03-b4fb-43cc0459640b', NULL),
  ('b1a867d4-0697-4a95-a299-83921036276d', 'e2915cf7-4f36-48ea-b35b-be98a8ba5df3', 'Objetivos evaluados — Dimensión Histórica', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('f07c8259-7170-48c9-a649-b899d19a16cd', 'eac22ada-4e8e-4b3f-a40c-52e6f997b330', 'Objetivos evaluados — Dimensión Formación Ciudadana', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL)
on conflict (id) do nothing;
