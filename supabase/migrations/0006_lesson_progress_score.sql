-- Dominio: Resultados y progreso
-- Guarda el puntaje de la evaluación de práctica al completar una lección.

alter table public.lesson_progress
  add column if not exists score int,
  add column if not exists total_questions int;
