-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Matemática, 1° a 6° Básico.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA (léase antes de aprobar cualquier fila)
-- ============================================================================
-- Fuente citada: Bases Curriculares de Educación Básica, MINEDUC, aprobadas
-- por el Decreto Supremo N.° 439 de 2012 (1° a 6° Básico, asignatura
-- Matemática). Vigencia progresiva desde 2013.
--
-- Confianza en la denominación de los 5 ejes temáticos (Números; Patrones y
-- Álgebra; Geometría; Medición; Datos y Probabilidades) y en la progresión
-- general de contenidos por curso (rangos numéricos, orden de introducción de
-- fracciones/decimales/porcentaje, tipos de figuras y transformaciones,
-- tipos de gráficos): MEDIA-ALTA. Es un currículo estable y ampliamente
-- documentado (a diferencia del temario EPJA cargado en
-- supabase/seed/0001_epja_pilot_matematica.sql), y esta agrupación en ejes
-- corresponde a la organización oficial declarada por el propio MINEDUC, no a
-- una propuesta de ValidApp.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL de cada Objetivo de
-- Aprendizaje (código "OA n" tal como aparece en el PDF de Bases
-- Curriculares): BAJA. Este agente no tiene acceso a herramientas de
-- navegación web ni al PDF oficial en este entorno, por lo que NINGÚN texto
-- de este archivo debe leerse como cita literal de MINEDUC. Cada
-- `short_name`/`description` es una PARÁFRASIS de ValidApp basada en
-- conocimiento general del currículo chileno de Matemática, escrita para
-- representar el contenido esperado del curso -- no el enunciado oficial
-- verbatim. Por eso:
--   - `official_text` se deja NULL en todas las filas (no se inventa un texto
--     "oficial" que no se puede verificar).
--   - `code` (código OA oficial) se deja NULL en todas las filas, por el
--     mismo motivo: asignar "OA 1", "OA 2", etc. sin verificar el documento
--     fuente sería fabricar una numeración no confirmada.
--   - TODAS las filas quedan en `status = 'borrador'` (nunca 'aprobado'),
--     conforme a la regla "no considerar aprobado ningún contenido sin fuente
--     verificable o revisión pedagógica".
--   - `pedagogical_notes` repite esta advertencia en cada objetivo para que
--     quede visible fila por fila, no solo en este encabezado.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: los 5 ejes temáticos oficiales x 6 cursos (1° a 6° Básico) = 30
-- combinaciones eje-curso, cada una con 1 unidad y entre 4 y 6 objetivos de
-- aprendizaje curados (ampliado desde la versión inicial de 3 objetivos
-- "semilla" por eje/curso). El eje Números lleva 6 objetivos por curso (mayor
-- peso relativo en el currículo oficial); Patrones y Álgebra y Geometría
-- llevan 5; Medición y Datos y Probabilidades llevan 4 (ejes con menor
-- cantidad de OA oficiales en este tramo). Siguen siendo representativos, NO
-- exhaustivos -- el PDF oficial puede declarar un número distinto de OA por
-- eje y curso, y esta cobertura ampliada no reemplaza la verificación línea
-- por línea contra el documento oficial.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades (fuera de
-- alcance de esta tarea -- ver /validapp-assessments para preguntas/ensayos).
-- Tampoco cubre "Grandes ideas" ni "Conocimientos esenciales" (0014): quedan
-- pendientes para una fase posterior si se decide completarlos.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects (0016)
-- ============================================================================
-- Esas tablas se diseñaron para el problema específico de EPJA: varios
-- decretos vigentes en paralelo para un mismo año según nivel y PERÍODO DE
-- EXAMINACIÓN (`exam_year` + `exam_period`, columnas NOT NULL con check
-- ('primer_periodo','segundo_periodo')). El Currículum Regular no tiene ese
-- concepto de "período de examinación" a nivel de la BASE CURRICULAR misma
-- (es un currículo único vigente, no un temario semestral); forzar un valor
-- de `exam_period` para poder insertar una fila en `curriculum_frameworks`
-- sería fabricar un dato sin sustento. Se usa en su lugar la trazabilidad
-- simple ya disponible en `learning_objectives`: `curricular_source` (texto)
-- + `reference_year` (año del decreto) + `pedagogical_notes`. Si más adelante
-- se decide modelar versiones de currículo regular (p. ej. para distinguir
-- reformas futuras), se recomienda evaluarlo en una migración nueva revisada
-- por /validapp-db, no forzando el modelo EPJA existente.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- `subjects.name`, `strands (subject_id, name)`, `units (strand_id, name)` y
-- `learning_objectives (unit_id, level_id, short_name)` ya tienen restricción
-- única (0002/0010/0022), así que todo INSERT usa `on conflict ... do
-- nothing` (subjects, strands, units -- catálogo compartido, no se pisa
-- contenido ya editado por un administrador) o `on conflict ... do update`
-- solo sobre las columnas propias de este archivo (learning_objectives:
-- description/curricular_source/reference_year/pedagogical_notes). Seguro de
-- correr más de una vez. `level_id` se resuelve siempre por `levels.code`
-- (nunca por id hardcodeado), y `subject_id` por `subjects.name` (catálogo
-- compartido con EPJA, ver supabase/seed/0001_epja_pilot_matematica.sql).
--
-- Seed SOLO local: NO se ha ejecutado contra ningún proyecto Supabase (ni
-- dev ni producción). No modifica Supabase por sí solo.

-- ============================================================================
-- 1) Asignatura: reutiliza "Matemática" si ya existe (EPJA la creó primero)
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Matemática', 'mathematics')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- "Números", "Geometría" y "Probabilidad y Estadística" ya existen (creados
-- por supabase/seed/0001_epja_pilot_matematica.sql) -- se reutilizan sin
-- modificar su descripción/orden ya asignado. Solo se crean los 3 ejes
-- nuevos específicos de esta banda (1°-6° Básico): "Patrones y Álgebra",
-- "Medición" y "Datos y Probabilidades" (nombres oficiales de esta banda,
-- distintos de "Álgebra" y "Probabilidad y Estadística" usados en 7°
-- Básico-2° Medio, ver supabase/seed/0012).
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Números', 'Números naturales, fracciones, decimales y operatoria.', 0)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Patrones y Álgebra', 'Patrones numéricos y de figuras, igualdades y lenguaje algebraico inicial.', 4)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Geometría', 'Figuras 2D, cuerpos 3D, transformaciones isométricas y ubicación espacial.', 2)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Medición', 'Longitud, peso, capacidad, tiempo, perímetro, área y volumen.', 5)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Datos y Probabilidades', 'Recolección e interpretación de datos, tablas, gráficos y probabilidad.', 6)
on conflict (subject_id, name) do nothing;

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================
-- Constantes repetidas por fila (ver encabezado): `status = 'borrador'`,
-- `curricular_source` cita el decreto, `reference_year = 2012` (año del
-- decreto; la implementación fue progresiva desde 2013), `pedagogical_notes`
-- advierte que el texto es paráfrasis ValidApp pendiente de verificación.

-- ---------------------------------------------------------------------
-- 1° BÁSICO (order_index de nivel = 101, ver supabase/seed/0009)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 1° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Números.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Conteo hasta 20', 'Contar números hasta 20 de 1 en 1 y de 2 en 2, en forma ascendente y descendente.', 0),
  ('Lectura, escritura y representación hasta 20', 'Leer, escribir y representar números naturales del 0 al 20 de manera concreta, pictórica y simbólica.', 1),
  ('Adición y sustracción hasta 20', 'Resolver problemas de adición y sustracción en el ámbito del 20, sin reagrupación.', 2),
  ('Composición y descomposición de números hasta 20', 'Componer y descomponer números del 0 al 20 de manera aditiva, usando material concreto y pictórico.', 3),
  ('Estimación de cantidades', 'Estimar cantidades hasta 20 y comprobar la estimación mediante el conteo.', 4),
  ('Uso de monedas de uso común', 'Identificar y usar monedas de uso común ($10, $50, $100, $500) en situaciones cotidianas simples de compra y venta.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Patrones y Álgebra — 1° Básico', 'Objetivos de aprendizaje de Matemática, eje Patrones y Álgebra, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Patrones y Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Patrones y Álgebra.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Patrones repetitivos', 'Reconocer, describir y crear patrones numéricos y de figuras repetitivos.', 0),
  ('El signo igual como equivalencia', 'Comprender el signo igual como una relación de equivalencia entre dos expresiones.', 1),
  ('Predicción de elementos en una secuencia', 'Usar un patrón para predecir elementos faltantes en una secuencia numérica o de figuras.', 2),
  ('Patrones crecientes y decrecientes simples', 'Reconocer y describir patrones numéricos crecientes y decrecientes simples de 1 en 1 y de 2 en 2.', 3),
  ('Igualdades numéricas simples', 'Completar igualdades numéricas simples de adición y sustracción hasta 20.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Patrones y Álgebra') and name = 'Patrones y Álgebra — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 1° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Geometría.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Figuras 2D y cuerpos 3D básicos', 'Reconocer y nombrar figuras 2D (cuadrado, triángulo, círculo, rectángulo) y cuerpos 3D (esfera, cono, cubo, cilindro) en el entorno.', 0),
  ('Ubicación relativa de objetos', 'Describir la posición de personas y objetos usando vocabulario de ubicación relativa (izquierda/derecha, arriba/abajo, dentro/fuera).', 1),
  ('Representación de objetos con figuras geométricas', 'Representar objetos del entorno mediante figuras geométricas 2D y cuerpos 3D básicos.', 2),
  ('Comparación de tamaños y formas', 'Comparar y clasificar figuras 2D y cuerpos 3D según sus atributos (forma, tamaño, número de lados).', 3),
  ('Referentes de posición en trayectos', 'Describir trayectos y ubicaciones usando referentes de posición (adelante/atrás, cerca/lejos).', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Medición — 1° Básico', 'Objetivos de aprendizaje de Matemática, eje Medición, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Medición'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Medición.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comparación de longitudes, pesos y capacidades', 'Comparar y ordenar longitudes, pesos y capacidades de objetos sin usar instrumentos de medida estandarizados.', 0),
  ('Secuencia temporal', 'Ubicar eventos de la rutina diaria y semanal en una secuencia temporal (antes/después, días de la semana).', 1),
  ('Lectura de la hora en punto', 'Leer la hora en punto en relojes análogos y digitales.', 2),
  ('Comparación de la duración de eventos', 'Comparar la duración de eventos cotidianos usando vocabulario temporal (más corto/más largo, antes/después).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Medición') and name = 'Medición — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Datos y Probabilidades — 1° Básico', 'Objetivos de aprendizaje de Matemática, eje Datos y Probabilidades, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Datos y Probabilidades'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Datos y Probabilidades.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Recolección y registro de datos', 'Recolectar datos del entorno y registrarlos en tablas simples y pictogramas.', 0),
  ('Eventos seguros, posibles e imposibles', 'Distinguir entre eventos seguros, posibles e imposibles en situaciones cotidianas.', 1),
  ('Interpretación de pictogramas simples', 'Interpretar información presentada en pictogramas simples de hasta dos categorías.', 2),
  ('Clasificación de objetos según un atributo', 'Clasificar objetos concretos según un atributo y justificar el criterio de clasificación usado.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Datos y Probabilidades') and name = 'Datos y Probabilidades — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° BÁSICO (order_index de nivel = 102)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 2° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Números.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Conteo hasta 100', 'Contar números hasta 100 de 1 en 1, de 2 en 2, de 5 en 5 y de 10 en 10, en forma ascendente y descendente.', 0),
  ('Comparación de números hasta 100', 'Leer, escribir, representar y comparar números naturales hasta 100.', 1),
  ('Adición y sustracción hasta 100', 'Resolver problemas de adición y sustracción hasta 100, incluyendo situaciones con reagrupación.', 2),
  ('Composición y descomposición hasta 100', 'Componer y descomponer números del 0 al 100 en forma aditiva, de acuerdo a su valor posicional.', 3),
  ('Fracciones simples: mitades y cuartos', 'Identificar mitades y cuartos como partes de un todo, de manera concreta y pictórica.', 4),
  ('Estrategias de cálculo mental', 'Aplicar estrategias de cálculo mental para adiciones y sustracciones hasta 20.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Patrones y Álgebra — 2° Básico', 'Objetivos de aprendizaje de Matemática, eje Patrones y Álgebra, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Patrones y Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Patrones y Álgebra.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Patrones numéricos con una regla', 'Crear, describir y registrar patrones numéricos identificando la regla que los genera.', 0),
  ('Valores desconocidos en igualdades', 'Determinar valores desconocidos en igualdades numéricas simples de adición y sustracción.', 1),
  ('Doble, triple y mitad', 'Representar de manera concreta y pictórica el doble, el triple y la mitad de una cantidad.', 2),
  ('Secuencias con dos operaciones', 'Crear y describir secuencias numéricas que combinan una regla de suma y una de resta.', 3),
  ('Uso de la balanza para igualdades', 'Representar igualdades numéricas usando el modelo de balanza en equilibrio.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Patrones y Álgebra') and name = 'Patrones y Álgebra — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 2° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Geometría.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ubicación mediante coordenadas informales', 'Describir la posición de objetos en una cuadrícula usando coordenadas informales (filas y columnas).', 0),
  ('Simetría en figuras 2D', 'Identificar la línea de simetría en figuras 2D.', 1),
  ('Guardas y teselados', 'Diseñar guardas y teselados simples combinando figuras 2D.', 2),
  ('Figuras 3D a partir de redes simples', 'Reconocer figuras 3D a partir de sus redes o desarrollos planos simples.', 3),
  ('Descripción de trayectos con giros', 'Describir la posición de objetos y trayectos utilizando puntos de referencia y giros simples.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Medición — 2° Básico', 'Objetivos de aprendizaje de Matemática, eje Medición, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Medición'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Medición.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Medición de longitudes', 'Medir longitudes usando unidades no estandarizadas y estandarizadas (centímetro, metro).', 0),
  ('Hora en punto y media hora', 'Registrar y comunicar la hora en punto y media hora en relojes análogos y digitales.', 1),
  ('Estimación de peso', 'Estimar y medir el peso de objetos usando unidades no estandarizadas.', 2),
  ('Comparación de capacidades', 'Comparar y ordenar la capacidad de recipientes usando unidades no estandarizadas y estandarizadas (litro).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Medición') and name = 'Medición — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Datos y Probabilidades — 2° Básico', 'Objetivos de aprendizaje de Matemática, eje Datos y Probabilidades, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Datos y Probabilidades'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Datos y Probabilidades.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Preguntas y recolección de datos', 'Formular preguntas y recolectar datos del entorno para responderlas.', 0),
  ('Pictogramas y gráficos de barra simples', 'Construir e interpretar pictogramas y gráficos de barra simples.', 1),
  ('Eventos más o menos probables', 'Reconocer que algunos eventos cotidianos son más o menos probables que otros.', 2),
  ('Tablas de conteo', 'Registrar datos recolectados en tablas de conteo simples y responder preguntas a partir de ellas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Datos y Probabilidades') and name = 'Datos y Probabilidades — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 3° BÁSICO (order_index de nivel = 103)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 3° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Números.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Números hasta 1.000', 'Leer, escribir, representar y comparar números naturales hasta 1.000.', 0),
  ('Adición y sustracción hasta 1.000', 'Resolver problemas de adición y sustracción hasta 1.000, con y sin reagrupación.', 1),
  ('Multiplicación y división hasta el 10', 'Resolver problemas de multiplicación y división en el contexto de las tablas hasta el 10.', 2),
  ('Valor posicional hasta la unidad de mil', 'Representar y describir números hasta 1.000 según su valor posicional (unidades, decenas, centenas).', 3),
  ('Fracciones como parte de un todo', 'Identificar y representar fracciones de uso común (1/2, 1/3, 1/4) como partes de un todo o de un grupo de objetos.', 4),
  ('Estrategias de multiplicación', 'Aplicar estrategias para construir las tablas de multiplicar hasta el 10 (representación en tablas, arreglos rectangulares).', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Patrones y Álgebra — 3° Básico', 'Objetivos de aprendizaje de Matemática, eje Patrones y Álgebra, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Patrones y Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Patrones y Álgebra.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Cálculo mental', 'Aplicar estrategias de cálculo mental para resolver adiciones y sustracciones.', 0),
  ('Ecuaciones simples de un paso', 'Resolver ecuaciones simples de un paso usando la relación entre las cuatro operaciones.', 1),
  ('Patrones con las cuatro operaciones', 'Describir patrones numéricos que involucran adición, sustracción, multiplicación y división.', 2),
  ('Reglas de formación de patrones', 'Describir la regla de formación de un patrón numérico y usarla para extenderlo.', 3),
  ('Relación entre multiplicación y división', 'Aplicar la relación inversa entre la multiplicación y la división para resolver problemas.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Patrones y Álgebra') and name = 'Patrones y Álgebra — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 3° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Geometría.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Prismas y pirámides', 'Identificar y describir prismas y pirámides según el número de caras, vértices y aristas.', 0),
  ('Traslaciones de figuras 2D', 'Realizar traslaciones de figuras 2D sobre una cuadrícula.', 1),
  ('Plano cartesiano — primer cuadrante', 'Ubicar objetos en el primer cuadrante de un plano cartesiano simple.', 2),
  ('Ángulos rectos en el entorno', 'Identificar ángulos rectos en figuras 2D y en objetos del entorno, usando una escuadra como referencia.', 3),
  ('Simetría de reflexión', 'Determinar si una figura 2D tiene uno o más ejes de simetría de reflexión.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Medición — 3° Básico', 'Objetivos de aprendizaje de Matemática, eje Medición, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Medición'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Medición.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Perímetro de figuras 2D', 'Medir y estimar el perímetro de figuras 2D.', 0),
  ('Paso del tiempo', 'Resolver problemas que involucran el paso del tiempo en horas y minutos.', 1),
  ('Estimación de volumen con unidades no estandarizadas', 'Estimar y medir volumen usando unidades no estandarizadas.', 2),
  ('Lectura de calendarios', 'Leer y utilizar calendarios para resolver problemas relacionados con el paso del tiempo (días, semanas, meses).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Medición') and name = 'Medición — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Datos y Probabilidades — 3° Básico', 'Objetivos de aprendizaje de Matemática, eje Datos y Probabilidades, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Datos y Probabilidades'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Datos y Probabilidades.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Gráficos de barra simple y doble', 'Comparar e interpretar datos representados en pictogramas y gráficos de barra simple y doble.', 0),
  ('Registro de experimentos aleatorios', 'Registrar los resultados de experimentos aleatorios repetidos.', 1),
  ('Promedio de un conjunto de datos', 'Calcular el promedio (media aritmética) de un conjunto de datos y usarlo para describirlos.', 2),
  ('Formulación de preguntas estadísticas', 'Formular preguntas estadísticas y planificar la recolección de datos para responderlas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Datos y Probabilidades') and name = 'Datos y Probabilidades — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° BÁSICO (order_index de nivel = 104)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 4° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Números.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Números hasta 10.000', 'Leer, escribir, representar y comparar números naturales hasta 10.000.', 0),
  ('Adición y sustracción hasta 10.000', 'Aplicar estrategias para resolver adiciones y sustracciones hasta 10.000.', 1),
  ('Multiplicación y división con el algoritmo', 'Resolver problemas de multiplicación y división usando el algoritmo, con dígitos hasta el 10.000.', 2),
  ('Equivalencia de fracciones', 'Identificar y representar fracciones equivalentes de manera concreta, pictórica y simbólica.', 3),
  ('Adición y sustracción de fracciones y decimales simples', 'Resolver adiciones y sustracciones de fracciones con igual denominador y de números decimales hasta la décima.', 4),
  ('Estimación de resultados', 'Estimar el resultado de operaciones antes de calcularlas, y verificar la razonabilidad de la respuesta obtenida.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Patrones y Álgebra — 4° Básico', 'Objetivos de aprendizaje de Matemática, eje Patrones y Álgebra, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Patrones y Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Patrones y Álgebra.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Patrones en tablas y plano cartesiano', 'Representar patrones numéricos mediante tablas y gráficos en el plano cartesiano.', 0),
  ('Valores desconocidos en adición y sustracción', 'Determinar valores desconocidos en adiciones y sustracciones.', 1),
  ('Propiedad distributiva', 'Aplicar la propiedad distributiva de la multiplicación respecto de la adición.', 2),
  ('Ecuaciones simples con multiplicación y división', 'Resolver ecuaciones simples de un paso que involucran multiplicación y división.', 3),
  ('Reglas de dos operaciones combinadas', 'Describir y aplicar reglas que combinan dos operaciones para generar secuencias numéricas.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Patrones y Álgebra') and name = 'Patrones y Álgebra — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 4° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Geometría.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ángulos como abertura entre rayos', 'Identificar ángulos como la abertura entre dos rayos con un origen común, y compararlos.', 0),
  ('Perímetro y área de rectángulos y cuadrados', 'Determinar el perímetro y el área de rectángulos y cuadrados.', 1),
  ('Reflexiones y rotaciones', 'Realizar reflexiones y rotaciones de figuras 2D en el plano cartesiano.', 2),
  ('Clasificación de triángulos y cuadriláteros', 'Clasificar triángulos según sus lados y ángulos, y cuadriláteros según sus propiedades.', 3),
  ('Coordenadas en los cuatro cuadrantes', 'Ubicar y describir posiciones de objetos en los cuatro cuadrantes de un plano cartesiano.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Medición — 4° Básico', 'Objetivos de aprendizaje de Matemática, eje Medición, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Medición'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Medición.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Conversión de unidades de tiempo', 'Convertir entre unidades de medida de tiempo (segundos, minutos, horas, días).', 0),
  ('Medición exploratoria de ángulos', 'Medir y comparar ángulos de forma exploratoria usando un transportador.', 1),
  ('Problemas de perímetro y área', 'Resolver problemas cotidianos que involucran perímetro y área.', 2),
  ('Conversión de unidades de longitud y masa', 'Convertir entre unidades de medida de longitud (m, cm, mm) y de masa (kg, g) en contextos cotidianos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Medición') and name = 'Medición — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Datos y Probabilidades — 4° Básico', 'Objetivos de aprendizaje de Matemática, eje Datos y Probabilidades, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Datos y Probabilidades'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Datos y Probabilidades.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Gráficos de línea', 'Construir e interpretar gráficos de línea para representar cambios en el tiempo.', 0),
  ('Encuestas y tablas de frecuencia', 'Realizar encuestas simples y organizar los datos en tablas de frecuencia.', 1),
  ('Probabilidad con fracciones simples', 'Comparar la probabilidad de ocurrencia de eventos usando fracciones simples.', 2),
  ('Interpretación de la moda en un conjunto de datos', 'Determinar e interpretar la moda de un conjunto de datos presentados en tablas o gráficos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Datos y Probabilidades') and name = 'Datos y Probabilidades — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 5° BÁSICO (order_index de nivel = 105)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 5° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Números.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Números hasta 1.000.000', 'Leer, escribir, representar y comparar números naturales hasta 1.000.000.', 0),
  ('Operatoria con fracciones', 'Resolver problemas con las cuatro operaciones que incluyen fracciones propias, impropias y números mixtos.', 1),
  ('Decimales hasta la centésima', 'Identificar y representar números decimales hasta la centésima.', 2),
  ('Múltiplos y divisores', 'Determinar múltiplos y divisores de un número y aplicarlos en la resolución de problemas.', 3),
  ('Multiplicación y división de decimales', 'Resolver problemas de multiplicación y división de números decimales por números naturales de un dígito.', 4),
  ('Relación entre fracciones, decimales y porcentajes', 'Relacionar fracciones, decimales y porcentajes de uso común (1/2=0,5=50%) en situaciones cotidianas.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Patrones y Álgebra — 5° Básico', 'Objetivos de aprendizaje de Matemática, eje Patrones y Álgebra, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Patrones y Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Patrones y Álgebra.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Prioridad de operaciones', 'Aplicar la prioridad de operaciones al resolver expresiones numéricas combinadas.', 0),
  ('Lenguaje algebraico simple', 'Utilizar lenguaje algebraico simple para representar situaciones cotidianas.', 1),
  ('Ecuaciones e inecuaciones de un paso', 'Resolver ecuaciones e inecuaciones de un paso en el ámbito de los números naturales.', 2),
  ('Secuencias con números decimales y fracciones', 'Describir y continuar secuencias numéricas que involucran fracciones o decimales.', 3),
  ('Representación gráfica de relaciones simples', 'Representar en tablas y gráficos la relación entre dos cantidades que varían juntas.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Patrones y Álgebra') and name = 'Patrones y Álgebra — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 5° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Geometría.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Construcción de triángulos', 'Construir triángulos dado un conjunto de medidas de lados y/o ángulos.', 0),
  ('Área de triángulos y paralelogramos', 'Determinar el área de triángulos y paralelogramos.', 1),
  ('Elementos de figuras 3D', 'Identificar y describir la relación entre los elementos de figuras 3D (aristas, caras, vértices).', 2),
  ('Círculo y sus elementos', 'Identificar y describir los elementos del círculo (centro, radio, diámetro, circunferencia).', 3),
  ('Redes de cuerpos geométricos', 'Construir redes (desarrollos planos) de prismas y pirámides.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Medición — 5° Básico', 'Objetivos de aprendizaje de Matemática, eje Medición, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Medición'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Medición.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Volumen mediante conteo de cubos', 'Estimar y medir el volumen de prismas rectos mediante el conteo de cubos unitarios.', 0),
  ('Conversión de unidades del Sistema Internacional', 'Convertir entre unidades de medida del Sistema Internacional (longitud, masa, capacidad).', 1),
  ('Perímetro y área de figuras compuestas', 'Resolver problemas geométricos que involucran perímetro y área de figuras compuestas.', 2),
  ('Estimación y medición de ángulos con transportador', 'Estimar y medir ángulos usando un transportador, clasificándolos según su medida.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Medición') and name = 'Medición — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Datos y Probabilidades — 5° Básico', 'Objetivos de aprendizaje de Matemática, eje Datos y Probabilidades, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Datos y Probabilidades'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Datos y Probabilidades.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Gráficos circulares', 'Construir e interpretar gráficos circulares para representar datos.', 0),
  ('Media, moda y rango', 'Determinar la media, la moda y el rango de un conjunto de datos.', 1),
  ('Probabilidad experimental y teórica', 'Comparar resultados obtenidos experimentalmente con la probabilidad teórica de un evento.', 2),
  ('Comparación de dos conjuntos de datos', 'Comparar dos conjuntos de datos representados en gráficos, usando medidas de tendencia central.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Datos y Probabilidades') and name = 'Datos y Probabilidades — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 6° BÁSICO (order_index de nivel = 106)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 6° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Números.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Cuatro operaciones con números naturales', 'Resolver problemas rutinarios y no rutinarios que involucran las cuatro operaciones con números naturales.', 0),
  ('Cuatro operaciones con fracciones y decimales', 'Resolver problemas con las cuatro operaciones con fracciones y números decimales.', 1),
  ('Porcentaje en situaciones cotidianas', 'Aplicar el concepto de porcentaje en la resolución de problemas cotidianos.', 2),
  ('Números negativos en contexto', 'Ubicar números enteros negativos en la recta numérica en contextos como temperatura y altitud.', 3),
  ('Mínimo común múltiplo y máximo común divisor', 'Determinar el mínimo común múltiplo y el máximo común divisor de dos números y aplicarlos en la resolución de problemas.', 4),
  ('Razones y proporciones', 'Utilizar razones y proporciones para representar y resolver problemas que involucran comparación de cantidades.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Patrones y Álgebra — 6° Básico', 'Objetivos de aprendizaje de Matemática, eje Patrones y Álgebra, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Patrones y Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Patrones y Álgebra.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Reducción de expresiones algebraicas simples', 'Utilizar simbología algebraica para reducir expresiones simples.', 0),
  ('Ecuaciones e inecuaciones con enteros', 'Resolver ecuaciones e inecuaciones de un paso en el ámbito de los números enteros.', 1),
  ('Proporcionalidad en tablas y gráficos', 'Representar la relación de proporcionalidad directa en tablas y gráficos.', 2),
  ('Expresiones algebraicas para representar relaciones', 'Utilizar expresiones algebraicas simples para representar la relación entre dos variables.', 3),
  ('Resolución de problemas con proporcionalidad directa', 'Resolver problemas de la vida cotidiana que involucran proporcionalidad directa.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Patrones y Álgebra') and name = 'Patrones y Álgebra — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 6° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Geometría.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Construcción de ángulos', 'Construir un ángulo dada su medida, usando un transportador.', 0),
  ('Área y perímetro de figuras compuestas', 'Determinar el área y el perímetro de figuras compuestas por triángulos y cuadriláteros.', 1),
  ('Teselaciones del plano', 'Realizar teselaciones del plano usando figuras 2D y transformaciones isométricas.', 2),
  ('Ángulos entre rectas y un transversal', 'Identificar y clasificar ángulos formados por dos rectas y una transversal (correspondientes, alternos internos).', 3),
  ('Circunferencia: longitud y área del círculo', 'Calcular la longitud de la circunferencia y el área del círculo, de manera manual y/o con software educativo.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Medición — 6° Básico', 'Objetivos de aprendizaje de Matemática, eje Medición, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Medición'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Medición.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Volumen de prismas rectos con fórmula', 'Determinar el volumen de prismas rectos usando una fórmula.', 0),
  ('Conversión de unidades de superficie y volumen', 'Convertir entre unidades de medida de superficie y de volumen.', 1),
  ('Problemas combinados de perímetro, área y volumen', 'Resolver problemas geométricos que combinan perímetro, área y volumen.', 2),
  ('Área de superficie de prismas', 'Calcular el área de superficie de prismas rectos a partir de su red.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Medición') and name = 'Medición — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Datos y Probabilidades — 6° Básico', 'Objetivos de aprendizaje de Matemática, eje Datos y Probabilidades, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Datos y Probabilidades'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Matemática, eje Datos y Probabilidades.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comparación de distintos tipos de gráficos', 'Comparar e interpretar datos usando distintos tipos de gráficos (barra, línea, circular).', 0),
  ('Estudios con muestras y poblaciones', 'Explicar la diferencia entre estudios estadísticos basados en muestras y en poblaciones completas.', 1),
  ('Probabilidad como razón de casos favorables', 'Registrar resultados de experimentos aleatorios y estimar la probabilidad de un evento como la razón entre casos favorables y casos posibles.', 2),
  ('Combinaciones simples en experimentos aleatorios', 'Determinar el número de resultados posibles en experimentos aleatorios simples mediante diagramas de árbol o tablas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Datos y Probabilidades') and name = 'Datos y Probabilidades — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
