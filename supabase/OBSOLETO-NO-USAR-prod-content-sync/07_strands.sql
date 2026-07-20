-- ============================================================
-- Tabla: strands (14 filas)
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

insert into public.strands (id, subject_id, name, description, order_index, active, created_at, framework_id, source_id, official_text)
values
  ('3291dad2-cdea-46ad-9ee9-4a06c7d13153', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Números', 'Números enteros, racionales, irracionales y potencias.', '0', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('47a8b070-5796-4ea3-b7d3-b3579ddfb3f3', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Álgebra y Funciones', 'Lenguaje algebraico, expresiones algebraicas, funciones y ecuaciones.', '1', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('78a31128-00da-4d87-89ba-4aa8fc8c65bb', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Geometría', 'Ángulos, polígonos, semejanza, transformaciones isométricas, perímetro/área/volumen.', '2', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('d00b0fda-b590-45f2-a36b-45b7fa08d623', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Probabilidad y Estadística', 'Medidas de tendencia central, probabilidad y tablas de frecuencia.', '3', 'true', '2026-07-19 03:03:05.926181+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('1990a42d-c2c6-4498-a75a-4b60fdc6ce5e', '4c8eb815-32e1-4201-b31d-85e21467627b', 'Comprensión Lectora en Inglés', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('75087f8b-26d0-45d5-88bf-78c2b6b6024a', '9e370682-12df-4ea6-89e6-9aa124f540a3', 'Ciencias Químicas', '', '2', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('88237dce-744d-4b62-894b-1ede49357d30', '6ffd5df7-d59d-4ed8-b83a-8fb57ca3bdbb', 'Dimensión Geográfica y Económica', '', '1', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', '61662a55-c547-4f03-b4fb-43cc0459640b', NULL),
  ('8b76a0aa-32fa-47c8-ae9c-18830e894da7', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Funciones y Ecuaciones', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', '61662a55-c547-4f03-b4fb-43cc0459640b', NULL),
  ('b763d2b9-96cc-45f3-ac2d-020d541f101a', '9e370682-12df-4ea6-89e6-9aa124f540a3', 'Ciencias Biológicas', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('b8c8cffb-c705-4330-bf57-125da9d73fa1', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Geometría y Trigonometría', '', '1', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', '61662a55-c547-4f03-b4fb-43cc0459640b', NULL),
  ('c3674772-3838-4017-8f53-71f8df479790', '84d729e1-faeb-43b9-802c-cc6cc5b6b251', 'Comprensión Lectora', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('cdb2bc78-ca28-4906-89b6-9d1280789a1f', '9e370682-12df-4ea6-89e6-9aa124f540a3', 'Ciencias Físicas', '', '1', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('e2915cf7-4f36-48ea-b35b-be98a8ba5df3', '6ffd5df7-d59d-4ed8-b83a-8fb57ca3bdbb', 'Dimensión Histórica', '', '0', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL),
  ('eac22ada-4e8e-4b3f-a40c-52e6f997b330', '6ffd5df7-d59d-4ed8-b83a-8fb57ca3bdbb', 'Dimensión Formación Ciudadana', '', '1', 'true', '2026-07-19 03:03:06.383185+00', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'f1fc0e12-2183-4674-8aa0-3c5f294a5ddf', NULL)
on conflict (id) do nothing;
