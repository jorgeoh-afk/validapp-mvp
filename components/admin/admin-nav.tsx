"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

type NavItem = { href: string; label: string };
type NavGroup = { title: string; items: NavItem[] };

const NAV_GROUPS: NavGroup[] = [
  {
    title: "Gestión general",
    items: [
      { href: "/admin", label: "Inicio" },
      { href: "/admin/asignaturas", label: "Asignaturas" },
      { href: "/admin/niveles", label: "Niveles" },
      { href: "/admin/lecciones", label: "Lecciones" },
      { href: "/admin/importar-temario", label: "Importar temario completo" },
      { href: "/admin/preguntas", label: "Preguntas" },
      { href: "/admin/revision-preguntas", label: "Revisión de preguntas IA" },
      { href: "/admin/resultados", label: "Resultados" },
      { href: "/admin/leads", label: "Interesados" },
      { href: "/admin/ensayos", label: "Ensayos" },
      { href: "/admin/cobertura", label: "Cobertura curricular" },
      { href: "/admin/estadisticas", label: "Estadísticas de preguntas" },
      { href: "/admin/curriculum-epja", label: "Currículum EPJA" },
    ],
  },
  {
    title: "Estructura curricular",
    items: [
      { href: "/admin/programas", label: "Programas" },
      { href: "/admin/niveles-educativos", label: "Niveles educativos" },
      { href: "/admin/ejes", label: "Ejes temáticos" },
      { href: "/admin/unidades", label: "Unidades" },
      { href: "/admin/habilidades", label: "Habilidades" },
      {
        href: "/admin/objetivos-aprendizaje",
        label: "Objetivos de aprendizaje",
      },
      { href: "/admin/grandes-ideas", label: "Grandes ideas" },
      {
        href: "/admin/conocimientos-esenciales",
        label: "Conocimientos esenciales",
      },
    ],
  },
];

function isItemActive(pathname: string, href: string) {
  if (href === "/admin") return pathname === "/admin";
  return pathname === href || pathname.startsWith(`${href}/`);
}

type AdminNavProps = {
  adminName?: string | null;
  signOutAction: () => void | Promise<void>;
};

export function AdminNav({ adminName, signOutAction }: AdminNavProps) {
  const pathname = usePathname();
  const [isOpen, setIsOpen] = useState(false);
  const [previousPathname, setPreviousPathname] = useState(pathname);

  // Cierra el menú móvil cada vez que el usuario navega a otra sección.
  if (pathname !== previousPathname) {
    setPreviousPathname(pathname);
    setIsOpen(false);
  }

  // Permite cerrar el menú móvil con la tecla Escape.
  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") setIsOpen(false);
    }
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, []);

  return (
    <>
      <header className="flex items-center justify-between border-b border-border bg-card px-4 py-3 md:hidden">
        <Link
          href="/admin"
          className="text-base font-semibold text-foreground"
        >
          ValidApp{" "}
          <span className="font-normal text-muted-foreground">admin</span>
        </Link>
        <Button
          type="button"
          variant="outline"
          size="icon"
          aria-expanded={isOpen}
          aria-controls="admin-sidebar"
          onClick={() => setIsOpen((open) => !open)}
        >
          {isOpen ? <X aria-hidden="true" /> : <Menu aria-hidden="true" />}
          <span className="sr-only">
            {isOpen ? "Cerrar navegación" : "Abrir navegación"}
          </span>
        </Button>
      </header>

      {isOpen ? (
        <div
          className="fixed inset-0 z-30 bg-foreground/30 md:hidden"
          aria-hidden="true"
          onClick={() => setIsOpen(false)}
        />
      ) : null}

      <aside
        id="admin-sidebar"
        className={cn(
          "fixed inset-y-0 left-0 z-40 flex w-72 max-w-[85vw] flex-col border-r border-border bg-card transition-transform duration-200 ease-out md:static md:z-auto md:w-64 md:max-w-none md:translate-x-0",
          isOpen ? "translate-x-0" : "-translate-x-full"
        )}
      >
        <nav
          aria-label="Navegación del panel administrativo"
          className="flex flex-1 flex-col gap-6 overflow-y-auto px-4 py-6"
        >
          <Link
            href="/admin"
            className="hidden text-lg font-semibold text-foreground md:block"
          >
            ValidApp{" "}
            <span className="font-normal text-muted-foreground">admin</span>
          </Link>

          {NAV_GROUPS.map((group) => (
            <div key={group.title}>
              <h2 className="px-2 text-xs font-semibold tracking-wide text-muted-foreground uppercase">
                {group.title}
              </h2>
              <ul className="mt-2 flex flex-col gap-1">
                {group.items.map((item) => {
                  const active = isItemActive(pathname, item.href);
                  return (
                    <li key={item.href}>
                      <Link
                        href={item.href}
                        aria-current={active ? "page" : undefined}
                        className={cn(
                          "block rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                          active
                            ? "bg-primary text-primary-foreground"
                            : "text-foreground hover:bg-muted"
                        )}
                      >
                        {item.label}
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </nav>

        <div className="border-t border-border px-4 py-4">
          {adminName ? (
            <p className="truncate text-sm text-muted-foreground">
              {adminName}
            </p>
          ) : null}
          <form action={signOutAction} className="mt-2">
            <Button type="submit" variant="ghost" className="w-full justify-start px-2">
              Cerrar sesión
            </Button>
          </form>
        </div>
      </aside>
    </>
  );
}
