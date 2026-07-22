-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Matemática, 7° Básico a 2° Medio.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA
-- ============================================================================
-- Fuente citada: Bases Curriculares de 7° Básico a 2° Medio, MINEDUC,
-- aprobadas por el Decreto Supremo N.° 614 de 2013. Implementación progresiva
-- 2015-2019 según el propio decreto (por curso).
--
-- Confianza en la denominación de los 4 ejes temáticos de esta banda
-- (Números; Álgebra; Geometría; Probabilidad y Estadística -- nótese que
-- "Medición" del tramo 1°-6° Básico se integra dentro de Geometría en esta
-- banda, y "Datos y Probabilidades" pasa a llamarse "Probabilidad y
-- Estadística"): MEDIA. Confianza en la progresión general de contenidos
-- (números enteros/racionales/irracionales, álgebra creciente hasta sistemas
-- de ecuaciones, geometría con Pitágoras/semejanza/transformaciones,
-- estadística con medidas de tendencia central y probabilidad): MEDIA-ALTA,
-- reforzada porque ValidApp ya cargó un temario EPJA real para "Primer Nivel
-- Medio" (equivalente a 1°-2° Medio, pero bajo D.S. 257/2009, no 614/2013 --
-- ver supabase/seed/0001_epja_pilot_matematica.sql) que confirma varios de
-- estos objetivos con texto oficial verbatim para el tramo de Media.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL ("OA n") de cada
-- objetivo de ESTE decreto (614/2013) para 7°/8° Básico: BAJA -- no hay PDF
-- de esta fuente específica cargado ni verificado en este entorno. Por eso,
-- igual que en supabase/seed/0011:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - Todas las filas quedan `status = 'borrador'`.
--   - `pedagogical_notes` repite la advertencia en cada objetivo.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes x 4 cursos (7° Básico, 8° Básico, 1° Medio, 2° Medio) = 16
-- combinaciones eje-curso, cada una con 1 unidad y entre 5 y 6 objetivos de
-- aprendizaje curados (ampliado desde la versión inicial de 3 objetivos
-- "semilla" por eje/curso). Números y Álgebra llevan 6 objetivos por curso
-- (mayor peso relativo y progresión más extensa en esta banda); Geometría y
-- Probabilidad y Estadística llevan 5. Siguen siendo representativos, NO
-- exhaustivos -- mismo criterio que 0011.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades, Grandes
-- ideas ni Conocimientos esenciales (mismo alcance que 0011).
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects (0016)
-- ============================================================================
-- Mismo motivo documentado en supabase/seed/0011: esas tablas modelan
-- versiones curriculares EPJA con período de examinación obligatorio
-- (`exam_year`/`exam_period` NOT NULL), concepto que no aplica al Currículum
-- Regular. Se usa `curricular_source`/`reference_year`/`pedagogical_notes` en
-- `learning_objectives`, igual que en 0011.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011: `on conflict do nothing` para subjects/strands/units
-- (catálogo compartido, no se pisa edición de un administrador), `on
-- conflict do update` limitado a las columnas propias de este archivo para
-- learning_objectives. `level_id` por `levels.code`, `subject_id` por
-- `subjects.name`. Seed SOLO local: no se ha ejecutado contra Supabase.

-- ============================================================================
-- 1) Asignatura (reutiliza "Matemática")
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Matemática', 'mathematics')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- "Números", "Geometría" y "Probabilidad y Estadística" ya existen (creados
-- por supabase/seed/0001_epja_pilot_matematica.sql; "Probabilidad y
-- Estadística" también pudo haber sido creado por 0011 si se corrió antes --
-- ninguno de los dos archivos lo modifica, ambos hacen `do nothing`). Solo se
-- crea el eje nuevo de esta banda: "Álgebra" (nombre oficial distinto de
-- "Patrones y Álgebra" de 1°-6° Básico y de "Álgebra y Funciones" de 3°-4°
-- Medio -- ver supabase/seed/0013).
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Números', 'Números enteros, racionales, irracionales y potencias.', 0)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Álgebra', 'Expresiones algebraicas, ecuaciones, inecuaciones y sistemas de ecuaciones lineales.', 7)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Geometría', 'Ángulos, polígonos, semejanza, transformaciones isométricas, perímetro/área/volumen.', 2)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Matemática'),
   'Probabilidad y Estadística', 'Medidas de tendencia central y posición, probabilidad y combinatoria.', 3)
on conflict (subject_id, name) do nothing;

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 7° BÁSICO (order_index de nivel = 107)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 7° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Números.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Operatoria con números enteros', 'Resolver problemas con las cuatro operaciones que involucran números enteros.', 0),
  ('Fracciones y decimales positivos y negativos', 'Comparar y ordenar fracciones y decimales positivos y negativos, representándolos en la recta numérica.', 1),
  ('Problemas con porcentajes', 'Resolver problemas que involucran el cálculo de porcentajes.', 2),
  ('Potencias de base entera y exponente natural', 'Resolver problemas que involucran potencias de base entera y exponente natural.', 3),
  ('Múltiplos, divisores y factorización prima', 'Determinar múltiplos, divisores y la factorización prima de un número, aplicándolos en la resolución de problemas.', 4),
  ('Razones, proporciones y porcentajes en contexto financiero', 'Aplicar razones, proporciones y porcentajes en la resolución de problemas financieros simples (descuentos, recargos).', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Álgebra — 7° Básico', 'Objetivos de aprendizaje de Matemática, eje Álgebra, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Álgebra.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Relación entre variables', 'Identificar y describir la relación entre una variable dependiente y una independiente en una tabla o gráfico.', 0),
  ('Reducción de expresiones algebraicas', 'Reducir expresiones algebraicas aplicando las cuatro operaciones.', 1),
  ('Ecuaciones e inecuaciones lineales', 'Resolver ecuaciones e inecuaciones lineales de primer grado con una incógnita.', 2),
  ('Lenguaje algebraico y su traducción', 'Traducir enunciados en lenguaje cotidiano a expresiones algebraicas y viceversa.', 3),
  ('Valorización de expresiones algebraicas', 'Evaluar expresiones algebraicas asignando valores numéricos a las variables.', 4),
  ('Proporcionalidad directa e inversa', 'Representar y resolver problemas de proporcionalidad directa e inversa mediante tablas, gráficos y expresiones algebraicas.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Álgebra') and name = 'Álgebra — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 7° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Geometría.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Construcción de triángulos y cuadriláteros', 'Construir triángulos y cuadriláteros de forma manual y/o con software geométrico.', 0),
  ('Área y volumen de prismas y pirámides', 'Determinar el área y el volumen de prismas y pirámides.', 1),
  ('Teorema de Pitágoras', 'Aplicar el teorema de Pitágoras en la resolución de problemas geométricos.', 2),
  ('Ángulos interiores de polígonos', 'Determinar la suma de los ángulos interiores de triángulos y cuadriláteros, y generalizar a otros polígonos.', 3),
  ('Construcciones con regla y compás', 'Realizar construcciones geométricas básicas (bisectriz, mediatriz, ángulos) usando regla y compás.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Probabilidad y Estadística — 7° Básico', 'Objetivos de aprendizaje de Matemática, eje Probabilidad y Estadística, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Probabilidad y Estadística'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Probabilidad y Estadística.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Medidas de tendencia central y de posición', 'Determinar las medidas de tendencia central y de posición (percentiles) de un conjunto de datos.', 0),
  ('Comparación de poblaciones y muestras', 'Comparar poblaciones y muestras a partir de sus medidas de tendencia central.', 1),
  ('Probabilidad de eventos simples y compuestos', 'Calcular la probabilidad teórica de eventos simples y compuestos.', 2),
  ('Recolección de datos y tipos de muestreo', 'Distinguir tipos de muestreo simples y su efecto en la representatividad de una muestra.', 3),
  ('Espacio muestral de un experimento', 'Determinar el espacio muestral de experimentos aleatorios simples y compuestos.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Probabilidad y Estadística') and name = 'Probabilidad y Estadística — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 8° BÁSICO (order_index de nivel = 108)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 8° Básico', 'Objetivos de aprendizaje de Matemática, eje Números, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Números.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Potencias de base racional y exponente entero', 'Resolver problemas que involucran potencias de base racional y exponente entero.', 0),
  ('Raíces cuadradas y cúbicas', 'Resolver problemas con raíces cuadradas y cúbicas de números racionales.', 1),
  ('Aproximación de números irracionales', 'Identificar y aproximar números irracionales, ubicándolos en la recta numérica.', 2),
  ('Operatoria con números racionales', 'Resolver problemas que involucran las cuatro operaciones con números racionales, incluyendo su representación decimal.', 3),
  ('Notación científica', 'Utilizar notación científica para expresar números muy grandes o muy pequeños.', 4),
  ('Propiedades de las potencias', 'Aplicar las propiedades de las potencias para simplificar expresiones numéricas.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Álgebra — 8° Básico', 'Objetivos de aprendizaje de Matemática, eje Álgebra, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Álgebra.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Operatoria de expresiones algebraicas', 'Operar expresiones algebraicas mediante multiplicación, división y productos notables.', 0),
  ('Factorización de expresiones algebraicas', 'Factorizar expresiones algebraicas usando el factor común y productos notables.', 1),
  ('Sistemas de dos ecuaciones lineales', 'Resolver sistemas de dos ecuaciones lineales con dos incógnitas de manera gráfica y algebraica.', 2),
  ('Función lineal y afín', 'Analizar la función lineal y afín a partir de su representación gráfica y algebraica.', 3),
  ('Ecuaciones literales', 'Resolver ecuaciones literales despejando una variable en función de las demás.', 4),
  ('Inecuaciones lineales con una incógnita', 'Resolver inecuaciones lineales con una incógnita y representar su solución en la recta numérica.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Álgebra') and name = 'Álgebra — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 8° Básico', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Geometría.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Transformaciones isométricas y homotecia', 'Aplicar transformaciones isométricas y de homotecia a figuras 2D en el plano cartesiano.', 0),
  ('Volumen y área de cilindros, conos y esferas', 'Determinar el volumen y el área de superficie de cilindros, conos y esferas.', 1),
  ('Semejanza de figuras geométricas', 'Aplicar relaciones de semejanza entre figuras geométricas en la resolución de problemas.', 2),
  ('Teorema de Thales', 'Aplicar el teorema de Thales para determinar segmentos proporcionales en triángulos.', 3),
  ('Vistas y desarrollos de cuerpos geométricos', 'Representar vistas (frontal, lateral, superior) y desarrollos planos de cuerpos geométricos compuestos.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Probabilidad y Estadística — 8° Básico', 'Objetivos de aprendizaje de Matemática, eje Probabilidad y Estadística, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Probabilidad y Estadística'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Probabilidad y Estadística.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Diagramas de dispersión', 'Comparar e interpretar datos representados en distintos tipos de gráficos, incluyendo diagramas de dispersión.', 0),
  ('Diagramas de árbol', 'Determinar la probabilidad de eventos compuestos usando diagramas de árbol.', 1),
  ('Principio multiplicativo', 'Aplicar el principio combinatorio (multiplicativo) para determinar el número de resultados posibles.', 2),
  ('Medidas de posición: cuartiles', 'Determinar e interpretar cuartiles de un conjunto de datos.', 3),
  ('Probabilidad de eventos complementarios', 'Calcular la probabilidad de eventos complementarios y su relación con la probabilidad del evento original.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Probabilidad y Estadística') and name = 'Probabilidad y Estadística — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 1° MEDIO (order_index de nivel = 109)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 1° Medio', 'Objetivos de aprendizaje de Matemática, eje Números, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Números.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Primer Nivel Medio" (equivalente informal a 1°-2° Medio), ver supabase/seed/0001, aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Operatoria con números enteros en contexto', 'Usar números enteros en contextos cotidianos, estableciendo comparaciones y resolviendo operatoria.', 0),
  ('Proporcionalidad directa, inversa y porcentual', 'Aplicar variaciones de proporcionalidad directa, inversa y porcentual mediante la organización de datos en tablas y gráficos.', 1),
  ('Potencias de base racional y exponente entero', 'Interpretar y aplicar potencias de base racional y exponente entero en diversos contextos.', 2),
  ('Raíces enésimas', 'Resolver problemas que involucran raíces enésimas de números racionales.', 3),
  ('Notación científica en contextos científicos', 'Aplicar notación científica para resolver problemas en contextos científicos y tecnológicos.', 4),
  ('Aproximación y truncamiento', 'Aplicar aproximación y truncamiento de números decimales, evaluando el error asociado.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Álgebra — 1° Medio', 'Objetivos de aprendizaje de Matemática, eje Álgebra, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Álgebra.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Primer Nivel Medio", ver supabase/seed/0001, aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Lenguaje algebraico', 'Usar lenguaje algebraico para establecer relaciones entre variables.', 0),
  ('Productos notables', 'Operar expresiones algebraicas y reconocer productos notables.', 1),
  ('Ecuaciones y sistemas de primer grado', 'Resolver problemas que involucran ecuaciones y sistemas de ecuaciones de primer grado con una y dos incógnitas.', 2),
  ('Factorización de expresiones algebraicas', 'Factorizar expresiones algebraicas utilizando factor común y productos notables.', 3),
  ('Función lineal como modelo', 'Modelar situaciones cotidianas mediante la función lineal, analizando su gráfico y su pendiente.', 4),
  ('Sistemas de ecuaciones: métodos de resolución', 'Resolver sistemas de dos ecuaciones lineales con dos incógnitas mediante los métodos de sustitución, igualación y reducción.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Álgebra') and name = 'Álgebra — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 1° Medio', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Geometría.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Primer Nivel Medio", ver supabase/seed/0001, aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Semejanza y teorema de Thales', 'Aplicar semejanza de figuras planas, dibujos a escala y el teorema de Thales.', 0),
  ('Transformaciones isométricas', 'Aplicar transformaciones isométricas (traslación, reflexión, rotación) en diversos contextos.', 1),
  ('Perímetro, área y volumen de cuerpos geométricos', 'Resolver problemas que involucran perímetro, área y volumen de cuerpos geométricos.', 2),
  ('Trigonometría en el triángulo rectángulo', 'Introducir las razones trigonométricas (seno, coseno, tangente) en el triángulo rectángulo.', 3),
  ('Vectores en el plano', 'Representar vectores en el plano y aplicar la suma y resta de vectores en la resolución de problemas geométricos.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Probabilidad y Estadística — 1° Medio', 'Objetivos de aprendizaje de Matemática, eje Probabilidad y Estadística, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Probabilidad y Estadística'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Probabilidad y Estadística.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje. Contenido consistente con el temario EPJA D.S. 257/2009 para "Primer Nivel Medio", ver supabase/seed/0001, aunque los decretos son distintos. Código OA y texto literal del D.S. 614/2013 pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Medidas de tendencia central con datos agrupados', 'Calcular e interpretar medidas de tendencia central con datos agrupados y no agrupados.', 0),
  ('Regla de Laplace', 'Calcular la probabilidad de un suceso usando la regla de Laplace.', 1),
  ('Tablas de frecuencia y gráficos', 'Interpretar información presentada en tablas de frecuencia y en gráficos de barras o circulares.', 2),
  ('Variable aleatoria discreta simple', 'Introducir el concepto de variable aleatoria discreta a partir de experimentos simples.', 3),
  ('Diseño de un estudio estadístico simple', 'Diseñar y llevar a cabo un estudio estadístico simple para responder una pregunta de interés.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Probabilidad y Estadística') and name = 'Probabilidad y Estadística — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° MEDIO (order_index de nivel = 110)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 2° Medio', 'Objetivos de aprendizaje de Matemática, eje Números, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Números.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Raíces enésimas y potencias de exponente racional', 'Resolver problemas que involucran raíces enésimas y potencias de exponente racional.', 0),
  ('Operatoria con números reales', 'Resolver problemas que involucran operatoria con números reales.', 1),
  ('Aproximaciones con números reales', 'Aplicar aproximaciones y estimaciones con números reales en la resolución de problemas.', 2),
  ('Racionalización de expresiones con raíces', 'Racionalizar expresiones numéricas simples que contienen raíces en el denominador.', 3),
  ('Intervalos numéricos', 'Representar y operar con intervalos de números reales en la recta numérica.', 4),
  ('Logaritmos como herramienta de cálculo', 'Introducir el concepto de logaritmo como herramienta para resolver problemas de crecimiento y decrecimiento.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Números') and name = 'Números — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Álgebra — 2° Medio', 'Objetivos de aprendizaje de Matemática, eje Álgebra, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Álgebra'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Álgebra.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ecuaciones cuadráticas', 'Resolver problemas que involucran ecuaciones cuadráticas de una incógnita, mediante factorización o la fórmula general.', 0),
  ('Función cuadrática', 'Analizar la función cuadrática a partir de su representación gráfica y algebraica.', 1),
  ('Sistemas de inecuaciones lineales', 'Resolver problemas que involucran sistemas de inecuaciones lineales con una incógnita.', 2),
  ('Discriminante y naturaleza de las raíces', 'Analizar el discriminante de una ecuación cuadrática para determinar la naturaleza de sus raíces.', 3),
  ('Modelamiento con función cuadrática', 'Modelar situaciones cotidianas y físicas (por ejemplo, trayectorias) mediante la función cuadrática.', 4),
  ('Sistemas de ecuaciones lineales y cuadráticas', 'Resolver problemas que combinan sistemas de ecuaciones lineales con ecuaciones cuadráticas simples.', 5)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Álgebra') and name = 'Álgebra — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geometría — 2° Medio', 'Objetivos de aprendizaje de Matemática, eje Geometría, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Geometría'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Geometría.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Razones trigonométricas', 'Aplicar razones trigonométricas (seno, coseno, tangente) en la resolución de problemas con triángulos rectángulos.', 0),
  ('Teorema de Pitágoras y sus recíprocos', 'Aplicar el teorema de Pitágoras y sus recíprocos en la resolución de problemas.', 1),
  ('Cuerpos geométricos compuestos', 'Determinar el volumen y el área de cuerpos geométricos compuestos.', 2),
  ('Vectores en el plano cartesiano', 'Aplicar operatoria de vectores (suma, resta, ponderación por escalar) en el plano cartesiano.', 3),
  ('Ángulos de elevación y depresión', 'Resolver problemas que involucran ángulos de elevación y depresión usando razones trigonométricas.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Geometría') and name = 'Geometría — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Probabilidad y Estadística — 2° Medio', 'Objetivos de aprendizaje de Matemática, eje Probabilidad y Estadística, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Probabilidad y Estadística'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), Matemática, eje Probabilidad y Estadística.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Medidas de dispersión', 'Comparar poblaciones a partir de sus medidas de tendencia central y de dispersión.', 0),
  ('Probabilidad condicional', 'Interpretar el concepto de probabilidad condicional en situaciones cotidianas.', 1),
  ('Permutaciones y combinaciones', 'Aplicar el cálculo de permutaciones y combinaciones en la resolución de problemas.', 2),
  ('Variable aleatoria discreta y su distribución', 'Analizar la distribución de una variable aleatoria discreta simple y calcular su valor esperado.', 3),
  ('Independencia de eventos', 'Determinar si dos eventos son independientes a partir de sus probabilidades condicionales.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Probabilidad y Estadística') and name = 'Probabilidad y Estadística — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
