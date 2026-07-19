-- Dominio: Contenido y preguntas
-- Ensayos de Estudios Sociales, Primer y Segundo Nivel Medio, D.S.
-- 257/2009.
--
-- Bancos ampliados en esta revisión: 50 preguntas en ambos niveles
-- (NM1: Dimensión Histórica=36 / Dimensión Formación Ciudadana=14;
-- NM2: Dimensión Histórica=31 / Dimensión Geográfica y Económica=19) --
-- cada uno soporta ahora Ensayo A y B. "Ensayo C" NO se crea todavía
-- (haría falta más banco). Ver
-- data/epja/exams/estudios-sociales-blueprint.test.ts.

do $$
declare
  v_framework_257_id uuid;
  v_level_nm1_id uuid;
  v_level_nm2_id uuid;
  v_subject_id uuid;
  v_strand_id_1 uuid;
  v_strand_id_2 uuid;
  v_essay_id uuid;
  v_label text;
begin
  select id into v_framework_257_id from public.curriculum_frameworks
    where decree_number = '257' and decree_year = 2009 and exam_year = 2026 and exam_period = 'primer_periodo';
  select id into v_level_nm1_id from public.levels where name = 'Primer Nivel Medio';
  select id into v_level_nm2_id from public.levels where name = 'Segundo Nivel Medio';
  select id into v_subject_id from public.subjects where name = 'Estudios Sociales';

  if v_framework_257_id is null or v_level_nm1_id is null or v_level_nm2_id is null or v_subject_id is null then
    raise exception 'Falta currículum base de Estudios Sociales. Ejecuta primero 0001 y 0002.';
  end if;

  -- NM1: disponible Dimensión Histórica=36 / Dimensión Formación
  -- Ciudadana=14 -> cuota por ensayo 18/7 (2x = 36/14, coincide
  -- exactamente con lo disponible).
  select id into v_strand_id_1 from public.strands where subject_id = v_subject_id and name = 'Dimensión Histórica';
  select id into v_strand_id_2 from public.strands where subject_id = v_subject_id and name = 'Dimensión Formación Ciudadana';
  if v_strand_id_1 is null or v_strand_id_2 is null then
    raise exception 'Faltan ejes de Estudios Sociales NM1. Ejecuta primero 0002.';
  end if;
  foreach v_label in array array['A', 'B'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Estudios Sociales, Primer Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Estudios Sociales, Primer Nivel Medio (D.S. 257/2009)',
        v_level_nm1_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values
        (v_essay_id, v_strand_id_1, 18, true),
        (v_essay_id, v_strand_id_2, 7, true);
    end if;
  end loop;

  -- NM2: disponible Dimensión Histórica=31 / Dimensión Geográfica y
  -- Económica=19 -> cuota por ensayo 15/9 (2x = 30/18 <= disponible).
  select id into v_strand_id_1 from public.strands where subject_id = v_subject_id and name = 'Dimensión Histórica';
  select id into v_strand_id_2 from public.strands where subject_id = v_subject_id and name = 'Dimensión Geográfica y Económica';
  if v_strand_id_1 is null or v_strand_id_2 is null then
    raise exception 'Faltan ejes de Estudios Sociales NM2. Ejecuta primero 0002.';
  end if;
  foreach v_label in array array['A', 'B'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Estudios Sociales, Segundo Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Estudios Sociales, Segundo Nivel Medio (D.S. 257/2009)',
        v_level_nm2_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values
        (v_essay_id, v_strand_id_1, 15, true),
        (v_essay_id, v_strand_id_2, 9, true);
    end if;
  end loop;
end $$;
