// Pruebas para las funciones puras de búsqueda y paginación de la tabla
// "Por estudiante" de /admin/resultados. `getStudentResults()` trae TODOS
// los estudiantes de una sola vez (agregación en memoria); el filtro y la
// paginación se hacen en el cliente sobre esos datos ya cargados, así que
// solo se prueba la lógica pura (`filterStudentsByName`/`paginate`), no el
// componente `StudentResultsTable` completo: el repo no tiene infraestructura
// de testing de componentes React (no hay @testing-library/react ni un
// entorno jsdom/happy-dom configurado en `vitest.config.ts`, que corre con
// `environment: "node"`).
import { describe, it, expect } from "vitest";
import {
  filterStudentsByName,
  paginate,
  STUDENTS_PAGE_SIZE,
  type StudentResultRow,
} from "./student-results-table";

function makeStudent(overrides: Partial<StudentResultRow>): StudentResultRow {
  return {
    id: "student-1",
    fullName: "Estudiante de prueba",
    targetLevel: null,
    diagnosticsCount: 0,
    diagnosticsAvgPercent: null,
    lessonsCompleted: 0,
    essaysCompleted: 0,
    essaysAvgPercent: null,
    totalPoints: 0,
    currentStreak: 0,
    ...overrides,
  };
}

describe("filterStudentsByName", () => {
  it("devuelve todos los estudiantes cuando la búsqueda está vacía", () => {
    const students = [
      makeStudent({ id: "1", fullName: "Ana Soto" }),
      makeStudent({ id: "2", fullName: "Beto Ríos" }),
    ];
    expect(filterStudentsByName(students, "")).toEqual(students);
    expect(filterStudentsByName(students, "   ")).toEqual(students);
  });

  it("filtra por coincidencia parcial sin distinguir mayúsculas", () => {
    const students = [
      makeStudent({ id: "1", fullName: "Ana Soto" }),
      makeStudent({ id: "2", fullName: "Beto Ríos" }),
      makeStudent({ id: "3", fullName: "Carla Anaya" }),
    ];
    const result = filterStudentsByName(students, "ana");
    expect(result.map((s) => s.id)).toEqual(["1", "3"]);
  });

  it("devuelve una lista vacía cuando no hay coincidencias", () => {
    const students = [makeStudent({ id: "1", fullName: "Ana Soto" })];
    expect(filterStudentsByName(students, "zzz")).toEqual([]);
  });
});

describe("paginate", () => {
  it("devuelve una sola página cuando hay menos elementos que el tamaño de página", () => {
    const items = [1, 2, 3];
    const result = paginate(items, 1, 25);
    expect(result).toEqual({ pageItems: [1, 2, 3], totalPages: 1, currentPage: 1 });
  });

  it("divide los elementos en páginas del tamaño indicado", () => {
    const items = Array.from({ length: 30 }, (_, i) => i + 1);
    const page1 = paginate(items, 1, STUDENTS_PAGE_SIZE);
    expect(page1.pageItems).toHaveLength(25);
    expect(page1.totalPages).toBe(2);
    expect(page1.currentPage).toBe(1);

    const page2 = paginate(items, 2, STUDENTS_PAGE_SIZE);
    expect(page2.pageItems).toHaveLength(5);
    expect(page2.pageItems[0]).toBe(26);
  });

  it("ajusta (clamp) una página fuera de rango a la última página disponible", () => {
    const items = Array.from({ length: 10 }, (_, i) => i + 1);
    const result = paginate(items, 99, 25);
    expect(result.currentPage).toBe(1);
    expect(result.totalPages).toBe(1);
  });

  it("nunca deja la página por debajo de 1", () => {
    const items = [1, 2, 3];
    const result = paginate(items, 0, 25);
    expect(result.currentPage).toBe(1);
  });
});
