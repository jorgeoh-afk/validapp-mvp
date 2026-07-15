import { Card, CardContent, CardHeader } from "@/components/ui/card";

export default function PanelLoading() {
  return (
    <main
      className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-6 bg-background px-4 py-8 sm:px-6 sm:py-12"
      role="status"
      aria-label="Cargando tu panel"
    >
      <Card>
        <CardHeader>
          <div className="h-5 w-40 animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-56 animate-pulse rounded-md bg-muted" />
        </CardHeader>
        <CardContent>
          <div className="h-9 w-full max-w-xs animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Card key={i} size="sm">
            <CardContent className="flex flex-col gap-2">
              <div className="h-3 w-20 animate-pulse rounded-md bg-muted" />
              <div className="h-5 w-12 animate-pulse rounded-md bg-muted" />
            </CardContent>
          </Card>
        ))}
      </div>

      <Card>
        <CardContent className="flex flex-col gap-3 pt-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div
              key={i}
              className="h-14 w-full animate-pulse rounded-xl bg-muted"
            />
          ))}
        </CardContent>
      </Card>

      <span className="sr-only">Cargando tu panel de estudiante…</span>
    </main>
  );
}
