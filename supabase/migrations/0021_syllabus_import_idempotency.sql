-- Dominio: Contenido y preguntas
-- Fase EPJA 5: la carga masiva de temario (`lib/data/syllabus-import.ts`,
-- introducida junto con `syllabus-import-shared.ts`) hacía `insert` puro
-- para TODOS los tipos de fila. `strands`/`units` ya tenían restricciones
-- únicas (`unique (subject_id, name)` / `unique (strand_id, name)`, 0010),
-- pero `learning_objectives` (índice PARCIAL de 0014), `big_ideas`,
-- `essential_knowledge` y `lessons` no tenían ninguna utilizable, así que
-- reimportar el mismo CSV los duplicaba silenciosamente en cada reintento.
--
-- Decisión de diseño — por qué son índices llanos, no de expresión ni
-- parciales: el cliente de Supabase (`.upsert(row, { onConflict:
-- "col1,col2" })`, vía PostgREST) solo puede resolver un `upsert` contra un
-- índice único cuyo target sea una lista LITERAL de columnas — no contra un
-- índice de expresión (`lower(btrim(x))`) ni, sin repetir el predicado (que
-- PostgREST no permite adjuntar), contra un índice único PARCIAL. Por eso:
--   - `big_ideas`/`essential_knowledge`/`lessons`: índices llanos sobre las
--     columnas de texto tal cual (no normalizadas). Reimportar el MISMO CSV
--     (el caso que este parche resuelve) queda protegido porque el texto es
--     idéntico byte a byte entre corrida y corrida; una variante con
--     mayúsculas/espacios distintos se seguiría tratando como fila nueva.
--   - `learning_objectives`: se agrega un índice llano `(unit_id, level_id,
--     code)` que REEMPLAZA, para efectos de `upsert`, al índice parcial de
--     0014 (que se deja intacto, ya no se usa como arbiter pero tampoco
--     estorba). Un índice único llano SÍ permite múltiples filas con
--     `code IS NULL` — Postgres nunca considera dos NULL iguales para
--     unicidad — así que sigue sin exigir `code` a los objetivos que no lo
--     traen; para esos se agrega un segundo índice llano sobre
--     `(unit_id, level_id, short_name)`, usado como arbiter solo cuando la
--     fila no trae código.
--
-- Limitación conocida: un índice btree de Postgres tiene un límite de ~2.7kB
-- por fila indexada; un `statement`/`title`/`short_name` inusualmente largo
-- podría exceder ese límite al insertar. No se espera para el contenido
-- EPJA de este piloto (enunciados de una oración), pero queda anotado para
-- revisión si se cargan textos largos en el futuro.
--
-- ADVERTENCIA antes de aplicar contra Supabase remoto: si ya existen filas
-- duplicadas (misma clave) en producción, el índice correspondiente fallará
-- al crearse. Verificar primero, por ejemplo:
--   select subject_id, level_id, statement, count(*)
--   from public.big_ideas group by 1,2,3 having count(*) > 1;
--
-- Migración solo local: no se ejecutó `supabase db push`.

create unique index if not exists big_ideas_subject_level_statement_key
  on public.big_ideas (subject_id, level_id, statement);

create unique index if not exists essential_knowledge_subject_level_statement_key
  on public.essential_knowledge (subject_id, level_id, statement);

create unique index if not exists lessons_subject_level_title_key
  on public.lessons (subject_id, level_id, title);

create unique index if not exists learning_objectives_unit_level_code_full_key
  on public.learning_objectives (unit_id, level_id, code);

create unique index if not exists learning_objectives_unit_level_name_key
  on public.learning_objectives (unit_id, level_id, short_name);
