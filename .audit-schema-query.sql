-- AUDITORÍA DE SOLO LECTURA — no modifica datos ni estructura.
-- Ejecutar tal cual en el SQL Editor de Supabase Studio y copiar el resultado completo.

-- 1) Columnas, tipos, defaults, nullable
select table_name, ordinal_position, column_name, data_type,
       column_default, is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name in (
    'profiles','subjects','levels','lessons','questions',
    'diagnostics','diagnostic_answers','lesson_progress',
    'gamification_stats','leads'
  )
order by table_name, ordinal_position;

-- 2) Claves primarias y foráneas
select
  tc.table_name, tc.constraint_name, tc.constraint_type,
  kcu.column_name,
  ccu.table_name as references_table,
  ccu.column_name as references_column,
  rc.update_rule, rc.delete_rule
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name and tc.table_schema = kcu.table_schema
left join information_schema.referential_constraints rc
  on tc.constraint_name = rc.constraint_name and tc.table_schema = rc.constraint_schema
left join information_schema.constraint_column_usage ccu
  on rc.unique_constraint_name = ccu.constraint_name
where tc.table_schema = 'public'
  and tc.table_name in (
    'profiles','subjects','levels','lessons','questions',
    'diagnostics','diagnostic_answers','lesson_progress',
    'gamification_stats','leads'
  )
  and tc.constraint_type in ('PRIMARY KEY','FOREIGN KEY','UNIQUE','CHECK')
order by tc.table_name, tc.constraint_type;

-- 3) Índices
select tablename, indexname, indexdef
from pg_indexes
where schemaname = 'public'
  and tablename in (
    'profiles','subjects','levels','lessons','questions',
    'diagnostics','diagnostic_answers','lesson_progress',
    'gamification_stats','leads'
  )
order by tablename, indexname;

-- 4) RLS habilitado + políticas
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
  and tablename in (
    'profiles','subjects','levels','lessons','questions',
    'diagnostics','diagnostic_answers','lesson_progress',
    'gamification_stats','leads'
  );

select tablename, policyname, cmd as operation, roles, qual as using_expr, with_check
from pg_policies
where schemaname = 'public'
  and tablename in (
    'profiles','subjects','levels','lessons','questions',
    'diagnostics','diagnostic_answers','lesson_progress',
    'gamification_stats','leads'
  )
order by tablename, policyname;

-- 5) Funciones definidas en public
select routine_name, data_type as return_type, routine_definition, security_type
from information_schema.routines
where routine_schema = 'public'
  and routine_type = 'FUNCTION';

-- 6) Triggers (incluye los que apuntan a auth.users, ej. on_auth_user_created)
select event_object_schema, event_object_table, trigger_name,
       action_timing, event_manipulation, action_statement
from information_schema.triggers
where trigger_schema not in ('pg_catalog','information_schema')
order by event_object_schema, event_object_table;

-- 7) Migraciones registradas por el CLI (tabla de control)
select version, name
from supabase_migrations.schema_migrations
order by version;
