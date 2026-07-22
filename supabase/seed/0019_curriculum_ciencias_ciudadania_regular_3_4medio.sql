-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Ciencias para la Ciudadanía, 3° y 4° Medio, Formación General.
--
-- ============================================================================
-- DECISIÓN CENTRAL DE ESTE ARCHIVO — POR QUÉ ES UNA ASIGNATURA NUEVA Y NO
-- UNA CONTINUACIÓN DE "Ciencias Naturales"
-- ============================================================================
-- El Plan de Formación General de 3°-4° Medio (Decreto Supremo N.° 193 de
-- 2019) NO contempla una asignatura llamada "Ciencias Naturales" que continúe
-- directamente los 3 ejes disciplinares de Básica/7° Básico-2° Medio
-- (Biología/Física/Química/Ciencias de la Tierra, ver supabase/seed/0017 y
-- 0018). En su lugar, crea una asignatura de Formación General nueva y
-- distinta: "Ciencias para la Ciudadanía", con un enfoque explícito de
-- alfabetización científica ciudadana (seguridad y autocuidado, sociedad y
-- tecnología, sustentabilidad ambiental, salud) organizada en módulos
-- temáticos transversales, no en los ejes disciplinares clásicos de
-- Biología/Física/Química por separado. (La Formación Diferenciada de 3°-4°
-- Medio sí ofrece asignaturas científicas disciplinares -- Biología,
-- Física, Química -- como electivos, pero esas están fuera del alcance de
-- este archivo, que cubre solo Formación General; ver sección "Qué cubre y
-- qué no" más abajo.)
--
-- Esto es una DIVERGENCIA CURRICULAR REAL, no un simple cambio de nombre
-- (a diferencia de Lenguaje, donde "Lenguaje y Comunicación" pasa a llamarse
-- "Lengua y Literatura" en 3°-4° Medio manteniendo el mismo contenido
-- esencial -- ver la decisión documentada en supabase/seed/0016). Por eso,
-- a diferencia de Lenguaje, en este archivo SÍ SE CREA UNA FILA NUEVA en
-- `subjects` ("Ciencias para la Ciudadanía"), en vez de reutilizar la fila
-- "Ciencias Naturales" (canonical_code = 'natural_sciences', creada por
-- supabase/seed/0002_epja_remaining_subjects.sql y reutilizada en 0017/0018).
--
-- Se verificó antes de decidir esto que "Ciencias Naturales" ya existe como
-- fila de `subjects` (name = 'Ciencias Naturales', canonical_code =
-- 'natural_sciences') y que `subjects.canonical_code` tiene un índice único
-- PARCIAL (`subjects_canonical_code_key`, creado en
-- supabase/migrations/0016_curriculum_frameworks.sql, `where canonical_code
-- is not null`). Por eso la nueva fila usa un `canonical_code` DISTINTO
-- ('citizen_science') para no colisionar con 'natural_sciences' ni con
-- ningún otro canonical_code ya usado (mathematics, language,
-- natural_sciences, social_sciences, english -- ver
-- supabase/seed/0001/0002/0011-0016).
--
-- Consecuencia práctica de esta decisión: un reporte de cobertura curricular
-- que agrupe por asignatura mostrará "Ciencias Naturales" (1°-2° Medio y
-- anteriores) y "Ciencias para la Ciudadanía" (3°-4° Medio) como dos
-- asignaturas separadas, NO como una progresión continua de una misma
-- asignatura. Esto es intencional y refleja la estructura real del
-- currículo -- fusionarlas artificialmente ocultaría la divergencia real y
-- dificultaría razonar sobre cobertura de OA por asignatura.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA -- decreto VERIFICADO
-- ============================================================================
-- Fuente citada: Bases Curriculares de 3° y 4° Medio (Formación General),
-- MINEDUC, aprobadas por el DECRETO SUPREMO N.° 193 DE 2019, publicado en el
-- Diario Oficial en torno al 3 de septiembre de 2019. Vigencia progresiva
-- desde 2020 (3° Medio) y 2021 (4° Medio). Mismo decreto que ya rige
-- Matemática (supabase/seed/0013) y Lengua y Literatura (supabase/seed/0016)
-- en esta banda.
--
-- DENOMINACIÓN OFICIAL DE LA ASIGNATURA: "Ciencias para la Ciudadanía".
-- CONFIANZA ALTA en que esta asignatura existe con este nombre y con este
-- enfoque general (alfabetización científica ciudadana, no continuación
-- disciplinar) -- este es un hecho ampliamente documentado sobre la reforma
-- 2019 del Plan de Formación General de 3°-4° Medio, reportado explícitamente
-- por el coordinador de esta sesión tras una búsqueda web realizada hoy
-- (este agente no tiene herramientas de navegación web en este entorno y no
-- verificó las URL directamente).
--
-- CONFIANZA EN LA ESTRUCTURA DE MÓDULOS Y SUS NOMBRES EXACTOS: MEDIA-BAJA.
-- Este agente tiene un recuerdo general (previo a esta sesión, sin
-- verificación directa contra el PDF del Decreto 193/2019) de que la
-- asignatura se organiza en 4 módulos temáticos aplicados a lo largo de
-- 3°-4° Medio, aproximadamente: "Seguridad, Prevención y Autocuidado",
-- "Tecnología y Sociedad", "Ecosistema, Comunidad y Sustentabilidad" y
-- "Célula, Tecnología y Sociedad". NINGUNO de estos 4 nombres fue verificado
-- letra por letra contra el texto del decreto en esta sesión -- podrían no
-- coincidir exactamente con la redacción oficial, podría haber un número
-- distinto de módulos, o podrían estar agrupados o secuenciados de otra
-- forma en el documento real. Se usan aquí como una estructura razonable y
-- representativa para poder cargar objetivos de aprendizaje, NO como una cita
-- verificada de la fuente. ANTES de promover cualquier fila de este archivo a
-- `status = 'aprobado'`, o de usar estos nombres de módulo en una interfaz
-- pública como si fueran oficiales, se recomienda fuertemente que un humano
-- (o un agente con acceso de navegación web) confirme directamente contra
-- las Bases Curriculares de Ciencias para la Ciudadanía si estos 4 módulos y
-- sus nombres son correctos.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL ("OA n") de cada
-- objetivo puntual: BAJA (mismo criterio que el resto de esta serie de
-- archivos). Por eso, igual que en 0011-0018:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - Todas las filas quedan `status = 'borrador'`.
--   - `pedagogical_notes` distingue, en cada fila, entre "el decreto y el
--     nombre de la asignatura están verificados con confianza ALTA" y "la
--     estructura de módulos y el texto de cada objetivo son de confianza
--     MEDIA-BAJA/BAJA, sin verificar contra el PDF oficial".
--
-- ============================================================================
-- MODELADO: "módulos" en la tabla `strands`
-- ============================================================================
-- El esquema no distingue entre "eje temático" (Matemática, Lenguaje,
-- Ciencias Naturales disciplinar) y "módulo" (Ciencias para la Ciudadanía):
-- ambos se guardan en la tabla `strands`, ligada a `subjects`. Se reutiliza
-- esa misma tabla para los 4 módulos de esta asignatura, dejando constancia
-- explícita aquí (y en `description` de cada fila de `strands`) de que se
-- trata de módulos temáticos de alfabetización científica ciudadana, no de
-- ejes disciplinares clásicos -- para que quien lea el dato en el futuro no
-- asuma erróneamente que son equivalentes a "Ciencias de la Vida" o
-- similares.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 módulos x 2 cursos (3° y 4° Medio) = 8 combinaciones módulo-curso,
-- cada una con 1 unidad y 4 objetivos de aprendizaje curados -- SOLO
-- Formación General.
--
-- NO cubre Formación Diferenciada de 3°-4° Medio (asignaturas científicas
-- disciplinares electivas como Biología, Física o Química): quedan
-- explícitamente fuera de alcance, mismo criterio que 0013/0016 con la
-- Formación Diferenciada de Matemática/Lengua y Literatura. Si se necesitan
-- más adelante, deben tratarse como asignaturas o unidades separadas, con su
-- propia verificación de fuente.
--
-- No cubre: banco de preguntas, lecciones, ensayos, catálogo de habilidades
-- (`skills`), actitudes (OAA), Grandes ideas ni Conocimientos esenciales.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects
-- ============================================================================
-- Mismo motivo documentado en 0011-0018: `exam_period` NOT NULL en
-- `curriculum_frameworks` modela el problema específico de EPJA (varios
-- decretos por período de examinación), no el Currículum Regular.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- `subjects.name` tiene restricción única -- este archivo crea la fila
-- "Ciencias para la Ciudadanía" con `on conflict (name) do nothing` (segura
-- de reintentar). `subjects.canonical_code` tiene índice único parcial: se
-- usa 'citizen_science', verificado que no colisiona con ningún
-- canonical_code ya usado en el repositorio (ver decisión central arriba).
-- `strands (subject_id, name)` y `units (strand_id, name)` tienen
-- restricción única (0010): `on conflict do nothing`. `learning_objectives
-- (unit_id, level_id, short_name)` tiene restricción única (0021): `on
-- conflict do update` limitado a las columnas propias de este archivo.
-- `level_id` por `levels.code`, `subject_id` por `subjects.name`. Seed SOLO
-- local: no se ha ejecutado contra Supabase.

-- ============================================================================
-- 1) Asignatura NUEVA: "Ciencias para la Ciudadanía"
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Ciencias para la Ciudadanía', 'citizen_science')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Módulos temáticos (guardados en `strands`, ver nota de modelado arriba)
-- ============================================================================
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias para la Ciudadanía'),
   'Seguridad, Prevención y Autocuidado', 'Módulo de alfabetización científica ciudadana sobre riesgos cotidianos, autocuidado y prevención (no es un eje disciplinar clásico; ver nota de confianza MEDIA-BAJA en el encabezado de este archivo).', 0)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias para la Ciudadanía'),
   'Tecnología y Sociedad', 'Módulo sobre el impacto social, ético y económico de la tecnología y la toma de decisiones informada (ver nota de confianza MEDIA-BAJA en el encabezado de este archivo).', 1)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias para la Ciudadanía'),
   'Ecosistema, Comunidad y Sustentabilidad', 'Módulo sobre sustentabilidad ambiental, cambio climático y uso responsable de recursos naturales (ver nota de confianza MEDIA-BAJA en el encabezado de este archivo).', 2)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias para la Ciudadanía'),
   'Célula, Tecnología y Sociedad', 'Módulo sobre biotecnología, salud y sus implicancias éticas y sociales (ver nota de confianza MEDIA-BAJA en el encabezado de este archivo).', 3)
on conflict (subject_id, name) do nothing;

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 3° MEDIO (order_index de nivel = 111)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Seguridad, Prevención y Autocuidado — 3° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Seguridad, Prevención y Autocuidado, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Seguridad, Prevención y Autocuidado'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Seguridad, Prevención y Autocuidado" (nombre de módulo de confianza MEDIA-BAJA, sin verificar letra por letra -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Análisis de riesgos cotidianos con base científica', 'Analizar riesgos presentes en la vida cotidiana (radiación, ruido, sustancias químicas de uso doméstico) usando evidencia científica.', 0),
  ('Primeros auxilios básicos', 'Aplicar procedimientos básicos de primeros auxilios ante situaciones de emergencia frecuentes.', 1),
  ('Prevención de enfermedades mediante hábitos saludables', 'Evaluar la relación entre hábitos de vida saludable y la prevención de enfermedades.', 2),
  ('Toma de decisiones informada sobre autocuidado', 'Tomar decisiones informadas sobre autocuidado a partir de información científica confiable.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Seguridad, Prevención y Autocuidado') and name = 'Seguridad, Prevención y Autocuidado — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Tecnología y Sociedad — 3° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Tecnología y Sociedad, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Tecnología y Sociedad'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Tecnología y Sociedad" (nombre de módulo de confianza MEDIA-BAJA -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Impacto social de la tecnología', 'Analizar el impacto social, económico y ambiental de tecnologías de uso cotidiano.', 0),
  ('Ética en el desarrollo científico y tecnológico', 'Discutir dilemas éticos asociados al desarrollo de la ciencia y la tecnología.', 1),
  ('Evaluación crítica de información tecnológica', 'Evaluar de forma crítica información sobre tecnología difundida en medios de comunicación.', 2),
  ('Toma de decisiones sobre consumo tecnológico', 'Tomar decisiones informadas sobre el consumo de tecnología, considerando su impacto personal y social.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Tecnología y Sociedad') and name = 'Tecnología y Sociedad — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ecosistema, Comunidad y Sustentabilidad — 3° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Ecosistema, Comunidad y Sustentabilidad, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Ecosistema, Comunidad y Sustentabilidad'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Ecosistema, Comunidad y Sustentabilidad" (nombre de módulo de confianza MEDIA-BAJA -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Cambio climático y evidencia científica', 'Analizar evidencia científica sobre las causas y consecuencias del cambio climático.', 0),
  ('Huella ecológica y consumo responsable', 'Evaluar la huella ecológica de hábitos de consumo personales y comunitarios.', 1),
  ('Biodiversidad y conservación', 'Argumentar sobre la importancia de la biodiversidad y de las medidas de conservación ambiental.', 2),
  ('Uso sustentable de recursos naturales', 'Proponer acciones de uso sustentable de recursos naturales a nivel comunitario.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Ecosistema, Comunidad y Sustentabilidad') and name = 'Ecosistema, Comunidad y Sustentabilidad — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Célula, Tecnología y Sociedad — 3° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Célula, Tecnología y Sociedad, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Célula, Tecnología y Sociedad'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Célula, Tecnología y Sociedad" (nombre de módulo de confianza MEDIA-BAJA -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Biotecnología y sus aplicaciones', 'Describir aplicaciones de la biotecnología en la salud, la agricultura y la industria.', 0),
  ('Salud reproductiva y sexual con enfoque ciudadano', 'Analizar información científica sobre salud reproductiva y sexual desde una perspectiva de autocuidado ciudadano.', 1),
  ('Enfermedades de origen genético', 'Describir enfermedades de origen genético y su impacto en las personas y sus familias.', 2),
  ('Dilemas éticos de la manipulación genética', 'Discutir dilemas éticos asociados a la manipulación genética y sus aplicaciones tecnológicas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Célula, Tecnología y Sociedad') and name = 'Célula, Tecnología y Sociedad — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° MEDIO (order_index de nivel = 112)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Seguridad, Prevención y Autocuidado — 4° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Seguridad, Prevención y Autocuidado, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Seguridad, Prevención y Autocuidado'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Seguridad, Prevención y Autocuidado" (nombre de módulo de confianza MEDIA-BAJA -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Evaluación de riesgos en el entorno laboral', 'Evaluar riesgos científicos y tecnológicos presentes en distintos entornos laborales.', 0),
  ('Seguridad ante desastres naturales', 'Analizar medidas de prevención y autocuidado ante desastres naturales frecuentes en Chile.', 1),
  ('Uso responsable de medicamentos y sustancias', 'Evaluar el uso responsable de medicamentos y otras sustancias con base en información científica.', 2),
  ('Comunicación de riesgos a la comunidad', 'Comunicar de forma clara información científica sobre riesgos y medidas de autocuidado a la comunidad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Seguridad, Prevención y Autocuidado') and name = 'Seguridad, Prevención y Autocuidado — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Tecnología y Sociedad — 4° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Tecnología y Sociedad, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Tecnología y Sociedad'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Tecnología y Sociedad" (nombre de módulo de confianza MEDIA-BAJA -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ciencia, tecnología y desarrollo sostenible', 'Analizar el rol de la ciencia y la tecnología en el desarrollo sostenible de la sociedad.', 0),
  ('Big data y uso de información personal', 'Discutir implicancias éticas del uso de datos personales por parte de tecnologías digitales.', 1),
  ('Innovación tecnológica y empleo', 'Analizar el efecto de la innovación tecnológica en el mercado laboral y sus desafíos ciudadanos.', 2),
  ('Participación ciudadana en decisiones científico-tecnológicas', 'Evaluar formas de participación ciudadana en decisiones públicas relacionadas con ciencia y tecnología.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Tecnología y Sociedad') and name = 'Tecnología y Sociedad — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ecosistema, Comunidad y Sustentabilidad — 4° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Ecosistema, Comunidad y Sustentabilidad, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Ecosistema, Comunidad y Sustentabilidad'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Ecosistema, Comunidad y Sustentabilidad" (nombre de módulo de confianza MEDIA-BAJA -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Políticas públicas ambientales', 'Analizar políticas públicas orientadas a enfrentar problemas ambientales a nivel local y nacional.', 0),
  ('Energías renovables y transición energética', 'Evaluar el rol de las energías renovables en la transición energética de Chile.', 1),
  ('Impacto ambiental de actividades productivas', 'Analizar el impacto ambiental de actividades productivas relevantes para la comunidad.', 2),
  ('Compromiso ciudadano con la sustentabilidad', 'Proponer y argumentar acciones de compromiso ciudadano con la sustentabilidad ambiental.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Ecosistema, Comunidad y Sustentabilidad') and name = 'Ecosistema, Comunidad y Sustentabilidad — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Célula, Tecnología y Sociedad — 4° Medio', 'Objetivos de aprendizaje de Ciencias para la Ciudadanía, módulo Célula, Tecnología y Sociedad, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and s.name = 'Célula, Tecnología y Sociedad'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Ciencias para la Ciudadanía" (decreto y nombre de asignatura verificados con confianza ALTA), módulo "Célula, Tecnología y Sociedad" (nombre de módulo de confianza MEDIA-BAJA -- ver encabezado de este archivo).',
  2019,
  'Paráfrasis ValidApp; confianza MEDIA-BAJA en la estructura y nombre del módulo, BAJA en el texto y numeración OA específicos. No es cita textual del PDF oficial. Revisar contra la fuente antes de marcar como aprobado.',
  v.order_index
from (values
  ('Terapias génicas y sus implicancias', 'Analizar el desarrollo de terapias génicas y sus implicancias para la salud pública.', 0),
  ('Alimentos transgénicos y seguridad alimentaria', 'Evaluar controversias científicas y sociales sobre alimentos transgénicos y seguridad alimentaria.', 1),
  ('Reproducción asistida y clonación: aspectos científicos y éticos', 'Discutir aspectos científicos y éticos de la reproducción asistida y la clonación.', 2),
  ('Rol de la ciencia en políticas de salud pública', 'Analizar el rol de la evidencia científica en el diseño de políticas de salud pública.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias para la Ciudadanía') and name = 'Célula, Tecnología y Sociedad') and name = 'Célula, Tecnología y Sociedad — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
