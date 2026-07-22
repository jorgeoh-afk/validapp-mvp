-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Idioma Extranjero: Inglés, 7° Básico a 2° Medio.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA (léase antes de aprobar cualquier fila)
-- ============================================================================
-- Fuente citada: Bases Curriculares 7° Básico a 2° Medio, MINEDUC, aprobadas
-- por el Decreto Supremo N.° 614 de 2013 (asignatura Idioma Extranjero:
-- Inglés). Vigencia progresiva desde 2015 (7° y 8° Básico) y 2017 (1° y 2°
-- Medio). Mismo decreto único multi-asignatura que ya rige Matemática,
-- Lenguaje, Ciencias Naturales e Historia en esta banda (ver
-- supabase/seed/0012, 0015, 0018, 0022) -- verificado por el coordinador de
-- esta sesión vía búsqueda web, no por este agente (sin acceso a navegación
-- web en este entorno).
--
-- DENOMINACIÓN OFICIAL DE LA ASIGNATURA: "Idioma Extranjero: Inglés".
-- CONFIANZA MEDIA-ALTA -- mismo nombre reutilizado de la fila `subjects` ya
-- creada por EPJA y por supabase/seed/0023 (5° y 6° Básico). No hay
-- evidencia de que el nombre cambie entre 5°-6° Básico y esta banda; a
-- diferencia de Lenguaje, que sí cambia de nombre entre bandas. Este dato NO
-- ha sido verificado línea por línea contra el PDF oficial de esta banda
-- específica.
--
-- Confianza en los 4 ejes temáticos (mismos que supabase/seed/0023:
-- Comprensión Auditiva; Comprensión Lectora; Expresión Oral; Expresión
-- Escrita) y en la progresión general de contenidos (nivel A2 creciente:
-- narración en pasado, comparativos, exposición oral breve con apoyo
-- visual): MEDIA. Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL de
-- cada Objetivo de Aprendizaje: BAJA, mismo motivo que 0011-0023. Por eso:
--   - `code` se deja NULL en todas las filas.
--   - TODAS las filas quedan en `status = 'borrador'`.
--   - `pedagogical_notes` repite esta advertencia en cada objetivo.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes oficiales x 4 cursos (7° Básico, 8° Básico, 1° Medio, 2°
-- Medio) = 16 combinaciones eje-curso, cada una con 1 unidad y 4 objetivos
-- (64 objetivos en total). Representativos, NO exhaustivos.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades (fuera de
-- alcance de esta tarea).
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects
-- ============================================================================
-- Mismo motivo documentado en 0011-0023: `exam_period` NOT NULL en
-- `curriculum_frameworks` no tiene equivalente en el Currículum Regular.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011-0023. Los 4 ejes ya existen (creados por
-- supabase/seed/0023) -- este archivo NO inserta ejes nuevos, solo
-- unidades y objetivos para los cursos de esta banda. Seed SOLO local: NO se
-- ha ejecutado contra ningún proyecto Supabase (ni dev ni producción).

-- ============================================================================
-- 1) Asignatura (reutiliza "Idioma Extranjero: Inglés", ver decisión en
--    supabase/seed/0023)
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Idioma Extranjero: Inglés', 'english')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- Los 4 ejes ("Comprensión Auditiva", "Comprensión Lectora", "Expresión
-- Oral", "Expresión Escrita") ya existen en el esquema (creados por 0023).
-- Se reutilizan sin modificar -- no se inserta ningún eje nuevo en este
-- archivo.

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 7° BÁSICO (order_index de nivel = 107)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 7° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Auditiva.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de narraciones orales simples', 'Comprender narraciones orales simples sobre hechos pasados.', 0),
  ('Identificación de información específica en un audio', 'Identificar información específica (fechas, lugares, personas) en un texto oral.', 1),
  ('Comprensión de diálogos sobre experiencias personales', 'Comprender diálogos que relatan experiencias personales o anécdotas.', 2),
  ('Reconocimiento de la actitud o emoción del hablante', 'Reconocer la actitud o emoción del hablante a partir de la entonación.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 7° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Lectora.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de textos narrativos breves', 'Comprender textos narrativos breves relacionados con hechos pasados.', 0),
  ('Identificación del propósito comunicativo de un texto', 'Identificar el propósito comunicativo de un texto simple (informar, invitar, narrar).', 1),
  ('Uso de estrategias de comprensión lectora', 'Usar estrategias de comprensión lectora como predicción y relectura en inglés.', 2),
  ('Comparación de información entre dos textos breves', 'Comparar información presentada en dos textos breves sobre un mismo tema.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 7° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Narración oral de experiencias pasadas', 'Narrar oralmente experiencias y hechos pasados usando el tiempo pasado simple.', 0),
  ('Formulación de opiniones simples con justificación', 'Formular opiniones simples sobre un tema, entregando una razón breve.', 1),
  ('Participación en conversaciones sobre planes futuros', 'Participar en conversaciones breves sobre planes e intenciones futuras.', 2),
  ('Uso de conectores simples en el discurso oral', 'Usar conectores simples (and, but, because) para organizar ideas al hablar.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 7° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Escrita.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Escritura de un texto narrativo breve', 'Escribir un texto narrativo breve sobre una experiencia personal, usando el pasado simple.', 0),
  ('Uso de conectores para dar cohesión al texto', 'Usar conectores de secuencia y causa para dar cohesión a un texto escrito.', 1),
  ('Redacción de un correo o mensaje informal', 'Redactar un correo o mensaje informal siguiendo un modelo dado.', 2),
  ('Aplicación de reglas ortográficas básicas del inglés', 'Aplicar reglas ortográficas básicas del inglés en la escritura de palabras frecuentes.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 8° BÁSICO (order_index de nivel = 108)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 8° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Auditiva.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2-B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de instrucciones y explicaciones más extensas', 'Comprender instrucciones y explicaciones orales más extensas sobre temas conocidos.', 0),
  ('Identificación de la idea principal y detalles de apoyo', 'Identificar la idea principal y detalles de apoyo en un texto oral.', 1),
  ('Comprensión de diálogos con distintos puntos de vista', 'Comprender diálogos en los que se presentan distintos puntos de vista sobre un tema.', 2),
  ('Reconocimiento de vocabulario de interés juvenil', 'Reconocer vocabulario relacionado con temas de interés juvenil: tecnología, deportes, medio ambiente.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 8° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Lectora.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2-B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de textos informativos breves', 'Comprender textos informativos breves sobre temas de interés juvenil.', 0),
  ('Distinción entre hechos y opiniones en un texto', 'Distinguir hechos de opiniones en un texto simple en inglés.', 1),
  ('Identificación de la estructura de un texto', 'Identificar la estructura de un texto (introducción, desarrollo, cierre) en textos simples.', 2),
  ('Uso del diccionario y contexto para ampliar vocabulario', 'Usar el diccionario y el contexto para ampliar el vocabulario propio.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 8° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2-B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Exposición oral breve sobre un tema conocido', 'Realizar una exposición oral breve sobre un tema conocido, con apoyo visual.', 0),
  ('Comparación oral de ideas o situaciones', 'Comparar oralmente dos ideas, objetos o situaciones usando comparativos y superlativos.', 1),
  ('Expresión de acuerdo y desacuerdo', 'Expresar acuerdo y desacuerdo de manera respetuosa en una conversación.', 2),
  ('Uso de un registro adecuado a la situación', 'Adecuar el registro (formal/informal) según la situación comunicativa.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 8° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Escrita.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A2-B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Redacción de un texto informativo breve', 'Redactar un texto informativo breve sobre un tema conocido.', 0),
  ('Uso de comparativos y superlativos en la escritura', 'Usar comparativos y superlativos al escribir sobre personas, objetos o lugares.', 1),
  ('Planificación previa a la escritura de un texto', 'Planificar un texto antes de escribirlo, organizando las ideas principales.', 2),
  ('Revisión y corrección de un texto propio', 'Revisar y corregir un texto propio, prestando atención a la gramática y el vocabulario.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 1° MEDIO (order_index de nivel = 109)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 1° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Auditiva.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de discursos orales sobre temas variados', 'Comprender discursos orales de mayor extensión sobre temas variados y de actualidad.', 0),
  ('Inferencia del propósito y la audiencia de un mensaje oral', 'Inferir el propósito y la audiencia de un mensaje oral.', 1),
  ('Identificación de argumentos en un discurso oral', 'Identificar los argumentos principales presentados en un discurso oral.', 2),
  ('Comprensión de entrevistas o conversaciones formales', 'Comprender entrevistas o conversaciones en un registro más formal.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 1° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Lectora.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de textos informativos y argumentativos', 'Comprender textos informativos y argumentativos de complejidad creciente.', 0),
  ('Identificación de la tesis y los argumentos de un texto', 'Identificar la tesis y los argumentos que la sustentan en un texto.', 1),
  ('Interpretación de vocabulario en contexto académico', 'Interpretar el significado de palabras y expresiones en un contexto académico o técnico simple.', 2),
  ('Evaluación de la confiabilidad de una fuente escrita', 'Evaluar de manera inicial la confiabilidad de una fuente escrita en inglés.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 1° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Presentación oral organizada sobre un tema de interés', 'Realizar una presentación oral organizada (introducción, desarrollo, cierre) sobre un tema de interés.', 0),
  ('Argumentación oral de una postura personal', 'Argumentar oralmente una postura personal sobre un tema, con al menos dos razones.', 1),
  ('Participación en discusiones grupales', 'Participar en discusiones grupales, respetando los turnos de habla y las opiniones de otros.', 2),
  ('Uso de vocabulario más variado y preciso', 'Usar vocabulario más variado y preciso al expresarse oralmente sobre temas conocidos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 1° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Escrita.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Redacción de un texto argumentativo simple', 'Redactar un texto argumentativo simple, presentando una postura y razones que la apoyan.', 0),
  ('Uso de conectores de contraste y consecuencia', 'Usar conectores de contraste y consecuencia para dar cohesión a un texto escrito.', 1),
  ('Aplicación de un proceso de escritura con planificación y revisión', 'Aplicar un proceso de escritura que incluya planificación, borrador y revisión.', 2),
  ('Adecuación del registro escrito a la situación comunicativa', 'Adecuar el registro de un texto escrito (formal/informal) a la situación comunicativa.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° MEDIO (order_index de nivel = 110)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 2° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Auditiva.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión crítica de discursos sobre temas sociales', 'Comprender críticamente discursos orales sobre temas sociales o culturales.', 0),
  ('Identificación de la postura del hablante frente a un tema', 'Identificar la postura del hablante frente a un tema controversial.', 1),
  ('Comprensión de textos orales con vocabulario técnico simple', 'Comprender textos orales que incluyen vocabulario técnico simple relacionado con un área de interés.', 2),
  ('Toma de notas a partir de un texto oral', 'Tomar notas a partir de un texto oral para apoyar la comprensión y el registro de información.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 2° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Lectora.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de textos argumentativos de mediana extensión', 'Comprender textos argumentativos de mediana extensión sobre temas sociales o culturales.', 0),
  ('Análisis de la estructura argumentativa de un texto', 'Analizar la estructura argumentativa (tesis, argumentos, conclusión) de un texto.', 1),
  ('Comparación de puntos de vista en distintos textos', 'Comparar los puntos de vista presentados en dos o más textos sobre un mismo tema.', 2),
  ('Ampliación de vocabulario académico', 'Ampliar el vocabulario académico a partir de la lectura de textos de mayor complejidad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 2° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Debate formal sobre un tema de relevancia social', 'Participar en un debate formal sobre un tema de relevancia social, defendiendo una postura.', 0),
  ('Uso de recursos persuasivos en el discurso oral', 'Usar recursos persuasivos simples al presentar una postura oralmente.', 1),
  ('Análisis oral crítico de un texto o discurso', 'Analizar oralmente, de manera crítica, un texto o discurso escuchado o leído.', 2),
  ('Adecuación del discurso oral a distintas audiencias', 'Adecuar el discurso oral a distintas audiencias y contextos comunicativos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 2° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Escrita.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Redacción de un ensayo argumentativo breve', 'Redactar un ensayo argumentativo breve sobre un tema social o cultural.', 0),
  ('Uso de evidencia y ejemplos para sustentar una idea', 'Usar evidencia y ejemplos concretos para sustentar una idea en un texto escrito.', 1),
  ('Revisión de un texto propio a partir de criterios explícitos', 'Revisar un texto propio aplicando criterios explícitos de calidad: coherencia, cohesión, gramática.', 2),
  ('Escritura de un texto con estructura formal', 'Escribir un texto con estructura formal (introducción, desarrollo, conclusión) sobre un tema dado.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
