-- Dominio: Contenido y preguntas
-- Datos de la carga EPJA — Etapa 1b: resto de asignaturas (Lengua Castellana
-- y Comunicación, Ciencias Naturales, Estudios Sociales, Idioma Extranjero:
-- Inglés) en Primer y Segundo Nivel Medio, más Matemática en Segundo Nivel
-- Medio (no cargada en 0001, que solo cubrió el piloto de Primer Nivel).
--
-- Misma fuente y mismo hallazgo de decreto que 0001_epja_pilot_matematica.sql:
-- ambos documentos (NM1 y NM2, 2025) se autodenominan "DS 257" — no existe
-- temario EPJA de Media bajo D.S. N.° 10/2022 públicamente disponible. Todo
-- el contenido de este archivo queda bajo el framework D.S. 257/2009 (mismo
-- framework de primer_periodo 2026 creado en 0001). El registro D.S. 10/2022
-- (segundo_periodo 2026, sin contenido) ya existe desde 0001 y no se
-- duplica aquí.
--
-- Ejes: para Ciencias Naturales y Estudios Sociales, los ejes (Ciencias
-- Biológicas/Físicas/Químicas; Dimensión Histórica/Formación Ciudadana/
-- Geográfica y Económica) son subtítulos EXPLÍCITOS del propio documento
-- MINEDUC, no una agrupación propuesta por ValidApp. Para Lengua e Inglés,
-- el documento no declara ejes — se usa un único eje "Comprensión Lectora"
-- (fiel al único encabezado real de la fuente, sin inventar subdivisiones).
-- Todos los objetivos quedan `status='en_revision'`, igual criterio que 0001.
--
-- Alcance de datos de demostración: por volumen, esta carga NO agrega
-- lecciones ni preguntas de demostración (a diferencia del piloto de
-- Matemática/Primer Nivel en 0001) — es contenido curricular puro, listo
-- para que un administrador cargue preguntas reales sobre él. Framework
-- subjects, ejes, unidades y objetivos sí quedan completos y trazables.
--
-- Idempotente (mismo patrón que 0001): `on conflict` contra las
-- restricciones únicas de 0010/0016/0021, o `select ... where not exists`
-- cuando no hay restricción única aplicable.
--
-- NO SE EJECUTÓ contra ningún Supabase (ni local ni remoto). Revisar y
-- ejecutar manualmente, con 0001_epja_pilot_matematica.sql ya aplicado
-- primero (este script asume que `v_framework_257_id`/Primer Nivel
-- Medio/Matemática ya existen).

do $$
declare
  v_framework_257_id uuid;
  v_level_nm1_id uuid;
  v_level_nm2_id uuid;
  v_source_nm1_id uuid;
  v_source_nm2_id uuid;
  v_subject_id uuid;
  v_strand_id uuid;
  v_unit_id uuid;
begin
  -- ---------- Reutiliza framework y fuente NM1 ya creados por 0001 ----------
  select id into v_framework_257_id from public.curriculum_frameworks
    where decree_number = '257' and decree_year = 2009 and exam_year = 2026 and exam_period = 'primer_periodo';
  if v_framework_257_id is null then
    raise exception 'No se encontró el framework D.S. 257/2009 (2026, primer_periodo). Ejecuta primero 0001_epja_pilot_matematica.sql.';
  end if;

  select id into v_level_nm1_id from public.levels where name = 'Primer Nivel Medio';
  if v_level_nm1_id is null then
    raise exception 'No se encontró el nivel "Primer Nivel Medio". Ejecuta primero 0001_epja_pilot_matematica.sql.';
  end if;

  select id into v_source_nm1_id from public.content_sources where source_url = 'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM1_2025.pdf';
  if v_source_nm1_id is null then
    raise exception 'No se encontró la fuente NM1 2025 en content_sources. Ejecuta primero 0001_epja_pilot_matematica.sql.';
  end if;

  -- ---------- Segundo Nivel Medio (nuevo) ----------
  insert into public.levels (name, order_index, program_id, education_level_id, equivalence, track)
  select 'Segundo Nivel Medio', 20, l.program_id, l.education_level_id, '3° y 4° Medio', 'humanistico_cientifico'
  from public.levels l where l.name = 'Primer Nivel Medio'
  on conflict (name) do update set
    program_id = excluded.program_id, education_level_id = excluded.education_level_id,
    equivalence = excluded.equivalence, track = excluded.track
  returning id into v_level_nm2_id;

  -- ---------- Fuente NM2 ----------
  select id into v_source_nm2_id from public.content_sources where source_url = 'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM2_2025.pdf';
  if v_source_nm2_id is null then
    insert into public.content_sources (
      source_name, source_url, source_domain, source_document_type,
      source_year, source_decree, source_checksum, retrieved_at
    )
    values (
      'Temario Segundo Nivel de Educación Media (Validación de Estudios Adultos, DS 257)',
      'https://epja.mineduc.cl/wp-content/uploads/sites/43/2025/02/TEMARIOS_VE-NM2_2025.pdf', 'epja.mineduc.cl', 'temario_oficial_pdf',
      2025, 'DS 257/2009', 'b4a5a4aef18070e239573f53094de21c04548814c475c42c543410703b528252', now()
    )
    returning id into v_source_nm2_id;
  end if;

  -- ================= Lengua Castellana y Comunicación — NM1 =================
  insert into public.subjects (name, canonical_code)
  values ('Lengua Castellana y Comunicación', 'language')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm1_id, v_subject_id, 'Lengua Castellana y Comunicación', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Comprensión Lectora', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Comprensión Lectora', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm1_id, 'Identifica información explícita', '', 'Identifica información explícita del texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Infiere el sentido global del texto', '', 'Infiere el sentido global de un texto (idea principal, central, temas, propósitos).', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Infiere información del texto', '', 'Infiere información del texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Identifica el tipo de texto por estructura', '', 'Identifica el tipo de texto de acuerdo con su estructura y contenido.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Identifica aspectos de los personajes', '', 'Identifica aspectos físicos y sicológicos de los personajes.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Infiere sentido de palabra según contexto', '', 'Infiere el sentido de una palabra o expresión según contexto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Reemplaza palabra por sinónimo según contexto', '', 'Remplaza una palabra por su sinónimo según contexto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Infiere significado de palabra según contexto', '', 'Infiere el significado de una palabra según contexto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Reconoce estructura del texto expositivo', '', 'Reconoce que el texto expositivo está estructurado en: introducción, desarrollo y conclusión.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Identifica formas del discurso expositivo', '', 'Identifica algunas formas básicas del discurso expositivo (descripción, definición y caracterización).', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 9, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Distingue hechos de opiniones', '', 'Distingue hechos de opiniones.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 10, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Analiza recursos verbales y no verbales', '', 'Analiza la función de distintos recursos verbales y no verbales usados para comunicar información en textos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 11, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Fundamenta el tipo de mundo literario', '', 'Fundamenta el tipo de mundo literario presente en un texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 12, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Fundamenta opiniones sobre textos leídos', '', 'Fundamenta sus opiniones sobre los textos leídos argumentando y ejemplificando con información del texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Primer Nivel Medio (2025)', 2025, 13, v_framework_257_id, v_source_nm1_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Ciencias Naturales — NM1 =================
  insert into public.subjects (name, canonical_code)
  values ('Ciencias Naturales', 'natural_sciences')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm1_id, v_subject_id, 'Ciencias Naturales', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Ciencias Biológicas', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Ciencias Biológicas', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm1_id, 'Componentes y funciones de la célula', '', 'Identifica los principales componentes que forman parte de las células o sus funciones.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Intercambio entre célula y ambiente', '', 'Explica los procesos de intercambio entre célula y ambiente.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Conceptos de metabolismo', '', 'Reconoce conceptos relacionados con metabolismo.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Composición química de la célula', '', 'Describe la composición química de la célula, organización y moléculas orgánicas e inorgánicas en la estructura y función celular.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Sistemas del cuerpo humano y nutrición', '', 'Identifica los componentes de los sistemas del cuerpo humano relacionados con la nutrición: sistema digestivo, respiratorio, circulatorio y excretor.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Procesos vitales de nutrición', '', 'Explica los procesos vitales, relacionados con la nutrición, de los sistemas circulatorio, digestivo, respiratorio o excretor y/o la relación entre estos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Circulación y respiración sanguínea', '', 'Reconoce los conceptos de circulación y respiración sanguínea: intercambio de sustancias a nivel capilar, distribución de nutrientes, respiración y gasto energético, intercambio gaseoso y nutrientes y producción de energía.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Interpretación de gráficos sobre nutrición', '', 'Analiza o interpreta gráficos, diagramas o tablas relacionados con el proceso de nutrición.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Concepto de dieta equilibrada', '', 'Evalúa el concepto de dieta equilibrada a distintas situaciones nutricionales.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Población, comunidad, ecosistema, biodiversidad', '', 'Describe los conceptos de población, comunidad, ecosistema, biodiversidad.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 9, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Interdependencia de los seres vivos', '', 'Analiza los efectos que produce la interdependencia de los seres vivos en el medio ambiente.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 10, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Gráficos sobre tamaño de poblaciones', '', 'Analiza o interpreta gráficos, diagramas o tablas en relación con el tamaño de las poblaciones.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 11, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Conservación del medioambiente', '', 'Evalúa problemáticas como la conservación del medioambiente, los efectos de la acción humana en la diversidad, equilibrio de un ecosistema.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 12, v_framework_257_id, v_source_nm1_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Ciencias Físicas', '', 1, v_framework_257_id, v_source_nm1_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Ciencias Físicas', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm1_id, 'Movimientos rectilíneos y circulares', '', 'Describe movimientos rectilíneos y circulares, de acuerdo con sus componentes.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Conceptos de movimiento o fuerza', '', 'Describe conceptos y fenómenos relacionados con movimiento o fuerza y su aplicación.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Problemas de movimiento rectilíneo/circular', '', 'Resuelve problemas sencillos sobre movimientos rectilíneos (cuantitativo) y circulares (cualitativo).', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Origen y propagación de ondas', '', 'Explica el origen, naturaleza o propagación de las ondas sonoras o luminosas.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Ley de reflexión de la luz y óptica del ojo', '', 'Explica los conceptos de la ley de reflexión de la luz, la óptica del ojo y los defectos en la visión, instrumentos ópticos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Ondas sonoras o luminosas y aplicaciones', '', 'Explica fenómenos relacionados con la generación, naturaleza o propagación de las ondas sonoras o luminosas y/o sus aplicaciones prácticas.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Conceptos de energía', '', 'Describe conceptos relacionados con energía (trabajo, roce, calor, temperatura, momentum).', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Conservación de la energía o momentum', '', 'Describe fenómenos, utilizando el principio de conservación de la energía o momentum.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Problemas de trabajo y energía', '', 'Resuelve problemas sencillos, utilizando los conceptos de trabajo y energía.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Calor y temperatura', '', 'Describe fenómenos relacionados con calor y temperatura.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 9, v_framework_257_id, v_source_nm1_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Ciencias Químicas', '', 2, v_framework_257_id, v_source_nm1_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Ciencias Químicas', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm1_id, 'Tipos de disoluciones y concentración', '', 'Describe conceptos asociados a tipos de disoluciones según las concentraciones de soluto y solvente y/o sus unidades de concentración.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Problemas de concentración de disoluciones', '', 'Resuelve problemas sencillos, considerando unidades de concentración de disoluciones: porcentaje en peso, en volumen, molaridad y solubilidad, usando las ecuaciones que correspondan.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Solubilidad y factores que la afectan', '', 'Explica fenómenos del entorno, usando conocimientos sobre solubilidad y/o los factores que la afectan como, por ejemplo: la disolución de un jugo en polvo en agua.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Ácidos, bases y neutralización', '', 'Clasifica ejemplos de ácidos y bases comunes, reacciones ácido-base y de neutralización o conceptos asociados como pH.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Reacciones de óxido-reducción', '', 'Clasifica las reacciones de óxido-reducción o conceptos asociados en situaciones cotidianas y biológicas.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Velocidad de una reacción química', '', 'Explica fenómenos del entorno, usando conocimientos sobre velocidad de una reacción química o los factores que la afectan.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Reacciones de combustión', '', 'Explica los conceptos asociados a reacciones de combustión en situaciones cotidianas.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Primer Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm1_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Estudios Sociales — NM1 =================
  insert into public.subjects (name, canonical_code)
  values ('Estudios Sociales', 'social_sciences')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm1_id, v_subject_id, 'Estudios Sociales', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Dimensión Histórica', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Dimensión Histórica', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm1_id, 'Períodos, procesos e hitos de Chile', '', 'Ubica temporalmente de períodos, procesos, hitos y personajes claves en el desarrollo histórico de Chile.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Pueblos indígenas originarios', '', 'Identifica los principales rasgos culturales de los pueblos indígenas originarios presentes en Chile al momento de la conquista y sus manifestaciones en el presente.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Relaciones españoles-indígenas en la Colonia', '', 'Caracteriza las relaciones entre españoles e indígenas en Chile durante la Colonia: trabajo obligatorio, mestizaje, evangelización, sincretismo cultural, comercio, resistencia indígena, la herencia cultural e institucionalidad de España.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Factores del proceso de Independencia', '', 'Identifica los factores que precipitaron el proceso de Independencia en América y en Chile.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Características del republicanismo', '', 'Distingue las principales características del republicanismo y la organización de una república.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Configuración del territorio de Chile en el s. XIX', '', 'Identifica los principales procesos de configuración del territorio de Chile a lo largo del siglo XIX: Guerra del Pacífico; la incorporación de la Araucanía, la soberanía del Estado chileno en el extremo austral y en la Antártica en el siglo XX.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Transición del siglo XIX al XX', '', 'Identifica las principales características del proceso de transición del siglo XIX al siglo XX: la explotación minera del salitre, los capitales ingleses en la actividad económica a fines del siglo XIX; inversiones públicas en vías de comunicación, infraestructura y educación, fin de la riqueza del salitre, los efectos en Chile de la crisis de 1929.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'La cuestión social y el régimen presidencial', '', 'Caracteriza la "cuestión social"; las nuevas organizaciones de los trabajadores; la adopción del régimen presidencial.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Industrialización sustitutiva y Estado Benefactor', '', 'Describe las principales características del modelo de industrialización sustitutiva de importaciones y de Estado Benefactor.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Ampliación del sufragio y reformas estructurales', '', 'Describe el proceso de ampliación del sufragio (mujeres, analfabetos, no videntes) y la implementación de reformas estructurales (Reforma Agraria, Nacionalización del cobre).', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 9, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Quiebre de la democracia y transición', '', 'Caracteriza el proceso de quiebre de la democracia: el régimen militar y las transformaciones que impone en lo económico, social, político y cultural; la transición a la democracia.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 10, v_framework_257_id, v_source_nm1_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Dimensión Formación Ciudadana', '', 1, v_framework_257_id, v_source_nm1_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Dimensión Formación Ciudadana', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm1_id, 'Características del régimen democrático', '', 'Caracteriza el régimen democrático: los derechos de los ciudadanos, elección periódica de autoridades, división de poderes del Estado, fiscalización de las autoridades, participación ciudadana.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Artículos constitucionales y tratados internacionales', '', 'Identifica principales artículos constitucionales y tratados internacionales suscritos por Chile, que garantizan derechos políticos, civiles, económicos y sociales, instituciones responsables de resguardar esos derechos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Situaciones de violencia o atropello de derechos', '', 'Identifica situaciones de violencia o atropello de los derechos de las personas en contextos cotidianos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Ciudadanía y participación ciudadana', '', 'Identifica alcances e implicancias del concepto ciudadanía y formas de participación ciudadana: voto, partidos políticos, organizaciones y movimientos sociales.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm1_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Idioma Extranjero: Inglés — NM1 =================
  insert into public.subjects (name, canonical_code)
  values ('Idioma Extranjero: Inglés', 'english')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm1_id, v_subject_id, 'Idioma Extranjero: Inglés', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Comprensión Lectora en Inglés', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Comprensión Lectora en Inglés', '', 0, v_framework_257_id, v_source_nm1_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm1_id, 'Identificar información específica', '', 'Identificar información específica.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Primer Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Inferir el sentido global', '', 'Inferir el sentido global.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Primer Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Inferir el propósito', '', 'Inferir el propósito.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Primer Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Deducir significado de palabra según contexto', '', 'Deducir el significado de una palabra según el contexto aportado por un texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Primer Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Interpretar información', '', 'Interpretar información.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Primer Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Complementar información', '', 'Complementar información.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Primer Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm1_id),
    (v_unit_id, v_level_nm1_id, 'Inferir sentido de palabras y expresiones cotidianas', '', 'Inferir el sentido de palabras y expresiones en inglés, relativas a lo cotidiano.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Primer Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm1_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Lengua Castellana y Comunicación — NM2 =================
  insert into public.subjects (name, canonical_code)
  values ('Lengua Castellana y Comunicación', 'language')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm2_id, v_subject_id, 'Lengua Castellana y Comunicación', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Comprensión Lectora', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Comprensión Lectora', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Identifica información explícita', '', 'Identifica información explícita del texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Infiere el sentido global del texto', '', 'Infiere el sentido global de un texto (idea principal, central, temas, propósitos).', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Infiere información del texto', '', 'Infiere información del texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Identifica el tipo de texto por estructura', '', 'Identifica el tipo de texto de acuerdo con su estructura y contenido.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Identifica aspectos de los personajes', '', 'Identifica aspectos físicos y sicológicos de los personajes.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Infiere sentido de palabra según contexto', '', 'Infiere el sentido de una palabra o expresión según contexto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Reemplaza palabra por sinónimo según contexto', '', 'Remplaza una palabra por su sinónimo según contexto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Infiere significado de palabra o expresión', '', 'Infiere el significado de una palabra o expresión según contexto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Reconoce estructura del texto argumentativo', '', 'Reconoce la estructura de un texto argumentativo.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Elementos del texto argumentativo', '', 'Reconoce los elementos que componen el texto argumentativo como son: tesis, contraargumentos, argumentos y conclusión.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 9, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Tesis, argumentos y conclusiones', '', 'Identifica en el texto argumentativo: la tesis o supuestos que proponen; los argumentos y las conclusiones que entregan.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 10, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Función de componentes del texto argumentativo', '', 'Infiere la función de cada uno de los componentes del texto argumentativo.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 11, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Distingue hechos de opiniones', '', 'Distingue hechos de opiniones.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 12, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Analiza recursos verbales y no verbales', '', 'Analiza la función de distintos recursos verbales y no verbales usados para comunicar información en textos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 13, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Relaciona el tema con la realidad contemporánea', '', 'Relaciona el tema de un texto con aspectos de la realidad contemporánea.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 14, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Fundamenta opiniones sobre textos leídos', '', 'Fundamenta sus opiniones sobre los textos leídos argumentando y ejemplificando con información del texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Lengua Castellana y Comunicación, Segundo Nivel Medio (2025)', 2025, 15, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Ciencias Naturales — NM2 =================
  insert into public.subjects (name, canonical_code)
  values ('Ciencias Naturales', 'natural_sciences')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm2_id, v_subject_id, 'Ciencias Naturales', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Ciencias Biológicas', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Ciencias Biológicas', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Homeostasis: sistemas nervioso, endocrino y renal', '', 'Explica los principales procesos vitales de los sistemas nervioso, endocrino y renal y/o la relación entre estos sistemas con la homeostasis.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Procesos vitales del sistema inmunológico', '', 'Explica los principales procesos vitales del sistema inmunológico.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Sistemas relacionados con la homeostasis', '', 'Clasifica los componentes de los sistemas del cuerpo humano relacionados con la homeostasis: sistema nervioso, endocrino y renal.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Enfermedades que alteran la homeostasis', '', 'Describe tipos de enfermedades que generan alteraciones de la homeostasis a nivel endocrino, nervioso, inmunológico o genético.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Gráficos sobre enfermedades', '', 'Analiza o interpreta gráficos, diagramas o tablas relacionados con enfermedades infectocontagiosas, endocrinas, nerviosas, inmunológicas o genéticas.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Información genética y reproducción celular', '', 'Reconoce las principales características, propiedades y procesos (transmisión, conservación y variación) de la información genética y reproducción celular, considerando conceptos de: cromosoma, gen, estructura del ADN, ciclo celular, mitosis y meiosis.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Ciencias Físicas', '', 1, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Ciencias Físicas', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Fluidos: presión, empuje y presión atmosférica', '', 'Describe conceptos relacionados con fluidos (presión, presión hidrostática, empuje y presión atmosférica).', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Conceptos de electricidad', '', 'Reconoce conceptos relacionados con electricidad (carga, campo, corriente, potencial, intensidad, resistencia y circuitos).', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Componentes de circuitos eléctricos', '', 'Reconoce funciones de cada uno de los siguientes componentes: conductores, aisladores, fusibles, conexión a tierra, resistencias de artefactos e interruptores.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Conceptos de magnetismo', '', 'Reconoce conceptos relacionados con magnetismo (imanes, campo, inducción).', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Fenómenos de electricidad cotidiana', '', 'Explica fenómenos, usando conocimientos relacionados con la electricidad o sus aplicaciones en la vida cotidiana.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Fenómenos de magnetismo y electricidad', '', 'Explica fenómenos cotidianos, usando conocimientos relacionados con el magnetismo, su relación con la electricidad o sus aplicaciones.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Ciencias Químicas', '', 2, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Ciencias Químicas', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Evolución de las especies', '', 'Reconoce teorías sobre la evolución de las especies y evidencias de la evolución orgánica y biológica.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Modelos atómicos', '', 'Reconoce diferentes modelos atómicos (estructura, componentes) y/o sus conceptos asociados.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Partículas microscópicas del átomo', '', 'Clasifica características de las partículas microscópicas constituyentes del átomo: electrones y núcleo, y que constituyen la materia: átomos, moléculas e iones.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Tipos de enlaces químicos', '', 'Describe distintos tipos de enlaces químicos usando conocimientos sobre la organización de sus electrones.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Fenómenos radiactivos', '', 'Explica situaciones que involucren fenómenos radiactivos, tipos de emisiones, sus riesgos e impacto ambiental.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Tabla periódica', '', 'Describe las características de átomos comunes, su ubicación en grupos y periodos en la Tabla Periódica.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Moléculas orgánicas comunes', '', 'Describe moléculas orgánicas comunes, sus propiedades o usos y sus distintos tipos de enlaces.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Grupos funcionales', '', 'Clasifica los grupos funcionales y/o las propiedades que otorgan a la molécula y ejemplos de sustancias de uso cotidiano que los contienen.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Polímeros sintéticos y naturales', '', 'Reconoce el concepto de polímero, ejemplos de polímeros sintéticos y naturales.', 'en_revision', 'Temario VE EPJA D.S. 257 — Ciencias Naturales, Segundo Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Estudios Sociales — NM2 =================
  insert into public.subjects (name, canonical_code)
  values ('Estudios Sociales', 'social_sciences')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm2_id, v_subject_id, 'Estudios Sociales', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Dimensión Histórica', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Dimensión Histórica', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Hitos y procesos del siglo XX', '', 'Ubica temporalmente los principales hitos y procesos de la historia de la humanidad con énfasis en el siglo XX.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Segunda Guerra Mundial y Guerra Fría', '', 'Identifica principales características de la Segunda Guerra Mundial y la emergencia de un sistema bipolar, la Guerra Fría; la descolonización del Tercer Mundo.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Creación de la ONU', '', 'Identifica creación de la ONU y describe su rol e importancia en la generación de acuerdos políticos y económicos mundiales.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Caída de los socialismos reales', '', 'Identifica las principales características del proceso de caída de los socialismos reales y el sistema unipolar; Nuevo orden mundial.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Desarrollo tecnológico e interconectividad global', '', 'Describe el desarrollo tecnológico y su impacto en la interconectividad global, física y virtual.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Medios de comunicación y patrones culturales', '', 'Identifica el rol de los medios de comunicación y transporte en la transmisión de patrones culturales a escala mundial.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Internacionalización de las economías', '', 'Explica la creciente internacionalización de las economías nacionales: el impacto de la inversión extranjera y de las empresas transnacionales en la economía nacional, el rol de los organismos económicos internacionales.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Acuerdos de libre comercio', '', 'Identifica acuerdos de libre comercio y la integración en bloques económicos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Problemas sociales del mundo actual', '', 'Distingue los principales problemas sociales del mundo actual: caracterización de la pobreza y el hambre, el deterioro medioambiental, las pandemias.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Dimensión Geográfica y Económica', '', 1, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Dimensión Geográfica y Económica', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Conceptos básicos de economía', '', 'Identifica algunos conceptos básicos de economía (trabajo, empleo, producción, empresa, mercado, regulación estatal, propiedad privada, propiedad pública, servicios públicos, privatización).', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Características del empleo actual', '', 'Identifica las principales características del empleo a nivel global en la actualidad (terciarización, flexibilización, obsolescencia veloz, necesidad de adaptarse al cambio y permanente capacitación).', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Modalidades de organización del capitalismo', '', 'Identifica diferentes modalidades de organización del capitalismo actual. El rol del Estado como regulador. Revisión histórica de otros sistemas económicos: la esclavitud, la economía feudal, el Socialismo.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Población mundial y migraciones', '', 'Identifica volumen y distribución de la población mundial. Factores que explican el crecimiento de la población: natalidad, mortalidad y migraciones. Efectos de las grandes migraciones en las sociedades de origen y destino, la explosión demográfica y el envejecimiento de la población.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Asentamientos urbanos y rurales en Chile', '', 'Caracteriza los asentamientos urbanos y rurales en Chile, localización de las principales ciudades del país y sus vínculos con el contexto rural; predominio de la vida urbana en Chile y los factores del éxodo rural.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Expansión física de las ciudades latinoamericanas', '', 'Identifica los principales problemas derivados de la expansión física de las ciudades latinoamericanas, tales como el aumento en los tiempos de desplazamiento; la generación de residuos sólidos y líquidos; la contaminación atmosférica, acústica e hídrica; la segregación socioespacial: impacto sobre la calidad de vida.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Medio natural y actividades productivas', '', 'Identifica y describe las relaciones entre el medio natural y las actividades productivas; la explotación de recursos naturales y su impacto ambiental en la actualidad a nivel local y global.', 'en_revision', 'Temario VE EPJA D.S. 257 — Estudios Sociales, Segundo Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Idioma Extranjero: Inglés — NM2 =================
  insert into public.subjects (name, canonical_code)
  values ('Idioma Extranjero: Inglés', 'english')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm2_id, v_subject_id, 'Idioma Extranjero: Inglés', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Comprensión Lectora en Inglés', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Comprensión Lectora en Inglés', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Identificar información específica', '', 'Identificar información específica.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Inferir el sentido global', '', 'Inferir el sentido global.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Inferir el propósito', '', 'Inferir el propósito.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Deducir significado de palabra según contexto', '', 'Deducir el significado de una palabra según el contexto aportado por un texto.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Interpretar información', '', 'Interpretar información.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Complementar información', '', 'Complementar información.', 'en_revision', 'Temario VE EPJA D.S. 257 — Idioma Extranjero: Inglés, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  -- ================= Matemática — NM2 =================
  insert into public.subjects (name, canonical_code)
  values ('Matemática', 'mathematics')
  on conflict (name) do update set canonical_code = excluded.canonical_code
  returning id into v_subject_id;

  insert into public.framework_subjects (framework_id, level_id, subject_id, official_name, is_examined)
  values (v_framework_257_id, v_level_nm2_id, v_subject_id, 'Educación Matemática', true)
  on conflict (framework_id, level_id, subject_id) do update set official_name = excluded.official_name;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Funciones y Ecuaciones', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Funciones y Ecuaciones', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Raíz cuadrada como proceso inverso de potencias', '', 'Usa el concepto de raíz cuadrada como un proceso inverso de potencias con exponente dos y como potencias de exponente fraccionario.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Propiedades de las raíces cuadradas', '', 'Aplica propiedades de las raíces cuadradas para resolver expresiones numéricas.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Problemas con raíces cuadradas', '', 'Resuelve un problema que involucra raíces cuadradas y sus propiedades tanto para modelar como para encontrar una solución.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Función logaritmo y función exponencial', '', 'Representa de forma algebraica y gráfica la función logaritmo y la función exponencial.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 3, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Problemas con funciones exponenciales', '', 'Resuelve un problema que involucra funciones exponenciales tanto para modelar como para encontrar una solución.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 4, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Problemas con funciones logarítmicas', '', 'Resuelve un problema que involucra funciones logarítmicas tanto para modelar como para encontrar una solución.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 5, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Problemas con funciones cuadráticas', '', 'Resuelve un problema que involucra funciones cuadráticas tanto para modelar como para encontrar una solución.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 6, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Soluciones de ecuación de segundo grado', '', 'Determina la o las soluciones de una ecuación de segundo grado con una incógnita.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 7, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Problemas con ecuación de segundo grado', '', 'Resuelve un problema que involucra plantear y/o resolver una ecuación de segundo grado con una incógnita.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 8, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Geometría y Trigonometría', '', 1, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Geometría y Trigonometría', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Razones trigonométricas en triángulo rectángulo', '', 'Determina razones trigonométricas (seno, coseno y tangente) en el triángulo rectángulo.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Problemas de alturas o distancias inaccesibles', '', 'Resuelve un problema que involucra razones trigonométricas para encontrar el cálculo de alturas o distancias inaccesibles.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

  insert into public.strands (subject_id, name, description, order_index, framework_id, source_id)
  values (v_subject_id, 'Probabilidad y Estadística', '', 2, v_framework_257_id, v_source_nm2_id)
  on conflict (subject_id, name) do update set framework_id = excluded.framework_id
  returning id into v_strand_id;

  insert into public.units (strand_id, name, description, order_index, framework_id, source_id)
  values (v_strand_id, 'Objetivos evaluados — Probabilidad y Estadística', '', 0, v_framework_257_id, v_source_nm2_id)
  on conflict (strand_id, name) do update set framework_id = excluded.framework_id
  returning id into v_unit_id;

  insert into public.learning_objectives (unit_id, level_id, short_name, description, official_text, status, curricular_source, reference_year, order_index, framework_id, source_id)
  values    (v_unit_id, v_level_nm2_id, 'Tablas de frecuencia e histogramas', '', 'Interpreta información presentada en tablas de frecuencia e histogramas, con datos agrupados en intervalos.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 0, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Caracterización de una población por muestra', '', 'Caracteriza una población a partir de los datos de una muestra tomada.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 1, v_framework_257_id, v_source_nm2_id),
    (v_unit_id, v_level_nm2_id, 'Probabilidad condicional, suma o producto', '', 'Resuelve un problema que involucra determinar el valor de una probabilidad condicional, o una suma o un producto de probabilidades.', 'en_revision', 'Temario VE EPJA D.S. 257 — Educación Matemática, Segundo Nivel Medio (2025)', 2025, 2, v_framework_257_id, v_source_nm2_id)
  on conflict (unit_id, level_id, short_name) do update set official_text = excluded.official_text;

end $$;
