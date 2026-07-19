-- Dominio: Contenido y preguntas / Resultados y progreso
-- Datos de la importación PILOTO EPJA: Enseñanza Media → Primer Nivel Medio
-- → Educación Matemática. NO es una migración de esquema (no crea ni altera
-- tablas) — es una carga de datos, separada a propósito en `supabase/seed/`
-- para no mezclar DDL con DML en el mismo archivo numerado.
--
-- ============================================================================
-- HALLAZGO IMPORTANTE — léase antes de ejecutar (ver también el reporte final
-- de esta etapa): el piloto se pidió específicamente bajo el Decreto Supremo
-- N.° 10 de 2022 (segundo período de examinación 2026). Al buscar el temario
-- oficial en epja.mineduc.cl, NINGÚN documento de "Enseñanza Media" (ni el de
-- 2024 ni el de 2025) está redactado bajo D.S. N.° 10 — ambos se
-- autodenominan explícitamente "Validación de Estudios Adultos (DS 257)".
-- La página https://epja.mineduc.cl/como-se-evalua-5/ confirma, con texto
-- literal, que D.S. N.° 10/2022 rige hoy solo el "Nivel 1 de Educación
-- Básica" (y, en una frase, también dice "nivel 1 de Enseñanza Media", lo
-- que contradice la frase siguiente de la MISMA página, que ubica "primer y
-- segundo nivel de educación media" bajo D.S. 257). Es una discrepancia de
-- la propia fuente oficial, no algo que este script haya resuelto por su
-- cuenta: se documenta aquí y en el reporte, sin inventar una solución.
--
-- Por lo tanto, este script importa el temario de Matemática REALMENTE
-- disponible y verificable (D.S. 257/2009, documento 2025, el más
-- reciente), y crea el registro D.S. 10/2022 igualmente, pero en estado
-- `draft` y SIN contenido curricular — queda pendiente de revisión humana
-- si/cuando MINEDUC publique el temario de Media bajo ese decreto.
-- ============================================================================
--
-- Fuente citada:
--   https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM1_2025.pdf
--   ("Temario Primer Nivel de Educación Media", Decreto Supremo N° 257 de
--   2009, autora del documento según metadatos PDF: Soledad Vargas Ossa,
--   creado 2025-02-11). SHA-256 del PDF descargado:
--   23f9ab4c1ef00563c381d7f16e81fbf0f8dbb94bf8d4c6275486905347e78f08
--
-- Agrupación en 4 ejes (Números; Álgebra y Funciones; Geometría;
-- Probabilidad y Estadística): el documento fuente presenta los 19
-- objetivos de "EDUCACIÓN MATEMÁTICA" como una lista plana, sin ejes ni
-- unidades declaradas. Esta agrupación es una PROPUESTA de ValidApp (sigue
-- la organización estándar del currículum chileno de Matemática, y respeta
-- el orden en que los objetivos aparecen en el documento), no una
-- estructura que el MINEDUC haya declarado explícitamente — por eso cada
-- objetivo queda `status='en_revision'` (no `aprobado`) y el texto oficial
-- se conserva sin modificar en `official_text`.
--
-- Este script es idempotente: usa `on conflict` en cada insert contra las
-- restricciones únicas ya existentes (o agregadas por 0016/0021/0022), así
-- que se puede reintentar sin duplicar filas.
--
-- NO SE EJECUTÓ contra ningún Supabase (ni local ni remoto). Revisar y
-- ejecutar manualmente, con las migraciones 0016-0022 ya aplicadas.

do $$
declare
  v_program_id uuid;
  v_education_level_id uuid;
  v_level_id uuid;
  v_subject_id uuid;
  v_source_id uuid;
  v_framework_257_id uuid;
  v_framework_10_id uuid;
  v_strand_numeros_id uuid;
  v_strand_algebra_id uuid;
  v_strand_geometria_id uuid;
  v_strand_probabilidad_id uuid;
  v_unit_numeros_id uuid;
  v_unit_algebra_id uuid;
  v_unit_geometria_id uuid;
  v_unit_probabilidad_id uuid;
  v_lesson_id uuid;
  v_obj_numeros_1_id uuid;
  v_essay_id uuid;
begin
  -- ---------- Catálogo base ----------
  insert into public.programs (name, description)
  values ('EPJA - Modalidad Regular', 'Educación de Personas Jóvenes y Adultas, modalidad regular.')
  on conflict (name) do update set description = excluded.description
  returning id into v_program_id;

  insert into public.education_levels (name, description)
  values ('Educación Media', 'Enseñanza Media (EPJA y regular).')
  on conflict (name) do update set description = excluded.description
  returning id into v_education_level_id;

  insert into public.levels (name, order_index, program_id, education_level_id, equivalence, track)
  values (
    'Primer Nivel Medio', 10, v_program_id, v_education_level_id,
    '1° y 2° Medio', 'humanistico_cientifico'
  )
  on conflict (name) do update set
    program_id = excluded.program_id,
    education_level_id = excluded.education_level_id,
    equivalence = excluded.equivalence,
    track = excluded.track
  returning id into v_level_id;

  insert into public.subjects (name, canonical_code)
  values ('Matemática', 'mathematics')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  -- ---------- Fuente oficial ----------
  -- `content_sources` no tiene restricción única (una misma URL puede citarse
  -- por motivos distintos), así que la idempotencia se resuelve a mano:
  -- busca primero por URL antes de insertar, en vez de usar `on conflict`.
  select id into v_source_id
    from public.content_sources
    where source_url = 'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM1_2025.pdf'
    limit 1;

  if v_source_id is null then
    insert into public.content_sources (
      source_name, source_url, source_domain, source_document_type,
      source_year, source_decree, source_checksum, retrieved_at
    )
    values (
      'Temario Primer Nivel de Educación Media (Validación de Estudios Adultos, DS 257)',
      'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM1_2025.pdf',
      'epja.mineduc.cl',
      'temario_oficial_pdf',
      2025,
      'DS 257/2009',
      '23f9ab4c1ef00563c381d7f16e81fbf0f8dbb94bf8d4c6275486905347e78f08',
      now()
    )
    returning id into v_source_id;
  end if;

  -- ---------- Versiones curriculares ----------
  insert into public.curriculum_frameworks (
    modality, certification_process, audience, purpose, name,
    decree_number, decree_year, exam_year, exam_period, status,
    source_name, source_url, source_domain, source_document_type,
    source_checksum, retrieved_at, verified_at
  )
  values (
    'EPJA', 'examen_libre', 'mayores_18', 'continuidad_estudios',
    'Enseñanza Media EPJA — D.S. N.° 257 de 2009 (primer período 2026)',
    '257', 2009, 2026, 'primer_periodo', 'verified',
    'Temario Primer Nivel de Educación Media (Validación de Estudios Adultos, DS 257)',
    'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM1_2025.pdf',
    'epja.mineduc.cl', 'temario_oficial_pdf',
    '23f9ab4c1ef00563c381d7f16e81fbf0f8dbb94bf8d4c6275486905347e78f08',
    now(), now()
  )
  on conflict (decree_number, decree_year, exam_year, exam_period) do update set status = excluded.status
  returning id into v_framework_257_id;

  -- D.S. 10/2022: registro estructural sin contenido curricular todavía —
  -- ver hallazgo documentado arriba. `status='draft'` refleja que no hay
  -- fuente verificada para Matemática/Media bajo este decreto a la fecha.
  insert into public.curriculum_frameworks (
    modality, certification_process, audience, purpose, name,
    decree_number, decree_year, exam_year, exam_period, status
  )
  values (
    'EPJA', 'examen_libre', 'mayores_18', 'continuidad_estudios',
    'Enseñanza Media EPJA — D.S. N.° 10 de 2022 (segundo período 2026, SIN temario de Media publicado)',
    '10', 2022, 2026, 'segundo_periodo', 'draft'
  )
  on conflict (decree_number, decree_year, exam_year, exam_period) do nothing
  returning id into v_framework_10_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_id, v_subject_id, 'Educación Matemática', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  -- ---------- Ejes (agrupación propuesta por ValidApp, ver nota arriba) ----------
  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Números', 'Números enteros, racionales, irracionales y potencias.', 0, v_framework_257_id, v_source_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_numeros_id;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Álgebra y Funciones', 'Lenguaje algebraico, expresiones algebraicas, funciones y ecuaciones.', 1, v_framework_257_id, v_source_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_algebra_id;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Geometría', 'Ángulos, polígonos, semejanza, transformaciones isométricas, perímetro/área/volumen.', 2, v_framework_257_id, v_source_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_geometria_id;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Probabilidad y Estadística', 'Medidas de tendencia central, probabilidad y tablas de frecuencia.', 3, v_framework_257_id, v_source_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_probabilidad_id;

  -- ---------- Unidades (una por eje: el documento fuente no declara unidades) ----------
  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_numeros_id, 'Objetivos evaluados — Números', '', 0, v_framework_257_id, v_source_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_numeros_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_algebra_id, 'Objetivos evaluados — Álgebra y Funciones', '', 0, v_framework_257_id, v_source_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_algebra_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_geometria_id, 'Objetivos evaluados — Geometría', '', 0, v_framework_257_id, v_source_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_geometria_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_probabilidad_id, 'Objetivos evaluados — Probabilidad y Estadística', '', 0, v_framework_257_id, v_source_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_probabilidad_id;

  -- ---------- Objetivos de aprendizaje (texto oficial verbatim en official_text) ----------
  -- Eje: Números (7 objetivos)
  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values
    (v_unit_numeros_id, v_level_id, 'Números enteros en contextos cotidianos',
     'Comparación y operatoria con números enteros.',
     'Usa números enteros en contextos cotidianos, estableciendo comparaciones y/o resolviendo operatoria.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_id),
    (v_unit_numeros_id, v_level_id, 'Proporcionalidad directa, inversa y porcentual',
     'Organización de datos en tablas o gráficos, razón y valores desconocidos.',
     'Aplica variaciones de proporcionalidad directa, inversa o porcentual mediante la organización de datos en tablas o gráficos, aplicando el concepto de razón, determinando valores desconocidos.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_id),
    (v_unit_numeros_id, v_level_id, 'Números racionales en contextos cotidianos',
     'Escritura decimal o fraccionaria, comparación, recta numérica y operatoria básica.',
     'Usa números racionales en contextos cotidianos aplicando la escritura decimal o fraccionaria, comparando cantidades, representándola en la recta numérica y resolviendo operatoria básica.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_id),
    (v_unit_numeros_id, v_level_id, 'Aproximación de números irracionales',
     'Representación de irracionales en la recta numérica.',
     'Aproxima números irracionales e identifica su representación en la recta numérica.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_id),
    (v_unit_numeros_id, v_level_id, 'Potencias de base racional y exponente entero',
     'Interpretación de potencias para escribir números grandes o pequeños.',
     'Interpreta potencias de base racional y exponente entero en variados ámbitos para escribir grandes o pequeños números.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_id),
    (v_unit_numeros_id, v_level_id, 'Potencia como multiplicación iterada y propiedades',
     'Multiplicación iterada, propiedades de multiplicación y división de potencias.',
     'Resuelve un problema que involucra interpretar una potencia con base racional positiva y exponente natural como multiplicación iterada, o bien las propiedades de la multiplicación y de la división de potencias de igual base o igual exponente.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_id),
    (v_unit_numeros_id, v_level_id, 'Operatoria con enteros y racionales',
     'Comparación y operatoria (adición, sustracción, multiplicación, división).',
     'Resuelve un problema que involucra comparar o determinar operatoria (adición sustracción, multiplicación, división) con número enteros y/o número racionales.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text
  returning id into v_obj_numeros_1_id;

  -- Eje: Álgebra y Funciones (5 objetivos)
  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values
    (v_unit_algebra_id, v_level_id, 'Lenguaje algebraico y relaciones entre variables',
     'Fórmulas y generalización de propiedades numéricas.',
     'Usa lenguaje algebraico estableciendo relaciones entre variables (fórmulas, generalizar propiedades numéricas).',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_id),
    (v_unit_algebra_id, v_level_id, 'Operatoria de expresiones algebraicas',
     'Multiplicación, factorización, términos semejantes y productos notables.',
     'Opera expresiones algebraicas (multiplica, factoriza) y reduce términos semejantes reconociendo productos notables y su representación geométrica.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_id),
    (v_unit_algebra_id, v_level_id, 'Función lineal y función afín',
     'Distinción entre función lineal y afín: notación algebraica y gráfica.',
     'Distingue una función lineal, de una función afín en variados contextos, su notación algebraica y su representación gráfica.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_id),
    (v_unit_algebra_id, v_level_id, 'Ecuaciones de primer grado con una incógnita',
     'Planteo y resolución, pertinencia de la solución según contexto.',
     'Resuelve un problema que incluye plantear y/o resolver ecuaciones de primer grado con una incógnita, analizando la pertinencia de la solución según un contexto.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_id),
    (v_unit_algebra_id, v_level_id, 'Sistemas de ecuaciones de primer grado con dos incógnitas',
     'Resolución algebraica o gráfica.',
     'Resuelve un problema que implica resolver de forma algebraica o gráfica un sistema de ecuaciones de primer grado con dos incógnitas.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- Eje: Geometría (4 objetivos)
  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values
    (v_unit_geometria_id, v_level_id, 'Conceptos geométricos básicos',
     'Clasificación de ángulos y polígonos, posiciones de rectas en un plano.',
     'Reconoce conceptos geométricos básicos como clasificación de ángulos y polígonos, posiciones de rectas en un plano.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_id),
    (v_unit_geometria_id, v_level_id, 'Semejanza, escala y teorema de Thales',
     'Semejanza de figuras planas, dibujos a escala y teorema de Thales.',
     'Aplica semejanza de figuras planas, dibujos a escala y el teorema de Thales en situaciones de proporcionalidad.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_id),
    (v_unit_geometria_id, v_level_id, 'Transformaciones isométricas',
     'Traslación, reflexión y rotación de figuras planas.',
     'Reconoce transformaciones isométricas: traslación, reflexión y rotación de figuras planas en diversos contextos como geométricos (plano cartesiano), la naturaleza, el arte, la arquitectura.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_id),
    (v_unit_geometria_id, v_level_id, 'Perímetro, área y volumen',
     'Cálculo de perímetro o área de figuras geométricas y volumen de cuerpos regulares.',
     'Resuelve un problema que involucra calcular el perímetro o área de figuras geométricas, volumen en cuerpos geométricos regulares.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- Eje: Probabilidad y Estadística (3 objetivos)
  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values
    (v_unit_probabilidad_id, v_level_id, 'Medidas de tendencia central',
     'Cálculo e interpretación con datos no agrupados en intervalos.',
     'Calcula e interpreta medidas de tendencia central con datos no agrupados en intervalos.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_id),
    (v_unit_probabilidad_id, v_level_id, 'Probabilidad de un suceso (regla de Laplace)',
     'Cálculo de probabilidad usando la regla de Laplace.',
     'Calcula la probabilidad de un suceso usando la regla de Laplace.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_id),
    (v_unit_probabilidad_id, v_level_id, 'Tablas de frecuencia y gráficos',
     'Interpretación de tablas de frecuencia absoluta/relativa/porcentual, gráficos de barras o circulares.',
     'Resuelve problemas interpretando información presentada en tablas de frecuencia (absoluta, relativa y porcentual) o bien en un gráfico de barras o gráfico circular con datos no agrupados en intervalos.',
     'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ---------- Lección de demostración (contenido ValidApp, NO texto MINEDUC) ----------
  insert into public.lessons (subject_id, level_id, title, content, order_index, framework_id)
  values (
    v_subject_id, v_level_id,
    'Introducción a los números racionales',
    'Contenido pedagógico ValidApp (no es texto oficial MINEDUC): repaso de la escritura decimal y fraccionaria de los números racionales, comparación de cantidades y ubicación en la recta numérica, como apoyo al objetivo "Usa números racionales en contextos cotidianos" del temario oficial de Matemática, Primer Nivel Medio.',
    0, v_framework_257_id
  )
  on conflict (subject_id, level_id, title) do update set content = excluded.content
  returning id into v_lesson_id;

  -- ---------- Preguntas de demostración + ensayo piloto ----------
  -- Ni `questions` ni `essays` tienen una clave natural única razonable para
  -- este bloque (el `prompt` de una pregunta o el `name` de un ensayo no
  -- deberían forzarse a ser únicos a nivel de esquema). La idempotencia de
  -- ESTE bloque puntual se resuelve verificando si el ensayo piloto ya
  -- existe (por nombre) antes de insertar nada del bloque completo.
  if not exists (
    select 1 from public.essays
    where name = 'Ensayo de preparación ValidApp — Matemática, Primer Nivel Medio (piloto)'
  ) then

  insert into public.questions (
    subject_id, level_id, lesson_id, prompt, choices, correct_index,
    explanation, learning_objective_id, difficulty, question_type, points,
    review_status, validation_status, is_active, framework_id, source_type
  )
  values
    (
      v_subject_id, v_level_id, v_lesson_id,
      '¿Cuál de las siguientes fracciones es equivalente a 0,75?',
      '["1/2", "2/3", "3/4", "4/5"]'::jsonb, 2,
      '0,75 = 75/100, que simplificado equivale a 3/4.',
      v_obj_numeros_1_id, 'inicial', 'seleccion_multiple', 1,
      'aprobado', 'approved_for_exam', true, v_framework_257_id, 'validapp_original'
    ),
    (
      v_subject_id, v_level_id, v_lesson_id,
      'Si un artículo cuesta $8.000 y tiene un descuento del 25%, ¿cuál es el precio final?',
      '["$2.000", "$6.000", "$6.500", "$7.000"]'::jsonb, 1,
      'El 25% de $8.000 es $2.000 de descuento; $8.000 - $2.000 = $6.000.',
      v_obj_numeros_1_id, 'intermedia', 'seleccion_multiple', 1,
      'aprobado', 'approved_for_exam', true, v_framework_257_id, 'validapp_original'
    ),
    (
      v_subject_id, v_level_id, null,
      'Ordena de menor a mayor: -5, 2, -8, 0. ¿Cuál es el orden correcto?',
      '["-8, -5, 0, 2", "-5, -8, 0, 2", "0, -5, -8, 2", "2, 0, -5, -8"]'::jsonb, 0,
      'En los números enteros, mientras más lejos está un número negativo del cero, menor es su valor.',
      v_obj_numeros_1_id, 'inicial', 'seleccion_multiple', 1,
      'aprobado', 'approved_for_exam', true, v_framework_257_id, 'validapp_original'
    ),
    (
      v_subject_id, v_level_id, null,
      '¿Cuál es el resultado de (2/3) + (1/6)?',
      '["1/2", "3/9", "5/6", "1/9"]'::jsonb, 2,
      '(2/3) = (4/6); (4/6) + (1/6) = (5/6).',
      v_obj_numeros_1_id, 'intermedia', 'seleccion_multiple', 1,
      'aprobado', 'approved_for_exam', true, v_framework_257_id, 'validapp_original'
    ),
    (
      v_subject_id, v_level_id, null,
      'Un número irracional se ubica en la recta numérica entre dos números enteros consecutivos. ¿Qué par de números encierra a √10?',
      '["2 y 3", "3 y 4", "4 y 5", "5 y 6"]'::jsonb, 1,
      '3² = 9 y 4² = 16; como 9 < 10 < 16, entonces 3 < √10 < 4.',
      v_obj_numeros_1_id, 'avanzada', 'seleccion_multiple', 1,
      'aprobado', 'approved_for_exam', true, v_framework_257_id, 'validapp_original'
    );

  -- ---------- Ensayo piloto (blueprint), SIN publicar ----------
  insert into public.essays (
    name, level_id, essay_type, total_questions, time_limit_minutes,
    order_mode, feedback_mode, status, framework_id
  )
  values (
    'Ensayo de preparación ValidApp — Matemática, Primer Nivel Medio (piloto)',
    v_level_id, 'por_asignatura', 5, 20, 'aleatorio', 'al_finalizar', 'borrador', v_framework_257_id
  )
  returning id into v_essay_id;

  insert into public.essay_subjects (essay_id, subject_id, question_count)
  values (v_essay_id, v_subject_id, 5);

  end if;

end $$;
