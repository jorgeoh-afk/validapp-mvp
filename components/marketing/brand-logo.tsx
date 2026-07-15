import Link from "next/link";
import { GraduationCap } from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Marca de ValidApp reutilizada en encabezado y pie de página.
 * Es una wordmark tipográfica propia (icono + texto), sin relación
 * con marcas de terceros.
 */
export function BrandLogo({ className }: { className?: string }) {
  return (
    <Link
      href="/"
      className={cn(
        "flex items-center gap-2 text-lg font-semibold tracking-tight text-foreground",
        className
      )}
    >
      <span
        aria-hidden="true"
        className="flex size-9 items-center justify-center rounded-xl bg-primary text-primary-foreground"
      >
        <GraduationCap className="size-5" />
      </span>
      ValidApp
    </Link>
  );
}
