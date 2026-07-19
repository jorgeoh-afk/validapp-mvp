import { Card, CardContent, CardHeader } from "@/components/ui/card";

export default function LeccionLoading() {
  return (
    <main
      className="mx-auto flex w-full max-w-xl flex-col gap-6 px-4 py-8 sm:px-6 sm:py-12"
      role="status"
      aria-label="Cargando lección"
    >
      <div className="h-4 w-24 animate-pulse rounded-md bg-muted" />

      <Card>
        <CardHeader>
          <div className="h-5 w-48 animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-28 animate-pulse rounded-md bg-muted" />
        </CardHeader>
        <CardContent className="flex flex-col gap-2">
          <div className="h-4 w-full animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-full animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-2/3 animate-pulse rounded-md bg-muted" />
        </CardContent>
      </Card>

      <Card>
        <CardContent className="flex flex-col gap-3 pt-4">
          <div className="h-5 w-full animate-pulse rounded-md bg-muted" />
          {Array.from({ length: 3 }).map((_, i) => (
            <div
              key={i}
              className="h-12 w-full animate-pulse rounded-xl bg-muted"
            />
          ))}
        </CardContent>
      </Card>

      <span className="sr-only">Cargando la lección…</span>
    </main>
  );
}
