import { getStudentResults, getSubjectResults } from "@/lib/data/admin-results";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ProgressBar } from "@/components/ui/progress-bar";

/** Celda compacta que muestra el porcentaje como texto y como barra. */
function PercentCell({ value }: { value: number | null }) {
  if (value === null) {
    return <span className="text-muted-foreground">—</span>;
  }
  return (
    <div className="flex items-center gap-2">
      <span className="tabular-nums">{value}%</span>
      <ProgressBar value={value} showValue={false} size="sm" className="w-20" />
    </div>
  );
}

export default async function ResultadosPage() {
  const [students, subjects] = await Promise.all([
    getStudentResults(),
    getSubjectResults(),
  ]);

  return (
    <main className="mx-auto flex max-w-3xl flex-col gap-8 px-6 py-12">
      <header>
        <h1 className="font-heading text-xl font-semibold text-foreground">
          Resultados
        </h1>
      </header>

      <Card>
        <CardHeader>
          <CardTitle>Por asignatura</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[500px] border-collapse text-sm">
              <thead>
                <tr className="border-b border-border text-left">
                  <th className="py-2 pr-4">Asignatura</th>
                  <th className="py-2 pr-4">Diagnósticos rendidos</th>
                  <th className="py-2 pr-4">Promedio de aciertos</th>
                  <th className="py-2 pr-4">Lecciones completadas</th>
                </tr>
              </thead>
              <tbody>
                {subjects.map((subject) => (
                  <tr key={subject.id} className="border-b border-border/50">
                    <td className="py-2 pr-4">{subject.name}</td>
                    <td className="py-2 pr-4">{subject.diagnosticsCount}</td>
                    <td className="py-2 pr-4">
                      <PercentCell value={subject.diagnosticsAvgPercent} />
                    </td>
                    <td className="py-2 pr-4">{subject.lessonsCompletedCount}</td>
                  </tr>
                ))}
                {subjects.length === 0 && (
                  <tr>
                    <td colSpan={4} className="py-4 text-muted-foreground">
                      Aún no hay asignaturas.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Por estudiante</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[600px] border-collapse text-sm">
              <thead>
                <tr className="border-b border-border text-left">
                  <th className="py-2 pr-4">Estudiante</th>
                  <th className="py-2 pr-4">Diagnósticos</th>
                  <th className="py-2 pr-4">Promedio</th>
                  <th className="py-2 pr-4">Lecciones completadas</th>
                  <th className="py-2 pr-4">Puntos</th>
                  <th className="py-2 pr-4">Racha</th>
                </tr>
              </thead>
              <tbody>
                {students.map((student) => (
                  <tr key={student.id} className="border-b border-border/50">
                    <td className="py-2 pr-4">{student.fullName}</td>
                    <td className="py-2 pr-4">{student.diagnosticsCount}</td>
                    <td className="py-2 pr-4">
                      <PercentCell value={student.diagnosticsAvgPercent} />
                    </td>
                    <td className="py-2 pr-4">{student.lessonsCompleted}</td>
                    <td className="py-2 pr-4">{student.totalPoints}</td>
                    <td className="py-2 pr-4">{student.currentStreak} días</td>
                  </tr>
                ))}
                {students.length === 0 && (
                  <tr>
                    <td colSpan={6} className="py-4 text-muted-foreground">
                      Aún no hay estudiantes registrados.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </main>
  );
}
