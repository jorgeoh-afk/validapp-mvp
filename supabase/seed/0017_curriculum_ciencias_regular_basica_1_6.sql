-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Ciencias Naturales, 1° a 6° Básico.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA (léase antes de aprobar cualquier fila)
-- ============================================================================
-- Fuente citada: Bases Curriculares de Educación Básica, MINEDUC, aprobadas
-- por el Decreto Supremo N.° 439 de 2012 (1° a 6° Básico, asignatura Ciencias
-- Naturales). Vigencia progresiva desde 2013. Mismo decreto ya usado para
-- Matemática (supabase/seed/0011) y Lenguaje (supabase/seed/0014).
--
-- Confianza en los 3 EJES TEMÁTICOS OFICIALES declarados por el propio
-- MINEDUC para esta asignatura y banda ("Ciencias de la Vida", "Ciencias
-- Físicas y Químicas", "Ciencias de la Tierra y el Universo"): MEDIA-ALTA.
-- Es la organización ampliamente documentada y estable de la asignatura.
--
-- ============================================================================
-- DECISIÓN DE MODELADO — "Habilidades de Investigación Científica" como
-- 4° fila de `strands`
-- ============================================================================
-- Las Bases Curriculares de Ciencias Naturales NO declaran "Habilidades de
-- Investigación Científica" como un cuarto eje temático de contenido al
-- mismo nivel que los 3 anteriores: lo tratan como una categoría transversal
-- de Objetivos de Aprendizaje de Habilidad (OAH), aplicable en principio a
-- las tres unidades/ejes de cada curso, no como un bloque de contenido
-- propio y autocontenido. El esquema de ValidApp (subjects > strands > units
-- > learning_objectives), sin embargo, no tiene una forma de etiquetar un OA
-- como "transversal a varios ejes" sin una tabla puente adicional (fuera de
-- alcance de esta tarea, que es solo de contenido). Por eso, como decisión
-- de modelado EXPLÍCITA y documentada (no una simplificación silenciosa), se
-- crea una 4ª fila en `strands` llamada "Habilidades de Investigación
-- Científica" para poder cargar objetivos representativos de esta categoría
-- (observar, formular preguntas, experimentar, registrar, comunicar
-- resultados) sin forzarlos dentro de uno de los 3 ejes de contenido. Esta
-- fila NO debe confundirse con la tabla `skills` (catálogo de habilidades
-- cognitivas transversal a todas las asignaturas, fuera de alcance de esta
-- tarea): aquí se trata de objetivos de aprendizaje curriculares específicos
-- de indagación científica, con su propio texto y progresión por curso, tal
-- como los declara el temario oficial (aunque agrupados de otra forma).
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL de cada Objetivo de
-- Aprendizaje (código "OA n" tal como aparece en el PDF de Bases
-- Curriculares): BAJA. Este agente no tiene acceso a herramientas de
-- navegación web ni al PDF oficial en este entorno. Cada `short_name`/
-- `description` es una PARÁFRASIS de ValidApp basada en conocimiento general
-- del currículo chileno de Ciencias Naturales, no una cita literal. Por eso:
--   - `official_text` se deja NULL en todas las filas.
--   - `code` (código OA oficial) se deja NULL en todas las filas.
--   - TODAS las filas quedan en `status = 'borrador'` (nunca 'aprobado').
--   - `pedagogical_notes` repite esta advertencia en cada objetivo.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: los 4 ejes (3 de contenido + 1 de habilidades, ver decisión de
-- modelado arriba) x 6 cursos (1° a 6° Básico) = 24 combinaciones eje-curso,
-- cada una con 1 unidad. "Ciencias de la Vida" y "Ciencias Físicas y
-- Químicas" llevan 4 objetivos por curso (mayor peso relativo de contenido);
-- "Ciencias de la Tierra y el Universo" y "Habilidades de Investigación
-- Científica" llevan 3. Representativos, NO exhaustivos.
--
-- No cubre: banco de preguntas, lecciones, ensayos, catálogo de habilidades
-- (`skills`/`learning_objective_skills`) ni actitudes (OAA). Tampoco "Grandes
-- ideas" ni "Conocimientos esenciales" (0014): quedan pendientes.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects
-- ============================================================================
-- Mismo motivo documentado en 0011/0012/0014/0015: `exam_period` NOT NULL en
-- `curriculum_frameworks` modela el problema específico de EPJA (varios
-- decretos por período de examinación), no el Currículum Regular. Se usa
-- `curricular_source`/`reference_year`/`pedagogical_notes` en
-- `learning_objectives`.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- `subjects.name` ya tiene restricción única (reutiliza "Ciencias Naturales",
-- creada por supabase/seed/0002_epja_remaining_subjects.sql con
-- canonical_code = 'natural_sciences' — no se modifica). `strands (subject_id,
-- name)` y `units (strand_id, name)` tienen restricción única (0010), así que
-- sus INSERT usan `on conflict ... do nothing` (catálogo compartido, no se
-- pisa contenido ya editado por un administrador). `learning_objectives
-- (unit_id, level_id, short_name)` tiene restricción única (0021), así que su
-- INSERT usa `on conflict ... do update` solo sobre las columnas propias de
-- este archivo. Seguro de correr más de una vez. `level_id` se resuelve
-- siempre por `levels.code`, `subject_id` por `subjects.name`.
--
-- Seed SOLO local: NO se ha ejecutado contra ningún proyecto Supabase (ni
-- dev ni producción). No modifica Supabase por sí solo.

-- ============================================================================
-- 1) Asignatura: reutiliza "Ciencias Naturales" (creada por EPJA)
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Ciencias Naturales', 'natural_sciences')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- Los 4 ejes de este archivo son nuevos en el esquema: EPJA creó "Ciencias
-- Biológicas", "Ciencias Físicas" y "Ciencias Químicas" (nombres propios del
-- temario D.S. 257/2009, ver supabase/seed/0007), distintos de los nombres
-- oficiales de esta banda del Currículum Regular. No se reutilizan esas 3
-- filas EPJA -- se crean 4 filas nuevas con los nombres oficiales de Básica.
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias Naturales'),
   'Ciencias de la Vida', 'Los seres vivos, sus características, funciones vitales, relaciones ecológicas y salud.', 0)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias Naturales'),
   'Ciencias Físicas y Químicas', 'Propiedades de la materia, energía, fuerzas, ondas y sus transformaciones.', 1)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias Naturales'),
   'Ciencias de la Tierra y el Universo', 'La Tierra, su dinámica, los recursos naturales, el sistema solar y el universo.', 2)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Ciencias Naturales'),
   'Habilidades de Investigación Científica', 'Observación, formulación de preguntas, experimentación, registro y comunicación de resultados científicos (ver nota de modelado en el encabezado de este archivo).', 3)
on conflict (subject_id, name) do nothing;

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================
-- Constantes repetidas por fila (ver encabezado): `status = 'borrador'`,
-- `curricular_source` cita el decreto, `reference_year = 2012`,
-- `pedagogical_notes` advierte que el texto es paráfrasis ValidApp pendiente
-- de verificación.

-- ---------------------------------------------------------------------
-- 1° BÁSICO (order_index de nivel = 101)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 1° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Vida.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Características de los seres vivos', 'Reconocer y describir características que diferencian a los seres vivos de los objetos no vivos.', 0),
  ('Necesidades básicas de plantas y animales', 'Identificar las necesidades básicas de las plantas y los animales (agua, luz, aire, alimento) para vivir y crecer.', 1),
  ('Partes del cuerpo humano y sus funciones', 'Reconocer las partes externas del cuerpo humano y describir de manera simple su función.', 2),
  ('Hábitos de higiene y vida saludable', 'Identificar y practicar hábitos de higiene y vida saludable en su rutina diaria.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 1° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Propiedades de los materiales', 'Observar y describir propiedades de materiales de uso cotidiano (color, textura, flexibilidad, dureza).', 0),
  ('Estados sólido y líquido de la materia', 'Distinguir entre el estado sólido y líquido de un material a partir de sus propiedades observables.', 1),
  ('Fuentes de luz y de sonido', 'Reconocer distintas fuentes de luz y de sonido presentes en el entorno cotidiano.', 2),
  ('Efecto de la luz sobre los objetos', 'Explorar el efecto de la luz sobre distintos objetos (opacos, translúcidos, transparentes).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 1° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('El día y la noche', 'Describir el ciclo del día y la noche y relacionarlo con la presencia o ausencia de luz solar.', 0),
  ('El Sol como fuente de luz y calor', 'Reconocer al Sol como fuente de luz y calor, e identificar su efecto en la vida cotidiana.', 1),
  ('Cambios del entorno según la estación del año', 'Observar y describir cambios en el entorno (clima, plantas, vestimenta) asociados a las estaciones del año.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 1° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de este archivo).',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Observación guiada del entorno', 'Observar, con ayuda del docente, objetos y fenómenos simples del entorno natural.', 0),
  ('Descripción oral de observaciones', 'Describir de manera oral lo observado durante una actividad exploratoria simple.', 1),
  ('Registro de observaciones en dibujos', 'Registrar observaciones simples mediante dibujos y símbolos.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° BÁSICO (order_index de nivel = 102)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 2° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Vida.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ciclo de vida de animales ovíparos y vivíparos', 'Describir el ciclo de vida de animales ovíparos y vivíparos, comparando sus semejanzas y diferencias.', 0),
  ('Adaptaciones simples de los seres vivos al entorno', 'Reconocer adaptaciones simples que permiten a plantas y animales sobrevivir en su hábitat.', 1),
  ('Plantas nativas y su hábitat en Chile', 'Identificar plantas nativas de Chile y describir el hábitat en el que crecen.', 2),
  ('Alimentación saludable', 'Clasificar alimentos según su origen y explicar la importancia de una alimentación saludable y variada.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 2° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Fuerzas y su efecto sobre el movimiento', 'Describir el efecto de una fuerza al empujar o tirar un objeto sobre su movimiento.', 0),
  ('Mezclas simples de materiales', 'Explorar y describir mezclas simples de materiales sólidos y líquidos de uso cotidiano.', 1),
  ('Magnetismo básico', 'Explorar el efecto de un imán sobre distintos materiales, clasificándolos según si son o no atraídos.', 2),
  ('Formas de energía en la vida cotidiana', 'Identificar formas de energía presentes en situaciones cotidianas (luz, calor, movimiento, sonido).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 2° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Fases de la Luna', 'Observar y describir las fases de la Luna a lo largo de un mes.', 0),
  ('El clima y su variación durante el año', 'Describir el clima de su localidad y cómo varía a lo largo del año.', 1),
  ('Tipos de suelo', 'Comparar distintos tipos de suelo según su color, textura y capacidad de retener agua.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 2° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de este archivo).',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Predicción simple antes de observar', 'Predecir de manera simple qué podría ocurrir antes de realizar una observación o actividad exploratoria.', 0),
  ('Uso de instrumentos simples de medición', 'Usar instrumentos simples (regla, lupa) para explorar objetos y fenómenos del entorno.', 1),
  ('Comunicación de resultados de una actividad exploratoria', 'Comunicar de forma oral o mediante dibujos los resultados de una actividad exploratoria simple.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 3° BÁSICO (order_index de nivel = 103)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 3° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Vida.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Clasificación de seres vivos según características observables', 'Clasificar animales y plantas según características observables (cubierta corporal, tipo de hojas, entre otras).', 0),
  ('Funciones vitales de los seres vivos', 'Describir las funciones vitales de nutrición, respiración y reproducción en distintos seres vivos.', 1),
  ('Componentes bióticos y abióticos de un ecosistema', 'Identificar los componentes bióticos y abióticos de un ecosistema cercano.', 2),
  ('Relaciones entre los seres vivos y su ambiente', 'Describir relaciones simples entre los seres vivos y su ambiente en un ecosistema.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 3° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('La luz y sus efectos', 'Explorar y describir efectos de la luz sobre distintos materiales (sombras, reflexión).', 0),
  ('Formas de energía y sus fuentes', 'Reconocer distintas formas de energía y sus fuentes en situaciones cotidianas.', 1),
  ('La fuerza de gravedad', 'Describir el efecto de la fuerza de gravedad sobre los objetos.', 2),
  ('Cambios producidos por la aplicación de una fuerza', 'Explorar cambios en la forma o el movimiento de un objeto al aplicar una fuerza.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 3° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('El Sistema Solar', 'Describir el Sistema Solar y los principales cuerpos celestes que lo componen.', 0),
  ('Recursos naturales renovables y no renovables', 'Distinguir entre recursos naturales renovables y no renovables, con ejemplos del entorno.', 1),
  ('Uso responsable de los recursos naturales', 'Proponer acciones simples para el uso responsable de los recursos naturales en la vida diaria.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 3° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de este archivo).',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Formulación de preguntas investigables', 'Formular preguntas simples que puedan responderse mediante una observación o un experimento sencillo.', 0),
  ('Planificación de una investigación sencilla', 'Planificar, con ayuda del docente, los pasos de una investigación experimental sencilla.', 1),
  ('Análisis de resultados de un experimento sencillo', 'Analizar de manera simple los resultados obtenidos en un experimento y compararlos con lo esperado.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° BÁSICO (order_index de nivel = 104)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 4° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Vida.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Sistema esquelético y muscular', 'Describir la función del sistema esquelético y muscular en el movimiento del cuerpo humano.', 0),
  ('Sistema nervioso y órganos de los sentidos', 'Reconocer la función del sistema nervioso en la relación entre los órganos de los sentidos y el cuerpo.', 1),
  ('Cadenas alimentarias simples', 'Representar cadenas alimentarias simples de un ecosistema, identificando productores, consumidores y descomponedores.', 2),
  ('Función de la raíz, el tallo y la hoja en las plantas', 'Explicar la función de la raíz, el tallo y la hoja en el proceso de nutrición de las plantas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 4° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Circuitos eléctricos simples', 'Construir y describir circuitos eléctricos simples, identificando sus componentes básicos.', 0),
  ('Transformación de la energía', 'Reconocer que la energía se transforma de una forma a otra en distintos artefactos de uso cotidiano.', 1),
  ('El sonido y sus características', 'Describir cómo se produce el sonido y reconocer características como el volumen y el tono.', 2),
  ('Conductores y aislantes de electricidad', 'Clasificar materiales de uso cotidiano según si son conductores o aislantes de electricidad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 4° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Capas de la Tierra', 'Describir de manera simple las principales capas que componen la Tierra.', 0),
  ('El ciclo del agua', 'Explicar el ciclo del agua identificando sus principales etapas (evaporación, condensación, precipitación).', 1),
  ('Fenómenos naturales de la Tierra', 'Describir fenómenos naturales como erupciones volcánicas y terremotos, y su efecto en el entorno.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 4° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de este archivo).',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Control de variables en un experimento simple', 'Identificar variables simples que se deben mantener constantes al realizar un experimento.', 0),
  ('Registro de datos en tablas y gráficos simples', 'Registrar datos obtenidos en una investigación en tablas y gráficos simples de barra.', 1),
  ('Comparación de resultados con predicciones', 'Comparar los resultados obtenidos en una investigación con la predicción inicial realizada.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 5° BÁSICO (order_index de nivel = 105)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 5° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Vida.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Sistema digestivo y su relación con la nutrición', 'Describir la función de los principales órganos del sistema digestivo en el proceso de nutrición.', 0),
  ('Microorganismos y su efecto en la salud', 'Reconocer la existencia de microorganismos y describir su efecto beneficioso o perjudicial en la salud.', 1),
  ('La fotosíntesis como proceso vital de las plantas', 'Explicar de manera simple el proceso de fotosíntesis y su importancia para los seres vivos.', 2),
  ('Biodiversidad de Chile', 'Describir ejemplos de biodiversidad de distintas zonas de Chile y su importancia para el ecosistema.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 5° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Cambios de estado de la materia', 'Describir cambios de estado de la materia (fusión, evaporación, condensación, solidificación) en situaciones cotidianas.', 0),
  ('Mezclas y soluciones', 'Distinguir entre mezclas y soluciones, identificando ejemplos de la vida cotidiana.', 1),
  ('Máquinas simples y su función', 'Describir la función de máquinas simples (palanca, polea, plano inclinado) en tareas cotidianas.', 2),
  ('Métodos de separación de mezclas', 'Aplicar métodos simples de separación de mezclas (filtración, tamizado, decantación).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 5° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Capas de la atmósfera', 'Describir de manera simple las capas de la atmósfera y su importancia para la vida en la Tierra.', 0),
  ('Movimientos de rotación y traslación de la Tierra', 'Relacionar el movimiento de rotación de la Tierra con el día y la noche, y el de traslación con las estaciones del año.', 1),
  ('El aire y sus propiedades', 'Describir propiedades del aire y su importancia para los seres vivos y los fenómenos atmosféricos.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 5° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de este archivo).',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Diseño de un procedimiento experimental con variables controladas', 'Diseñar, con apoyo del docente, un procedimiento experimental que controle al menos una variable.', 0),
  ('Interpretación de tablas y gráficos de resultados', 'Interpretar tablas y gráficos que muestran los resultados de una investigación científica.', 1),
  ('Formulación de conclusiones simples', 'Formular conclusiones simples a partir de los resultados obtenidos en una investigación.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 6° BÁSICO (order_index de nivel = 106)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Vida — 6° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Vida, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Vida'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Vida.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Sistemas respiratorio y circulatorio', 'Describir la función de los sistemas respiratorio y circulatorio y la relación entre ambos.', 0),
  ('Cambios de la pubertad', 'Reconocer los principales cambios físicos y emocionales que ocurren durante la pubertad.', 1),
  ('Cadenas y redes tróficas en un ecosistema', 'Representar cadenas y redes tróficas de un ecosistema, describiendo el flujo de materia y energía.', 2),
  ('Efectos de la actividad humana en un ecosistema', 'Analizar efectos de la actividad humana sobre el equilibrio de un ecosistema local.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Vida') and name = 'Ciencias de la Vida — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias Físicas y Químicas — 6° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias Físicas y Químicas, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias Físicas y Químicas'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias Físicas y Químicas.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Transferencia de calor', 'Describir cómo se transfiere el calor entre objetos a distinta temperatura.', 0),
  ('Propiedades de la materia: masa y volumen', 'Medir y comparar la masa y el volumen de distintos objetos y materiales.', 1),
  ('Reacciones químicas simples de la vida cotidiana', 'Reconocer ejemplos de reacciones químicas simples de la vida cotidiana, como la combustión y la oxidación.', 2),
  ('Uso responsable de la energía', 'Proponer acciones para el uso responsable de fuentes de energía en el hogar y la escuela.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias Físicas y Químicas') and name = 'Ciencias Físicas y Químicas — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Ciencias de la Tierra y el Universo — 6° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Ciencias de la Tierra y el Universo, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Ciencias de la Tierra y el Universo'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Ciencias de la Tierra y el Universo.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Capas internas de la Tierra y placas tectónicas', 'Relacionar las capas internas de la Tierra con fenómenos como los volcanes y los terremotos.', 0),
  ('El universo y los cuerpos celestes', 'Describir el universo y sus principales cuerpos celestes (estrellas, galaxias, planetas).', 1),
  ('Recursos energéticos y su impacto ambiental', 'Comparar distintos recursos energéticos según su origen y su impacto en el medioambiente.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Ciencias de la Tierra y el Universo') and name = 'Ciencias de la Tierra y el Universo — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Habilidades de Investigación Científica — 6° Básico', 'Objetivos de aprendizaje de Ciencias Naturales, eje Habilidades de Investigación Científica, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and s.name = 'Habilidades de Investigación Científica'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Ciencias Naturales, eje Habilidades de Investigación Científica (ver decisión de modelado en el encabezado de este archivo).',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Formulación de preguntas de investigación con variables', 'Formular preguntas de investigación que identifiquen una variable a estudiar.', 0),
  ('Análisis crítico de fuentes de información científica', 'Analizar de manera crítica y simple información científica proveniente de distintas fuentes.', 1),
  ('Comunicación de conclusiones de una investigación', 'Comunicar de forma oral o escrita las conclusiones de una investigación científica, usando evidencia.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Ciencias Naturales') and name = 'Habilidades de Investigación Científica') and name = 'Habilidades de Investigación Científica — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
