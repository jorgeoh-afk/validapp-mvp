-- ============================================================
-- Tabla: framework_subjects (10 filas)
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

insert into public.framework_subjects (id, framework_id, level_id, subject_id, official_name, official_code, is_examined, sort_order, created_at)
values
  ('fe9adaf9-17c8-431b-b6d8-59982a1a06a7', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'cb7467bf-5407-40f6-953e-28ad17aae434', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Educación Matemática', NULL, 'true', '0', '2026-07-19 03:03:05.926181+00'),
  ('239345cc-4843-4941-9c9a-63bca2971d05', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'a62eb30a-79bc-4087-9b45-cb49482ce66e', '84d729e1-faeb-43b9-802c-cc6cc5b6b251', 'Lengua Castellana y Comunicación', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('2665c94b-8435-4e95-9b83-e13f87756e20', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'cb7467bf-5407-40f6-953e-28ad17aae434', '4c8eb815-32e1-4201-b31d-85e21467627b', 'Idioma Extranjero: Inglés', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('280d2198-1d57-45f5-94df-f30be5bce94c', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'a62eb30a-79bc-4087-9b45-cb49482ce66e', '30043bb0-fb2e-4bdd-96a0-1cee37a3c322', 'Educación Matemática', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('3b219241-1100-4126-8463-137ee7027612', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'a62eb30a-79bc-4087-9b45-cb49482ce66e', '9e370682-12df-4ea6-89e6-9aa124f540a3', 'Ciencias Naturales', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('54c301fd-442d-4165-b5dc-812ef4d0a90e', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'a62eb30a-79bc-4087-9b45-cb49482ce66e', '4c8eb815-32e1-4201-b31d-85e21467627b', 'Idioma Extranjero: Inglés', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('80815b54-8985-43ac-a855-cffc3865f59d', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'a62eb30a-79bc-4087-9b45-cb49482ce66e', '6ffd5df7-d59d-4ed8-b83a-8fb57ca3bdbb', 'Estudios Sociales', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('92397f15-04eb-440e-adf3-b031d6243a60', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'cb7467bf-5407-40f6-953e-28ad17aae434', '9e370682-12df-4ea6-89e6-9aa124f540a3', 'Ciencias Naturales', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('d29047b0-1c91-4766-bb54-e26a79212dde', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'cb7467bf-5407-40f6-953e-28ad17aae434', '6ffd5df7-d59d-4ed8-b83a-8fb57ca3bdbb', 'Estudios Sociales', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00'),
  ('f967789d-5ca8-455f-b64d-083559085971', 'b83f2d84-f278-4f26-af9d-317667f5d300', 'cb7467bf-5407-40f6-953e-28ad17aae434', '84d729e1-faeb-43b9-802c-cc6cc5b6b251', 'Lengua Castellana y Comunicación', NULL, 'true', '0', '2026-07-19 03:03:06.383185+00')
on conflict (id) do nothing;
