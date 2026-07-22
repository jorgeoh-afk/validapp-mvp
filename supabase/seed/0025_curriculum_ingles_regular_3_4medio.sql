-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Idioma Extranjero: Inglés, 3° y 4° Medio, Formación General.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA -- decreto VERIFICADO, nombre de asignatura
-- CON UNA INCERTIDUMBRE RESIDUAL EXPLÍCITA
-- ============================================================================
-- Fuente citada: Bases Curriculares de 3° y 4° Medio (Formación General),
-- MINEDUC, aprobadas por el DECRETO SUPREMO N.° 193 DE 2019 (Subsecretaría de
-- Educación), publicado en el Diario Oficial en torno al 3 de septiembre de
-- 2019. Vigencia progresiva desde 2020 (3° Medio) y 2021 (4° Medio). Mismo
-- decreto que ya rige Matemática (supabase/seed/0013) y Lengua y Literatura
-- (supabase/seed/0016) en esta banda.
--
-- CONFIANZA ALTA en que Inglés es una de las 6 asignaturas del Plan de
-- Formación General de 3°-4° Medio (junto a Lengua y Literatura, Matemáticas,
-- Educación Ciudadana, Filosofía y Ciencias para la Ciudadanía), es decir,
-- CONTINÚA como asignatura de Formación General SIN la divergencia real que
-- sí tuvieron Ciencias Naturales (que se transforma en "Ciencias para la
-- Ciudadanía", ver supabase/seed/0019) e Historia (ver supabase/seed/0022)
-- en esta banda. Este dato fue aportado y verificado por el coordinador de
-- esta sesión vía búsqueda web realizada hoy, con dos fuentes citadas
-- explícitamente: BCN LeyChile (idNorma=1136078) y MINEDUC Currículum
-- Nacional (curriculumnacional.cl/614/w3-article-133992.html). Este agente
-- no navegó esas URL directamente (sin herramientas de navegación web en este
-- entorno); registra el dato como aportado y citado por una fuente externa
-- verificable, no como verificación propia línea por línea del texto oficial.
--
-- INCERTIDUMBRE RESIDUAL EXPLÍCITA sobre la DENOMINACIÓN EXACTA de la
-- asignatura en esta banda -- CONFIANZA MEDIA, NO ALTA: es razonablemente
-- posible que el nombre oficial exacto en el Plan de Formación General de
-- 3°-4° Medio sea simplemente "Inglés" (forma abreviada, consistente con
-- cómo suele listarse esta asignatura en tablas de asignaturas de Formación
-- General en fuentes de divulgación de curriculumnacional.cl) en vez de
-- "Idioma Extranjero: Inglés" (la denominación más formal usada en el resto
-- de la escolaridad y ya cargada en `subjects.name` por el temario EPJA, ver
-- supabase/seed/0002 y supabase/seed/0023/0024). Este agente NO tiene forma
-- de confirmar cuál de las dos formas aparece literalmente en el Decreto
-- Supremo N.° 193/2019 sin acceso a navegación web en este entorno, y el
-- coordinador de la sesión tampoco aportó ese dato específico (solo confirmó
-- que Inglés SÍ pertenece a las 6 asignaturas de Formación General, no el
-- nombre exacto en el decreto).
--
-- DECISIÓN: se REUTILIZA la fila de `subjects` ya existente
-- ("Idioma Extranjero: Inglés", canonical_code = 'english') para esta banda,
-- en vez de crear una fila nueva ("Inglés"), por el mismo motivo documentado
-- en supabase/seed/0014 para Lenguaje: `subjects.name` es UNIQUE y
-- `subjects.canonical_code` tiene un índice único parcial -- crear una
-- segunda fila fragmentaría el reporting de "Inglés" como asignatura única a
-- lo largo de toda la escolaridad, y la eventual diferencia de nombre es de
-- ROTULACIÓN/ETIQUETA (posible forma abreviada), NO una divergencia real de
-- contenido/enfoque como la de Ciencias Naturales o Historia en esta misma
-- banda. La denominación oficial de ESTA banda ("Inglés" o "Idioma
-- Extranjero: Inglés", sin resolver cuál es la forma exacta del decreto) se
-- registra explícitamente, con la incertidumbre completa, en
-- `curricular_source` y `pedagogical_notes` de cada objetivo de este
-- archivo -- nunca se fabrica ni se pisa en `subjects.name`.
--
-- Confianza en los 4 ejes temáticos (mismos que 0023/0024: Comprensión
-- Auditiva; Comprensión Lectora; Expresión Oral; Expresión Escrita) y en la
-- progresión de contenidos (nivel B1-B2: comprensión crítica, argumentación,
-- ensayo, presentaciones formales): MEDIA -- análogo al criterio aplicado a
-- Lengua y Literatura en 0016. Confianza en el TEXTO EXACTO y la NUMERACIÓN
-- OFICIAL de cada Objetivo de Aprendizaje: BAJA, mismo motivo que
-- 0011-0024. Por eso:
--   - `code` se deja NULL en todas las filas.
--   - TODAS las filas quedan en `status = 'borrador'`.
--   - `pedagogical_notes` distingue explícitamente, en cada fila, entre "el
--     decreto y la pertenencia de Inglés al Plan de Formación General están
--     verificados" y "el nombre exacto de la asignatura en el decreto y el
--     texto de cada objetivo puntual siguen sin verificar".
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes x 2 cursos (3° y 4° Medio) = 8 combinaciones eje-curso, cada
-- una con 1 unidad y 4 objetivos (32 objetivos en total) -- SOLO Formación
-- General. Representativos, NO exhaustivos.
--
-- NO cubre Formación Diferenciada (asignaturas electivas de 3°-4° Medio):
-- fuera de alcance, mismo criterio que 0013/0016/0019/0022.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades.
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects
-- ============================================================================
-- Mismo motivo documentado en 0011-0024: `exam_period` NOT NULL en
-- `curriculum_frameworks` no tiene equivalente en el Currículum Regular.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011-0024. Los 4 ejes ya existen (creados por
-- supabase/seed/0023) -- este archivo NO inserta ejes nuevos. Seed SOLO
-- local: no se ha ejecutado contra Supabase.

-- ============================================================================
-- 1) Asignatura (reutiliza "Idioma Extranjero: Inglés", ver decisión arriba
--    y en supabase/seed/0023)
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Idioma Extranjero: Inglés', 'english')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
-- Los 4 ejes de esta banda ("Comprensión Auditiva", "Comprensión Lectora",
-- "Expresión Oral", "Expresión Escrita") ya existen en el esquema (creados
-- por 0023). Se reutilizan sin modificar -- no se inserta ningún eje nuevo
-- en este archivo.

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 3° MEDIO (order_index de nivel = 111)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 3° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia de Inglés al Plan de Formación General verificada; nombre EXACTO en el decreto -- "Inglés" vs "Idioma Extranjero: Inglés" -- NO verificado, ver encabezado de este archivo; catalogada en subjects.name como "Idioma Extranjero: Inglés"), eje Comprensión Auditiva.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1-B2); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de discursos orales auténticos de mayor complejidad', 'Comprender discursos orales auténticos (podcasts, entrevistas, noticias) de mayor complejidad.', 0),
  ('Identificación de matices de significado en un discurso oral', 'Identificar matices de significado, ironía o énfasis en un discurso oral.', 1),
  ('Síntesis de la información relevante de un texto oral', 'Sintetizar la información relevante de un texto oral extenso.', 2),
  ('Evaluación crítica de un mensaje oral', 'Evaluar críticamente la intención y el punto de vista de un mensaje oral.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 3° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia al Plan de Formación General verificada; nombre exacto en el decreto no verificado, ver encabezado de este archivo), eje Comprensión Lectora.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1-B2); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de textos académicos o de divulgación', 'Comprender textos académicos o de divulgación científica de complejidad creciente.', 0),
  ('Análisis crítico de la argumentación de un texto', 'Analizar críticamente la argumentación, las evidencias y los supuestos de un texto.', 1),
  ('Interpretación de recursos retóricos en un texto', 'Interpretar recursos retóricos (ironía, comparación, énfasis) presentes en un texto.', 2),
  ('Investigación y contraste de fuentes en inglés', 'Investigar un tema utilizando y contrastando distintas fuentes escritas en inglés.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 3° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia al Plan de Formación General verificada; nombre exacto en el decreto no verificado, ver encabezado de este archivo), eje Expresión Oral.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1-B2); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Presentación oral formal con apoyo de recursos', 'Planificar y realizar una presentación oral formal, con apoyo de recursos audiovisuales.', 0),
  ('Argumentación oral con evidencia y contraargumentos', 'Argumentar oralmente una postura, considerando evidencia y posibles contraargumentos.', 1),
  ('Participación en discusiones académicas', 'Participar en discusiones de carácter académico, fundamentando las ideas propias.', 2),
  ('Evaluación de la propia producción oral', 'Evaluar la propia producción oral y la de pares a partir de criterios explícitos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 3° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 3° Medio (Formación General).', 111
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia al Plan de Formación General verificada; nombre exacto en el decreto no verificado, ver encabezado de este archivo), eje Expresión Escrita.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B1-B2); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Redacción de un ensayo con tesis y argumentos', 'Redactar un ensayo con una tesis clara y argumentos organizados coherentemente.', 0),
  ('Uso de un registro académico en la escritura', 'Usar un registro académico y vocabulario preciso en la producción escrita.', 1),
  ('Investigación y citación de fuentes en un texto propio', 'Incorporar información de fuentes externas en un texto propio, citándolas adecuadamente.', 2),
  ('Revisión recursiva de un texto con foco en la voz propia', 'Revisar de manera recursiva un texto propio, cuidando la coherencia y el desarrollo de una voz propia.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 3° Medio') as u
cross join (select id from public.levels where code = 'regular_3_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° MEDIO (order_index de nivel = 112)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 4° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia al Plan de Formación General verificada; nombre exacto en el decreto no verificado, ver encabezado de este archivo), eje Comprensión Auditiva.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B2, cierre de la Enseñanza Media); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de discursos orales complejos sobre temas diversos', 'Comprender discursos orales complejos sobre temas sociales, culturales o científicos.', 0),
  ('Análisis crítico de la intención comunicativa de un discurso oral', 'Analizar críticamente la intención comunicativa y los recursos persuasivos de un discurso oral.', 1),
  ('Comprensión de debates o paneles de discusión', 'Comprender debates o paneles de discusión con múltiples posturas.', 2),
  ('Evaluación de la confiabilidad de un discurso oral', 'Evaluar la confiabilidad y el sesgo de un discurso oral informativo.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 4° Medio', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia al Plan de Formación General verificada; nombre exacto en el decreto no verificado, ver encabezado de este archivo), eje Comprensión Lectora.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B2, cierre de la Enseñanza Media); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión crítica de textos complejos y de diversa índole', 'Comprender críticamente textos complejos de diversa índole: académicos, periodísticos, literarios.', 0),
  ('Evaluación de la validez de los argumentos de un texto', 'Evaluar la validez y pertinencia de los argumentos presentados en un texto.', 1),
  ('Análisis comparativo de textos con posturas distintas', 'Analizar comparativamente textos que presentan posturas distintas sobre un mismo tema.', 2),
  ('Construcción de una postura crítica frente a lo leído', 'Construir una postura crítica y fundamentada frente a un texto leído.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 4° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia al Plan de Formación General verificada; nombre exacto en el decreto no verificado, ver encabezado de este archivo), eje Expresión Oral.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B2, cierre de la Enseñanza Media); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Discurso oral formal con postura personal fundamentada', 'Diseñar y presentar un discurso oral formal que exprese una postura personal fundamentada.', 0),
  ('Participación en debates formales sobre temas de actualidad', 'Participar en debates formales sobre temas de actualidad, defendiendo y refutando posturas.', 1),
  ('Análisis crítico oral de discursos públicos en inglés', 'Analizar críticamente, en una exposición oral, discursos públicos en inglés (charlas, discursos, entrevistas).', 2),
  ('Evaluación de la comunicación oral propia y ajena', 'Evaluar la propia comunicación oral y la de otros, a partir de criterios explícitos de fluidez y pertinencia.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 4° Medio', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 4° Medio (Formación General).', 112
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares de 3° y 4° Medio (Formación General), MINEDUC, Decreto Supremo N.° 193 de 2019, asignatura Inglés (pertenencia al Plan de Formación General verificada; nombre exacto en el decreto no verificado, ver encabezado de este archivo), eje Expresión Escrita.',
  2019,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel B2, cierre de la Enseñanza Media); no es cita textual del PDF oficial. Decreto y pertenencia al Plan de Formación General verificados (193/2019), pero el nombre exacto de la asignatura en el decreto, el código OA y el texto literal del objetivo siguen pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Redacción de un ensayo argumentativo complejo', 'Redactar un ensayo argumentativo complejo sobre un tema social, cultural o científico.', 0),
  ('Integración crítica de múltiples fuentes en un texto propio', 'Integrar críticamente múltiples fuentes en la construcción de un texto propio, citándolas de manera consistente.', 1),
  ('Adecuación del texto escrito a un propósito y audiencia específicos', 'Adecuar un texto escrito a un propósito comunicativo y una audiencia específicos.', 2),
  ('Reflexión sobre el propio proceso de escritura en inglés', 'Reflexionar sobre el propio proceso de escritura en inglés y las decisiones tomadas como autor.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 4° Medio') as u
cross join (select id from public.levels where code = 'regular_4_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
