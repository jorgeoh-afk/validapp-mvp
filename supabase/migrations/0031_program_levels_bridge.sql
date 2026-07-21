-- Dominio: Contenido y preguntas.
--
-- Problema que resuelve: hasta esta migración, `levels.program_id` (0010,
-- ampliado en 0028) es una FK simple -- cada curso/nivel pertenece a UN solo
-- programa. Eso funciona bien para los 12 cursos del Currículum Regular y
-- para "EPJA - Exámenes Libres (Mayores de 18 años)" (que ya tiene sus 5
-- niveles condensados con 664 preguntas/ensayos/objetivos de aprendizaje
-- reales colgando de esos `level_id`, ver 0028 y el seed 0009). Pero
-- "EPJA - Modalidad Regular" y "EPJA - Modalidad Flexible" (programas ya
-- existentes en `programs`, sin ningún nivel propio) necesitan ofrecer esos
-- MISMOS 5 niveles a sus estudiantes.
--
-- Investigación previa (skill `/validapp-content`,
-- validapp-curriculum-specialist, confianza media-alta): las 3 modalidades
-- EPJA (Regular, Flexible, Exámenes Libres) comparten la MISMA estructura
-- curricular de 5 niveles condensados -- lo que cambia entre modalidades es
-- la forma de asistencia/evaluación (presencial, semipresencial, examen
-- puntual), no el contenido evaluado. Incertidumbre normativa explícita que
-- deja ese análisis, y que esta migración NO resuelve: no está confirmado
-- que el D.S. 257/2009 (que fija esta estructura de 5 niveles EPJA) siga
-- vigente sin cambios posteriores -- se requiere verificación normativa
-- adicional antes de tratar esta equivalencia como definitiva. Por el mismo
-- motivo, la rama Técnico-Profesional de Educación Media EPJA (distinta de
-- la Humanístico-Científica que ya cubren los niveles existentes, ver
-- columna `levels.track` de 0022_levels_epja_metadata.sql) NO se incorpora
-- aquí a propósito: queda pendiente de verificación normativa, no se asume.
--
-- Decisión de diseño (aprobada explícitamente por el usuario): en vez de
-- duplicar las 5 filas de `levels` una vez por cada uno de los 3 programas
-- EPJA (lo que triplicaría la autoría de 664 preguntas/ensayos/objetivos de
-- aprendizaje ya validados, o forzaría a inventar una capa de "clonado" de
-- contenido), se agrega una relación muchos-a-muchos mediante una tabla
-- puente nueva, `program_levels`. Mismo patrón de tabla puente ya usado en
-- este dominio para `learning_objective_skills` (0010): claves foráneas
-- `on delete cascade` + llave primaria compuesta, sin columnas propias.
--
-- IMPORTANTE -- `levels.program_id` NO se toca: se mantiene intacto como el
-- "programa principal/canónico" de cada nivel, exactamente como lo dejaron
-- 0010/0028/el seed 0009 (incluyendo el re-apunte de los 2 niveles EPJA de
-- nivel medio de "EPJA - Modalidad Regular" a "EPJA - Exámenes Libres" que
-- hizo el seed 0009). Ningún lector existente de `program_id` (CRUD admin de
-- `lib/data/curriculum.ts`, diagnóstico, generación de ensayos, selección de
-- preguntas -- ver auditoría de lectores en 0028) se ve afectado por esta
-- migración: es puramente aditiva. `program_levels` es un complemento para
-- expresar "este nivel TAMBIÉN está disponible bajo este otro programa", no
-- un reemplazo de la relación canónica.
--
-- Consumo desde TypeScript (`lib/data/curriculum.ts`, `listLevelsByProgram`)
-- queda fuera de esta migración a propósito: lo hace otro agente en un paso
-- posterior, después de revisión de este esquema.
--
-- Migración solo local: no se ejecutó `supabase db push` ni ningún SQL de
-- escritura contra un proyecto remoto (dev o prod). Reversible: si se
-- necesita deshacer, basta un `drop table if exists public.program_levels`
-- en una migración correctiva nueva -- no se modifica ningún archivo
-- histórico.

-- ---------- Tabla puente: programas <-> niveles ----------
create table if not exists public.program_levels (
  program_id uuid not null references public.programs (id) on delete cascade,
  level_id uuid not null references public.levels (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (program_id, level_id)
);

comment on table public.program_levels is
  'Tabla puente muchos-a-muchos entre public.programs y public.levels: expresa qué niveles/cursos están disponibles bajo qué programas/modalidades, además de la relación canónica levels.program_id (que NO se modifica). Caso de uso principal: los 5 niveles EPJA condensados (Primer/Segundo/Tercer Nivel Básico, Primer/Segundo Nivel Medio) son compartidos por las 3 modalidades EPJA (Exámenes Libres, Regular, Flexible) sin duplicar filas de levels ni el contenido (preguntas/ensayos/objetivos de aprendizaje) que cuelga de esos level_id.';
comment on column public.program_levels.program_id is
  'Programa/modalidad bajo el cual el nivel está disponible. on delete cascade: si se elimina el programa, desaparece la disponibilidad asociada (no el nivel en sí, que sigue existiendo vía su program_id canónico salvo que ese también sea el programa eliminado).';
comment on column public.program_levels.level_id is
  'Nivel/curso disponible bajo el programa. on delete cascade: si se elimina el nivel, desaparece la fila puente (el contenido real -- preguntas, ensayos, objetivos de aprendizaje -- cuelga de levels.id directamente y sigue las reglas de integridad ya existentes para esa tabla, no las de program_levels).';

-- Índice de apoyo para el sentido de consulta inverso (niveles de un
-- programa dado), que es el caso de uso principal (listLevelsByProgram). La
-- llave primaria (program_id, level_id) ya cubre eficientemente ese sentido
-- por ser la columna líder, así que no se agrega un índice adicional aquí
-- -- se deja explícito este comentario para que quede claro que se evaluó.

-- ---------- Row Level Security ----------
-- Mismo patrón exacto que `learning_objective_skills` (0010): lectura para
-- cualquier usuario autenticado, escritura solo para administradores,
-- verificando el rol directamente contra `profiles` (no vía `is_admin()`,
-- para mantener consistencia literal con el resto de tablas puente de este
-- dominio).
alter table public.program_levels enable row level security;

create policy "program_levels_select_authenticated" on public.program_levels for select to authenticated using (true);

create policy "program_levels_write_admin" on public.program_levels for all to authenticated
  using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'))
  with check (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'administrador'));
