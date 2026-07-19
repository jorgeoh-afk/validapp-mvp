import { ProgressBar } from "@/components/ui/progress-bar";

/** Celda compacta que muestra el porcentaje como texto y como barra. */
export function PercentCell({ value }: { value: number | null }) {
  if (value === null) {
    return <span className="text-muted-foreground">—</span>;
  }
  return (
    <div className="flex items-center gap-2">
      <span className="tabular-nums">{value}%</span>
      <ProgressBar value={value} showValue={false} size="sm" className="w-20" />
    </div>
  );
}
