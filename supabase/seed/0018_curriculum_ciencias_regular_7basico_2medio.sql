-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Ciencias Naturales, 7° Básico a 2° Medio.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA
-- ============================================================================
-- Fuente citada: Bases Curriculares de 7° Básico a 2° Medio, MINEDUC,
-- aprobadas por el Decreto Supremo N.° 614 de 2013. Implementación progresiva
-- 2015-2019 según el propio decreto (por curso). Mismo decreto ya usado para
-- Matemática (supabase/seed/0012) y Lenguaje (supabase/seed/0015).
--
-- Confianza en que los 3 EJES DE CONTENIDO de esta banda mantienen los
-- mismos nombres que 1°-6° Básico ("Ciencias de la Vida", "Ciencias Físicas
-- y Químicas", "Ciencias de la Tierra y el Universo"): MEDIA. A diferencia de
-- Matemática (donde "Medición" y "Datos y Probabilidades" del tramo 1°-6°
-- Básico sí cambian de nombre en 7° Básico-2° Medio, ver supabase/seed/0012),
-- este agente no tiene evidencia concreta de un cambio de nomenclatura de
-- ejes para Ciencias Naturales entre ambos decretos (439/2012 y 614/2013) --
-- se asume continuidad de nombre como hipótesis razonable, no como dato
-- verificado línea por línea. Por eso se REUTILIZAN los 3 ejes de contenido
-- creados en supabase/seed/0017, sin crear filas nuevas.
--
-- Confianza en la progresión general de contenidos por curso (sistemas del
-- cuerpo humano más complejos, genética introductoria, modelo atómico,
-- geología, cambio climático): MEDIA-ALTA, reforzada porque ValidApp ya
-- cargó un temario EPJA real para "Primer y Segundo Nivel Medio" (D.S.
-- 257/2009, no 614/2013) que confirma varios de estos objetivos con texto
-- oficial verbatim para el tramo de Media (ver supabase/seed/0007).
--
-- Se mantiene la misma decisión de modelado documentada en el encabezado de
-- supabase/seed/0017 sobre "Habilidades de Investigación Científica" como
-- 4ª fila de `strands` (no un eje oficial de contenido, sino una categoría
-- transversal de OAH modelada así por limitación del esquema, documentada
-- explícitamente). Se reutiliza la misma fila, sin crearla de nuevo.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL de cada Objetivo de
-- Aprendizaje de ESTE decreto (614/2013): BAJA -- no hay PDF de esta fuente
-- específica cargado ni verificado en este entorno. Por eso, igual que en
-- supabase/seed/0017:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - Todas las filas quedan `status = 'borrador'`.
--   - `pedagogical_notes` repite la advertencia en cada objetivo.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes x 4 cursos (7° Básico, 8° Básico, 1° Medio, 2° Medio) = 16
-- combinaciones eje-curso, cada una con 1 unidad. "Ciencias de la Vida" y
-- "Ciencias Físicas y Químicas" llevan 4 objetivos por curso; "Ciencias de la
-- Tierra y el Universo" y "Habilidades de Investigación Científica" llevan
-- 3. Representativos, NO exhaustivos.
--
-- No cubre: banco de preguntas, lecciones, ensayos, catálogo de habilidades
-- (`skills`), actitudes (OAA), Grandes ideas ni Conocimientos esenciales.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects
-- ============================================================================
-- Mismo motivo documentado en 0011/0012/0014/0015/0017: `exam_period` NOT
-- NULL en `curriculum_frameworks` modela el problema específico de EPJA, no
-- el Currículum Regular.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0017. `subjects`/`strands`/`units` reutilizan filas
-- existentes vía `on conflict do nothing`; `learning_objectives` usa `on
-- conflict do update` limitado a las columnas propias de este archivo.
-- `level_id` por `levels.code`, `subject_id` por `subjects.name`. Seed SOLO
-- local: no se ha ejecutado contra Supabase.

-- ============================================================================
-- 1) Asignatura (reutiliza "Ciencias Naturales")
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Ciencias Naturales', 'natural_sciences')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- Los 4 ejes de esta banda ("Ciencias de la Vida", "Ciencias Físicas y
-- Químicas", "Ciencias de la Tierra y el Universo", "Habilidades de
-- Investigación Científica") ya existen en el esquema (creados por
-- supabase/seed/0017). Se reutilizan sin modificar -- no se inserta ningún
-- eje nuevo en este archivo (ver nota de confianza MEDIA en el encabezado
-- sobre esta continuidad de nombres).

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 7° BÁSICO (order_index de nivel = 107)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 7° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Vida.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Sistemas del cuerpo humano relacionados con la nutrición', 'Describir los sistemas digestivo, respiratorio, circulatorio y excretor, y su rol en el proceso de nutrición.', 0),
  ('Dieta equilibrada', 'Evaluar el concepto de dieta equilibrada aplicado a distintas situaciones nutricionales.', 1),
  ('Relaciones entre población, comunidad y ecosistema', 'Describir los conceptos de población, comunidad y ecosistema, y su relación con la biodiversidad.', 2),
  ('Efectos de la interdependencia de los seres vivos', 'Analizar los efectos de la interdependencia de los seres vivos en el equilibrio de un ecosistema.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 7° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Movimientos rectilíneos y circulares', 'Describir movimientos rectilíneos y circulares de acuerdo con sus componentes (rapidez, dirección).', 0),
  ('Tipos de mezclas y métodos de separación', 'Clasificar tipos de mezclas y aplicar métodos adecuados para su separación.', 1),
  ('Concepto de concentración de una disolución', 'Describir el concepto de concentración de una disolución en términos de soluto y solvente.', 2),
  ('Ondas sonoras y luminosas', 'Explicar el origen y la propagación de las ondas sonoras y luminosas y sus aplicaciones prácticas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 7° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Capas de la Tierra y placas tectónicas', 'Describir las capas de la Tierra y relacionarlas con el movimiento de placas tectónicas.', 0),
  ('Clasificación de recursos naturales', 'Clasificar recursos naturales según su origen y su capacidad de renovación.', 1),
  ('Riesgos geológicos y prevención', 'Describir riesgos geológicos comunes en Chile (sismos, volcanes) y medidas de prevención.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 7° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de supabase/seed/0017).',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Diseño de una investigación controlando variables', 'Diseñar una investigación científica identificando la variable independiente, dependiente y las que se deben controlar.', 0),
  ('Análisis de datos de una investigación', 'Analizar datos obtenidos en una investigación, identificando tendencias o patrones simples.', 1),
  ('Comunicación de resultados mediante informes simples', 'Comunicar los resultados de una investigación mediante un informe simple con evidencia y conclusiones.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 8° BÁSICO (order_index de nivel = 108)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 8° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Vida.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Sistemas óseo y muscular relacionados con el movimiento', 'Describir la función de los sistemas óseo y muscular en el movimiento del cuerpo humano.', 0),
  ('Pubertad y sistema reproductor', 'Describir los cambios de la pubertad y la función del sistema reproductor femenino y masculino.', 1),
  ('Prevención de infecciones de transmisión sexual', 'Reconocer métodos de prevención de infecciones de transmisión sexual y su importancia para la salud.', 2),
  ('Modelo corpuscular de la materia y niveles de organización de la vida', 'Relacionar el modelo corpuscular de la materia con los niveles de organización de los seres vivos (célula, tejido, órgano).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 8° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Fuerza neta y equilibrio', 'Determinar la fuerza neta que actúa sobre un objeto y su relación con el estado de equilibrio o movimiento.', 0),
  ('Presión en fluidos', 'Describir el concepto de presión en fluidos y su relación con la profundidad y la densidad.', 1),
  ('Elementos, compuestos y mezclas', 'Distinguir entre elementos, compuestos y mezclas a partir de sus propiedades.', 2),
  ('Modelo atómico simple', 'Describir un modelo simple de la estructura del átomo (núcleo, electrones).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 8° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('El universo, galaxias y el Sistema Solar', 'Describir el universo, las galaxias y la posición del Sistema Solar dentro de la Vía Láctea.', 0),
  ('Origen del universo', 'Reconocer, a nivel introductorio, teorías sobre el origen del universo.', 1),
  ('Herramientas tecnológicas para la observación astronómica', 'Describir el aporte de herramientas tecnológicas (telescopios, satélites) para la observación astronómica.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 8° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de supabase/seed/0017).',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Formulación de hipótesis contrastables', 'Formular hipótesis contrastables a partir de una pregunta de investigación.', 0),
  ('Diseño de procedimientos experimentales', 'Diseñar procedimientos experimentales para poner a prueba una hipótesis.', 1),
  ('Evaluación de la evidencia obtenida', 'Evaluar si la evidencia obtenida en una investigación apoya o refuta la hipótesis planteada.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 1° MEDIO (order_index de nivel = 109)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 1° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Vida.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Primer Nivel Medio" (ver supabase/seed/0007), aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Sistemas nervioso y endocrino y homeostasis', 'Explicar la función de los sistemas nervioso y endocrino y su relación con la homeostasis del organismo.', 0),
  ('La célula y sus organelos', 'Describir la célula y la función de sus principales organelos.', 1),
  ('Composición química de la célula', 'Describir la composición química de la célula, distinguiendo moléculas orgánicas e inorgánicas.', 2),
  ('Transmisión de la información genética a nivel introductorio', 'Reconocer, a nivel introductorio, cómo se transmite la información genética entre generaciones.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 1° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Primer Nivel Medio" (ver supabase/seed/0007), aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ondas y sus características', 'Describir las características de las ondas (longitud de onda, frecuencia, amplitud) y su propagación.', 0),
  ('Electricidad y magnetismo básico', 'Describir conceptos básicos de electricidad y magnetismo (carga, corriente, campo magnético) y su relación.', 1),
  ('Tabla periódica y organización de los elementos', 'Describir la organización de los elementos en la Tabla Periódica según sus propiedades.', 2),
  ('Modelos atómicos', 'Reconocer distintos modelos atómicos y los conceptos asociados a su evolución histórica.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 1° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Primer Nivel Medio" (ver supabase/seed/0007), aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Formación de rocas y ciclo de las rocas', 'Describir el ciclo de las rocas y los procesos que dan origen a rocas ígneas, sedimentarias y metamórficas.', 0),
  ('Cambio climático y actividad humana', 'Explicar la relación entre el cambio climático y la actividad humana, con evidencia científica.', 1),
  ('Recursos hídricos y su distribución', 'Describir la distribución de los recursos hídricos y su importancia para los ecosistemas y la sociedad.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 1° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de supabase/seed/0017).',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Elaboración de informes de investigación', 'Elaborar informes de investigación científica que incluyan pregunta, procedimiento, resultados y conclusiones.', 0),
  ('Evaluación de la validez de fuentes de información', 'Evaluar la validez y confiabilidad de fuentes de información científica.', 1),
  ('Uso de modelos para explicar fenómenos', 'Usar modelos científicos simples para explicar fenómenos naturales.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° MEDIO (order_index de nivel = 110)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 2° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Vida.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Segundo Nivel Medio" (ver supabase/seed/0007), aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Información genética, cromosomas y ciclo celular', 'Describir la información genética, considerando cromosoma, gen, ADN, mitosis y meiosis.', 0),
  ('Leyes de Mendel a nivel introductorio', 'Aplicar principios básicos de las leyes de Mendel para explicar patrones simples de herencia.', 1),
  ('Evolución de las especies', 'Reconocer teorías y evidencias sobre la evolución de las especies.', 2),
  ('Sistema inmunológico', 'Describir los principales procesos vitales del sistema inmunológico.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 2° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Segundo Nivel Medio" (ver supabase/seed/0007), aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Energía y sus transformaciones', 'Analizar situaciones cotidianas en las que la energía se transforma de una forma a otra, aplicando el principio de conservación.', 0),
  ('Tipos de enlaces químicos', 'Describir distintos tipos de enlaces químicos a partir de la organización de los electrones.', 1),
  ('Reacciones de óxido-reducción', 'Clasificar reacciones de óxido-reducción en situaciones cotidianas y biológicas.', 2),
  ('Fenómenos radiactivos', 'Explicar situaciones que involucren fenómenos radiactivos, sus riesgos y su impacto ambiental.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 2° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Recursos energéticos y uso sustentable', 'Analizar el uso sustentable de distintos recursos energéticos, considerando su impacto ambiental.', 0),
  ('Fenómenos atmosféricos y el clima', 'Describir fenómenos atmosféricos y su relación con el clima de una región.', 1),
  ('Impacto de la actividad humana en la atmósfera', 'Analizar el impacto de la actividad humana en la composición de la atmósfera y el clima global.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 2° Medio', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de supabase/seed/0017).',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Diseño de una investigación científica completa', 'Diseñar y llevar a cabo una investigación científica completa para responder una pregunta de interés.', 0),
  ('Comunicación de resultados con lenguaje científico', 'Comunicar los resultados de una investigación usando lenguaje científico y evidencia cuantitativa.', 1),
  ('Análisis crítico de investigaciones científicas publicadas', 'Analizar de forma crítica investigaciones científicas publicadas, evaluando sus métodos y conclusiones.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
