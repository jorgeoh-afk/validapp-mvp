-- Dominio: Resultados y progreso
-- Repara la restricción UNIQUE(student_id, lesson_id) en lesson_progress,
-- requerida por el upsert(onConflict: "student_id,lesson_id") en
-- lib/data/lessons.ts. Sin ella, cada intento de re-completar una lección
-- falla en Postgres (error 42P10) de forma silenciosa, ya que el código no
-- revisa el resultado de ese upsert.
--
-- Idempotente: solo agrega la restricción si no existe ya una restricción
-- UNIQUE sobre exactamente estas dos columnas (sin importar su nombre).

do $$
begin
  if not exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'lesson_progress'
      and c.contype = 'u'
      and (
        select array_agg(a.attname::text order by a.attname::text)
        from unnest(c.conkey) as k(attnum)
        join pg_attribute a on a.attrelid = t.oid and a.attnum = k.attnum
      ) = array['lesson_id', 'student_id']
  ) then
    alter table public.lesson_progress
      add constraint lesson_progress_student_id_lesson_id_key
      unique (student_id, lesson_id);
  end if;
end $$;
