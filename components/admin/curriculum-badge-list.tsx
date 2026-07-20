import { Badge } from "@/components/ui/badge";
import type { CurriculumBadge } from "@/lib/curriculum-badges";

/** Lista de badges curriculares (Regular/EPJA/Menores/Adultos/etc.), reutilizable
 * en los listados admin de programas, niveles, objetivos y preguntas. */
export function CurriculumBadgeList({
  badges,
}: {
  badges: CurriculumBadge[];
}) {
  if (badges.length === 0) return null;
  return (
    <div className="flex flex-wrap gap-1.5">
      {badges.map((badge) => (
        <Badge key={badge.label} variant={badge.variant}>
          {badge.label}
        </Badge>
      ))}
    </div>
  );
}
