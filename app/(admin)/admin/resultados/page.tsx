import {
  getStudentResults,
  getSubjectResults,
  getEssayResults,
} from "@/lib/data/admin-results";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { PercentCell } from "@/components/admin/percent-cell";
import { StudentResultsTable } from "./student-results-table";

const ESSAY_STATUS_LABEL: Record<string, string> = {
  borrador: "Borrador",
  en_revision: "En revisión",
  programado: "Programado",
  publicado: "Publicado",
  finalizado: "Finalizado",
  archivado: "Archivado",
};

const ESSAY_STATUS_VARIANT: Record<
  string,
  "muted" | "warning" | "success" | "destructive"
> = {
  borrador: "muted",
  en_revision: "warning",
  programado: "warning",
  publicado: "success",
  finalizado: "success",
  archivado: "destructive",
};

export default async function ResultadosPage() {
  const [students, subjects, essays] = await Promise.all([
    getStudentResults(),
    getSubjectResults(),
    getEssayResults(),
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
          <StudentResultsTable students={students} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Por ensayo</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[560px] border-collapse text-sm">
              <thead>
                <tr className="border-b border-border text-left">
                  <th className="py-2 pr-4">Ensayo</th>
                  <th className="py-2 pr-4">Curso</th>
                  <th className="py-2 pr-4">Estado</th>
                  <th className="py-2 pr-4">Intentos rendidos</th>
                  <th className="py-2 pr-4">Promedio</th>
                </tr>
              </thead>
              <tbody>
                {essays.map((essay) => (
                  <tr key={essay.id} className="border-b border-border/50">
                    <td className="py-2 pr-4">{essay.name}</td>
                    <td className="py-2 pr-4">{essay.levelName}</td>
                    <td className="py-2 pr-4">
                      <Badge variant={ESSAY_STATUS_VARIANT[essay.status]}>
                        {ESSAY_STATUS_LABEL[essay.status] ?? essay.status}
                      </Badge>
                    </td>
                    <td className="py-2 pr-4">{essay.attemptsCount}</td>
                    <td className="py-2 pr-4">
                      <PercentCell value={essay.avgScorePercent} />
                    </td>
                  </tr>
                ))}
                {essays.length === 0 && (
                  <tr>
                    <td colSpan={5} className="py-4 text-muted-foreground">
                      Aún no hay ensayos creados.
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
