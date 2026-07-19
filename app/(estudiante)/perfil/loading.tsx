import { Card, CardContent, CardHeader } from "@/components/ui/card";

export default function PerfilLoading() {
  return (
    <main
      className="mx-auto flex min-h-screen w-full max-w-xl flex-col gap-6 bg-background px-4 py-8 sm:px-6 sm:py-12"
      role="status"
      aria-label="Cargando tu perfil"
    >
      <div className="h-4 w-32 animate-pulse rounded-md bg-muted" />

      <Card>
        <CardHeader>
          <div className="h-5 w-24 animate-pulse rounded-md bg-muted" />
          <div className="h-4 w-56 animate-pulse rounded-md bg-muted" />
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          <div className="h-14 w-full animate-pulse rounded-xl bg-muted" />
          <div className="h-14 w-full animate-pulse rounded-xl bg-muted" />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <div className="h-5 w-32 animate-pulse rounded-md bg-muted" />
        </CardHeader>
        <CardContent>
          <div className="h-9 w-full max-w-xs animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>

      <span className="sr-only">Cargando tu perfil…</span>
    </main>
  );
}
