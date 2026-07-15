import Link from "next/link";
import { BrandLogo } from "@/components/marketing/brand-logo";

const NAV_LINKS = [
  { href: "#como-funciona", label: "Cómo funciona" },
  { href: "#beneficios", label: "Beneficios" },
  { href: "#preguntas-frecuentes", label: "Preguntas frecuentes" },
  { href: "#contacto", label: "Contacto" },
];

export function SiteFooter() {
  return (
    <footer className="border-t border-border bg-muted/40">
      <div className="mx-auto flex w-full max-w-6xl flex-col gap-8 px-4 py-10 sm:px-6">
        <div className="grid gap-8 sm:grid-cols-3">
          <div className="flex flex-col gap-3">
            <BrandLogo />
            <p className="max-w-xs text-sm text-muted-foreground">
              Plataforma chilena para preparar exámenes libres, con una ruta
              de aprendizaje adaptada a tu nivel y seguimiento de tu
              progreso.
            </p>
          </div>

          <nav aria-label="Enlaces del pie de página" className="flex flex-col gap-2">
            <span className="text-sm font-semibold text-foreground">
              Navegación
            </span>
            {NAV_LINKS.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="text-sm text-muted-foreground transition-colors hover:text-foreground"
              >
                {link.label}
              </a>
            ))}
            <Link
              href="/login"
              className="text-sm text-muted-foreground transition-colors hover:text-foreground"
            >
              Iniciar sesión
            </Link>
          </nav>

          <div className="flex flex-col gap-2">
            <span className="text-sm font-semibold text-foreground">
              Legal
            </span>
            {/* Contenido temporal: aún no existen páginas de términos y
                privacidad definitivas. Se muestran como próximamente. */}
            <span className="text-sm text-muted-foreground">
              Términos de uso (próximamente)
            </span>
            <span className="text-sm text-muted-foreground">
              Política de privacidad (próximamente)
            </span>
          </div>
        </div>

        <div className="flex flex-col gap-2 border-t border-border pt-6 text-xs text-muted-foreground">
          <p>
            ValidApp es una plataforma de preparación educativa y no
            reemplaza al MINEDUC ni realiza directamente los exámenes de
            validación de estudios.
          </p>
          <p>© {new Date().getFullYear()} ValidApp. Todos los derechos reservados.</p>
        </div>
      </div>
    </footer>
  );
}
