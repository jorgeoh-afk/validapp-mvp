-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Lengua y Literatura, 3° y 4° Medio, Formación General.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA -- decreto y denominación VERIFICADOS
-- ============================================================================
-- Fuente citada: Bases Curriculares de 3° y 4° Medio (Formación General),
-- MINEDUC, aprobadas por el DECRETO SUPREMO N.° 193 DE 2019 (Subsecretaría de
-- Educación), publicado en el Diario Oficial en torno al 3 de septiembre de
-- 2019. Vigencia progresiva desde 2020 (3° Medio) y 2021 (4° Medio). Mismo
-- decreto que ya rige Matemática en esta banda (ver
-- supabase/seed/0013_curriculum_matematica_regular_3_4medio.sql).
--
-- DENOMINACIÓN OFICIAL DE LA ASIGNATURA: "Lengua y Literatura" (no "Lenguaje
-- y Comunicación", nombre usado en Básica y en 1°-2° Medio, ver
-- supabase/seed/0014 y 0015). CONFIANZA ALTA -- este dato fue aportado y
-- verificado por el coordinador de esta sesión vía búsqueda web, con dos
-- fuentes públicas/oficiales citadas explícitamente en el encabezado de
-- 0013_curriculum_matematica_regular_3_4medio.sql (BCN Ley Chile,
-- idNorma=1136078; MINEDUC Currículum Nacional,
-- curriculumnacional.cl/614/w3-article-133992.html). Este agente no navegó
-- esas URL directamente (sin herramientas de navegación web en este
-- entorno); registra el dato como aportado y citado por una fuente externa
-- verificable, no como verificación propia línea por línea del texto oficial.
--
-- IMPORTANTE -- qué SÍ y qué NO resuelve esta verificación (mismo criterio
-- que 0013): SÍ resuelve qué decreto rige y cuál es el nombre oficial de la
-- asignatura para esta banda. NO resuelve el TEXTO EXACTO ni la NUMERACIÓN
-- OFICIAL ("OA n") de cada objetivo puntual -- esa es una pregunta distinta,
-- sin verificar. Por eso:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - TODAS las filas quedan `status = 'borrador'` (ninguna se promueve a
--     'aprobado': aprobado exige fuente verificable Y revisión pedagógica del
--     contenido específico; aquí solo la primera condición está resuelta).
--   - `pedagogical_notes` distingue explícitamente, en cada fila, entre "el
--     decreto y el nombre de la asignatura están verificados" y "el texto de
--     este objetivo puntual sigue siendo paráfrasis ValidApp sin verificar".
--
-- Confianza en los 4 ejes temáticos (Lectura; Escritura; Comunicación Oral;
-- Investigación -- mismos 4 ejes que 7° Básico-2° Medio, ver
-- supabase/seed/0015, dado que "Lengua y Literatura" mantiene esta
-- estructura de ejes en ambas bandas según el conocimiento de este agente):
-- MEDIA-ALTA. Confianza en la progresión de contenidos: MEDIA -- análisis
-- literario y argumentativo de mayor profundidad y autonomía, propio del
-- cierre de la Enseñanza Media, es una expectativa razonable pero no
-- verificada línea por línea contra el PDF oficial de esta banda específica.
--
-- ============================================================================
-- DECISIÓN SOBRE EL NOMBRE DE LA ASIGNATURA (subjects.name)
-- ============================================================================
-- Misma decisión documentada en el encabezado de
-- supabase/seed/0014_curriculum_lenguaje_regular_basica_1_6.sql: se reutiliza
-- la única fila de `subjects` ("Lengua Castellana y Comunicación",
-- canonical_code = 'language'). No se repite aquí el razonamiento completo.
-- La denominación oficial de ESTA banda ("Lengua y Literatura", confianza
-- ALTA) se registra explícitamente en `curricular_source`/`pedagogical_notes`
-- de cada objetivo, nunca en `subjects.name`.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes x 2 cursos (3° y 4° Medio) = 8 combinaciones eje-curso, cada
-- una con 1 unidad -- SOLO Formación General. Lectura lleva 5 objetivos por
-- curso; Escritura, Comunicación Oral e Investigación llevan 4 cada uno.
-- Representativos, NO exhaustivos.
--
-- NO cubre Formación Diferenciada (asignaturas electivas de 3°-4° Medio,
-- p. ej. "Literatura e Identidad" o "Participación y argumentación en
-- democracia"): quedan explícitamente fuera de alcance, mismo criterio que
-- 0013 con la Formación Diferenciada de Matemática.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades, Grandes
-- ideas ni Conocimientos esenciales.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects (0016 migración)
-- ============================================================================
-- Mismo motivo documentado en 0011-0015: `exam_period` NOT NULL en
-- `curriculum_frameworks` no tiene equivalente en el Currículum Regular.
-- Aunque el decreto y el nombre de la asignatura ya están identificados, se
-- sigue sin crear una fila en `curriculum_frameworks` -- ese modelo se
-- diseñó para el problema específico de EPJA (varios decretos vigentes en
-- paralelo por período de examinación), no para el Currículum Regular.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011-0015. Seed SOLO local: no se ha ejecutado contra
-- Supabase.

-- ============================================================================
-- 1) Asignatura (reutiliza "Lengua Castellana y Comunicación", ver decisión
--    arriba y en 0014)
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Lengua Castellana y Comunicación', 'language')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- Los 4 ejes de esta banda ("Lectura", "Escritura", "Comunicación Oral",
-- "Investigación") ya existen en el esquema (creados por 0014 y 0015). Se
-- reutilizan sin modificar -- no se inserta ningún eje nuevo en este
-- archivo.

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 3° MEDIO (order_index de nivel = 111)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 3° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Lectura, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo; distinta del nombre "Lengua Castellana y Comunicación" bajo el que está catalogada esta asignatura en subjects.name), eje Lectura.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Valor estético y contexto de producción de obras completas', 'Analizar obras literarias completas considerando su valor estético y su relación con el contexto de producción.', 0),
  ('Comprensión crítica de ensayos y artículos de opinión', 'Comprender críticamente textos no literarios de diversa complejidad, como ensayos y artículos de opinión.', 1),
  ('Voz narrativa, punto de vista y recursos estilísticos', 'Interpretar la voz narrativa, el punto de vista y los recursos estilísticos de una obra literaria.', 2),
  ('Interpretaciones propias contrastadas con otras', 'Formular interpretaciones propias sobre una obra, contrastándolas con otras interpretaciones existentes.', 3),
  ('Pertinencia y validez de argumentos en textos diversos', 'Evaluar la pertinencia y validez de los argumentos presentados en textos de diversa índole.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 3° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Escritura, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo), eje Escritura.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ensayo con interpretación personal de una obra', 'Producir un ensayo que desarrolla una interpretación personal de una obra literaria.', 0),
  ('Textos que combinan distintos propósitos comunicativos', 'Producir textos que combinan distintos propósitos comunicativos: informar, argumentar y narrar.', 1),
  ('Proceso de escritura con foco en la voz propia', 'Aplicar un proceso de escritura completo y recursivo, con foco en el desarrollo de una voz propia.', 2),
  ('Revisión con criterios explícitos de calidad', 'Revisar textos propios y de pares aplicando criterios explícitos de calidad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 3° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Comunicación Oral, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo), eje Comunicación Oral.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Presentación oral formal sobre una obra o tema', 'Planificar y realizar una presentación oral formal sobre una obra literaria o un tema de interés.', 0),
  ('Discusiones literarias defendiendo interpretaciones', 'Participar en discusiones literarias, formulando y defendiendo interpretaciones propias.', 1),
  ('Análisis crítico de discursos públicos', 'Analizar críticamente discursos orales públicos, identificando su intención comunicativa.', 2),
  ('Registro formal en contextos académicos', 'Usar un registro formal adecuado a distintos contextos académicos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Investigación — 3° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Investigación, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Investigación'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo), eje Investigación.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Tema y preguntas de investigación literaria o cultural', 'Formular un tema y preguntas de investigación de carácter literario o cultural.', 0),
  ('Búsqueda y evaluación de fuentes especializadas', 'Buscar, seleccionar y evaluar fuentes especializadas pertinentes al tema investigado.', 1),
  ('Organización de la información evitando el plagio', 'Organizar la información en un texto propio, evitando el plagio mediante citación adecuada.', 2),
  ('Comunicación de resultados en formato académico simple', 'Comunicar los resultados de una investigación en un formato académico simple.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Investigación') and name = 'Investigación — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° MEDIO (order_index de nivel = 112)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 4° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Lectura, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo), eje Lectura.',
  2019,
  case v.short_name
    when 'Diálogo de una obra con su tradición literaria' then
      'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (evaluar cómo una obra "dialoga" con su tradición literaria y el contexto contemporáneo es un tópico más interpretativo y menos estandarizado que el resto del eje). Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero la incertidumbre aquí es de ALCANCE PEDAGÓGICO -- profundidad y redacción exacta esperada en Formación General -- no de decreto. Código OA y texto literal pendientes de verificar antes de marcar como aprobado; revisar con especial cuidado pedagógico.'
    else
      'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.'
  end,
  v.order_index
from (values
  ('Obras de la tradición hispanoamericana y universal', 'Analizar obras literarias representativas de la tradición hispanoamericana y universal.', 0),
  ('Problemáticas éticas, sociales o filosóficas en los textos', 'Comprender e interpretar críticamente textos que abordan problemáticas éticas, sociales o filosóficas.', 1),
  ('Diálogo de una obra con su tradición literaria', 'Evaluar el modo en que una obra dialoga con su tradición literaria y con el contexto contemporáneo.', 2),
  ('Argumentación y retórica en discursos contemporáneos', 'Analizar la argumentación y la retórica presentes en discursos públicos contemporáneos.', 3),
  ('Postura crítica frente a las obras y textos leídos', 'Construir una postura crítica y fundamentada frente a las obras y textos leídos.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 4° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Escritura, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo), eje Escritura.',
  2019,
  case v.short_name
    when 'Reflexión sobre el propio proceso de escritura' then
      'Paráfrasis ValidApp; CONFIANZA BAJA específica en este objetivo (la reflexión metacognitiva explícita sobre el propio proceso de autor es un tópico de nivel más avanzado y menos estandarizado, propio del cierre de la reforma 2019). Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero la incertidumbre es de ALCANCE PEDAGÓGICO -- no de decreto. Código OA y texto literal pendientes de verificar antes de marcar como aprobado; revisar con especial cuidado pedagógico.'
    else
      'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.'
  end,
  v.order_index
from (values
  ('Ensayo argumentativo complejo', 'Producir un ensayo argumentativo complejo sobre un tema literario o de interés público.', 0),
  ('Textos de intención literaria con estilo propio', 'Producir textos de intención literaria, evidenciando un estilo propio.', 1),
  ('Revisión autónoma con atención al registro y léxico', 'Revisar y editar textos de manera autónoma, con atención al registro y a la precisión léxica.', 2),
  ('Reflexión sobre el propio proceso de escritura', 'Reflexionar sobre el propio proceso de escritura y las decisiones tomadas como autor.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 4° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Comunicación Oral, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo), eje Comunicación Oral.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Discurso oral con postura personal fundamentada', 'Diseñar y presentar un discurso oral que sintetiza una postura personal fundamentada.', 0),
  ('Debates formales sobre temas de relevancia social', 'Participar en debates formales sobre temas de relevancia social o cultural.', 1),
  ('Análisis crítico del discurso persuasivo en medios', 'Analizar críticamente el discurso persuasivo presente en distintos medios y soportes.', 2),
  ('Evaluación de la propia comunicación oral', 'Evaluar la propia comunicación oral y la de otros a partir de criterios explícitos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Investigación — 4° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Investigación, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Investigación'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura "Lengua y Literatura" (decreto y nombre verificados, ver encabezado de este archivo), eje Investigación.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Decreto y nombre de asignatura verificados (193/2019, "Lengua y Literatura"), pero código OA y texto literal del objetivo siguen pendientes de verificar línea por línea antes de marcar como aprobado.',
  v.order_index
from (values
  ('Proyecto de investigación personal literario o social', 'Diseñar un proyecto de investigación personal sobre un tema literario, cultural o social.', 0),
  ('Integración crítica de múltiples fuentes', 'Integrar críticamente múltiples fuentes en la construcción de un texto propio.', 1),
  ('Normas de citación y referencias bibliográficas', 'Aplicar de manera consistente normas de citación y referencias bibliográficas.', 2),
  ('Comunicación de resultados a audiencia académica', 'Comunicar los resultados de una investigación en un formato adecuado a la audiencia académica.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Investigación') and name = 'Investigación — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
