-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Lengua y Literatura, 7° Básico a 2° Medio.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA
-- ============================================================================
-- Fuente citada: Bases Curriculares de 7° Básico a 2° Medio, MINEDUC,
-- aprobadas por el Decreto Supremo N.° 614 de 2013. Implementación
-- progresiva 2015-2019 según el propio decreto (por curso) -- mismo decreto
-- único multi-asignatura que ya rige Matemática en esta banda (ver
-- supabase/seed/0012_curriculum_matematica_regular_7basico_2medio.sql),
-- verificado por el coordinador de esta sesión.
--
-- DENOMINACIÓN OFICIAL DE LA ASIGNATURA EN ESTA BANDA: se usa "Lengua y
-- Literatura" en este archivo (mismo nombre que reemplaza a "Lenguaje y
-- Comunicación" a partir de 7° Básico, según el conocimiento general de este
-- agente sobre la reforma 2013). CONFIANZA MEDIA -- a diferencia de 3°-4°
-- Medio (ver supabase/seed/0016), este dato NO fue verificado por búsqueda
-- web por el coordinador en esta sesión; es un recuerdo de este agente sobre
-- la nomenclatura de Bases Curriculares 2013, no una cita confirmada. Se dejó
-- constancia explícita de este nivel de confianza en `curricular_source` y
-- `pedagogical_notes` de cada fila para que un administrador humano lo
-- verifique antes de aprobar cualquier contenido.
--
-- Confianza en los 4 ejes temáticos de esta banda (Lectura; Escritura;
-- Comunicación Oral; Investigación -- este último es nuevo respecto de
-- 1°-6° Básico, ver supabase/seed/0014) y en la progresión general de
-- contenidos (análisis literario creciente, argumentación, exposición e
-- investigación cada vez más formales): MEDIA. Confianza en el TEXTO EXACTO
-- y la NUMERACIÓN OFICIAL ("OA n") de cada objetivo de este decreto: BAJA
-- -- no hay PDF de esta fuente específica cargado ni verificado en este
-- entorno. Por eso, igual que en 0011/0012/0013/0014:
--   - `official_text` y `code` quedan NULL en todas las filas.
--   - Todas las filas quedan `status = 'borrador'`.
--   - `pedagogical_notes` repite la advertencia en cada objetivo.
--
-- ============================================================================
-- DECISIÓN SOBRE EL NOMBRE DE LA ASIGNATURA (subjects.name)
-- ============================================================================
-- Misma decisión documentada en el encabezado de
-- supabase/seed/0014_curriculum_lenguaje_regular_basica_1_6.sql: se reutiliza
-- la única fila de `subjects` ("Lengua Castellana y Comunicación",
-- canonical_code = 'language', creada por EPJA en 0002), en vez de crear una
-- fila nueva para "Lengua y Literatura". No se repite aquí el razonamiento
-- completo -- ver ese archivo. La denominación oficial de ESTA banda ("Lengua
-- y Literatura", confianza MEDIA) se registra explícitamente en
-- `curricular_source`/`pedagogical_notes` de cada objetivo, nunca en
-- `subjects.name`.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes x 4 cursos (7° Básico, 8° Básico, 1° Medio, 2° Medio) = 16
-- combinaciones eje-curso, cada una con 1 unidad. Lectura lleva 5 objetivos
-- por curso (mayor peso relativo); Escritura, Comunicación Oral e
-- Investigación llevan 4 cada uno. Representativos, NO exhaustivos.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades, Grandes
-- ideas ni Conocimientos esenciales (mismo alcance que 0011-0014).
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects (0016 migración)
-- ============================================================================
-- Mismo motivo documentado en 0011/0012/0013/0014: `exam_period` NOT NULL en
-- `curriculum_frameworks` no tiene equivalente en el Currículum Regular. Se
-- usa `curricular_source`/`reference_year`/`pedagogical_notes` en
-- `learning_objectives`.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011-0014: `on conflict do nothing` para
-- subjects/strands/units, `on conflict do update` limitado a las columnas
-- propias de este archivo para `learning_objectives`. `level_id` por
-- `levels.code`, `subject_id` por `subjects.name`. Seed SOLO local: no se ha
-- ejecutado contra Supabase.

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
-- "Lectura", "Escritura" y "Comunicación Oral" ya existen (creados por
-- 0014) -- se reutilizan sin modificar. Se crea el eje nuevo de esta banda:
-- "Investigación" (subtítulo distinto de los ejes de 1°-6° Básico).
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Lengua Castellana y Comunicación'),
   'Investigación', 'Formulación de preguntas de investigación, búsqueda y evaluación de fuentes, y comunicación de resultados.', 4)
on conflict (subject_id, name) do nothing;

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================

-- ---------------------------------------------------------------------
-- 7° BÁSICO (order_index de nivel = 107)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 7° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Lectura, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, no verificada por búsqueda web esta sesión, ver encabezado de este archivo; distinta del nombre "Lengua Castellana y Comunicación" bajo el que está catalogada esta asignatura en subjects.name), eje Lectura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Narrador, tiempo y espacio en textos literarios', 'Analizar textos literarios (novela, cuento, poema) considerando narrador, tiempo y espacio.', 0),
  ('Hechos y opiniones en textos no literarios', 'Comprender textos no literarios, distinguiendo hechos de opiniones y evaluando la confiabilidad de la fuente.', 1),
  ('Figuras literarias y su función expresiva', 'Interpretar figuras literarias presentes en un texto y su función expresiva.', 2),
  ('Comparación de perspectivas sobre un tema', 'Comparar textos que abordan un mismo tema desde distintas perspectivas.', 3),
  ('Interpretación propia apoyada en evidencia textual', 'Formular una interpretación propia de un texto, apoyada en evidencia extraída del mismo.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 7° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Escritura, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Textos narrativos y líricos con recursos literarios', 'Producir textos narrativos y líricos aplicando recursos literarios trabajados en clase.', 0),
  ('Textos argumentativos breves', 'Producir textos argumentativos breves con tesis, argumentos y conclusión.', 1),
  ('Proceso de escritura autónomo', 'Aplicar de manera autónoma un proceso de escritura: planificación, escritura, revisión y edición.', 2),
  ('Ortografía y gramática crecientes', 'Aplicar normas de ortografía y gramática de manera creciente en la producción de textos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 7° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Comunicación Oral, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Exposición oral con apoyo audiovisual', 'Planificar y realizar una exposición oral usando apoyo audiovisual.', 0),
  ('Debates formales con respeto', 'Participar en debates formales, contrastando argumentos con respeto.', 1),
  ('Escucha crítica de un discurso oral', 'Escuchar críticamente un discurso oral, analizando el punto de vista presentado.', 2),
  ('Registro formal e informal según la situación', 'Usar el registro formal o informal adecuado según la situación comunicativa.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Investigación — 7° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Investigación, para 7° Básico.', 107
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Investigación'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Investigación.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado. CONFIANZA ADICIONAL BAJA en que "Investigación" sea, específicamente en 7° Básico, un eje declarado desde el primer año de esta banda (podría introducirse más adelante en la progresión) -- revisar con especial cuidado.',
  v.order_index
from (values
  ('Investigación guiada sobre un tema de interés', 'Planificar y desarrollar una investigación guiada sobre un tema de interés.', 0),
  ('Selección y evaluación de fuentes', 'Seleccionar y evaluar fuentes de información impresas y digitales pertinentes al tema investigado.', 1),
  ('Organización de la información recopilada', 'Organizar la información recopilada en esquemas o resúmenes.', 2),
  ('Comunicación de resultados de una investigación', 'Comunicar los resultados de una investigación en un texto o presentación.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Investigación') and name = 'Investigación — 7° Básico') as u
cross join (select id from public.levels where code = 'regular_7_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 8° BÁSICO (order_index de nivel = 108)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 8° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Lectura, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comparación de obras de distintas épocas y culturas', 'Comparar obras literarias de distintas épocas y culturas.', 0),
  ('Comprensión crítica de textos de los medios', 'Comprender críticamente textos de los medios de comunicación (noticias, reportajes, columnas de opinión).', 1),
  ('Lenguaje figurado y simbólico', 'Interpretar el lenguaje figurado y simbólico presente en textos poéticos y narrativos.', 2),
  ('Validez de los argumentos de un texto', 'Evaluar la validez de los argumentos presentados en un texto.', 3),
  ('Relación del texto con su contexto histórico y social', 'Relacionar un texto leído con su contexto histórico y social de producción.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 8° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Escritura, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Textos argumentativos con estructura completa', 'Producir textos argumentativos con estructura completa y variedad de argumentos.', 0),
  ('Textos creativos con recursos estilísticos propios', 'Producir textos creativos (cuento, poema) incorporando recursos estilísticos propios.', 1),
  ('Reescritura con coherencia, cohesión y corrección', 'Reescribir y editar un texto aplicando criterios de coherencia, cohesión y corrección idiomática.', 2),
  ('Vocabulario amplio adecuado al género', 'Usar un vocabulario amplio y preciso, adecuado al género textual producido.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 8° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Comunicación Oral, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Discursos orales con propósito persuasivo', 'Organizar y presentar discursos orales con propósito persuasivo.', 0),
  ('Foros o mesas redondas defendiendo una postura', 'Participar en foros o mesas redondas, defendiendo una postura con argumentos.', 1),
  ('Análisis crítico de discursos audiovisuales', 'Analizar críticamente discursos audiovisuales (publicidad, noticieros).', 2),
  ('Recursos verbales y no verbales efectivos', 'Usar de manera efectiva recursos verbales y no verbales en la comunicación oral.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Investigación — 8° Básico', 'Objetivos de aprendizaje de Lengua y Literatura, eje Investigación, para 8° Básico.', 108
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Investigación'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Investigación.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Preguntas de investigación relevantes', 'Formular preguntas de investigación relevantes sobre un tema.', 0),
  ('Contrastación de fuentes diversas', 'Contrastar información proveniente de diversas fuentes para verificar su validez.', 1),
  ('Citación básica de fuentes', 'Citar de manera básica las fuentes consultadas, evitando el plagio.', 2),
  ('Informe de investigación con conclusiones propias', 'Elaborar un informe de investigación con conclusiones propias.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Investigación') and name = 'Investigación — 8° Básico') as u
cross join (select id from public.levels where code = 'regular_8_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 1° MEDIO (order_index de nivel = 109)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 1° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Lectura, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Estructura y visión de mundo de obras completas', 'Analizar obras literarias completas (novela, obra dramática) considerando su estructura y visión de mundo.', 0),
  ('Comprensión de ensayos y textos argumentativos complejos', 'Comprender e interpretar ensayos y textos argumentativos complejos.', 1),
  ('Contexto de producción y recepción de una obra', 'Analizar el contexto de producción y recepción de una obra literaria.', 2),
  ('Perspectiva y sesgos de un texto no literario', 'Evaluar la perspectiva y los posibles sesgos presentes en un texto no literario.', 3),
  ('Relaciones intertextuales entre obras', 'Establecer relaciones intertextuales entre distintas obras leídas.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 1° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Escritura, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ensayos breves que plantean y defienden una tesis', 'Producir ensayos breves que plantean y defienden una tesis.', 0),
  ('Textos literarios con distintos recursos y estilos', 'Producir textos literarios explorando distintos recursos y estilos.', 1),
  ('Proceso de escritura recursivo', 'Aplicar un proceso de escritura recursivo, con múltiples instancias de revisión.', 2),
  ('Convenciones de la lengua escrita', 'Aplicar con dominio creciente las convenciones de ortografía, sintaxis y puntuación.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 1° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Comunicación Oral, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Disertaciones orales con rigor argumentativo', 'Planificar y desarrollar disertaciones orales con rigor argumentativo.', 0),
  ('Debates sobre temas contingentes', 'Participar en debates sobre temas contingentes, considerando distintas posturas.', 1),
  ('Análisis crítico del discurso público', 'Analizar críticamente el discurso público (político, publicitario).', 2),
  ('Estrategias de persuasión oral de manera ética', 'Usar estrategias de persuasión oral de manera ética.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Investigación — 1° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Investigación, para 1° Medio.', 109
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Investigación'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Investigación.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Proyecto de investigación con objetivos y metodología', 'Diseñar un proyecto de investigación con objetivos y una metodología simple.', 0),
  ('Confiabilidad de fuentes digitales', 'Evaluar críticamente la confiabilidad y pertinencia de fuentes digitales.', 1),
  ('Síntesis de múltiples fuentes en un texto propio', 'Sintetizar información proveniente de múltiples fuentes en un texto propio.', 2),
  ('Presentación de resultados en distintos formatos', 'Presentar los resultados de una investigación en distintos formatos: escrito, oral, multimedial.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Investigación') and name = 'Investigación — 1° Medio') as u
cross join (select id from public.levels where code = 'regular_1_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° MEDIO (order_index de nivel = 110)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Lectura — 2° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Lectura, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Lectura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Lectura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Obras de distintos movimientos o períodos', 'Analizar comparativamente obras literarias representativas de distintos movimientos o períodos.', 0),
  ('Interpretación de textos filosóficos y ensayísticos', 'Interpretar críticamente textos filosóficos y ensayísticos.', 1),
  ('Recursos retóricos en discursos públicos', 'Analizar el uso del lenguaje y los recursos retóricos en discursos públicos.', 2),
  ('Argumentación y falacias en un texto', 'Evaluar la argumentación y detectar posibles falacias presentes en un texto.', 3),
  ('Interpretación personal fundamentada de una obra', 'Elaborar una interpretación personal fundamentada de una obra literaria completa.', 4)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Lectura') and name = 'Lectura — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Escritura — 2° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Escritura, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Escritura'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Escritura.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ensayos argumentativos con contraargumentación', 'Producir ensayos argumentativos con tesis compleja y contraargumentación.', 0),
  ('Textos literarios con intención estética definida', 'Producir textos literarios con una intención estética definida.', 1),
  ('Revisión aplicando criterios de estilo y registro', 'Revisar y editar textos propios aplicando criterios de estilo y registro.', 2),
  ('Uso autónomo y correcto de convenciones', 'Usar de manera autónoma y correcta las convenciones de la lengua escrita.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Escritura') and name = 'Escritura — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comunicación Oral — 2° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Comunicación Oral, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Comunicación Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Comunicación Oral.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Discurso persuasivo sobre un tema controversial', 'Desarrollar un discurso persuasivo sobre un tema controversial.', 0),
  ('Panel de discusión sintetizando posturas', 'Participar en un panel de discusión, sintetizando y contrastando posturas.', 1),
  ('Análisis crítico de argumentación en medios masivos', 'Analizar críticamente la argumentación presente en medios de comunicación masivos.', 2),
  ('Adecuación a contextos comunicativos formales', 'Adecuar el discurso oral a distintos contextos comunicativos formales.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Comunicación Oral') and name = 'Comunicación Oral — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Investigación — 2° Medio', 'Objetivos de aprendizaje de Lengua y Literatura, eje Investigación, para 2° Medio.', 110
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and s.name = 'Investigación'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares 7° Básico a 2° Medio, MINEDUC (Decreto Supremo N.° 614/2013), denominación oficial probable de la asignatura en esta banda: "Lengua y Literatura" (confianza MEDIA, ver encabezado de este archivo), eje Investigación.',
  2013,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Investigación monográfica literaria o social', 'Desarrollar una investigación monográfica sobre un tema literario o social.', 0),
  ('Jerarquización de fuentes según pertinencia', 'Evaluar y jerarquizar fuentes según su pertinencia y confiabilidad.', 1),
  ('Citas y referencias bibliográficas', 'Elaborar citas y referencias bibliográficas siguiendo un formato dado.', 2),
  ('Comunicación clara de conclusiones', 'Comunicar las conclusiones de una investigación de manera clara y fundamentada.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Lengua Castellana y Comunicación') and name = 'Investigación') and name = 'Investigación — 2° Medio') as u
cross join (select id from public.levels where code = 'regular_2_medio') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
