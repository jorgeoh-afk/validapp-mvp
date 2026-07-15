import { cn } from "@/lib/utils";

type ProgressBarProps = {
  value: number;
  label?: string;
  showValue?: boolean;
  className?: string;
  barClassName?: string;
  size?: "sm" | "default";
};

/**
 * Barra de progreso accesible. El porcentaje siempre se muestra como texto
 * (no depende únicamente del color) y expone los atributos ARIA de progreso.
 */
export function ProgressBar({
  value,
  label,
  showValue = true,
  className,
  barClassName,
  size = "default",
}: ProgressBarProps) {
  const clamped = Math.min(100, Math.max(0, Math.round(value)));

  return (
    <div className={cn("flex flex-col gap-1", className)}>
      {(label || showValue) && (
        <div className="flex items-center justify-between gap-2 text-xs font-medium text-muted-foreground">
          {label && <span>{label}</span>}
          {showValue && <span>{clamped}%</span>}
        </div>
      )}
      <div
        role="progressbar"
        aria-valuenow={clamped}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label={label ?? "Progreso"}
        className={cn(
          "w-full overflow-hidden rounded-full bg-muted",
          size === "sm" ? "h-1.5" : "h-2.5"
        )}
      >
        <div
          className={cn(
            "h-full rounded-full bg-primary transition-[width] duration-500",
            barClassName
          )}
          style={{ width: `${clamped}%` }}
        />
      </div>
    </div>
  );
}
