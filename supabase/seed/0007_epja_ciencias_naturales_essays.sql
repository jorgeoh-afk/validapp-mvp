-- Dominio: Contenido y preguntas
-- Ensayos de Ciencias Naturales, Primer y Segundo Nivel Medio, D.S.
-- 257/2009.
--
-- Bancos ampliados en esta revisión: 50 preguntas en ambos niveles
-- (NM1: Biológicas=23 / Físicas=16 / Químicas=11; NM2: Biológicas=14 /
-- Físicas=13 / Químicas=23) -- cada uno soporta ahora Ensayo A y B.
-- "Ensayo C" NO se crea todavía (haría falta más banco). Ver
-- data/epja/exams/ciencias-naturales-blueprint.test.ts.
--
-- A diferencia de Lengua/Inglés (un solo eje), Ciencias Naturales tiene 3
-- ejes reales (Ciencias Biológicas/Físicas/Químicas, explícitos en el
-- propio temario), así que sí se agrega distribución por eje. Las cuotas
-- de Ensayo B usan los mismos números que Ensayo A (misma proporción por
-- eje, verificado contra la disponibilidad real: 2 × cuota <= banco por
-- eje en ambos niveles); no suman exactamente 25 por ensayo (24, con 1
-- pregunta de relleno libre dentro de la misma asignatura vía
-- essay_subjects) porque escalar 25 preguntas en proporciones exactas de
-- 3 ejes no da números enteros limpios.

do $$
declare
  v_framework_257_id uuid;
  v_level_nm1_id uuid;
  v_level_nm2_id uuid;
  v_subject_id uuid;
  v_strand_bio_id uuid;
  v_strand_fis_id uuid;
  v_strand_qui_id uuid;
  v_essay_id uuid;
  v_label text;
begin
  select id into v_framework_257_id from public.curriculum_frameworks
    where decree_number = '257' and decree_year = 2009 and exam_year = 2026 and exam_period = 'primer_periodo';
  select id into v_level_nm1_id from public.levels where name = 'Primer Nivel Medio';
  select id into v_level_nm2_id from public.levels where name = 'Segundo Nivel Medio';
  select id into v_subject_id from public.subjects where name = 'Ciencias Naturales';
  select id into v_strand_bio_id from public.strands where subject_id = v_subject_id and name = 'Ciencias Biológicas';
  select id into v_strand_fis_id from public.strands where subject_id = v_subject_id and name = 'Ciencias Físicas';
  select id into v_strand_qui_id from public.strands where subject_id = v_subject_id and name = 'Ciencias Químicas';

  if v_framework_257_id is null or v_level_nm1_id is null or v_level_nm2_id is null
     or v_subject_id is null or v_strand_bio_id is null or v_strand_fis_id is null or v_strand_qui_id is null then
    raise exception 'Falta currículum base de Ciencias Naturales. Ejecuta primero 0001 y 0002.';
  end if;

  -- NM1: disponible Bio=23 / Fis=16 / Qui=11 -> cuota por ensayo 11/8/5
  -- (2x = 22/16/10 <= disponible).
  foreach v_label in array array['A', 'B'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Ciencias Naturales, Primer Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Ciencias Naturales, Primer Nivel Medio (D.S. 257/2009)',
        v_level_nm1_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values
        (v_essay_id, v_strand_bio_id, 11, true),
        (v_essay_id, v_strand_fis_id, 8, true),
        (v_essay_id, v_strand_qui_id, 5, true);
    end if;
  end loop;

  -- NM2: disponible Bio=14 / Fis=13 / Qui=23 -> cuota por ensayo 7/6/11
  -- (2x = 14/12/22 <= disponible).
  foreach v_label in array array['A', 'B'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Ciencias Naturales, Segundo Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Ciencias Naturales, Segundo Nivel Medio (D.S. 257/2009)',
        v_level_nm2_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values
        (v_essay_id, v_strand_bio_id, 7, true),
        (v_essay_id, v_strand_fis_id, 6, true),
        (v_essay_id, v_strand_qui_id, 11, true);
    end if;
  end loop;
end $$;
