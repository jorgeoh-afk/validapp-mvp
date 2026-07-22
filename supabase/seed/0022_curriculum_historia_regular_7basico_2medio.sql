-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Historia, Geografía y Ciencias Sociales, 7° Básico a 2° Medio.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA
-- ============================================================================
-- Fuente citada: Bases Curriculares de 7° Básico a 2° Medio, MINEDUC,
-- aprobadas por el Decreto Supremo N.° 614 de 2013. Implementación progresiva
-- 2015-2019 según el propio decreto (por curso). Mismo decreto que ya rige
-- Matemática (supabase/seed/0012) y Lenguaje (supabase/seed/0015) en esta
-- banda.
--
-- Confianza en la denominación de los 3 ejes temáticos (Historia; Geografía;
-- Formación Ciudadana -- mismos 3 ejes que 1°-6° Básico, ver
-- supabase/seed/0021): MEDIA-ALTA, mismo criterio y mismas razones que 0021.
-- Confianza en la progresión general de contenidos (de civilizaciones
-- antiguas/Roma/Edad Media en 7° Básico, pasando por conquista y Colonia en
-- 8° Básico, hasta consolidación del Estado nación e Historia reciente de
-- Chile en 1°-2° Medio): MEDIA.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL ("OA n") de cada
-- objetivo de este decreto (614/2013): BAJA -- no hay PDF de esta fuente
-- específica cargado ni verificado en este entorno. Por eso, igual que en
-- supabase/seed/0012/0021:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - Todas las filas quedan `status = 'borrador'`.
--   - `pedagogical_notes` repite la advertencia en cada objetivo.
--
-- ============================================================================
-- ALCANCE DE ESTE ARCHIVO: SOLO 7° BÁSICO A 2° MEDIO -- 3° Y 4° MEDIO
-- QUEDAN EXPLÍCITAMENTE FUERA DE ESTE SEED (ver razonamiento completo abajo)
-- ============================================================================
-- A diferencia de Matemática (0011-0013) y Lenguaje (0014-0016), que sí
-- cubren 1° a 4° Medio bajo una asignatura de Formación General continua,
-- este archivo NO tiene una contraparte "0021_..._3_4medio.sql" para Historia.
-- Motivo, con criterio pedagógico explícito:
--
-- El Plan de Formación General de 3° y 4° Medio (D.S. 193/2019, mismo
-- decreto ya verificado en supabase/seed/0013 y 0016 para Matemática y
-- Lengua y Literatura) NO contiene una asignatura llamada "Historia,
-- Geografía y Ciencias Sociales" que continúe esta banda. En su lugar,
-- contiene "Educación Ciudadana": una asignatura de Formación General
-- distinta y más acotada, centrada en formación cívica/ciudadana
-- (instituciones democráticas, Constitución, derechos y deberes,
-- participación), NO en Historia ni Geografía. El contenido de Historia y
-- Geografía propiamente tal pasa, en esta reforma, a la Formación
-- DIFERENCIADA (electiva) de 3°-4° Medio, no a la Formación General.
--
-- Esto es una divergencia curricular REAL, no solo un cambio de nombre --
-- a diferencia de Lenguaje, donde "Lenguaje y Comunicación" -> "Lengua y
-- Literatura" sí es esencialmente la misma asignatura con otro nombre (mismo
-- objeto de estudio, misma continuidad de ejes: Lectura, Escritura,
-- Comunicación Oral, Investigación). Aquí el OBJETO DE ESTUDIO cambia:
-- "Educación Ciudadana" recorta drásticamente el alcance de Historia y
-- Geografía en Formación General, dejando prácticamente solo Formación
-- Ciudadana como continuación obligatoria para todos los estudiantes.
--
-- Decisión tomada: NO cargar contenido de 3°-4° Medio bajo la fila de
-- `subjects` "Estudios Sociales"/Historia en este seed. Forzar continuidad
-- aquí sería más cuestionable pedagógicamente que en el caso de Lenguaje --
-- equivaldría a fabricar objetivos de "Historia y Geografía" para un curso
-- donde, en Formación General, esos ejes prácticamente no existen como tales.
--
-- Alternativas consideradas y descartadas para esta pasada:
--   a) Cargar los 3 ejes de Historia/Geografía/Formación Ciudadana también
--      para 3°-4° Medio, como si "Educación Ciudadana" fuera una
--      continuación directa -- DESCARTADA: sería inexacta, mezclaría
--      contenido de una asignatura electiva (Historia y Geografía en
--      Formación Diferenciada) con una asignatura obligatoria distinta
--      (Educación Ciudadana), fabricando una continuidad que el propio
--      decreto no establece.
--   b) Crear una fila `subjects` nueva "Educación Ciudadana" y poblarla con
--      sus propios ejes y objetivos -- NO se hace en esta pasada: este
--      agente no tiene, con la confianza mínima exigida, el detalle de los
--      ejes/OA propios y verificados de esa asignatura específica (es
--      distinta de "Formación Ciudadana" como eje dentro de Historia; tiene
--      su propio diseño curricular). Crearla igual sería fabricar contenido
--      oficial sin base verificable, lo que está expresamente prohibido.
--
-- Recomendación para una fase futura: si se decide cubrir 3°-4° Medio, debe
-- tratarse como una tarea separada y explícita para "Educación Ciudadana"
-- (subjects.name nuevo, ejes propios, fuente y confianza declaradas desde
-- cero), no como una extensión de este archivo ni de la fila "Estudios
-- Sociales". Del mismo modo, si se desea cubrir el contenido electivo de
-- "Historia, Geografía y Ciencias Sociales" de Formación Diferenciada en
-- 3°-4° Medio, debe modelarse explícitamente como asignatura/electivo
-- diferenciado, no mezclado con la Formación General.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO (dentro del alcance de este archivo)
-- ============================================================================
-- Cubre: los 3 ejes temáticos oficiales x 4 cursos (7° Básico, 8° Básico,
-- 1° Medio, 2° Medio) = 12 combinaciones eje-curso, cada una con 1 unidad y
-- 4 objetivos de aprendizaje curados. Mismo criterio que 0021: distribución
-- pareja de 4 objetivos por eje, sin ponderación diferenciada no verificada.
-- Representativos, NO exhaustivos.
--
-- No cubre: 3°-4° Medio (ver razonamiento arriba), banco de preguntas,
-- lecciones, ensayos, habilidades, Grandes ideas ni Conocimientos esenciales.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects
-- ============================================================================
-- Mismo motivo documentado en supabase/seed/0011/0012/0021: `exam_period`
-- NOT NULL en `curriculum_frameworks` no tiene equivalente en el Currículum
-- Regular. Se usa `curricular_source`/`reference_year`/`pedagogical_notes`.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0012/0021. Reutiliza `subjects.name = 'Estudios
-- Sociales'` y los 3 ejes ya creados por supabase/seed/0021 ("Historia",
-- "Geografía", "Formación Ciudadana") -- no se crea ningún eje nuevo en este
-- archivo. Seed SOLO local: no se ha ejecutado contra ningún proyecto
-- Supabase (ni dev ni producción).

-- ============================================================================
-- 1) Asignatura (reutiliza "Estudios Sociales", ver supabase/seed/0021)
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Estudios Sociales', 'social_sciences')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos: los 3 ejes de esta banda ("Historia", "Geografía",
--    "Formación Ciudadana") ya existen (creados por supabase/seed/0021). Se
--    reutilizan sin modificar -- no se inserta ningún eje nuevo aquí.
-- ============================================================================

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 7° BÁSICO (order_index de nivel = 107)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 7° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Historia.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Legado institucional y cultural de Roma', 'Analizar el legado institucional, jurídico y cultural de la civilización romana.', 0),
  ('Sociedad feudal y rol de la Iglesia en la Edad Media', 'Caracterizar la organización social feudal y el rol de la Iglesia católica durante la Edad Media europea.', 1),
  ('Formación de monarquías y expansión europea', 'Describir el proceso de formación de las monarquías y de expansión europea hacia otros continentes.', 2),
  ('Análisis de fuentes históricas diversas', 'Analizar distintos tipos de fuentes históricas para fundamentar interpretaciones sobre procesos del pasado.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 7° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Relieve, clima e hidrografía de Chile', 'Caracterizar el relieve, el clima y la hidrografía de Chile y su distribución en el territorio.', 0),
  ('Riesgos naturales y su prevención', 'Analizar riesgos naturales presentes en el territorio chileno y medidas de prevención y mitigación.', 1),
  ('Recursos naturales y sustentabilidad', 'Evaluar el uso de recursos naturales en Chile desde la perspectiva de la sustentabilidad.', 2),
  ('Uso de sistemas de información geográfica', 'Utilizar sistemas de información geográfica simples para analizar problemas territoriales.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 7° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Universalidad de los derechos humanos', 'Fundamentar la universalidad de los derechos humanos y su relevancia para la convivencia social.', 0),
  ('Diversidad y no discriminación', 'Analizar situaciones de discriminación y proponer formas de promover la no discriminación.', 1),
  ('Organización política de Chile: poderes del Estado', 'Describir la organización política de Chile y las funciones de los poderes del Estado.', 2),
  ('Participación estudiantil y comunitaria', 'Evaluar distintas formas de participación estudiantil y comunitaria disponibles para adolescentes.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 8° BÁSICO (order_index de nivel = 108)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 8° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Historia.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Descubrimiento y conquista de América', 'Analizar el proceso de descubrimiento y conquista de América y sus consecuencias para los pueblos originarios.', 0),
  ('Organización política, económica y social de la Colonia', 'Describir la organización política, económica y social de Chile durante el período colonial.', 1),
  ('Independencia de Chile: proceso y actores', 'Explicar el proceso de Independencia de Chile, sus principales actores y consecuencias.', 2),
  ('Construcción de relatos históricos con evidencia', 'Construir relatos históricos simples fundamentados en evidencia de distintas fuentes.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 8° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Regiones y paisajes de América', 'Caracterizar regiones y paisajes de América Latina y sus principales rasgos geográficos.', 0),
  ('Recursos naturales de América Latina', 'Analizar el uso de recursos naturales en América Latina y su relación con el desarrollo económico.', 1),
  ('Problemas ambientales y desarrollo sostenible', 'Analizar problemas ambientales actuales y su relación con el concepto de desarrollo sostenible.', 2),
  ('Distribución espacial de actividades productivas', 'Describir la distribución espacial de actividades productivas en América Latina.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 8° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Construcción de la identidad nacional', 'Analizar procesos de construcción de la identidad nacional chilena durante el siglo XIX.', 0),
  ('Instituciones republicanas del siglo XIX', 'Describir las principales instituciones republicanas creadas en Chile durante el siglo XIX.', 1),
  ('Participación y ciudadanía en democracia', 'Fundamentar la importancia de la participación ciudadana para el funcionamiento de la democracia.', 2),
  ('Ampliación histórica de derechos ciudadanos', 'Analizar procesos históricos de ampliación de derechos ciudadanos (por ejemplo, el sufragio).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 1° MEDIO (order_index de nivel = 109)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 1° Medio', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Historia.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Consolidación del Estado nación en Chile (siglo XIX)', 'Explicar el proceso de consolidación del Estado nación en Chile durante el siglo XIX.', 0),
  ('Expansión territorial y Guerra del Pacífico', 'Analizar procesos de expansión territorial de Chile en el siglo XIX, incluida la Guerra del Pacífico.', 1),
  ('Cuestión social y movimiento obrero', 'Caracterizar la "cuestión social" y el surgimiento del movimiento obrero en Chile a fines del siglo XIX e inicios del XX.', 2),
  ('Uso de múltiples fuentes para explicar procesos históricos', 'Explicar procesos históricos complejos integrando información de múltiples fuentes.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 1° Medio', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Geografía económica de Chile: sectores productivos', 'Analizar los principales sectores productivos de la economía chilena y su distribución territorial.', 0),
  ('Globalización y su impacto territorial', 'Analizar el impacto de la globalización en la organización del territorio y la economía chilena.', 1),
  ('Geografía de los océanos y recursos marinos', 'Describir la importancia geográfica y económica de los océanos y recursos marinos para Chile.', 2),
  ('Comparación de indicadores territoriales', 'Comparar indicadores territoriales entre distintas regiones de Chile para analizar desigualdades.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 1° Medio', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Derechos económicos, sociales y culturales', 'Analizar derechos económicos, sociales y culturales reconocidos en tratados internacionales suscritos por Chile.', 0),
  ('Rol del Estado en la economía', 'Analizar distintas concepciones sobre el rol del Estado en la economía a lo largo de la historia reciente de Chile.', 1),
  ('Organizaciones de la sociedad civil', 'Evaluar el rol de organizaciones de la sociedad civil en la promoción de derechos y demandas sociales.', 2),
  ('Análisis crítico de fuentes sobre temas ciudadanos', 'Analizar críticamente fuentes de información sobre temas ciudadanos y económicos de actualidad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° MEDIO (order_index de nivel = 110)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 2° Medio', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Historia.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Crisis del parlamentarismo y régimen presidencial', 'Explicar la crisis del sistema parlamentario en Chile y la instauración del régimen presidencial en el siglo XX.', 0),
  ('Guerra Fría y su impacto en Chile y el mundo', 'Caracterizar el conflicto de la Guerra Fría y su impacto en la política chilena y mundial.', 1),
  ('Régimen militar y transición a la democracia', 'Analizar el régimen militar en Chile (1973-1990) y el proceso de transición a la democracia.', 2),
  ('Uso de memoria histórica y fuentes contemporáneas', 'Analizar procesos de la historia reciente de Chile a partir de fuentes contemporáneas y ejercicios de memoria histórica.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 2° Medio', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Geopolítica mundial y organismos internacionales', 'Analizar la organización geopolítica mundial y el rol de organismos internacionales.', 0),
  ('Indicadores de desarrollo socioeconómico', 'Comparar países y regiones del mundo a partir de indicadores de desarrollo socioeconómico.', 1),
  ('Globalización cultural y económica', 'Analizar el impacto de la globalización cultural y económica en distintas sociedades del mundo.', 2),
  ('Problemas territoriales de escala global', 'Analizar problemas territoriales de escala global, como la desigualdad y la crisis medioambiental.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 2° Medio', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Sistema político chileno actual', 'Describir la estructura y el funcionamiento del sistema político chileno actual.', 0),
  ('Derechos humanos y memoria histórica', 'Fundamentar la importancia de los derechos humanos y de la memoria histórica en la democracia actual.', 1),
  ('Participación ciudadana y medios de comunicación', 'Evaluar el rol de los medios de comunicación en la formación de opinión pública y la participación ciudadana.', 2),
  ('Desafíos actuales de la democracia', 'Analizar desafíos actuales de la democracia chilena, como la participación electoral y la confianza institucional.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
