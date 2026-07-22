-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Matemática, 3° y 4° Medio, Formación General.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA -- INCERTIDUMBRE MÁS ALTA QUE 0011/0012
-- ============================================================================
-- Fuente citada: Bases Curriculares de 3° y 4° Medio (Formación General),
-- MINEDUC, reforma implementada progresivamente desde 2020 (3° Medio) / 2021
-- (4° Medio).
--
-- ADVERTENCIA EXPLÍCITA -- número de decreto NO VERIFICADO: a diferencia de
-- supabase/seed/0011 (Decreto 439/2012) y supabase/seed/0012 (Decreto
-- 614/2013), este agente NO tiene certeza suficiente sobre el número y año
-- exactos del decreto que aprobó las Bases Curriculares de 3°-4° Medio.
-- `curricular_source` en este archivo se deja como una descripción textual
-- SIN número de decreto específico, y `reference_year` se deja NULL a
-- propósito -- afirmar un número de decreto sin poder verificarlo contra el
-- Diario Oficial o curriculumnacional.cl sería fabricar un dato. Antes de
-- promover cualquier fila de este archivo a `status = 'aprobado'`, se
-- recomienda verificar el decreto exacto contra una fuente oficial
-- (curriculumnacional.cl o el Diario Oficial) y actualizar `curricular_source`
-- / `reference_year` en consecuencia.
--
-- Confianza en los 4 ejes temáticos (Números; Álgebra y Funciones; Geometría;
-- Probabilidad y Estadística): MEDIA -- estos mismos 4 nombres ya existen en
-- el esquema porque ValidApp cargó el temario EPJA "Primer Nivel Medio" bajo
-- D.S. 257/2009 con esos ejes (ver supabase/seed/0001), y la reforma de 3°-4°
-- Medio mantiene una estructura de ejes similar a la de 7° Básico-2° Medio,
-- pero esto no ha sido verificado línea por línea contra el documento de
-- 3°-4° Medio específico.
--
-- Confianza en el TEXTO Y LA PROGRESIÓN de contenidos: MEDIA para 3° Medio
-- (funciones exponenciales/logarítmicas, teorema del seno/coseno, vectores,
-- medidas de dispersión, variable aleatoria -- contenidos bien documentados
-- de la reforma). BAJA-MEDIA para 4° Medio, en particular para los tópicos
-- más recientes de la reforma 2019 (inferencia estadística, intervalos de
-- confianza, y nociones introductorias de tasa de variación/cálculo): este
-- agente reconoce explícitamente no tener certeza plena sobre el alcance
-- exacto y la redacción oficial de esos objetivos en particular.
--
-- Por todo lo anterior, igual que 0011/0012:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - Todas las filas quedan `status = 'borrador'`.
--   - `pedagogical_notes` marca la incertidumbre normativa fila por fila, y
--     además de forma más enfática para 4° Medio.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes x 2 cursos (3° y 4° Medio) = 8 combinaciones eje-curso, cada
-- una con 1 unidad y 3 objetivos "semilla" -- SOLO Formación General.
--
-- NO cubre Formación Diferenciada (asignaturas electivas de 3°-4° Medio como
-- "Límites, derivadas e integrales" o "Probabilidad y estadística descriptiva
-- e inferencial"): quedan explícitamente fuera de alcance. Si se necesitan
-- más adelante, deben tratarse como asignaturas/unidades separadas, con su
-- propia verificación de fuente, no mezcladas con la Formación General.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades, Grandes
-- ideas ni Conocimientos esenciales.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects (0016)
-- ============================================================================
-- Mismo motivo documentado en supabase/seed/0011 y 0012: `exam_period` NOT
-- NULL en `curriculum_frameworks` no tiene equivalente en el Currículum
-- Regular. Se usa `curricular_source`/`reference_year`/`pedagogical_notes` en
-- `learning_objectives`. Dado que aquí ni siquiera el número de decreto está
-- verificado, forzar una fila en `curriculum_frameworks` (que exige
-- `decree_number`/`decree_year` NOT NULL) sería aún más problemático que en
-- las otras dos bandas -- razón adicional para no usarlo en este archivo.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011/0012. Seed SOLO local: no se ha ejecutado contra
-- Supabase.

-- ============================================================================
-- 1) Asignatura (reutiliza "Matemática")
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Matemática', 'mathematics')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- Los 4 ejes de esta banda ("Números", "Álgebra y Funciones", "Geometría",
-- "Probabilidad y Estadística") ya existen en el esquema (creados por
-- supabase/seed/0001_epja_pilot_matematica.sql para el temario EPJA "Primer
-- Nivel Medio"). Se reutilizan sin modificar -- no se inserta ningún eje
-- nuevo en este archivo.

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 3° MEDIO (order_index de nivel = 111)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 3° Medio', 'Objetivos de aprendizaje de Matemática, eje Números, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Números. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Operatoria con números reales en contexto', 'Resolver problemas que involucran operatoria con números reales en contextos financieros y científicos.', 0),
  ('Logaritmo como inverso de la potencia', 'Aplicar el concepto de logaritmo como inverso de la potencia en la resolución de problemas.', 1),
  ('Notación científica', 'Estimar y aproximar resultados usando notación científica.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Álgebra y Funciones — 3° Medio', 'Objetivos de aprendizaje de Matemática, eje Álgebra y Funciones, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Álgebra y Funciones'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Álgebra y Funciones. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Funciones potencia, exponencial y logarítmica', 'Analizar el comportamiento de funciones potencia, exponencial y logarítmica a partir de su representación gráfica.', 0),
  ('Modelamiento con funciones exponenciales y logarítmicas', 'Modelar situaciones cotidianas y científicas usando funciones exponenciales y logarítmicas.', 1),
  ('Ecuaciones exponenciales y logarítmicas', 'Resolver problemas que involucran ecuaciones exponenciales y logarítmicas.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Álgebra y Funciones') and name = 'Álgebra y Funciones — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 3° Medio', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Geometría. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Teorema del seno y del coseno', 'Aplicar el teorema del seno y del coseno en la resolución de problemas de triángulos oblicuángulos.', 0),
  ('Vectores en el plano cartesiano', 'Representar puntos, rectas y figuras en el plano cartesiano usando vectores.', 1),
  ('Figuras 3D y proyecciones', 'Resolver problemas geométricos que involucran figuras 3D y sus proyecciones.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Probabilidad y Estadística — 3° Medio', 'Objetivos de aprendizaje de Matemática, eje Probabilidad y Estadística, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Probabilidad y Estadística'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Probabilidad y Estadística. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Medidas de dispersión', 'Interpretar y comparar distribuciones de datos usando medidas de dispersión (varianza, desviación estándar).', 0),
  ('Variable aleatoria discreta', 'Aplicar el modelo de probabilidad de una variable aleatoria discreta.', 1),
  ('Distribución normal', 'Interpretar la distribución normal como modelo de una variable aleatoria continua.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Probabilidad y Estadística') and name = 'Probabilidad y Estadística — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° MEDIO (order_index de nivel = 112)
-- ---------------------------------------------------------------------
-- ADVERTENCIA ADICIONAL para 4° Medio (más allá de la general del
-- encabezado): los objetivos de "Tasa de variación media" (Álgebra y
-- Funciones) y de inferencia estadística (Probabilidad y Estadística) tocan
-- los tópicos más recientes/menos consolidados en el conocimiento de este
-- agente sobre esta reforma específica -- se marcan con confianza BAJA
-- individualmente, no solo por el motivo general de decreto no verificado.
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 4° Medio', 'Objetivos de aprendizaje de Matemática, eje Números, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Números. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Interés simple y compuesto', 'Resolver problemas financieros que involucran interés simple y compuesto.', 0),
  ('Sucesiones y progresiones', 'Aplicar el concepto de sucesiones y progresiones aritméticas y geométricas en la resolución de problemas.', 1),
  ('Crecimiento y decrecimiento exponencial', 'Analizar situaciones que involucran crecimiento y decrecimiento exponencial en contextos financieros y científicos.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Álgebra y Funciones — 4° Medio', 'Objetivos de aprendizaje de Matemática, eje Álgebra y Funciones, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Álgebra y Funciones'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Álgebra y Funciones. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (tópico reciente de la reforma, ver advertencia adicional de 4° Medio en este archivo). No es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado -- revisar con especial cuidado pedagógico si "tasa de variación media" corresponde a Formación General o a Formación Diferenciada.',
  v.order_index
from (values
  ('Funciones a trozos', 'Analizar el comportamiento de funciones a trozos y su aplicación en contextos reales.', 0),
  ('Optimización con funciones cuadráticas', 'Resolver problemas de optimización que involucran funciones cuadráticas.', 1),
  ('Tasa de variación media', 'Interpretar el concepto de tasa de variación media y su relación intuitiva con el concepto de derivada.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Álgebra y Funciones') and name = 'Álgebra y Funciones — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 4° Medio', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Geometría. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Cuerpos geométricos y transformaciones en el espacio', 'Resolver problemas cotidianos que involucran cuerpos geométricos y sus transformaciones en el espacio.', 0),
  ('Vectores en problemas geométricos y físicos', 'Aplicar el concepto de vectores en el plano para resolver problemas geométricos y físicos.', 1),
  ('Herramientas tecnológicas para lugares geométricos', 'Utilizar herramientas tecnológicas para representar y analizar lugares geométricos.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Probabilidad y Estadística — 4° Medio', 'Objetivos de aprendizaje de Matemática, eje Probabilidad y Estadística, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Probabilidad y Estadística'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, asignatura Matemática, eje Probabilidad y Estadística. Número de decreto NO verificado -- ver advertencia en encabezado del archivo.',
  null,
  'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (inferencia estadística/intervalos de confianza, tópico reciente de la reforma, ver advertencia adicional de 4° Medio en este archivo). No es cita textual del PDF oficial. Decreto exacto sin verificar, código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Estudio estadístico e inferencia', 'Diseñar y llevar a cabo un estudio estadístico para responder una pregunta de interés, aplicando conceptos de inferencia.', 0),
  ('Intervalos de confianza', 'Interpretar intervalos de confianza en el contexto de un estudio estadístico.', 1),
  ('Variable aleatoria continua', 'Aplicar el concepto de variable aleatoria continua y su distribución en la resolución de problemas.', 2)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Probabilidad y Estadística') and name = 'Probabilidad y Estadística — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
