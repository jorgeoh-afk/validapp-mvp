-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Lenguaje y Comunicación, 1° a 6° Básico.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA (léase antes de aprobar cualquier fila)
-- ============================================================================
-- Fuente citada: Bases Curriculares de Educación Básica, MINEDUC, aprobadas
-- por el Decreto Supremo N.° 439 de 2012 (1° a 6° Básico, asignatura de
-- lenguaje). Vigencia progresiva desde 2013. Mismo decreto único
-- multi-asignatura que ya rige Matemática en esta banda (ver
-- supabase/seed/0011_curriculum_matematica_regular_basica_1_6.sql) —
-- verificado por el coordinador de esta sesión vía búsqueda web, no por este
-- agente (sin acceso a navegación web en este entorno).
--
-- Confianza en los 3 ejes temáticos (Lectura; Escritura; Comunicación Oral) y
-- en la progresión general de contenidos (conciencia fonológica y principio
-- alfabético en 1°, comprensión literal/inferencial creciente, producción de
-- textos de complejidad creciente, exposición oral cada vez más formal):
-- MEDIA-ALTA. Es la organización por ejes ampliamente documentada del
-- currículo chileno de Lenguaje en Básica, no una propuesta de ValidApp.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL de cada Objetivo de
-- Aprendizaje (código "OA n" tal como aparece en el PDF de Bases
-- Curriculares): BAJA, mismo motivo que 0011/0012/0013 (sin acceso a
-- navegación web ni al PDF oficial en este entorno). Por eso:
--   - `official_text` se deja NULL en todas las filas.
--   - `code` (código OA oficial) se deja NULL en todas las filas.
--   - TODAS las filas quedan en `status = 'borrador'`.
--   - `pedagogical_notes` repite esta advertencia en cada objetivo.
--
-- ============================================================================
-- DECISIÓN SOBRE EL NOMBRE DE LA ASIGNATURA (subjects.name) — LÉASE
-- ============================================================================
-- Problema: la denominación OFICIAL de esta asignatura varía por decreto:
--   - 1°-6° Básico (D.S. 439/2012): "Lenguaje y Comunicación" (confianza
--     MEDIA -- no verificado por búsqueda web esta sesión, es conocimiento
--     general de este agente sobre la reforma de 2012).
--   - 7° Básico-2° Medio (D.S. 614/2013): probablemente "Lengua y
--     Literatura" (confianza MEDIA, ver supabase/seed/0015).
--   - 3°-4° Medio (D.S. 193/2019): "Lengua y Literatura" (confianza ALTA,
--     verificado por el coordinador vía búsqueda web, ver
--     supabase/seed/0016).
--   - EPJA (D.S. 257/2009, temario examen libre adultos): "Lengua Castellana
--     y Comunicación" -- ya cargado en supabase/seed/0002_epja_remaining_subjects.sql
--     y supabase/seed/0006_epja_lengua_essays.sql, con
--     `subjects.canonical_code = 'language'`.
-- Es decir, NINGUNA de las 3 denominaciones del Currículum Regular coincide
-- literalmente con el nombre EPJA ya cargado en `subjects`.
--
-- Decisión: SE REUTILIZA la única fila existente de `subjects`
-- ("Lengua Castellana y Comunicación", canonical_code = 'language') para los
-- 12 cursos del Currículum Regular, EN VEZ de crear una fila nueva. Razones:
--   1. `subjects.name` es UNIQUE y `subjects.canonical_code` tiene un índice
--      único parcial (`subjects_canonical_code_key`, ver migración 0016)
--      -- no es posible crear una segunda fila con `canonical_code =
--      'language'` sin violar esa restricción. La alternativa de dejar
--      `canonical_code` null en una fila nueva fragmentaría el reporting de
--      "Lenguaje" como asignatura única a lo largo de toda la escolaridad
--      (12 cursos regulares + 5 niveles EPJA quedarían separados en el panel
--      admin), exactamente el riesgo que se buscaba evitar.
--   2. Renombrar la fila existente (p. ej. a "Lenguaje y Comunicación") NO
--      resuelve el problema de fondo -- seguiría sin coincidir con la
--      denominación oficial de 7°Básico-2°Medio ni de 3°-4°Medio, que usan
--      "Lengua y Literatura" -- y de paso modificaría en silencio la etiqueta
--      visible de contenido EPJA ya cargado (664 preguntas EPJA reales según
--      0028), sin necesidad real: ningún código en `lib/` busca `subjects`
--      por ese nombre literal (verificado con grep antes de escribir este
--      archivo), así que el riesgo es bajo pero innecesario de asumir.
--   3. Mismo patrón que 0011/0012/0013 con "Matemática": se reutiliza la fila
--      de asignatura ya creada por EPJA sin modificarla.
-- Consecuencia práctica: `subjects.name` en el esquema NO es la denominación
-- oficial exacta de esta asignatura para ninguna banda del Currículum
-- Regular. La denominación oficial de CADA banda (documentada arriba) se dice
-- explícitamente, banda por banda, en `curricular_source` y
-- `pedagogical_notes` de cada objetivo de este archivo y de 0015/0016 --
-- nunca se fabrica ni se pisa en `subjects.name`.
-- Pendiente abierto (no de este agente): si el panel admin necesita mostrar
-- la denominación oficial exacta por banda/curso en vez de un nombre
-- canónico único, el mecanismo natural sería extender el patrón de
-- `framework_subjects.official_name` (0016_curriculum_frameworks.sql) a
-- currículos que no usan `curriculum_frameworks` -- eso es una decisión de
-- esquema, se recomienda evaluarla con /validapp-db, no se implementa aquí.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 3 ejes oficiales x 6 cursos (1° a 6° Básico) = 18 combinaciones
-- eje-curso, cada una con 1 unidad. Lectura lleva 5 objetivos por curso
-- (mayor peso relativo, mismo criterio que 0011 aplicó a "Números" en
-- Matemática); Escritura y Comunicación Oral llevan 4 cada uno.
-- Representativos, NO exhaustivos -- el PDF oficial puede declarar un número
-- distinto de OA por eje y curso.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades (fuera de
-- alcance de esta tarea -- ver /validapp-assessments para preguntas/ensayos).
-- Tampoco cubre "Grandes ideas" ni "Conocimientos esenciales" (0014
-- migración, no confundir con este seed 0014).
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects (0016 migración)
-- ============================================================================
-- Mismo motivo documentado en 0011/0012/0013: esas tablas exigen
-- `exam_period` NOT NULL (concepto de período de examinación EPJA), que no
-- aplica al Currículum Regular. Se usa la trazabilidad simple ya disponible
-- en `learning_objectives`: `curricular_source` + `reference_year` +
-- `pedagogical_notes`.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011/0012/0013: `on conflict do nothing` para
-- subjects/strands/units (catálogo compartido, no se pisa contenido ya
-- editado por un administrador) o `on conflict do update` solo sobre las
-- columnas propias de este archivo para `learning_objectives`
-- (description/curricular_source/reference_year/pedagogical_notes).
-- `level_id` se resuelve siempre por `levels.code`, `subject_id` por
-- `subjects.name`.
--
-- Seed SOLO local: NO se ha ejecutado contra ningún proyecto Supabase (ni
-- dev ni producción). No modifica Supabase por sí solo.

-- ============================================================================
-- 1) Asignatura: reutiliza "Lengua Castellana y Comunicación" (EPJA la creó
--    primero, ver 0002). Ver decisión completa arriba.
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Lengua Castellana y Comunicación', 'language')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- "Comprensión Lectora" ya existe (creado por 0002 para el temario EPJA) --
-- no se modifica. Se crean 3 ejes nuevos, propios de esta banda del
-- Currículum Regular: "Lectura", "Escritura" y "Comunicación Oral".
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Lengua Castellana y Comunicación'),
   'Lectura', 'Comprensión de textos literarios y no literarios, estrategias de comprensión lectora y vocabulario.', 1)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Lengua Castellana y Comunicación'),
   'Escritura', 'Planificación, producción, revisión y edición de textos de distinto propósito.', 2)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Lengua Castellana y Comunicación'),
   'Comunicación Oral', 'Comprensión y producción de textos orales, exposición y participación en conversaciones y debates.', 3)
on conflict (subject_id, name) do nothing;

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================
-- Constantes repetidas por fila (ver encabezado): `status = 'borrador'`,
-- `curricular_source` cita el decreto y advierte sobre la denominación
-- oficial de la asignatura en esta banda, `reference_year = 2012`,
-- `pedagogical_notes` advierte que el texto es paráfrasis ValidApp.

-- ---------------------------------------------------------------------
-- 1° BÁSICO (order_index de nivel = 101)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 1° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Lectura, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo; distinta del nombre "Lengua Castellana y Comunicación" bajo el que está catalogada esta asignatura en subjects.name), eje Lectura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Conciencia fonológica', 'Reconocer sonidos, sílabas y fonemas iniciales y finales de palabras conocidas.', 0),
  ('Principio alfabético', 'Establecer la relación entre sonido y grafema para decodificar palabras simples.', 1),
  ('Lectura de palabras y oraciones simples', 'Leer palabras y oraciones simples en voz alta con precisión y fluidez crecientes.', 2),
  ('Comprensión de textos escuchados y leídos', 'Comprender textos escuchados y leídos, extrayendo información explícita y realizando predicciones simples.', 3),
  ('Estrategias de comprensión con apoyo', 'Aplicar, con apoyo del docente, estrategias de comprensión antes, durante y después de la lectura (predecir, verificar, recapitular).', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 1° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Escritura, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Escritura de letras, sílabas y palabras', 'Escribir letras, sílabas y palabras a mano con trazo legible.', 0),
  ('Oraciones simples con convenciones básicas', 'Escribir oraciones simples respetando el uso de mayúscula inicial y punto final.', 1),
  ('Producción de textos breves guiados', 'Producir textos breves guiados (tarjetas, mensajes) expresando ideas propias.', 2),
  ('Revisión de textos propios con ayuda', 'Revisar y mejorar un texto propio con ayuda del docente, releyendo y corrigiendo errores evidentes.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 1° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Comunicación Oral, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de instrucciones y textos orales sencillos', 'Comprender instrucciones y textos orales sencillos escuchados en clase.', 0),
  ('Participación respetando turnos de habla', 'Participar en conversaciones grupales respetando los turnos de habla.', 1),
  ('Expresión de ideas y experiencias personales', 'Expresar ideas y experiencias personales de manera clara ante el curso.', 2),
  ('Recitación de poemas y canciones breves', 'Recitar o cantar poemas, rimas y canciones breves memorizadas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° BÁSICO (order_index de nivel = 102)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 2° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Lectura, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Lectura fluida de textos breves', 'Leer en voz alta textos breves con precisión y velocidad adecuadas al curso.', 0),
  ('Comprensión de textos literarios y no literarios', 'Extraer información explícita e implícita de textos literarios y no literarios.', 1),
  ('Elementos del texto narrativo', 'Identificar personajes, ambiente y acciones principales de un texto narrativo.', 2),
  ('Incorporación de vocabulario nuevo', 'Incorporar palabras nuevas al vocabulario propio a partir de la lectura.', 3),
  ('Distinción de textos según su propósito', 'Distinguir entre textos literarios y no literarios según su propósito comunicativo.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 2° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Escritura, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Textos breves con secuencia lógica', 'Escribir textos breves (narraciones, descripciones) con una secuencia lógica de ideas.', 0),
  ('Reglas ortográficas básicas', 'Aplicar reglas ortográficas básicas: uso de mayúsculas, punto seguido y punto final.', 1),
  ('Planificación previa a la escritura', 'Planificar un texto antes de escribirlo, definiendo la idea central y el orden de las ideas.', 2),
  ('Revisión de textos propios', 'Revisar y editar un texto propio para mejorar su claridad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 2° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Comunicación Oral, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de textos orales', 'Comprender textos orales identificando la información relevante.', 0),
  ('Exposición oral breve con apoyo visual', 'Exponer oralmente sobre un tema conocido, con apoyo de imágenes.', 1),
  ('Preguntas y respuestas pertinentes', 'Formular preguntas y dar respuestas pertinentes durante una conversación.', 2),
  ('Uso de vocabulario variado', 'Usar vocabulario variado al expresarse oralmente.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 3° BÁSICO (order_index de nivel = 103)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 3° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Lectura, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Lectura independiente de textos más extensos', 'Leer de manera independiente textos literarios y no literarios de mayor extensión.', 0),
  ('Inferencias a partir del texto', 'Realizar inferencias sencillas a partir de la información entregada por el texto.', 1),
  ('Propósito y estructura de distintos textos', 'Identificar el propósito y la estructura de distintos tipos de textos (cartas, noticias, cuentos).', 2),
  ('Estrategias de comprensión lectora', 'Usar estrategias de comprensión lectora como la relectura, el subrayado y la formulación de preguntas.', 3),
  ('Relación del texto con conocimientos previos', 'Relacionar la información de un texto con conocimientos previos y con la propia experiencia.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 3° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Escritura, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Textos narrativos y descriptivos con estructura', 'Producir textos narrativos y descriptivos con estructura clara: inicio, desarrollo y cierre.', 0),
  ('Uso de conectores simples', 'Usar conectores simples para dar cohesión al texto escrito.', 1),
  ('Normas ortográficas y acentuación básica', 'Aplicar normas ortográficas básicas y de acentuación en la escritura de palabras frecuentes.', 2),
  ('Reescritura con sugerencias de mejora', 'Reescribir un texto propio incorporando sugerencias de mejora.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 3° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Comunicación Oral, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Exposición oral de un tema investigado', 'Exponer oralmente un tema investigado, organizando la información presentada.', 0),
  ('Escucha activa en una conversación', 'Escuchar activamente y comprender las ideas de otros en una conversación.', 1),
  ('Participación en debates simples', 'Participar en debates simples, fundamentando una opinión propia.', 2),
  ('Vocabulario preciso y adecuado al contexto', 'Usar un vocabulario preciso y adecuado al contexto al expresarse oralmente.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° BÁSICO (order_index de nivel = 104)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 4° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Lectura, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Conflicto, personajes y tema central', 'Identificar el conflicto, los personajes y el tema central de un texto literario.', 0),
  ('Propósito e ideas relevantes de textos no literarios', 'Identificar el propósito comunicativo e ideas relevantes de un texto no literario.', 1),
  ('Interpretación de lenguaje figurado simple', 'Interpretar comparaciones y personificaciones simples presentes en un texto.', 2),
  ('Opinión fundamentada sobre lo leído', 'Formar una opinión fundamentada sobre un texto leído, apoyándose en información del texto.', 3),
  ('Comparación de textos sobre un mismo tema', 'Comparar dos textos que tratan un mismo tema, identificando semejanzas y diferencias.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 4° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Escritura, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Planificación, escritura y revisión de textos completos', 'Planificar, escribir y revisar textos completos (narración, texto informativo).', 0),
  ('Conectores temporales y causales', 'Usar conectores para ordenar ideas de manera temporal y causal en un texto.', 1),
  ('Ortografía literal y acentual', 'Aplicar reglas de ortografía literal y acentual en la escritura de textos propios.', 2),
  ('Vocabulario preciso en la escritura', 'Incorporar vocabulario preciso al producir un texto escrito.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 4° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Comunicación Oral, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Exposición oral con recursos visuales', 'Exponer oralmente con apoyo de recursos visuales, organizando las ideas en introducción, desarrollo y cierre.', 0),
  ('Discusiones grupales respetando opiniones', 'Participar en discusiones grupales, respetando y contrastando las opiniones de otros.', 1),
  ('Comprensión crítica de mensajes audiovisuales simples', 'Comprender críticamente mensajes orales y audiovisuales simples.', 2),
  ('Registro adecuado a la situación comunicativa', 'Usar un registro adecuado según la situación comunicativa.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 5° BÁSICO (order_index de nivel = 105)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 5° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Lectura, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Narrador, personajes, ambiente y conflicto', 'Analizar el narrador, los personajes, el ambiente y el conflicto de un texto narrativo.', 0),
  ('Hecho y opinión en textos informativos', 'Comprender textos informativos, distinguiendo hechos de opiniones.', 1),
  ('Significado de palabras por contexto', 'Usar estrategias para determinar el significado de palabras desconocidas a partir del contexto.', 2),
  ('Postura personal fundamentada frente a lo leído', 'Formar una postura personal frente a lo leído, fundamentándola con evidencia del texto.', 3),
  ('Contexto sociocultural del texto', 'Reconocer el contexto sociocultural de producción de un texto literario o no literario.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 5° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Escritura, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Textos de diversos géneros con propósito definido', 'Producir textos de diversos géneros (narrativo, informativo, poético) con un propósito comunicativo definido.', 0),
  ('Conectores variados para cohesión y coherencia', 'Usar conectores variados para dar cohesión y coherencia al texto escrito.', 1),
  ('Convenciones de escritura crecientes', 'Aplicar convenciones de ortografía y puntuación de manera creciente.', 2),
  ('Revisión con pautas o rúbricas simples', 'Revisar un texto propio usando pautas o rúbricas simples.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 5° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Comunicación Oral, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Exposición oral con apoyo de TIC', 'Planificar y realizar una exposición oral con apoyo de tecnologías de la información.', 0),
  ('Debates con argumentación y contraargumentación', 'Participar en debates, argumentando y contraargumentando con respeto.', 1),
  ('Intención del hablante en un discurso', 'Comprender discursos orales, identificando la intención comunicativa del hablante.', 2),
  ('Registro y vocabulario según la audiencia', 'Adecuar el registro y el vocabulario oral a la audiencia y a la situación comunicativa.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 6° BÁSICO (order_index de nivel = 106)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 6° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Lectura, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Estructura de géneros literarios', 'Analizar la estructura y los elementos de distintos géneros literarios (cuento, poema, obra dramática breve).', 0),
  ('Tesis e ideas de apoyo en textos expositivos/argumentativos', 'Comprender textos expositivos y argumentativos, identificando la tesis y las ideas que la apoyan.', 1),
  ('Recursos literarios y su efecto', 'Interpretar recursos literarios (metáfora, hipérbole) y su efecto en el texto.', 2),
  ('Comparación de puntos de vista sobre un tema', 'Comparar los puntos de vista presentados en distintos textos sobre un mismo tema.', 3),
  ('Evaluación de la confiabilidad de una fuente', 'Evaluar la confiabilidad de una fuente de información no literaria.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 6° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Escritura, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Textos argumentativos simples', 'Producir textos argumentativos simples, con tesis y argumentos organizados.', 0),
  ('Vocabulario variado y preciso', 'Usar un vocabulario variado y preciso, evitando repeticiones innecesarias.', 1),
  ('Ortografía y puntuación autónomas', 'Aplicar de manera autónoma normas de ortografía y puntuación en la escritura.', 2),
  ('Reescritura a partir de retroalimentación', 'Reescribir un texto propio a partir de la retroalimentación de pares o del docente.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 6° Básico', 'Objetivos de aprendizaje de Lenguaje, eje Comunicación Oral, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, denominación oficial de la asignatura en esta banda: "Lenguaje y Comunicación" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Exposición oral formal sobre un tema de investigación', 'Organizar y presentar una exposición oral formal sobre un tema de investigación.', 0),
  ('Discusiones literarias fundamentadas', 'Participar activamente en discusiones literarias, fundamentando interpretaciones propias.', 1),
  ('Evaluación crítica de mensajes de los medios', 'Evaluar críticamente mensajes provenientes de los medios de comunicación.', 2),
  ('Recursos no verbales y paraverbales', 'Usar recursos no verbales y paraverbales para apoyar la comunicación oral.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
