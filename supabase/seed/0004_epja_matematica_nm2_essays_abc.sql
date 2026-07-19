-- Dominio: Contenido y preguntas
-- Blueprint de 3 ensayos paralelos (A/B/C) — Matemática, Segundo Nivel
-- Medio, D.S. 257/2009. Mismo criterio que
-- 0003_epja_pilot_matematica_essays_abc.sql (ver ese archivo para el
-- detalle de por qué no genera todavía `essay_questions` ni se ejecutó
-- contra ningún Supabase). 25 preguntas / 90 minutos: verificado en el
-- propio temario NM2 ("Cada prueba contiene 25 preguntas que deberá
-- contestar en un tiempo de 90 minutos"). Distribución por eje (16
-- Funciones y Ecuaciones / 4 Geometría y Trigonometría / 5 Probabilidad y
-- Estadística) es `validapp_inferred_blueprint`, proporcional a la
-- cantidad de objetivos por eje (9/2/3 de 14) — ver
-- data/epja/exams/matematica-nm2-blueprint.test.ts para la simulación de
-- 1000 generaciones sobre el banco real de 98 preguntas.
--
-- Requiere que 0002_epja_remaining_subjects.sql ya se haya ejecutado
-- (crea el nivel "Segundo Nivel Medio" y los ejes de Matemática NM2).

do $$
declare
  v_framework_257_id uuid;
  v_level_id uuid;
  v_subject_id uuid;
  v_strand_funciones_id uuid;
  v_strand_geotrig_id uuid;
  v_strand_probabilidad_id uuid;
  v_essay_id uuid;
  v_label text;
begin
  select id into v_framework_257_id from public.curriculum_frameworks
    where decree_number = '257' and decree_year = 2009 and exam_year = 2026 and exam_period = 'primer_periodo';
  select id into v_level_id from public.levels where name = 'Segundo Nivel Medio';
  select id into v_subject_id from public.subjects where name = 'Matemática';
  select id into v_strand_funciones_id from public.strands where subject_id = v_subject_id and name = 'Funciones y Ecuaciones';
  select id into v_strand_geotrig_id from public.strands where subject_id = v_subject_id and name = 'Geometría y Trigonometría';
  select id into v_strand_probabilidad_id from public.strands where subject_id = v_subject_id and name = 'Probabilidad y Estadística';

  if v_framework_257_id is null or v_level_id is null or v_subject_id is null
     or v_strand_funciones_id is null or v_strand_geotrig_id is null or v_strand_probabilidad_id is null then
    raise exception 'Falta currículum base de Matemática/Segundo Nivel Medio. Ejecuta primero 0001 y 0002.';
  end if;

  foreach v_label in array array['A', 'B', 'C'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Matemática, Segundo Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (
        name, level_id, essay_type, total_questions, time_limit_minutes,
        order_mode, feedback_mode, status, framework_id,
        is_official_format, variant_label
      )
      values (
        'Ensayo ' || v_label || ' — Matemática, Segundo Nivel Medio (D.S. 257/2009)',
        v_level_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision',
        v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;

      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values
        (v_essay_id, v_strand_funciones_id, 16, true),
        (v_essay_id, v_strand_geotrig_id, 4, true),
        (v_essay_id, v_strand_probabilidad_id, 5, true);
    end if;
  end loop;
end $$;
