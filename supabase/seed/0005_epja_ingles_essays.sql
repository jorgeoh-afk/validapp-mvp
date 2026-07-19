-- Dominio: Contenido y preguntas
-- Ensayos de Inglés (Idioma Extranjero: Inglés), Primer y Segundo Nivel
-- Medio, D.S. 257/2009.
--
-- Bancos ampliados en esta revisión (comprensión lectora requiere autoría
-- de texto original, por lo que crecieron en más de una pasada):
--   - NM1: 77 preguntas -> soporta Ensayo A, B y C (75 usadas, 2 de reserva).
--   - NM2: 60 preguntas -> soporta Ensayo A y B (50 usadas, 10 de reserva).
-- Ver data/epja/exams/ingles-nm1-blueprint.test.ts y
-- ingles-nm2-blueprint.test.ts, que verifican exactamente esta cantidad
-- soportada (no una cifra inventada) sobre el banco real.
--
-- 25 preguntas / 90 minutos: mismo texto oficial verificado que el resto
-- de las asignaturas (el temario aplica ese formato a todos los
-- subsectores, incluido Idioma Extranjero: Inglés).
--
-- Idempotente: reintentar este script no duplica ensayos ya creados
-- (verifica por nombre antes de insertar) y no reduce ensayos ya
-- existentes si el banco llegara a achicarse.

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
  select id into v_subject_id from public.subjects where name = 'Idioma Extranjero: Inglés';
  -- Inglés usa un único eje ("Comprensión Lectora en Inglés") tanto para
  -- NM1 como NM2 (mismo `strands.name`, ya que `strands` no está separado
  -- por nivel -- ver 0010).
  select id into v_strand_id from public.strands where subject_id = v_subject_id and name = 'Comprensión Lectora en Inglés';

  if v_framework_257_id is null or v_level_nm1_id is null or v_level_nm2_id is null
     or v_subject_id is null or v_strand_id is null then
    raise exception 'Falta currículum base de Inglés. Ejecuta primero 0001 y 0002.';
  end if;

  -- NM1: Ensayo A, B, C (77 preguntas disponibles). IMPORTANTE: se agrega
  -- essay_strand_distribution con question_count=25 -- sin esto,
  -- `buildCandidatePool` (lib/data/essays.ts) no filtra por asignatura, y
  -- el relleno "libre" tomaría preguntas de CUALQUIER asignatura de ese
  -- nivel, no solo Inglés.
  foreach v_label in array array['A', 'B', 'C'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Idioma Extranjero: Inglés, Primer Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Idioma Extranjero: Inglés, Primer Nivel Medio (D.S. 257/2009)',
        v_level_nm1_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values (v_essay_id, v_strand_id, 25, true);
    end if;
  end loop;

  -- NM2: Ensayo A y B (60 preguntas disponibles)
  foreach v_label in array array['A', 'B'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Idioma Extranjero: Inglés, Segundo Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (name, level_id, essay_type, total_questions, time_limit_minutes, order_mode, feedback_mode, status, framework_id, is_official_format, variant_label)
      values (
        'Ensayo ' || v_label || ' — Idioma Extranjero: Inglés, Segundo Nivel Medio (D.S. 257/2009)',
        v_level_nm2_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision', v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;
      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values (v_essay_id, v_strand_id, 25, true);
    end if;
  end loop;
end $$;
