// Dominio: Contenido y preguntas (presentación) — traduce los datos crudos de
// `programs.curriculum_type` / `programs.code` / `levels.education_type` en
// etiquetas cortas y legibles para los listados del panel admin
// (programas, niveles, y opcionalmente objetivos de aprendizaje/preguntas).
// Centralizado en un solo lugar para no repetir el mapeo en cada página.

export type CurriculumBadgeVariant =
  | "default"
  | "muted"
  | "success"
  | "warning"
  | "destructive"
  | "outline";

export type CurriculumBadge = {
  label: string;
  variant: CurriculumBadgeVariant;
};

type ProgramLike = {
  code?: string | null;
  curriculum_type?: string | null;
} | null;

/** Badges para una fila de `programs` (o el programa asociado a un curso). */
export function getProgramBadges(program: ProgramLike): CurriculumBadge[] {
  if (!program) return [];
  const badges: CurriculumBadge[] = [];

  if (program.curriculum_type === "regular") {
    badges.push({ label: "Regular", variant: "default" });
  } else if (program.curriculum_type === "epja") {
    badges.push({ label: "EPJA", variant: "outline" });
  }

  switch (program.code) {
    case "regular_examenes_libres_menores":
      badges.push({ label: "Menores", variant: "muted" });
      badges.push({ label: "Exámenes libres", variant: "success" });
      break;
    case "epja_examenes_libres_adultos":
      badges.push({ label: "Adultos", variant: "muted" });
      badges.push({ label: "Exámenes libres", variant: "success" });
      break;
    case "epja_regular":
      badges.push({ label: "Adultos", variant: "muted" });
      badges.push({ label: "Modalidad regular", variant: "warning" });
      break;
    case "epja_flexible":
      badges.push({ label: "Adultos", variant: "muted" });
      badges.push({ label: "Modalidad flexible", variant: "warning" });
      break;
    default:
      break;
  }

  return badges;
}

type LevelLike = {
  education_type?: string | null;
  programs?: ProgramLike;
} | null;

/**
 * Badges para una fila de `levels` (curso). Combina el `education_type`
 * propio del curso (más confiable que el del programa cuando aún no
 * coinciden del todo) con los badges derivados de su programa.
 */
export function getLevelBadges(level: LevelLike): CurriculumBadge[] {
  if (!level) return [];
  const badges: CurriculumBadge[] = [];

  if (level.education_type === "menor_18") {
    badges.push({ label: "Menores", variant: "muted" });
  } else if (level.education_type === "mayor_18") {
    badges.push({ label: "Adultos", variant: "muted" });
  }

  const programBadges = getProgramBadges(level.programs ?? null).filter(
    // Evita duplicar "Menores"/"Adultos" si ya se agregó desde el curso.
    (badge) => badge.label !== "Menores" && badge.label !== "Adultos"
  );

  return [...badges, ...programBadges];
}
