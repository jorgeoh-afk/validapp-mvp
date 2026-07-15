import Link from "next/link";
import { Check, Lock, Play } from "lucide-react";
import { buttonVariants } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import type { LessonStatus } from "@/lib/data/progress";

const STATUS_CONFIG: Record<
  LessonStatus,
  {
    label: string;
    circle: string;
    badge: string;
    icon: React.ReactNode;
  }
> = {
  completada: {
    label: "Completada",
    circle: "bg-success text-success-foreground",
    badge: "border-success/30 bg-success/10 text-success",
    icon: <Check className="size-5" aria-hidden="true" />,
  },
  disponible: {
    label: "Disponible",
    circle: "bg-primary text-primary-foreground",
    badge: "border-primary/30 bg-primary/10 text-primary",
    icon: <Play className="size-4" aria-hidden="true" />,
  },
  bloqueada: {
    label: "Bloqueada",
    circle: "border border-border bg-muted text-muted-foreground",
    badge: "border-border bg-muted text-muted-foreground",
    icon: <Lock className="size-4" aria-hidden="true" />,
  },
};

export function LessonNode({
  lessonId,
  order,
  title,
  levelName,
  status,
  isLast,
}: {
  lessonId: string;
  order: number;
  title: string;
  levelName?: string;
  status: LessonStatus;
  isLast: boolean;
}) {
  const config = STATUS_CONFIG[status];
  const isLocked = status === "bloqueada";

  return (
    <li className="relative flex gap-4">
      {!isLast && (
        <span
          aria-hidden="true"
          className="absolute top-14 left-[27px] h-[calc(100%-1.5rem)] w-0.5 bg-border"
        />
      )}
      <span
        className={cn(
          "flex size-14 shrink-0 items-center justify-center rounded-full text-base font-semibold shadow-sm",
          config.circle
        )}
        aria-hidden="true"
      >
        {status === "bloqueada" ? config.icon : order}
      </span>

      <div
        className={cn(
          "flex flex-1 flex-col gap-2 rounded-xl border border-border bg-card px-4 py-3 pb-4 sm:flex-row sm:items-center sm:justify-between",
          isLocked && "opacity-70"
        )}
      >
        <div className="flex flex-col gap-1">
          <span className="font-medium text-foreground">{title}</span>
          <span className="flex items-center gap-2 text-xs text-muted-foreground">
            {levelName && <span>{levelName}</span>}
            <span
              className={cn(
                "inline-flex items-center gap-1 rounded-full border px-2 py-0.5 font-medium",
                config.badge
              )}
            >
              {config.icon}
              {config.label}
            </span>
          </span>
        </div>

        {isLocked ? (
          <span className="text-xs text-muted-foreground sm:text-right">
            Completa la lección anterior para desbloquear
          </span>
        ) : (
          <Link
            href={`/leccion/${lessonId}`}
            className={cn(
              buttonVariants({ variant: status === "completada" ? "outline" : "default" }),
              "w-full sm:w-auto"
            )}
          >
            {status === "completada" ? "Repasar" : "Empezar"}
          </Link>
        )}
      </div>
    </li>
  );
}
