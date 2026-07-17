import { Card, CardContent, CardHeader } from "@/components/ui/card";

export default function PanelAdminLoading() {
  return (
    <div
      className="mx-auto flex max-w-5xl flex-col gap-8 pb-12"
      role="status"
      aria-label="Cargando el resumen del panel administrativo"
    >
      <div className="flex flex-col gap-2">
        <div className="h-7 w-64 animate-pulse rounded-md bg-muted" />
        <div className="h-4 w-80 animate-pulse rounded-md bg-muted" />
        <div className="h-3 w-56 animate-pulse rounded-md bg-muted" />
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <Card key={i}>
            <CardHeader>
              <div className="h-4 w-32 animate-pulse rounded-md bg-muted" />
            </CardHeader>
            <CardContent className="flex flex-col gap-2">
              <div className="h-8 w-16 animate-pulse rounded-md bg-muted" />
              <div className="h-3 w-full animate-pulse rounded-md bg-muted" />
              <div className="h-3 w-24 animate-pulse rounded-md bg-muted" />
            </CardContent>
          </Card>
        ))}
      </div>

      <span className="sr-only">Cargando el resumen del panel…</span>
    </div>
  );
}
