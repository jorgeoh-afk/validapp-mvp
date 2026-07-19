export default function DiagnosticoSubjectsLoading() {
  return (
    <main
      className="mx-auto max-w-xl px-6 py-12"
      role="status"
      aria-label="Cargando diagnóstico"
    >
      <div className="h-4 w-24 animate-pulse rounded-md bg-muted" />
      <div className="mt-2 h-6 w-32 animate-pulse rounded-md bg-muted" />
      <div className="mt-2 h-4 w-64 animate-pulse rounded-md bg-muted" />

      <ul className="mt-6 flex flex-col gap-2">
        {Array.from({ length: 4 }).map((_, i) => (
          <li
            key={i}
            className="h-14 w-full animate-pulse rounded-lg border border-border bg-muted"
          />
        ))}
      </ul>

      <span className="sr-only">Cargando asignaturas del diagnóstico…</span>
    </main>
  );
}
