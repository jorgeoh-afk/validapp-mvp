-- ============================================================
-- Tabla: essay_strand_distribution (50 filas)
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

insert into public.essay_strand_distribution (id, essay_id, strand_id, question_count, question_percent, is_required)
values
  ('c4b1718a-69cf-45b7-825e-e1197790ec48', '0cba59c2-b46a-4e69-9c6c-3f7d6daf3676', 'c3674772-3838-4017-8f53-71f8df479790', '25', NULL, 'true'),
  ('156d3991-b8b2-4e78-9cca-1b1ca9dcabb0', '11a7d502-8d7c-43cf-ac0a-445026406aa3', 'e2915cf7-4f36-48ea-b35b-be98a8ba5df3', '15', NULL, 'true'),
  ('7115255e-cf2c-4e53-b3e6-5cb20efb7e80', '11a7d502-8d7c-43cf-ac0a-445026406aa3', '88237dce-744d-4b62-894b-1ede49357d30', '9', NULL, 'true'),
  ('bfc2cac5-5a52-45b8-b283-557101f91a3c', '267cfcb6-1033-49b6-8c3f-adbab57c2c97', 'c3674772-3838-4017-8f53-71f8df479790', '25', NULL, 'true'),
  ('d908d8ce-bced-4343-91a8-c846871577fb', '306043d5-263e-492c-bbdd-7a808dfd0fcd', '1990a42d-c2c6-4498-a75a-4b60fdc6ce5e', '25', NULL, 'true'),
  ('3d04028d-0737-4610-b099-6a98f1a75730', '56abc207-43e3-45b0-87ef-49c2e7bee29c', '8b76a0aa-32fa-47c8-ae9c-18830e894da7', '16', NULL, 'true'),
  ('7424bc0d-7256-408d-b2fd-5aca7e895e0c', '56abc207-43e3-45b0-87ef-49c2e7bee29c', 'b8c8cffb-c705-4330-bf57-125da9d73fa1', '4', NULL, 'true'),
  ('acc069fb-9f94-4ad7-9092-6ea858833534', '56abc207-43e3-45b0-87ef-49c2e7bee29c', 'd00b0fda-b590-45f2-a36b-45b7fa08d623', '5', NULL, 'true'),
  ('84062b3a-e1cb-47e3-87f4-6871a5b59722', '5d2fdc3e-4914-4f28-b44f-70a2357826dd', 'b763d2b9-96cc-45f3-ac2d-020d541f101a', '11', NULL, 'true'),
  ('9c0b068f-8e6a-475a-9396-bbb0bb2ac4b6', '5d2fdc3e-4914-4f28-b44f-70a2357826dd', 'cdb2bc78-ca28-4906-89b6-9d1280789a1f', '8', NULL, 'true'),
  ('a87b64b0-8fca-41fa-9e0d-c7d2dd92ccae', '5d2fdc3e-4914-4f28-b44f-70a2357826dd', '75087f8b-26d0-45d5-88bf-78c2b6b6024a', '5', NULL, 'true'),
  ('7a2bfbb6-5158-4efd-bab1-742e910988dd', '5e213117-dadc-4e3b-b4f6-ba6f98c07bb1', 'd00b0fda-b590-45f2-a36b-45b7fa08d623', '4', NULL, 'true'),
  ('ce48a09c-d2e0-4e18-a1cd-65e989ab5223', '5e213117-dadc-4e3b-b4f6-ba6f98c07bb1', '47a8b070-5796-4ea3-b7d3-b3579ddfb3f3', '7', NULL, 'true'),
  ('ea5addb7-67ad-45ce-92f5-936d59417629', '5e213117-dadc-4e3b-b4f6-ba6f98c07bb1', '3291dad2-cdea-46ad-9ee9-4a06c7d13153', '9', NULL, 'true'),
  ('f035753e-c87d-4e95-baa2-5ec7584a8bc9', '5e213117-dadc-4e3b-b4f6-ba6f98c07bb1', '78a31128-00da-4d87-89ba-4aa8fc8c65bb', '5', NULL, 'true'),
  ('03da2b2f-d815-43b7-be09-58ee4ed0bfc9', '649052ee-f3a4-43fc-937a-3c01c4d72925', 'e2915cf7-4f36-48ea-b35b-be98a8ba5df3', '15', NULL, 'true'),
  ('a879613e-6fe3-4116-8fc1-6255fc2e6d60', '649052ee-f3a4-43fc-937a-3c01c4d72925', '88237dce-744d-4b62-894b-1ede49357d30', '9', NULL, 'true'),
  ('43f444fa-c77c-4ed5-b5a5-e05b2b4d1108', '77dbeb2c-909c-4e84-a8b6-c12bcf301b55', '1990a42d-c2c6-4498-a75a-4b60fdc6ce5e', '25', NULL, 'true'),
  ('5ec16fe4-bec3-4db5-9aa1-64c6b9c0d674', '7bde4c8c-2f39-405b-8f9b-9d24a85387bd', '8b76a0aa-32fa-47c8-ae9c-18830e894da7', '16', NULL, 'true'),
  ('64edbb16-e87c-44b5-91db-f6241837aabb', '7bde4c8c-2f39-405b-8f9b-9d24a85387bd', 'b8c8cffb-c705-4330-bf57-125da9d73fa1', '4', NULL, 'true'),
  ('89babe2c-3ecc-4a5c-9847-74386e0f15e2', '7bde4c8c-2f39-405b-8f9b-9d24a85387bd', 'd00b0fda-b590-45f2-a36b-45b7fa08d623', '5', NULL, 'true'),
  ('505cbf08-2f9c-48dc-99fd-bced3dc544dd', '84a3b603-0d88-40c0-b5fd-0112460e1efe', '3291dad2-cdea-46ad-9ee9-4a06c7d13153', '9', NULL, 'true'),
  ('7c77b417-064b-4002-9461-c9dfa131b659', '84a3b603-0d88-40c0-b5fd-0112460e1efe', '78a31128-00da-4d87-89ba-4aa8fc8c65bb', '5', NULL, 'true'),
  ('944b4f49-9d17-4f01-ae48-98ee2431ba6f', '84a3b603-0d88-40c0-b5fd-0112460e1efe', '47a8b070-5796-4ea3-b7d3-b3579ddfb3f3', '7', NULL, 'true'),
  ('b253d2a3-9a89-49b2-836e-20c9174c5cd4', '84a3b603-0d88-40c0-b5fd-0112460e1efe', 'd00b0fda-b590-45f2-a36b-45b7fa08d623', '4', NULL, 'true'),
  ('d4ca7f2c-659f-4523-b23d-20a580c9afdf', '89fc70da-e921-4e9c-a615-dc278bc9f805', '1990a42d-c2c6-4498-a75a-4b60fdc6ce5e', '25', NULL, 'true'),
  ('0c58e67d-062e-4a14-813b-0ddc8cc09bec', '8deebe06-56f4-4da0-b45f-7261a3fdd693', '1990a42d-c2c6-4498-a75a-4b60fdc6ce5e', '25', NULL, 'true'),
  ('ef9006b8-4440-47dc-9acc-4904462a8d7d', 'ba8b68cc-7d41-4c12-a840-1ad16ce7fa5b', 'c3674772-3838-4017-8f53-71f8df479790', '25', NULL, 'true'),
  ('0fb6b448-80ef-4797-a55f-9750612a1580', 'c35c3284-4d50-4d4f-a480-29ea9a576d59', 'cdb2bc78-ca28-4906-89b6-9d1280789a1f', '6', NULL, 'true'),
  ('5cefd943-b6b9-4d62-8d6a-ccb57d352ca1', 'c35c3284-4d50-4d4f-a480-29ea9a576d59', 'b763d2b9-96cc-45f3-ac2d-020d541f101a', '7', NULL, 'true'),
  ('e5429a92-fa47-40ed-bb4a-c4d12785d52f', 'c35c3284-4d50-4d4f-a480-29ea9a576d59', '75087f8b-26d0-45d5-88bf-78c2b6b6024a', '11', NULL, 'true'),
  ('4f639810-c65c-4d4b-92ea-ace127a10230', 'c3d448b3-b3a4-464f-947a-7288556c1eab', 'eac22ada-4e8e-4b3f-a40c-52e6f997b330', '7', NULL, 'true'),
  ('9ca9ca49-abd0-489d-8488-7539b1ce2f01', 'c3d448b3-b3a4-464f-947a-7288556c1eab', 'e2915cf7-4f36-48ea-b35b-be98a8ba5df3', '18', NULL, 'true'),
  ('0d23912d-961b-4e12-b7bb-cf28e7d41be0', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '47a8b070-5796-4ea3-b7d3-b3579ddfb3f3', '7', NULL, 'true'),
  ('90ce6b04-f041-4e68-ae8f-d0a70d0e822f', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '78a31128-00da-4d87-89ba-4aa8fc8c65bb', '5', NULL, 'true'),
  ('cc175675-15d9-4534-81c6-39eb36070ae9', 'c9f3a852-0463-459f-b4cf-058e6403bd50', '3291dad2-cdea-46ad-9ee9-4a06c7d13153', '9', NULL, 'true'),
  ('cd6f8f64-e6b1-4d9d-9b20-07587aafa707', 'c9f3a852-0463-459f-b4cf-058e6403bd50', 'd00b0fda-b590-45f2-a36b-45b7fa08d623', '4', NULL, 'true'),
  ('39f03121-1e55-443a-9244-491a7d30218d', 'ca8597da-290a-4722-9cb0-67b450ed00be', '75087f8b-26d0-45d5-88bf-78c2b6b6024a', '11', NULL, 'true'),
  ('958f0ed7-f540-4a85-b19a-817a0cf637fb', 'ca8597da-290a-4722-9cb0-67b450ed00be', 'cdb2bc78-ca28-4906-89b6-9d1280789a1f', '6', NULL, 'true'),
  ('ad3bbe32-b5ee-4540-b0b5-c3aab0d14bbb', 'ca8597da-290a-4722-9cb0-67b450ed00be', 'b763d2b9-96cc-45f3-ac2d-020d541f101a', '7', NULL, 'true'),
  ('b9164b5b-441c-438d-846b-9fc7b3d49e15', 'e5dba765-84d8-473b-91a4-ca3969193400', 'c3674772-3838-4017-8f53-71f8df479790', '25', NULL, 'true'),
  ('a0406e81-30dc-45cb-aa8a-8b66e16c6012', 'ecbec12d-8888-4c0b-bacc-4ac4ac579c4b', '1990a42d-c2c6-4498-a75a-4b60fdc6ce5e', '25', NULL, 'true'),
  ('bd7dd329-062a-46ac-ab25-e99d174710ca', 'ee5005e9-198e-4ebe-9460-3bcac530f752', 'eac22ada-4e8e-4b3f-a40c-52e6f997b330', '7', NULL, 'true'),
  ('d3515522-2bc7-409d-8622-37d11e10b538', 'ee5005e9-198e-4ebe-9460-3bcac530f752', 'e2915cf7-4f36-48ea-b35b-be98a8ba5df3', '18', NULL, 'true'),
  ('331327bc-ccc4-4a52-be96-9d67025c65ed', 'f1cc405a-5256-4c77-98d2-f1209da98b65', 'b8c8cffb-c705-4330-bf57-125da9d73fa1', '4', NULL, 'true'),
  ('e834d8b8-f774-44c3-9e17-f6e92e988747', 'f1cc405a-5256-4c77-98d2-f1209da98b65', '8b76a0aa-32fa-47c8-ae9c-18830e894da7', '16', NULL, 'true'),
  ('f7332d4b-1fbc-429e-b187-f8b3b2cc55fc', 'f1cc405a-5256-4c77-98d2-f1209da98b65', 'd00b0fda-b590-45f2-a36b-45b7fa08d623', '5', NULL, 'true'),
  ('29a4585a-446f-457b-bef8-91a4adcb5d20', 'f50b9843-8841-434d-871a-b0d446f956d0', 'b763d2b9-96cc-45f3-ac2d-020d541f101a', '11', NULL, 'true'),
  ('ab67e487-84bc-453a-a84e-c00607776dee', 'f50b9843-8841-434d-871a-b0d446f956d0', '75087f8b-26d0-45d5-88bf-78c2b6b6024a', '5', NULL, 'true'),
  ('b2d2d600-2204-427f-816b-43065d604e96', 'f50b9843-8841-434d-871a-b0d446f956d0', 'cdb2bc78-ca28-4906-89b6-9d1280789a1f', '8', NULL, 'true')
on conflict (id) do nothing;
