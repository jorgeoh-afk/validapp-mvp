import Link from "next/link";
import { getStudentResults, getSubjectResults } from "@/lib/data/admin-results";

export default async function ResultadosPage() {
  const [students, subjects] = await Promise.all([
    getStudentResults(),
    getSubjectResults(),
  ]);

  return (
    <main className="mx-auto max-w-3xl px-6 py-12">
      <Link href="/admin" className="text-sm underline">
        ← Panel admin
      </Link>
      <h1 className="mt-2 text-xl font-semibold">Resultados</h1>

      <section className="mt-8">
        <h2 className="text-lg font-medium">Por asignatura</h2>
        <div className="mt-3 overflow-x-auto">
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
                    {subject.diagnosticsAvgPercent === null
                      ? "—"
                      : `${subject.diagnosticsAvgPercent}%`}
                  </td>
                  <td className="py-2 pr-4">{subject.lessonsCompletedCount}</td>
                </tr>
              ))}
              {subjects.length === 0 && (
                <tr>
                  <td colSpan={4} className="py-4 text-zinc-500">
                    Aún no hay asignaturas.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>

      <section className="mt-10">
        <h2 className="text-lg font-medium">Por estudiante</h2>
        <div className="mt-3 overflow-x-auto">
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
                    {student.diagnosticsAvgPercent === null
                      ? "—"
                      : `${student.diagnosticsAvgPercent}%`}
                  </td>
                  <td className="py-2 pr-4">{student.lessonsCompleted}</td>
                  <td className="py-2 pr-4">{student.totalPoints}</td>
                  <td className="py-2 pr-4">{student.currentStreak} días</td>
                </tr>
              ))}
              {students.length === 0 && (
                <tr>
                  <td colSpan={6} className="py-4 text-zinc-500">
                    Aún no hay estudiantes registrados.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>
    </main>
  );
}
