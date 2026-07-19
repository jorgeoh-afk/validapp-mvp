-- Dominio: Contenido y preguntas
-- Ensayos de Lengua Castellana y Comunicación, Primer y Segundo Nivel
-- Medio, D.S. 257/2009. Mismo criterio que 0005 (Inglés): la comprensión
-- lectora requiere autoría de texto original, no se genera
-- paramétricamente.
--
-- Bancos ampliados en esta revisión: 58 preguntas (NM1), 57 preguntas
-- (NM2) -- cada uno soporta ahora Ensayo A y B (50 usadas, 7-8 de
-- reserva). "Ensayo C" NO se crea todavía (haría falta más banco). Ver
-- data/epja/exams/lengua-nm1-blueprint.test.ts y lengua-nm2-blueprint.test.ts,
-- que verifican esta cantidad soportada sobre el banco real.
--
-- Idempotente: reintentar este script no duplica ensayos ya creados.

do $$
declare
  v_framework_257_id uuid;
  v_level_nm1_id uuid;
  v_level_nm2_id uuid;
  v_subject_id uuid;
  v_strand_id uuid;
  v_essay_id uuid;
  v_label text;
begin
  select id into v_framework_257_id from public.curriculum_frameworks
    where decree_number = '257' and decree_year = 2009 and exam_year = 2026 and exam_period = 'primer_periodo';
  select id into v_level_nm1_id from public.levels where name = 'Primer Nivel Medio';
  select id into v_level_nm2_id from public.levels where name = 'Segundo Nivel Medio';
  select id into v_subject_id from public.subjects where name = 'Lengua Castellana y Comunicación';
  select id into v_strand_id from public.strands where subject_id = v_subject_id and name = 'Comprensión Lectora';

  if v_framework_257_id is null or v_level_nm1_id is null or v_level_nm2_id is null
     or v_subject_id is null or v_strand_id is null then
    raise exception 'Falta currículum base de Lengua. Ejecuta primero 0001 y 0002.';
  end if;

  -- NM1: Ensayo A y B (58 preguntas disponibles)
  foreach v_label in array array['A', 'B'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Lengua Castellana y Comunicación, Primer Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Lengua Castellana y Comunicación, Primer Nivel Medio (D.S. 257/2009)',
        v_level_nm1_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values (v_essay_id, v_strand_id, 25, true);
    end if;
  end loop;

  -- NM2: Ensayo A y B (57 preguntas disponibles)
  foreach v_label in array array['A', 'B'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Lengua Castellana y Comunicación, Segundo Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Lengua Castellana y Comunicación, Segundo Nivel Medio (D.S. 257/2009)',
        v_level_nm2_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values (v_essay_id, v_strand_id, 25, true);
    end if;
  end loop;
end $$;
