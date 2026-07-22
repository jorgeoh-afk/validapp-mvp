-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Historia, Geografía y Ciencias Sociales, 1° a 6° Básico.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA (léase antes de aprobar cualquier fila)
-- ============================================================================
-- Fuente citada: Bases Curriculares de Educación Básica, MINEDUC, aprobadas
-- por el Decreto Supremo N.° 439 de 2012 (1° a 6° Básico, asignatura
-- Historia, Geografía y Ciencias Sociales). Vigencia progresiva desde 2013.
-- Mismo decreto que ya rige Matemática (supabase/seed/0011) y Lenguaje
-- (supabase/seed/0014) en esta banda.
--
-- Confianza en la denominación de los 3 ejes temáticos (Historia; Geografía;
-- Formación Ciudadana) y en que estos son subtítulos declarados por el propio
-- documento MINEDUC (no una agrupación propuesta por ValidApp): MEDIA-ALTA.
-- Es la misma estructura de 3 ejes usada consistentemente por MINEDUC para
-- esta asignatura en Educación Básica y en 7° Básico-2° Medio (ver
-- supabase/seed/0018). No se agrega un cuarto eje "Economía": en este tramo
-- los contenidos económicos que existen se integran dentro de Historia o
-- Formación Ciudadana, no como eje separado (a diferencia de lo que ocurre en
-- el temario EPJA D.S. 257/2009, que sí declara "Dimensión Geográfica y
-- Económica" como un eje combinado propio para Segundo Nivel Medio -- ver más
-- abajo la nota sobre por qué no se reutilizan los ejes de EPJA).
--
-- Confianza en la progresión general de contenidos por curso (de la historia
-- personal/familiar en 1° Básico, pasando por pueblos originarios y conquista
-- en 3°-4° Básico, hasta civilizaciones antiguas e independencia de Chile en
-- 5°-6° Básico): MEDIA. Es una progresión ampliamente conocida y estable del
-- currículo chileno, pero este agente no tiene acceso a herramientas de
-- navegación web ni al PDF oficial en este entorno para verificar el detalle
-- curso por curso.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL de cada Objetivo de
-- Aprendizaje (código "OA n" tal como aparece en el PDF de Bases
-- Curriculares): BAJA. Por eso, mismo criterio que 0011/0014:
--   - `official_text` se deja NULL en todas las filas.
--   - `code` (código OA oficial) se deja NULL en todas las filas.
--   - TODAS las filas quedan en `status = 'borrador'` (nunca 'aprobado').
--   - `pedagogical_notes` repite esta advertencia en cada objetivo.
--
-- ============================================================================
-- DECISIÓN SOBRE EL NOMBRE DE LA ASIGNATURA (subjects.name)
-- ============================================================================
-- Ya existe una fila de `subjects` llamada "Estudios Sociales"
-- (canonical_code = 'social_sciences'), creada por
-- supabase/seed/0002_epja_remaining_subjects.sql para el temario EPJA D.S.
-- 257/2009. Se reutiliza esa misma fila para el Currículum Regular en este
-- archivo, en vez de crear una fila nueva "Historia, Geografía y Ciencias
-- Sociales": ambas denominaciones cubren la misma área de conocimiento
-- (historia, geografía y formación ciudadana) y mezclarlas bajo un único
-- registro de catálogo sigue el mismo criterio ya aplicado en
-- supabase/seed/0014 (que reutiliza "Lengua Castellana y Comunicación" para
-- lo que Bases Curriculares llama oficialmente "Lenguaje y Comunicación").
-- La denominación oficial exacta de esta banda ("Historia, Geografía y
-- Ciencias Sociales", D.S. 439/2012) se registra explícitamente en
-- `curricular_source`/`pedagogical_notes` de cada objetivo, nunca se escribe
-- en `subjects.name`.
--
-- ============================================================================
-- POR QUÉ NO SE REUTILIZAN LOS EJES DE EPJA ("Dimensión Histórica", etc.)
-- ============================================================================
-- supabase/seed/0002 ya creó, bajo la misma fila de `subjects` ("Estudios
-- Sociales"), los ejes "Dimensión Histórica", "Dimensión Formación
-- Ciudadana" y "Dimensión Geográfica y Económica" -- pero esos son los
-- subtítulos EXACTOS y propios del temario EPJA (D.S. 257/2009), un
-- documento y una organización de contenidos distinta a las Bases
-- Curriculares del Currículum Regular (D.S. 439/2012). Reutilizar esos
-- nombres aquí implicaría atribuir a Bases Curriculares una nomenclatura
-- ("Dimensión...", "...y Económica" combinado en un solo eje) que no es la
-- suya. Por eso este archivo crea 3 ejes NUEVOS y propios del Currículum
-- Regular: "Historia", "Geografía" y "Formación Ciudadana" (sin el prefijo
-- "Dimensión" y con Geografía separada de lo Económico) -- mismo criterio
-- que 0012, que crea un eje "Álgebra" nuevo y distinto aunque EPJA ya tuviera
-- ejes de Matemática con otros nombres.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: los 3 ejes temáticos oficiales x 6 cursos (1° a 6° Básico) = 18
-- combinaciones eje-curso, cada una con 1 unidad y 4 objetivos de aprendizaje
-- curados. Se usa el mismo número de objetivos (4) en los 3 ejes de cada
-- curso -- a diferencia de Matemática/Lenguaje, este agente no tiene base
-- suficiente para justificar una ponderación distinta entre ejes en esta
-- asignatura, así que se optó por una distribución pareja en vez de inventar
-- un peso relativo no verificado. Representativos, NO exhaustivos.
--
-- No cubre: banco de preguntas, lecciones, ensayos, habilidades, Grandes
-- ideas ni Conocimientos esenciales (mismo alcance que 0011/0014).
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects (0016)
-- ============================================================================
-- Mismo motivo documentado en supabase/seed/0011: esas tablas modelan
-- versiones curriculares EPJA con período de examinación obligatorio
-- (`exam_year`/`exam_period` NOT NULL), concepto que no aplica al Currículum
-- Regular. Se usa `curricular_source`/`reference_year`/`pedagogical_notes` en
-- `learning_objectives`.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011/0014: `on conflict do nothing` para
-- subjects/strands/units (catálogo compartido, no se pisa contenido ya
-- editado por un administrador), `on conflict do update` limitado a las
-- columnas propias de este archivo para learning_objectives. `level_id` por
-- `levels.code`, `subject_id` por `subjects.name`. Seed SOLO local: no se ha
-- ejecutado contra ningún proyecto Supabase (ni dev ni producción).

-- ============================================================================
-- 1) Asignatura: reutiliza "Estudios Sociales" (creada por EPJA, ver decisión
--    arriba)
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Estudios Sociales', 'social_sciences')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos (nuevos, propios del Currículum Regular -- ver decisión
--    arriba sobre por qué no se reutilizan los ejes "Dimensión..." de EPJA)
-- ============================================================================
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Estudios Sociales'),
   'Historia', 'Procesos, hitos, personajes y fuentes históricas de Chile y el mundo.', 0)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Estudios Sociales'),
   'Geografía', 'Ubicación espacial, paisajes, recursos naturales y relación entre territorio y sociedad.', 1)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Estudios Sociales'),
   'Formación Ciudadana', 'Convivencia, derechos y deberes, instituciones y participación democrática.', 2)
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
select s.id, 'Historia — 1° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Historia.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Línea de tiempo personal y familiar', 'Secuenciar hitos de la propia historia y de la historia familiar en una línea de tiempo simple.', 0),
  ('Cambios y permanencias en la vida cotidiana', 'Reconocer cambios y permanencias en la vida cotidiana de la familia a lo largo del tiempo.', 1),
  ('Costumbres y tradiciones familiares', 'Describir costumbres, tradiciones y celebraciones propias de la familia y la comunidad.', 2),
  ('Símbolos patrios y efemérides', 'Reconocer los símbolos patrios y el significado de efemérides relevantes para la comunidad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 1° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Ubicación de lugares cotidianos', 'Ubicar lugares de la vida cotidiana (casa, escuela, barrio) usando referentes espaciales simples.', 0),
  ('Trayectos y puntos de referencia cercanos', 'Describir trayectos cotidianos utilizando puntos de referencia del entorno cercano.', 1),
  ('Paisaje geográfico del entorno', 'Describir las principales características del paisaje geográfico del entorno cercano.', 2),
  ('Representación simple de espacios conocidos', 'Representar espacios conocidos mediante dibujos y maquetas simples.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 1° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 1° Básico.', 101
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Normas y acuerdos de convivencia en el aula', 'Reconocer la importancia de normas y acuerdos de convivencia en la sala de clases.', 0),
  ('Diversidad de las familias', 'Reconocer y respetar la diversidad de conformaciones familiares presentes en la comunidad.', 1),
  ('Roles y responsabilidades en la familia y la escuela', 'Identificar roles y responsabilidades propias y de otros en la familia y en la escuela.', 2),
  ('Trabajo colaborativo simple', 'Participar en actividades colaborativas simples, respetando turnos y opiniones distintas.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 1° Básico') as u
cross join (select id from public.levels where code = 'regular_1_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 2° BÁSICO (order_index de nivel = 102)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 2° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Historia.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Unidades convencionales de tiempo', 'Ubicar hechos y actividades en una línea de tiempo usando unidades convencionales (día, semana, mes, año).', 0),
  ('Costumbres de pueblos originarios de Chile', 'Describir costumbres y formas de vida de algunos pueblos originarios de Chile.', 1),
  ('Comparación de la vida cotidiana en distintas épocas', 'Comparar aspectos de la vida cotidiana del pasado y del presente a partir de evidencia simple.', 2),
  ('Efemérides de la comunidad', 'Reconocer efemérides relevantes para la comunidad y el país.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 2° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Planos simples del entorno', 'Interpretar y elaborar planos simples de espacios conocidos, como la sala de clases o el barrio.', 0),
  ('Paisajes geográficos de Chile', 'Reconocer distintos tipos de paisajes geográficos de Chile (urbano, rural, costero, montañoso).', 1),
  ('Recursos naturales y su cuidado', 'Reconocer recursos naturales del entorno y la importancia de su cuidado.', 2),
  ('Actividades humanas y el entorno geográfico', 'Describir cómo distintas actividades humanas se relacionan con las características del entorno geográfico.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 2° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 2° Básico.', 102
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Derechos y deberes de los niños', 'Reconocer derechos y deberes propios de los niños y niñas en la familia, la escuela y la comunidad.', 0),
  ('Instituciones cercanas de la comunidad', 'Identificar instituciones cercanas de la comunidad (junta de vecinos, municipalidad, escuela) y su función.', 1),
  ('Resolución de conflictos cotidianos', 'Proponer formas pacíficas y dialogadas de resolver conflictos cotidianos.', 2),
  ('Trabajo colaborativo con roles simples', 'Participar en trabajos colaborativos asumiendo roles simples y respetando acuerdos comunes.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 2° Básico') as u
cross join (select id from public.levels where code = 'regular_2_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 3° BÁSICO (order_index de nivel = 103)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 3° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Historia.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Pueblos originarios de Chile: formas de vida', 'Describir formas de vida y organización de pueblos originarios que habitaron el territorio de Chile.', 0),
  ('Llegada de los españoles y proceso de conquista', 'Caracterizar el proceso de llegada de los españoles y de conquista del territorio actual de Chile.', 1),
  ('Mestizaje y sincretismo cultural', 'Reconocer el mestizaje y el sincretismo cultural como resultado del encuentro entre españoles e indígenas.', 2),
  ('Uso de fuentes históricas simples', 'Obtener información sobre el pasado a partir de fuentes históricas simples (imágenes, objetos, relatos).', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 3° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Zonas y paisajes de Chile', 'Reconocer las principales zonas y paisajes de Chile (Norte, Centro, Sur, Austral) y sus características.', 0),
  ('Recursos naturales y actividades económicas asociadas', 'Relacionar recursos naturales de distintas zonas de Chile con actividades económicas asociadas.', 1),
  ('Uso de mapas y simbología cartográfica básica', 'Utilizar mapas y simbología cartográfica básica para ubicar lugares y elementos geográficos.', 2),
  ('Cuidado del entorno natural', 'Proponer acciones simples para el cuidado del entorno natural cercano.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 3° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 3° Básico.', 103
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Diversidad cultural de Chile', 'Reconocer y valorar la diversidad cultural presente en Chile, incluyendo pueblos originarios y migrantes.', 0),
  ('Instituciones y autoridades locales', 'Identificar instituciones y autoridades locales y su rol en la comunidad.', 1),
  ('Participación y trabajo en equipo', 'Participar en actividades grupales aportando ideas y respetando acuerdos.', 2),
  ('Normas de convivencia en distintos espacios', 'Reconocer la importancia de normas de convivencia en distintos espacios de la comunidad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 3° Básico') as u
cross join (select id from public.levels where code = 'regular_3_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 4° BÁSICO (order_index de nivel = 104)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 4° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Historia.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Civilizaciones americanas: mayas, aztecas e incas', 'Describir formas de organización política, social y cultural de civilizaciones americanas como los mayas, aztecas e incas.', 0),
  ('Proceso de conquista de América', 'Caracterizar el proceso de conquista de América y sus principales consecuencias.', 1),
  ('Legado indígena y español en la sociedad actual', 'Reconocer elementos del legado indígena y español presentes en la sociedad chilena actual.', 2),
  ('Líneas de tiempo y fuentes históricas', 'Elaborar líneas de tiempo y utilizar fuentes primarias y secundarias simples para estudiar el pasado.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 4° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Continentes y océanos del mundo', 'Ubicar los continentes y océanos del mundo en mapas y globos terráqueos.', 0),
  ('Zonas climáticas y vida humana', 'Relacionar las zonas climáticas del mundo con las formas de vida humana que se desarrollan en ellas.', 1),
  ('Regiones de Chile y sus características', 'Describir las regiones de Chile y sus principales características geográficas.', 2),
  ('Interpretación de mapas temáticos simples', 'Interpretar información geográfica presentada en mapas temáticos simples.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 4° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 4° Básico.', 104
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Organización básica del Estado', 'Reconocer nociones básicas sobre la organización del Estado y sus poderes públicos.', 0),
  ('Origen de los derechos humanos', 'Reconocer el origen y la importancia de los derechos humanos como acuerdos compartidos por la humanidad.', 1),
  ('Convivencia democrática en la escuela', 'Practicar formas de convivencia democrática en la escuela, como la elección de representantes.', 2),
  ('Diversidad y respeto en la comunidad escolar', 'Reconocer la diversidad presente en la comunidad escolar y la importancia de un trato respetuoso.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 4° Básico') as u
cross join (select id from public.levels where code = 'regular_4_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 5° BÁSICO (order_index de nivel = 105)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 5° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Historia.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Civilizaciones antiguas de Mesopotamia y Egipto', 'Describir características de las civilizaciones de Mesopotamia y Egipto y sus principales aportes.', 0),
  ('Legado de Grecia y Roma en la civilización occidental', 'Reconocer aportes de la civilización griega y romana presentes en la civilización occidental actual.', 1),
  ('Nociones generales de la Edad Media europea', 'Describir aspectos generales de la organización social y política de la Edad Media europea.', 2),
  ('Comparación de fuentes históricas diversas', 'Comparar información sobre un mismo hecho histórico a partir de distintas fuentes.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 5° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Relieve, hidrografía y clima de Chile por zonas', 'Describir el relieve, la hidrografía y el clima de las distintas zonas de Chile.', 0),
  ('Recursos naturales renovables y no renovables', 'Distinguir recursos naturales renovables y no renovables y su uso en la economía chilena.', 1),
  ('Riesgos naturales y prevención', 'Reconocer riesgos naturales presentes en el territorio chileno y medidas de prevención.', 2),
  ('Relación entre geografía y actividades económicas', 'Relacionar las características geográficas de una zona con las actividades económicas que se desarrollan en ella.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 5° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Organización política y territorial de Chile', 'Describir la organización política y territorial de Chile (regiones, provincias, comunas).', 0),
  ('Poderes del Estado', 'Distinguir los poderes del Estado (Ejecutivo, Legislativo, Judicial) y sus funciones principales.', 1),
  ('Participación ciudadana y organizaciones sociales', 'Reconocer distintas formas de participación ciudadana y el rol de organizaciones sociales.', 2),
  ('Derechos y responsabilidades como miembros de una comunidad', 'Reconocer derechos y responsabilidades propias como miembro de una comunidad escolar y territorial.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 6° BÁSICO (order_index de nivel = 106)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Historia — 6° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Historia, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Historia'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Historia.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Descubrimiento y conquista de América desde una perspectiva americana', 'Analizar el proceso de descubrimiento y conquista de América considerando distintas perspectivas, incluida la de los pueblos originarios.', 0),
  ('Independencia de Chile: causas y proceso', 'Explicar causas y describir el proceso de Independencia de Chile.', 1),
  ('Organización de la República en el siglo XIX', 'Describir la organización política de Chile durante el siglo XIX tras la Independencia.', 2),
  ('Uso de evidencia histórica para argumentar', 'Utilizar evidencia histórica simple para fundamentar una idea sobre un proceso del pasado.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Historia') and name = 'Historia — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Geografía — 6° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Geografía, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Geografía'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Geografía.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Geografía física y humana de América', 'Describir las principales características de la geografía física y humana del continente americano.', 0),
  ('Migraciones y su impacto territorial', 'Analizar procesos migratorios y su impacto en la organización del territorio.', 1),
  ('Uso de tecnologías de información geográfica', 'Utilizar herramientas tecnológicas simples de información geográfica para ubicar y comparar lugares.', 2),
  ('Distribución de la población en el territorio', 'Describir la distribución de la población en el territorio chileno y americano y algunos factores asociados.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Geografía') and name = 'Geografía — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Formación Ciudadana — 6° Básico', 'Objetivos de aprendizaje de Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Estudios Sociales') and s.name = 'Formación Ciudadana'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 1° a 6° Básico, Historia, Geografía y Ciencias Sociales, eje Formación Ciudadana.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('La Constitución y los derechos fundamentales', 'Reconocer la existencia de la Constitución como norma fundamental y algunos derechos que garantiza.', 0),
  ('Funcionamiento de la democracia representativa', 'Describir el funcionamiento básico de la democracia representativa en Chile.', 1),
  ('Mecanismos de participación ciudadana', 'Reconocer mecanismos de participación ciudadana como elecciones y plebiscitos.', 2),
  ('Valoración de la diversidad y no discriminación', 'Fundamentar la importancia de la no discriminación y el respeto a la diversidad en la vida en sociedad.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Estudios Sociales') and name = 'Formación Ciudadana') and name = 'Formación Ciudadana — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
