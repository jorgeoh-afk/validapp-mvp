import { Card, CardHeader } from "@/components/ui/card";

export default function ErroresLoading() {
  return (
    <main
      className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12"
      role="status"
      aria-label="Cargando tus errores"
    >
      <div className="h-4 w-20 animate-pulse rounded-md bg-muted" />
      <div className="flex flex-col gap-1.5">
        <div className="h-5 w-40 animate-pulse rounded-md bg-muted" />
        <div className="h-4 w-64 animate-pulse rounded-md bg-muted" />
      </div>
      {Array.from({ length: 3 }).map((_, i) => (
        <Card key={i}>
          <CardHeader>
            <div className="h-4 w-full animate-pulse rounded-md bg-muted" />
            <div className="h-4 w-2/3 animate-pulse rounded-md bg-muted" />
          </CardHeader>
        </Card>
      ))}
      <span className="sr-only">Cargando tus errores…</span>
    </main>
  );
}
