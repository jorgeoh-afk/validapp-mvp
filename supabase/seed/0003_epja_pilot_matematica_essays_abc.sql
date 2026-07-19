-- Dominio: Contenido y preguntas
-- Blueprint de 3 ensayos paralelos (A/B/C) — Matemática, Primer Nivel
-- Medio, D.S. 257/2009 — más su distribución por eje. NO genera todavía la
-- selección de preguntas (`essay_questions`): eso requiere que
-- `importEpjaQuestionBank` (lib/data/epja-question-bank-import.ts) haya
-- insertado antes las 114 preguntas de
-- data/epja/exams/ds-257-2009/primer-nivel-medio/matematica/question-bank.json
-- contra una base de datos real, cosa que este script NO hace (no hay
-- conexión a ningún Supabase en este entorno). Después de aplicar
-- migraciones + 0001/0002/0003 (seeds) + correr el importador, un
-- administrador (o un script) debe ejecutar `generateEssay` para cada uno
-- de estos 3 ensayos desde `/admin/ensayos/<id>` — recién ahí queda
-- poblado `essay_questions` y el ensayo puede pasar de `en_revision` a
-- `publicado` (bloqueado hasta que `checkEssayAvailability` devuelva
-- `ready`, ver lib/data/essay-coverage.ts).
--
-- Cantidad y duración (25 preguntas, 90 minutos) SÍ están verificadas
-- contra la fuente oficial (ver comentario de 0001_epja_pilot_matematica.sql
-- y el propio texto del temario: "Cada prueba contiene 25 preguntas que
-- deberá contestar en un tiempo de 90 minutos") — por eso
-- `is_official_format = true`. La distribución por eje (9 Números / 7
-- Álgebra y Funciones / 5 Geometría / 4 Probabilidad y Estadística) es
-- `validapp_inferred_blueprint`: proporcional a la cantidad de objetivos de
-- cada eje (7/5/4/3 de 19), sin fuente oficial que fije esa distribución —
-- ver data/epja/exams/matematica-nm1-blueprint.test.ts, que simula 1000
-- generaciones de este mismo blueprint sobre el banco real de 114
-- preguntas y confirma que las cuotas se cumplen sin repetir preguntas
-- entre A/B/C, con banco de reserva sobrante.
--
-- Estado inicial `en_revision` (no `publicado`): las 114 preguntas del
-- banco entran con `validation_status` en
-- `ai_generated_review_required`/`automatically_validated` (0023), nunca
-- `approved_for_exam` -- un administrador debe revisarlas y aprobarlas
-- antes de que estos ensayos puedan publicarse.
--
-- Idempotente: `select ... where not exists` por nombre (mismo patrón que
-- el bloque de preguntas+ensayo de 0001). NO SE EJECUTÓ contra ningún
-- Supabase.

do $$
declare
  v_framework_257_id uuid;
  v_level_id uuid;
  v_subject_id uuid;
  v_strand_numeros_id uuid;
  v_strand_algebra_id uuid;
  v_strand_geometria_id uuid;
  v_strand_probabilidad_id uuid;
  v_essay_id uuid;
  v_label text;
begin
  select id into v_framework_257_id from public.curriculum_frameworks
    where decree_number = '257' and decree_year = 2009 and exam_year = 2026 and exam_period = 'primer_periodo';
  if v_framework_257_id is null then
    raise exception 'No se encontró el framework D.S. 257/2009 (2026, primer_periodo). Ejecuta primero 0001_epja_pilot_matematica.sql.';
  end if;

  select id into v_level_id from public.levels where name = 'Primer Nivel Medio';
  select id into v_subject_id from public.subjects where name = 'Matemática';
  select id into v_strand_numeros_id from public.strands where subject_id = v_subject_id and name = 'Números';
  select id into v_strand_algebra_id from public.strands where subject_id = v_subject_id and name = 'Álgebra y Funciones';
  select id into v_strand_geometria_id from public.strands where subject_id = v_subject_id and name = 'Geometría';
  select id into v_strand_probabilidad_id from public.strands where subject_id = v_subject_id and name = 'Probabilidad y Estadística';

  if v_level_id is null or v_subject_id is null or v_strand_numeros_id is null
     or v_strand_algebra_id is null or v_strand_geometria_id is null or v_strand_probabilidad_id is null then
    raise exception 'Falta currículum base de Matemática/Primer Nivel Medio. Ejecuta primero 0001_epja_pilot_matematica.sql.';
  end if;

  foreach v_label in array array['A', 'B', 'C'] loop
    if not exists (
      select 1 from public.essays
      where name = 'Ensayo ' || v_label || ' — Matemática, Primer Nivel Medio (D.S. 257/2009)'
    ) then
      insert into public.essays (
        name, level_id, essay_type, total_questions, time_limit_minutes,
        order_mode, feedback_mode, status, framework_id,
        is_official_format, variant_label
      )
      values (
        'Ensayo ' || v_label || ' — Matemática, Primer Nivel Medio (D.S. 257/2009)',
        v_level_id, 'por_asignatura', 25, 90, 'aleatorio', 'al_finalizar', 'en_revision',
        v_framework_257_id, true, v_label
      )
      returning id into v_essay_id;

      insert into public.essay_strand_distribution (essay_id, strand_id, question_count, is_required)
      values
        (v_essay_id, v_strand_numeros_id, 9, true),
        (v_essay_id, v_strand_algebra_id, 7, true),
        (v_essay_id, v_strand_geometria_id, 5, true),
        (v_essay_id, v_strand_probabilidad_id, 4, true);
    end if;
  end loop;
end $$;
