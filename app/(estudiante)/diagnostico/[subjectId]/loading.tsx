export default function DiagnosticoSubjectLoading() {
  return (
    <main
      className="mx-auto max-w-2xl px-6 py-12"
      role="status"
      aria-label="Cargando preguntas del diagnóstico"
    >
      <div className="h-4 w-24 animate-pulse rounded-md bg-muted" />
      <div className="mt-2 h-6 w-56 animate-pulse rounded-md bg-muted" />

      <div className="mt-6 flex flex-col gap-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="flex flex-col gap-2">
            <div className="h-5 w-full animate-pulse rounded-md bg-muted" />
            <div className="h-12 w-full animate-pulse rounded-xl bg-muted" />
            <div className="h-12 w-full animate-pulse rounded-xl bg-muted" />
          </div>
        ))}
      </div>

      <span className="sr-only">Cargando las preguntas del diagnóstico…</span>
    </main>
  );
}
