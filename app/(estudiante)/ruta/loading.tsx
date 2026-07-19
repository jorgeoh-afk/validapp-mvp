import { Card, CardHeader } from "@/components/ui/card";

export default function RutaSubjectsLoading() {
  return (
    <main
      className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12"
      role="status"
      aria-label="Cargando ruta educativa"
    >
      <div className="h-4 w-24 animate-pulse rounded-md bg-muted" />

      <Card>
        <CardHeader>
          <div className="h-5 w-40 animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-64 animate-pulse rounded-md bg-muted" />
        </CardHeader>
      </Card>

      <div className="flex flex-col gap-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div
            key={i}
            className="h-14 w-full animate-pulse rounded-xl bg-muted"
          />
        ))}
      </div>

      <span className="sr-only">Cargando tu ruta educativa…</span>
    </main>
  );
}
