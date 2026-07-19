"use client";

import { useState } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { PercentCell } from "@/components/admin/percent-cell";
import type { getStudentResults } from "@/lib/data/admin-results";

export type StudentResultRow = Awaited<ReturnType<typeof getStudentResults>>[number];

/**
 * Filas por página. La tabla de resultados por estudiante trae TODOS los
 * estudiantes de una sola vez desde `getStudentResults` (agregación en
 * memoria sobre 4 tablas); para el volumen actual del MVP no vale la pena
 * paginar a nivel de base de datos, así que filtramos y paginamos en el
 * cliente sobre los datos ya cargados por el Server Component `page.tsx`.
 */
export const STUDENTS_PAGE_SIZE = 25;

/** Filtra estudiantes por nombre, sin distinguir mayúsculas/minúsculas ni acentos exactos. */
export function filterStudentsByName(
  students: StudentResultRow[],
  query: string
): StudentResultRow[] {
  const normalized = query.trim().toLowerCase();
  if (!normalized) return students;
  return students.filter((s) => s.fullName.toLowerCase().includes(normalized));
}

export function paginate<T>(
  items: T[],
  page: number,
  pageSize: number
): { pageItems: T[]; totalPages: number; currentPage: number } {
  const totalPages = Math.max(1, Math.ceil(items.length / pageSize));
  const currentPage = Math.min(Math.max(1, page), totalPages);
  const start = (currentPage - 1) * pageSize;
  return {
    pageItems: items.slice(start, start + pageSize),
    totalPages,
    currentPage,
  };
}

export function StudentResultsTable({ students }: { students: StudentResultRow[] }) {
  const [query, setQuery] = useState("");
  const [page, setPage] = useState(1);

  const filtered = filterStudentsByName(students, query);
  const { pageItems, totalPages, currentPage } = paginate(
    filtered,
    page,
    STUDENTS_PAGE_SIZE
  );

  function handleQueryChange(value: string) {
    setQuery(value);
    setPage(1);
  }

  return (
    <div className="flex flex-col gap-3">
      <div>
        <Label htmlFor="student-search" className="sr-only">
          Buscar estudiante por nombre
        </Label>
        <Input
          id="student-search"
          type="search"
          placeholder="Buscar estudiante por nombre..."
          value={query}
          onChange={(e) => handleQueryChange(e.target.value)}
          className="max-w-xs"
        />
      </div>

      <div className="overflow-x-auto">
        <table className="w-full min-w-[600px] border-collapse text-sm">
          <thead>
            <tr className="border-b border-border text-left">
              <th className="py-2 pr-4">Estudiante</th>
              <th className="py-2 pr-4">Diagnósticos</th>
              <th className="py-2 pr-4">Promedio</th>
              <th className="py-2 pr-4">Lecciones completadas</th>
              <th className="py-2 pr-4">Ensayos rendidos</th>
              <th className="py-2 pr-4">Promedio ensayos</th>
              <th className="py-2 pr-4">Puntos</th>
              <th className="py-2 pr-4">Racha</th>
            </tr>
          </thead>
          <tbody>
            {pageItems.map((student) => (
              <tr key={student.id} className="border-b border-border/50">
                <td className="py-2 pr-4">{student.fullName}</td>
                <td className="py-2 pr-4">{student.diagnosticsCount}</td>
                <td className="py-2 pr-4">
                  <PercentCell value={student.diagnosticsAvgPercent} />
                </td>
                <td className="py-2 pr-4">{student.lessonsCompleted}</td>
                <td className="py-2 pr-4">{student.essaysCompleted}</td>
                <td className="py-2 pr-4">
                  <PercentCell value={student.essaysAvgPercent} />
                </td>
                <td className="py-2 pr-4">{student.totalPoints}</td>
                <td className="py-2 pr-4">{student.currentStreak} días</td>
              </tr>
            ))}
            {students.length === 0 && (
              <tr>
                <td colSpan={8} className="py-4 text-muted-foreground">
                  Aún no hay estudiantes registrados.
                </td>
              </tr>
            )}
            {students.length > 0 && filtered.length === 0 && (
              <tr>
                <td colSpan={8} className="py-4 text-muted-foreground">
                  No se encontraron estudiantes con ese nombre.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {filtered.length > STUDENTS_PAGE_SIZE && (
        <div className="flex items-center justify-between gap-3 text-sm">
          <Button
            type="button"
            variant="outline"
            size="sm"
            disabled={currentPage <= 1}
            onClick={() => setPage(currentPage - 1)}
          >
            Anterior
          </Button>
          <span className="text-muted-foreground">
            Página {currentPage} de {totalPages}
          </span>
          <Button
            type="button"
            variant="outline"
            size="sm"
            disabled={currentPage >= totalPages}
            onClick={() => setPage(currentPage + 1)}
          >
            Siguiente
          </Button>
        </div>
      )}
    </div>
  );
}
