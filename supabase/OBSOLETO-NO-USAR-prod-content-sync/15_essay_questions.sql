-- ============================================================
-- Tabla: essay_questions (25 filas)
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

insert into public.essay_questions (id, essay_id, question_id, position, created_at)
values
  ('3a8eea5c-3e83-447d-8b09-27ab0598f30b', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'db044af0-a52e-418c-92ae-8d1ebc338e4a', '0', '2026-07-19 04:23:24.088808+00'),
  ('4df828ed-0f79-4881-9bff-27f7e23dd809', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '014a5765-c4cd-472c-9c24-a7350b7526dd', '1', '2026-07-19 04:23:24.088808+00'),
  ('5fbfc0a7-4739-4e38-be08-a3d02df5443d', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '13281ab8-3afe-47b7-86b1-4c3d46f767b0', '2', '2026-07-19 04:23:24.088808+00'),
  ('fec08db8-cc50-436c-a937-218ec3883f86', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'bca33e1f-7267-48ad-998e-4de166f39555', '3', '2026-07-19 04:23:24.088808+00'),
  ('7125b0f1-18f9-4dbb-800a-80e4e2375126', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'd110bf03-bfa2-4757-b9d9-8e9c4d49897a', '4', '2026-07-19 04:23:24.088808+00'),
  ('3d1c1ab6-9164-47c1-abbe-3c1b66eecbaa', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'a157ec0d-81e2-4b83-b096-150414cef0f4', '5', '2026-07-19 04:23:24.088808+00'),
  ('2219c90e-3a92-4a3c-8d23-2bfbf117d73f', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '17eed64f-6132-41d2-aaae-04e2c2d861e1', '6', '2026-07-19 04:23:24.088808+00'),
  ('7e27fc9e-c4d5-42aa-9a08-678badc2bf1a', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'd8206090-f4b1-4535-9fa2-dee28da692e8', '7', '2026-07-19 04:23:24.088808+00'),
  ('e1b235b2-4ebc-43c8-b3b6-f930c499bdc5', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '7f1a971d-9f65-42d0-a5c3-966e9ea446c3', '8', '2026-07-19 04:23:24.088808+00'),
  ('c95ed1f2-a129-482d-bb36-a2c28aef4239', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'e4130fe4-f95a-4711-9275-6c67361d25c3', '9', '2026-07-19 04:23:24.088808+00'),
  ('b677e756-3ae5-4575-a547-135aa0146d35', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '36880187-a787-409f-a868-cb76d1b4ea82', '10', '2026-07-19 04:23:24.088808+00'),
  ('ba3cd9cb-c3e0-4624-8e56-634c16bd1c25', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '2a0394f2-ce04-4dcf-8486-b65954a09893', '11', '2026-07-19 04:23:24.088808+00'),
  ('50f8c278-3309-4f56-84f2-4df5fc3937a5', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'ff3ba672-4e22-45c0-8076-28691b5d0ec3', '12', '2026-07-19 04:23:24.088808+00'),
  ('f94a003b-83c0-4106-9877-c2853639e878', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '3cfee7b9-d8e4-4cce-99e3-ed6eefd64b6e', '13', '2026-07-19 04:23:24.088808+00'),
  ('208a13fe-30c0-487a-92b9-d28b4d92e5f6', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'e8b27a64-160b-4039-9b54-4b29b23a92a5', '14', '2026-07-19 04:23:24.088808+00'),
  ('def3b33a-f0e1-4067-b463-df3abe51a418', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '21f1c082-3270-4ae4-ba83-5d6497f7b24a', '15', '2026-07-19 04:23:24.088808+00'),
  ('fd46aa38-5afc-480b-a5ee-0a30d7de4022', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'de482281-cadd-45b4-b017-897ecf480a66', '16', '2026-07-19 04:23:24.088808+00'),
  ('6b4e70c8-3ea1-4ee4-8afc-827eddb81331', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '50b660b2-401a-427a-884b-6606425249e8', '17', '2026-07-19 04:23:24.088808+00'),
  ('2e659f83-37c9-4f98-9657-bffb058fae09', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '06545895-395e-44ea-b0e0-ed71c8188e29', '18', '2026-07-19 04:23:24.088808+00'),
  ('ef3123b9-0a9d-448f-b601-7c9f53cc1ba0', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'e33c7a7a-922c-4769-b069-3c4c253bcbad', '19', '2026-07-19 04:23:24.088808+00'),
  ('4a38fc64-8ace-409d-a217-2290a6919e91', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '662b6bf4-9a95-42e1-a57b-7736bf4677fa', '20', '2026-07-19 04:23:24.088808+00'),
  ('4d17805b-306f-45c7-86d2-d9a95dd4d4a3', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '1be46c2e-6fd1-4a02-9eea-3aee3fdf9eb8', '21', '2026-07-19 04:23:24.088808+00'),
  ('addcf66d-53c6-4ef2-b2e1-0d4bf04b647c', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '8d47d4ca-2af7-4394-866b-f9c9b8450cf6', '22', '2026-07-19 04:23:24.088808+00'),
  ('50ddac2a-db66-417f-9629-c373de1b5e93', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '673b5082-77af-465b-a846-8757a750062d', '23', '2026-07-19 04:23:24.088808+00'),
  ('08e2e625-6df4-4783-bd65-1e11faf54a92', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '66efdec0-5f11-4b50-b384-13ce5501b709', '24', '2026-07-19 04:23:24.088808+00')
on conflict (id) do nothing;
