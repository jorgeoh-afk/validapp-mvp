-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Matemática, 3° y 4° Medio, Formación General.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA -- decreto VERIFICADO en esta pasada
-- ============================================================================
-- Fuente citada: Bases Curriculares de 3° y 4° Medio (Formación General),
-- MINEDUC, aprobadas por el DECRETO SUPREMO N.° 193 DE 2019 (Subsecretaría de
-- Educación), publicado en el Diario Oficial en torno al 3 de septiembre de
-- 2019. Vigencia progresiva desde 2020 (3° Medio) y 2021 (4° Medio).
--
-- ACTUALIZACIÓN RESPECTO DE LA VERSIÓN ANTERIOR DE ESTE ARCHIVO -- el número
-- de decreto quedó explícitamente SIN VERIFICAR en la primera versión (este
-- agente no tiene acceso a navegación web en este entorno). En esta pasada,
-- el coordinador de la sesión realizó la búsqueda web fuera del alcance de
-- este agente y aportó el dato con dos fuentes públicas/oficiales
-- verificables:
--   - Biblioteca del Congreso Nacional, Ley Chile: idNorma=1136078
--     (https://www.bcn.cl/leychile/navegar?idNorma=1136078).
--   - MINEDUC, Currículum Nacional (curriculumnacional.cl):
--     https://www.curriculumnacional.cl/614/w3-article-133992.html y
--     https://www.curriculumnacional.cl/portal/Documentos-Curriculares/Bases-curriculares/91414:Bases-Curriculares-3-y-4-Medio
-- Este agente no navegó esas URL directamente (sigue sin herramientas de
-- navegación web en este entorno); registra el dato como aportado y citado
-- por una fuente externa verificable, no como verificación propia línea por
-- línea del texto de la ley. Antes de marcar cualquier fila de este archivo
-- como `status = 'aprobado'`, se recomienda que un humano (o un agente con
-- acceso de navegación) confirme directamente el contenido en esas URL.
--
-- IMPORTANTE -- qué SÍ cambia y qué NO cambia con este dato:
--   - SÍ cambia: `curricular_source` ahora cita el Decreto 193/2019 en vez de
--     dejarlo como descripción sin número; `reference_year` pasa de NULL a
--     2019 (año del decreto, mismo criterio que 0011 con 439/2012 y 0012 con
--     614/2013: se registra el año del decreto, no el año de vigencia
--     progresiva).
--   - NO cambia: el texto de cada objetivo sigue siendo una PARÁFRASIS
--     ValidApp, no una cita textual del PDF oficial. `official_text` y
--     `code` (código OA oficial) siguen NULL en todas las filas. Conocer el
--     decreto correcto no resuelve la incertidumbre sobre el ALCANCE
--     PEDAGÓGICO específico de ciertos objetivos (ver advertencia de 4°
--     Medio más abajo) -- son dos preguntas distintas: "¿qué decreto rige?"
--     (ya resuelta) vs. "¿qué dice exactamente y con qué alcance ese
--     decreto sobre este objetivo puntual?" (sigue sin resolver para los
--     objetivos marcados con confianza BAJA).
--   - Por lo mismo, TODAS las filas siguen en `status = 'borrador'`. Ningún
--     objetivo se promueve a `'aprobado'` en esta pasada: `aprobado` requiere
--     fuente verificable Y revisión pedagógica del contenido específico, y
--     aquí solo se resolvió la primera condición (fuente/decreto), no la
--     segunda (revisión pedagógica línea por línea del texto de cada OA).
--
-- Confianza en los 4 ejes temáticos (Números; Álgebra y Funciones; Geometría;
-- Probabilidad y Estadística): MEDIA-ALTA (subida desde MEDIA en la versión
-- anterior, ahora que el decreto que los ampara está identificado). Estos
-- mismos 4 nombres ya existen en el esquema porque ValidApp cargó el temario
-- EPJA "Primer Nivel Medio" bajo D.S. 257/2009 con esos ejes (ver
-- supabase/seed/0001), y la reforma de 3°-4° Medio mantiene una estructura de
-- ejes similar a la de 7° Básico-2° Medio.
--
-- Confianza en el TEXTO Y LA PROGRESIÓN de contenidos: MEDIA para 3° Medio
-- (funciones exponenciales/logarítmicas, teorema del seno/coseno, vectores,
-- medidas de dispersión, variable aleatoria -- contenidos bien documentados
-- de la reforma). BAJA-MEDIA para 4° Medio, en particular para los tópicos
-- más recientes de la reforma 2019 (inferencia estadística, intervalos de
-- confianza, y nociones introductorias de tasa de variación/cálculo): este
-- agente reconoce explícitamente no tener certeza plena sobre el alcance
-- exacto y la redacción oficial de esos objetivos en particular. Esta duda es
-- de CONTENIDO PEDAGÓGICO, no de decreto -- sigue en pie aunque el decreto ya
-- esté identificado (ver nota de la fila correspondiente, marcada vía CASE en
-- el SQL de más abajo).
--
-- Por todo lo anterior:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - Todas las filas quedan `status = 'borrador'`.
--   - `pedagogical_notes` distingue, fila por fila, entre el texto estándar
--     (confianza MEDIA, decreto verificado) y el texto reforzado de CONFIANZA
--     BAJA para los objetivos de 4° Medio más sensibles (tasa de variación
--     media/su relación con la pendiente de la secante, e
--     inferencia/intervalos de confianza/errores de interpretación
--     estadística).
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes x 2 cursos (3° y 4° Medio) = 8 combinaciones eje-curso, cada
-- una con 1 unidad y entre 5 y 6 objetivos de aprendizaje curados (ampliado
-- desde la versión inicial de 3 objetivos "semilla" por eje/curso). Álgebra y
-- Funciones lleva 6 objetivos por curso; Números, Geometría y Probabilidad y
-- Estadística llevan 5 -- SOLO Formación General. Siguen siendo
-- representativos, NO exhaustivos.
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
-- `learning_objectives`. Aunque el decreto ya está identificado, seguimos sin
-- crear una fila en `curriculum_frameworks` en este archivo: ese modelo se
-- diseñó para el problema específico de EPJA (varios decretos vigentes en
-- paralelo por período de examinación), no para el Currículum Regular, que no
-- tiene ese concepto de período de examinación a nivel de base curricular.
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
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Números.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Operatoria con números reales en contexto', 'Resolver problemas que involucran operatoria con números reales en contextos financieros y científicos.', 0),
  ('Logaritmo como inverso de la potencia', 'Aplicar el concepto de logaritmo como inverso de la potencia en la resolución de problemas.', 1),
  ('Notación científica', 'Estimar y aproximar resultados usando notación científica.', 2),
  ('Interés compuesto y crecimiento exponencial', 'Resolver problemas de interés compuesto y crecimiento exponencial en contextos financieros.', 3),
  ('Propiedades de los logaritmos', 'Aplicar las propiedades de los logaritmos (producto, cociente, potencia) en la resolución de problemas.', 4)
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
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Álgebra y Funciones.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Funciones potencia, exponencial y logarítmica', 'Analizar el comportamiento de funciones potencia, exponencial y logarítmica a partir de su representación gráfica.', 0),
  ('Modelamiento con funciones exponenciales y logarítmicas', 'Modelar situaciones cotidianas y científicas usando funciones exponenciales y logarítmicas.', 1),
  ('Ecuaciones exponenciales y logarítmicas', 'Resolver problemas que involucran ecuaciones exponenciales y logarítmicas.', 2),
  ('Función inversa', 'Determinar la función inversa de una función biyectiva simple y su representación gráfica.', 3),
  ('Composición de funciones', 'Aplicar la composición de funciones y analizar su representación gráfica.', 4),
  ('Modelos de crecimiento y decrecimiento en ciencias', 'Analizar modelos de crecimiento y decrecimiento poblacional o de sustancias radiactivas mediante funciones exponenciales.', 5)
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
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Geometría.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Teorema del seno y del coseno', 'Aplicar el teorema del seno y del coseno en la resolución de problemas de triángulos oblicuángulos.', 0),
  ('Vectores en el plano cartesiano', 'Representar puntos, rectas y figuras en el plano cartesiano usando vectores.', 1),
  ('Figuras 3D y proyecciones', 'Resolver problemas geométricos que involucran figuras 3D y sus proyecciones.', 2),
  ('Resolución de triángulos oblicuángulos', 'Resolver problemas de triángulos oblicuángulos combinando el teorema del seno y del coseno.', 3),
  ('Aplicaciones de vectores en física', 'Aplicar la operatoria de vectores en la resolución de problemas de física (desplazamiento, fuerza).', 4)
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
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Probabilidad y Estadística.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Medidas de dispersión', 'Interpretar y comparar distribuciones de datos usando medidas de dispersión (varianza, desviación estándar).', 0),
  ('Variable aleatoria discreta', 'Aplicar el modelo de probabilidad de una variable aleatoria discreta.', 1),
  ('Distribución normal', 'Interpretar la distribución normal como modelo de una variable aleatoria continua.', 2),
  ('Comparación de distribuciones de datos', 'Comparar dos o más distribuciones de datos usando medidas de tendencia central y de dispersión en conjunto.', 3),
  ('Curva normal y su uso en la toma de decisiones', 'Interpretar la curva normal y su relación con la toma de decisiones basada en datos.', 4)
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
-- encabezado): los objetivos de "Tasa de variación media" / su relación con
-- la pendiente de la secante (Álgebra y Funciones) y de inferencia
-- estadística / intervalos de confianza / errores de interpretación
-- (Probabilidad y Estadística) tocan los tópicos más recientes/menos
-- consolidados en el conocimiento de este agente sobre esta reforma
-- específica -- se marcan con CONFIANZA BAJA individualmente vía CASE en el
-- SQL de más abajo, no solo por el motivo general de la advertencia de
-- cabecera. Esta incertidumbre es de ALCANCE PEDAGÓGICO (si corresponden a
-- Formación General y con qué profundidad), no de decreto -- el decreto ya
-- está identificado (193/2019) para las 4 filas por igual.
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Números — 4° Medio', 'Objetivos de aprendizaje de Matemática, eje Números, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Matemática') and s.name = 'Números'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Números.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Interés simple y compuesto', 'Resolver problemas financieros que involucran interés simple y compuesto.', 0),
  ('Sucesiones y progresiones', 'Aplicar el concepto de sucesiones y progresiones aritméticas y geométricas en la resolución de problemas.', 1),
  ('Crecimiento y decrecimiento exponencial', 'Analizar situaciones que involucran crecimiento y decrecimiento exponencial en contextos financieros y científicos.', 2),
  ('Aplicaciones financieras de sucesiones', 'Aplicar sucesiones y progresiones en la resolución de problemas financieros (ahorro, deuda).', 3),
  ('Comparación de modelos de crecimiento', 'Comparar modelos de crecimiento lineal, cuadrático y exponencial en contextos financieros y científicos.', 4)
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
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Álgebra y Funciones.',
  2019,
  case v.short_name
    when 'Tasa de variación media' then
      'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (tópico reciente de la reforma 2019, ver advertencia adicional de 4° Medio en este archivo). Decreto verificado (193/2019), pero la incertidumbre aquí es de ALCANCE PEDAGÓGICO -- si "tasa de variación media" corresponde a Formación General o a Formación Diferenciada, y con qué profundidad -- no sobre qué decreto rige. Código OA y texto literal pendientes de verificar antes de marcar como aprobado; revisar con especial cuidado pedagógico.'
    when 'Relación entre tasa de variación media y pendiente' then
      'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (extensión directa de "Tasa de variación media", mismo tópico reciente de la reforma 2019, ver advertencia adicional de 4° Medio). Decreto verificado (193/2019), pero la incertidumbre es de alcance pedagógico -- si este nivel de introducción al concepto de derivada corresponde efectivamente a Formación General -- no de decreto. Código OA y texto literal pendientes de verificar antes de marcar como aprobado; revisar con especial cuidado pedagógico.'
    else
      'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.'
  end,
  v.order_index
from (values
  ('Funciones a trozos', 'Analizar el comportamiento de funciones a trozos y su aplicación en contextos reales.', 0),
  ('Optimización con funciones cuadráticas', 'Resolver problemas de optimización que involucran funciones cuadráticas.', 1),
  ('Tasa de variación media', 'Interpretar el concepto de tasa de variación media y su relación intuitiva con el concepto de derivada.', 2),
  ('Análisis de gráficos de funciones en contexto', 'Interpretar gráficos de funciones en contextos cotidianos, científicos y económicos, describiendo su comportamiento cualitativo.', 3),
  ('Modelamiento con funciones definidas por tramos', 'Modelar situaciones cotidianas mediante funciones definidas por tramos.', 4),
  ('Relación entre tasa de variación media y pendiente', 'Relacionar la tasa de variación media de una función con la pendiente de la recta secante entre dos puntos de su gráfico.', 5)
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
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Geometría.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Cuerpos geométricos y transformaciones en el espacio', 'Resolver problemas cotidianos que involucran cuerpos geométricos y sus transformaciones en el espacio.', 0),
  ('Vectores en problemas geométricos y físicos', 'Aplicar el concepto de vectores en el plano para resolver problemas geométricos y físicos.', 1),
  ('Herramientas tecnológicas para lugares geométricos', 'Utilizar herramientas tecnológicas para representar y analizar lugares geométricos.', 2),
  ('Aplicaciones de la geometría analítica', 'Resolver problemas que involucran la ecuación de la recta y su relación con lugares geométricos.', 3),
  ('Proyecciones y sombras', 'Analizar situaciones cotidianas que involucran proyecciones y sombras usando semejanza de triángulos y trigonometría.', 4)
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
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Matemática, eje Probabilidad y Estadística.',
  2019,
  case v.short_name
    when 'Estudio estadístico e inferencia' then
      'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (inferencia estadística, tópico reciente de la reforma 2019, ver advertencia adicional de 4° Medio en este archivo). Decreto verificado (193/2019), pero la incertidumbre es de ALCANCE PEDAGÓGICO -- profundidad y redacción exacta del tratamiento de inferencia en Formación General -- no de decreto. Código OA y texto literal pendientes de verificar antes de marcar como aprobado; revisar con especial cuidado pedagógico.'
    when 'Intervalos de confianza' then
      'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (intervalos de confianza, tópico reciente de la reforma 2019, ver advertencia adicional de 4° Medio en este archivo). Decreto verificado (193/2019), pero la incertidumbre es de alcance pedagógico -- no de decreto. Código OA y texto literal pendientes de verificar antes de marcar como aprobado; revisar con especial cuidado pedagógico.'
    when 'Errores en la toma de decisiones basada en datos' then
      'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (asociado al mismo bloque de inferencia estadística introductoria de la reforma 2019). Decreto verificado (193/2019), pero la incertidumbre es de alcance pedagógico -- no de decreto. Código OA y texto literal pendientes de verificar antes de marcar como aprobado; revisar con especial cuidado pedagógico.'
    else
      'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto verificado (193/2019, ver encabezado del archivo), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.'
  end,
  v.order_index
from (values
  ('Estudio estadístico e inferencia', 'Diseñar y llevar a cabo un estudio estadístico para responder una pregunta de interés, aplicando conceptos de inferencia.', 0),
  ('Intervalos de confianza', 'Interpretar intervalos de confianza en el contexto de un estudio estadístico.', 1),
  ('Variable aleatoria continua', 'Aplicar el concepto de variable aleatoria continua y su distribución en la resolución de problemas.', 2),
  ('Muestreo aleatorio y representatividad', 'Analizar la importancia del muestreo aleatorio para la representatividad de un estudio estadístico.', 3),
  ('Errores en la toma de decisiones basada en datos', 'Reconocer errores comunes en la interpretación de estudios estadísticos y su impacto en la toma de decisiones.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Matemática') and name = 'Probabilidad y Estadística') and name = 'Probabilidad y Estadística — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
