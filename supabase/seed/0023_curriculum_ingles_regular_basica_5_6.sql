-- Dominio: Contenido y preguntas
-- Currículum Regular (menores de 18, examen libre curso por curso) —
-- Idioma Extranjero: Inglés, 5° y 6° Básico.
--
-- ============================================================================
-- DECISIÓN CENTRAL DE ESTE ARCHIVO — POR QUÉ NO CUBRE 1° A 4° BÁSICO
-- ============================================================================
-- La tarea original pedía los 12 cursos de Currículum Regular (1° a 8°
-- Básico, 1° a 4° Medio), replicando el patrón usado para Matemática
-- (0011-0013), Lenguaje (0014-0016), Ciencias Naturales (0017-0019) e
-- Historia (0021-0022). Este archivo cubre SOLO 5° y 6° Básico, NO 1° a 4°
-- Básico, por la siguiente razón:
--
-- CONFIANZA MEDIA-ALTA (conocimiento general de este agente sobre la
-- estructura del currículo chileno, NO verificado por búsqueda web en esta
-- sesión -- el coordinador no aportó una fuente específica sobre este punto):
-- la enseñanza obligatoria de Inglés en Chile, con Objetivos de Aprendizaje
-- propios definidos en Bases Curriculares, comienza en 5° Básico, no en 1°.
-- Existen iniciativas de exposición temprana al inglés en 1°-4° Básico en
-- algunos establecimientos (p. ej. el programa "Inglés Abre Puertas" y
-- programas complementarios/optativos de cada colegio), pero esto es
-- CONTENIDO COMPLEMENTARIO/OPCIONAL, no currículo obligatorio con OA propios
-- del Decreto Supremo N.° 439 de 2012 -- y este agente tiene instrucción
-- explícita de "Distinguir entre currículo regular, temario de exámenes
-- libres y contenido complementario" y de no inventar objetivos oficiales
-- que no pueda verificar que existen.
--
-- Evidencia interna corroborante (no concluyente, pero consistente): el
-- temario de Exámenes Libres EPJA (D.S. 257/2009, supabase/seed/0002) SOLO
-- incluye "Idioma Extranjero: Inglés" en Primer y Segundo Nivel Medio (NM1,
-- NM2) -- NO existe ninguna fila de Inglés para los niveles de Educación
-- Básica de Adultos en ese seed. Esto es consistente con que Inglés es,
-- estructuralmente, una asignatura que en el sistema chileno se consolida
-- más tarde que el resto (recién desde 5° Básico), a diferencia de
-- Matemática, Lenguaje, Ciencias Naturales e Historia, que sí tienen OA
-- obligatorios desde 1° Básico.
--
-- DECISIÓN: no se crean unidades ni objetivos de aprendizaje para 1°, 2°, 3°
-- ni 4° Básico en esta asignatura. Si el coordinador de la sesión verifica
-- (vía búsqueda web u otra fuente oficial) que sí existen OA obligatorios de
-- Inglés para 1°-4° Básico bajo el D.S. 439/2012, o que se desea cargar
-- igualmente contenido complementario/optativo para esos cursos marcado
-- explícitamente como tal (nunca como currículo obligatorio), se recomienda
-- pedir esa tarea por separado -- no se asume aquí.
--
-- ============================================================================
-- FUENTE Y NIVEL DE CONFIANZA (léase antes de aprobar cualquier fila)
-- ============================================================================
-- Fuente citada: Bases Curriculares de Educación Básica, MINEDUC, aprobadas
-- por el Decreto Supremo N.° 439 de 2012 (asignatura Idioma Extranjero:
-- Inglés, 5° y 6° Básico). Vigencia progresiva desde 2013. Mismo decreto
-- único multi-asignatura que ya rige Matemática, Lenguaje, Ciencias
-- Naturales e Historia en la porción de esta banda que sí les aplica (ver
-- supabase/seed/0011, 0014, 0017, 0021) -- verificado por el coordinador de
-- esta sesión vía búsqueda web, no por este agente (sin acceso a navegación
-- web en este entorno).
--
-- DENOMINACIÓN OFICIAL DE LA ASIGNATURA: "Idioma Extranjero: Inglés".
-- CONFIANZA MEDIA-ALTA -- es el mismo nombre bajo el cual ya existe la fila
-- de `subjects` creada por el temario EPJA (D.S. 257/2009, ver
-- supabase/seed/0002_epja_remaining_subjects.sql), y es consistente con el
-- conocimiento general de este agente de que MINEDUC usa esta denominación
-- de forma bastante estable a través de las Bases Curriculares de Inglés en
-- distintos niveles. A diferencia de Lenguaje (que sí cambia de "Lenguaje y
-- Comunicación" a "Lengua y Literatura" entre bandas), no hay evidencia de
-- que Inglés cambie de nombre entre 5°-6° Básico, 7° Básico-2° Medio y 3°-4°
-- Medio -- pero esto no ha sido verificado línea por línea contra el PDF
-- oficial de cada banda. Ver también la nota específica sobre 3°-4° Medio en
-- supabase/seed/0025.
--
-- Confianza en los 4 ejes temáticos (Comprensión Auditiva; Comprensión
-- Lectora; Expresión Oral; Expresión Escrita) y en la progresión general de
-- contenidos (nivel A1 inicial: alfabeto, saludos, vocabulario temático
-- básico, presente simple): MEDIA. Esta organización en 4 ejes (equivalente
-- a Listening/Reading/Speaking/Writing) es la forma habitual en que MINEDUC
-- y los marcos de referencia CEFR organizan Inglés como lengua extranjera,
-- pero no es una cita literal verificada del índice de las Bases
-- Curriculares de esta asignatura.
--
-- Confianza en el TEXTO EXACTO y la NUMERACIÓN OFICIAL de cada Objetivo de
-- Aprendizaje (código "OA n" tal como aparece en el PDF de Bases
-- Curriculares): BAJA, mismo motivo que 0011-0022 (sin acceso a navegación
-- web ni al PDF oficial en este entorno). Por eso:
--   - `code` (código OA oficial) se deja NULL en todas las filas.
--   - No existe columna `official_text` separada en el esquema actual
--     (`learning_objectives` solo tiene `code` y `description`, ver
--     supabase/migrations/0010_curriculum_structure.sql) -- `description`
--     contiene la paráfrasis ValidApp, nunca se presenta como cita textual.
--   - TODAS las filas quedan en `status = 'borrador'`.
--   - `pedagogical_notes` repite esta advertencia en cada objetivo.
--
-- ============================================================================
-- VERIFICACIÓN DE ASIGNATURA EXISTENTE (evita duplicar)
-- ============================================================================
-- Se revisó supabase/seed/0005_epja_ingles_essays.sql y
-- supabase/seed/0002_epja_remaining_subjects.sql antes de escribir este
-- archivo: la fila de `subjects` para Inglés YA EXISTE
-- (name = 'Idioma Extranjero: Inglés', canonical_code = 'english'), creada
-- por el temario EPJA. Se REUTILIZA esa fila sin duplicarla ni renombrarla,
-- mismo criterio que Matemática/Lenguaje/Ciencias Naturales/Historia
-- reutilizaron sus asignaturas EPJA ya existentes.
--
-- Los ejes ("Comprensión Auditiva", "Comprensión Lectora", "Expresión Oral",
-- "Expresión Escrita") son NUEVOS y propios de esta banda del Currículum
-- Regular -- no se confunden con el eje ya existente "Comprensión Lectora en
-- Inglés" (creado por 0002 para el temario EPJA, bajo el mismo subject_id).
-- Nombre deliberadamente distinto ("Comprensión Lectora" vs "Comprensión
-- Lectora en Inglés") para evitar colisión en la restricción
-- `unique (subject_id, name)` de `strands` y para no mezclar contenido de
-- examen libre EPJA con contenido de Currículum Regular bajo el mismo eje.
--
-- ============================================================================
-- QUÉ CUBRE Y QUÉ NO
-- ============================================================================
-- Cubre: 4 ejes oficiales x 2 cursos (5° y 6° Básico) = 8 combinaciones
-- eje-curso, cada una con 1 unidad y 4 objetivos (32 objetivos en total).
-- Representativos, NO exhaustivos -- el PDF oficial puede declarar un número
-- distinto de OA por eje y curso.
--
-- No cubre: 1° a 4° Básico (ver decisión arriba), banco de preguntas,
-- lecciones, ensayos, habilidades (fuera de alcance de esta tarea -- ver
-- /validapp-assessments para preguntas/ensayos).
--
-- ============================================================================
-- POR QUÉ NO SE USA curriculum_frameworks / framework_subjects
-- ============================================================================
-- Mismo motivo documentado en 0011-0022: esas tablas exigen `exam_period`
-- NOT NULL (concepto de período de examinación EPJA), que no aplica al
-- Currículum Regular. Se usa la trazabilidad simple ya disponible en
-- `learning_objectives`: `curricular_source` + `reference_year` +
-- `pedagogical_notes`.
--
-- ============================================================================
-- IDEMPOTENCIA
-- ============================================================================
-- Mismo patrón que 0011-0022: `on conflict do nothing` para
-- subjects/strands/units (catálogo compartido, no se pisa contenido ya
-- editado por un administrador) o `on conflict do update` solo sobre las
-- columnas propias de este archivo para `learning_objectives`
-- (description/curricular_source/reference_year/pedagogical_notes).
-- `level_id` se resuelve siempre por `levels.code`, `subject_id` por
-- `subjects.name`.
--
-- Seed SOLO local: NO se ha ejecutado contra ningún proyecto Supabase (ni
-- dev ni producción). No modifica Supabase por sí solo.

-- ============================================================================
-- 1) Asignatura: reutiliza "Idioma Extranjero: Inglés" (EPJA la creó
--    primero, ver 0002). Ver decisión completa arriba.
-- ============================================================================
insert into public.subjects (name, canonical_code)
values ('Idioma Extranjero: Inglés', 'english')
on conflict (name) do nothing;

-- ============================================================================
-- 2) Ejes temáticos
-- ============================================================================
insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Idioma Extranjero: Inglés'),
   'Comprensión Auditiva', 'Comprensión de textos orales en inglés: instrucciones, diálogos, descripciones y discursos de complejidad creciente.', 1)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Idioma Extranjero: Inglés'),
   'Comprensión Lectora', 'Comprensión de textos escritos en inglés: identificación de información explícita e implícita, vocabulario e ideas principales.', 2)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Idioma Extranjero: Inglés'),
   'Expresión Oral', 'Producción oral en inglés: pronunciación, interacción y comunicación de ideas propias con creciente autonomía.', 3)
on conflict (subject_id, name) do nothing;

insert into public.strands (subject_id, name, description, order_index)
values
  ((select id from public.subjects where name = 'Idioma Extranjero: Inglés'),
   'Expresión Escrita', 'Producción escrita en inglés: uso de convenciones ortográficas, gramaticales y de organización textual.', 4)
on conflict (subject_id, name) do nothing;

-- ============================================================================
-- 3) Unidades y objetivos de aprendizaje, curso por curso
-- ============================================================================
-- Constantes repetidas por fila (ver encabezado): `status = 'borrador'`,
-- `curricular_source` cita el decreto y advierte sobre el nivel de confianza
-- de la denominación oficial, `reference_year = 2012`, `pedagogical_notes`
-- advierte que el texto es paráfrasis ValidApp.

-- ---------------------------------------------------------------------
-- 5° BÁSICO (order_index de nivel = 105)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 5° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo; comienzo de la enseñanza obligatoria de Inglés en el sistema chileno, confianza MEDIA-ALTA no verificada por búsqueda web), eje Comprensión Auditiva.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A1 inicial); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Reconocimiento de sonidos y palabras del inglés', 'Reconocer sonidos, palabras y expresiones básicas del inglés en textos orales breves y simples.', 0),
  ('Comprensión de instrucciones simples en inglés', 'Comprender instrucciones simples dadas en inglés relacionadas con la sala de clases.', 1),
  ('Identificación de información puntual en textos orales breves', 'Identificar información puntual (nombres, números, lugares) en textos orales breves y conocidos.', 2),
  ('Discriminación de sonidos propios del inglés', 'Discriminar sonidos del inglés distintos de los del español.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 5° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Lectora.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A1 inicial); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Reconocimiento del alfabeto y palabras conocidas', 'Reconocer el alfabeto en inglés y palabras conocidas en textos simples.', 0),
  ('Comprensión de textos breves con apoyo visual', 'Comprender textos breves (rótulos, tarjetas, diálogos) con apoyo de imágenes.', 1),
  ('Identificación de información explícita', 'Identificar información explícita en textos simples sobre temas familiares.', 2),
  ('Vocabulario temático básico', 'Reconocer vocabulario temático básico: colores, números, familia y objetos de la sala de clases.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 5° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A1 inicial); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Saludos y presentaciones personales', 'Usar saludos, despedidas y expresiones para presentarse a sí mismo y a otros.', 0),
  ('Preguntas y respuestas sobre información personal', 'Formular y responder preguntas simples sobre información personal (nombre, edad, gustos).', 1),
  ('Repetición e imitación de patrones de pronunciación', 'Repetir e imitar patrones de pronunciación, ritmo y entonación de palabras y frases simples.', 2),
  ('Participación en canciones y juegos en inglés', 'Participar en canciones, rimas y juegos orales en inglés.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 5° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 5° Básico.', 105
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Escrita.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje (nivel A1 inicial); no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Copia y trazado de palabras y frases simples', 'Copiar y trazar correctamente palabras y frases simples en inglés.', 0),
  ('Completar oraciones con vocabulario conocido', 'Completar oraciones simples utilizando vocabulario conocido.', 1),
  ('Escritura de información personal básica', 'Escribir información personal básica (nombre, edad, curso) siguiendo un modelo.', 2),
  ('Uso de mayúsculas y puntuación elemental', 'Usar mayúsculas al inicio de oración y en nombres propios, y punto final, en textos simples.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 5° Básico') as u
cross join (select id from public.levels where code = 'regular_5_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

-- ---------------------------------------------------------------------
-- 6° BÁSICO (order_index de nivel = 106)
-- ---------------------------------------------------------------------
insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Auditiva — 6° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Auditiva, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Auditiva'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Auditiva.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de descripciones orales simples', 'Comprender descripciones orales simples sobre personas, lugares y objetos conocidos.', 0),
  ('Seguimiento de instrucciones de varios pasos', 'Seguir instrucciones orales de varios pasos relacionadas con actividades cotidianas.', 1),
  ('Identificación de la idea general de un texto oral', 'Identificar la idea general de un texto oral breve (diálogo o audio) sobre temas familiares.', 2),
  ('Reconocimiento de rutinas y horarios mencionados oralmente', 'Reconocer rutinas y horarios mencionados en un texto oral.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Auditiva') and name = 'Comprensión Auditiva — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Comprensión Lectora — 6° Básico', 'Objetivos de aprendizaje de Inglés, eje Comprensión Lectora, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Comprensión Lectora'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Comprensión Lectora.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Comprensión de textos breves sobre rutinas diarias', 'Comprender textos breves sobre rutinas diarias y actividades cotidianas.', 0),
  ('Identificación de secuencia temporal en un texto', 'Identificar la secuencia temporal de eventos en un texto simple.', 1),
  ('Inferencia de significado por contexto o imágenes', 'Inferir el significado de palabras desconocidas apoyándose en el contexto o en imágenes.', 2),
  ('Comprensión de mensajes y notas simples', 'Comprender mensajes, notas o correos simples sobre temas cotidianos.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Comprensión Lectora') and name = 'Comprensión Lectora — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Oral — 6° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Oral, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Oral'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Oral.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Descripción oral de personas y objetos', 'Describir oralmente personas, objetos y lugares conocidos usando frases simples.', 0),
  ('Expresión de gustos y preferencias', 'Expresar gustos, preferencias y opiniones simples usando expresiones aprendidas.', 1),
  ('Diálogos breves sobre situaciones cotidianas', 'Participar en diálogos breves sobre situaciones cotidianas (compras, comida, escuela).', 2),
  ('Uso de expresiones de cortesía', 'Usar expresiones de cortesía y fórmulas sociales básicas en una conversación.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Oral') and name = 'Expresión Oral — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;

insert into public.units (strand_id, name, description, order_index)
select s.id, 'Expresión Escrita — 6° Básico', 'Objetivos de aprendizaje de Inglés, eje Expresión Escrita, para 6° Básico.', 106
from public.strands s where s.subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and s.name = 'Expresión Escrita'
on conflict (strand_id, name) do nothing;

insert into public.learning_objectives (unit_id, level_id, short_name, description, status, curricular_source, reference_year, pedagogical_notes, order_index)
select u.id, l.id, v.short_name, v.description, 'borrador',
  'Bases Curriculares Educación Básica, MINEDUC (Decreto Supremo N.° 439/2012), 5° y 6° Básico, asignatura "Idioma Extranjero: Inglés" (confianza MEDIA-ALTA en denominación, ver encabezado de este archivo), eje Expresión Escrita.',
  2012,
  'Paráfrasis ValidApp basada en la progresión curricular conocida del eje; no es cita textual del PDF oficial. Código OA y texto literal pendientes de verificar antes de marcar como aprobado.',
  v.order_index
from (values
  ('Escritura de oraciones sobre rutinas diarias', 'Escribir oraciones simples describiendo rutinas y actividades diarias.', 0),
  ('Uso del presente simple en oraciones', 'Usar el presente simple en la escritura de oraciones afirmativas, negativas e interrogativas.', 1),
  ('Redacción de descripciones breves', 'Redactar una descripción breve de una persona, animal o lugar conocido.', 2),
  ('Revisión de la ortografía de palabras frecuentes', 'Revisar la ortografía de palabras frecuentes utilizando un modelo o diccionario simple.', 3)
) as v(short_name, description, order_index)
cross join (select id from public.units where strand_id = (select id from public.strands where subject_id = (select id from public.subjects where name = 'Idioma Extranjero: Inglés') and name = 'Expresión Escrita') and name = 'Expresión Escrita — 6° Básico') as u
cross join (select id from public.levels where code = 'regular_6_basico') as l
on conflict (unit_id, level_id, short_name) do update set
  description = excluded.description, curricular_source = excluded.curricular_source,
  reference_year = excluded.reference_year, pedagogical_notes = excluded.pedagogical_notes;
