import { Card, CardContent, CardHeader } from "@/components/ui/card";

export default function RutaSubjectLoading() {
  return (
    <main
      className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12"
      role="status"
      aria-label="Cargando tu ruta"
    >
      <div className="h-4 w-32 animate-pulse rounded-md bg-muted" />

      <Card>
        <CardHeader>
          <div className="h-5 w-48 animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-64 animate-pulse rounded-md bg-muted" />
        </CardHeader>
        <CardContent>
          <div className="h-2.5 w-full animate-pulse rounded-full bg-muted" />
        </CardContent>
      </Card>

      <div className="flex flex-col gap-4">
        {Array.from({ length: 2 }).map((_, groupIndex) => (
          <section key={groupIndex} className="flex flex-col gap-3">
            <div className="h-4 w-28 animate-pulse rounded-md bg-muted" />
            <div className="flex flex-col gap-3">
              {Array.from({ length: 3 }).map((_, i) => (
                <div
                  key={i}
                  className="h-16 w-full animate-pulse rounded-xl bg-muted"
                />
              ))}
            </div>
          </section>
        ))}
      </div>

      <span className="sr-only">Cargando tu ruta de lecciones…</span>
    </main>
  );
}
