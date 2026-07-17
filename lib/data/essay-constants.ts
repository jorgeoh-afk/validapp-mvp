// Dominio: Contenido y preguntas — constantes de ensayos (Fase 5).
// Se separan en un módulo sin "use server" porque un archivo de Server
// Actions solo puede exportar funciones async; estas listas se necesitan
// tanto en `lib/data/essays.ts` (validación) como en componentes de UI.

export const ESSAY_TYPES = [
  "general_curso",
  "por_asignatura",
  "por_objetivo",
  "diagnostico",
  "personalizado",
  "practica_errores",
  "refuerzo_objetivos",
] as const;

export const ORDER_MODES = ["fijo", "aleatorio"] as const;
export const FEEDBACK_MODES = ["inmediata", "al_finalizar"] as const;
export const ESSAY_STATUSES = [
  "borrador",
  "en_revision",
  "programado",
  "publicado",
  "finalizado",
  "archivado",
] as const;
