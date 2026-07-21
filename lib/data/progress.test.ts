// Prueba mínima de la restricción total por inscripción (decisión explícita
// del usuario, ver 0028_regular_epja_curriculum_hierarchy.sql y
// 0029_diagnostic_scoped_to_enrolled_level.sql) aplicada a la ruta de
// aprendizaje: `getLearningPath` -- el único punto de `lib/data/progress.ts`
// que trae `lessons` -- debe filtrar estrictamente por
// `profiles.target_level_id` del estudiante autenticado, además del
// `subject_id` que ya filtraba antes. Antes de este cambio traía TODAS las
// lecciones de la asignatura, sin importar el nivel.
//
// Mismo patrón de mock que `essays.test.ts`/`diagnostics.test.ts`
// (`__test-helpers__/supabase-mock.ts`): no se conecta a una base real, solo
// se verifica que el código TypeScript envía el filtro correcto.
import { describe, it, expect, vi } from "vitest";
import {
  createSupabaseMock,
  callsToTable,
  type TableHandler,
} from "./__test-helpers__/supabase-mock";

let mockClient: ReturnType<typeof createSupabaseMock>["client"];

vi.mock("@/lib/supabase/server", () => ({
  createClient: async () => mockClient,
}));

const { getLearningPath } = await import("./progress");

function setMock(opts: {
  user?: { id: string } | null;
  from?: Record<string, TableHandler>;
}) {
  const mock = createSupabaseMock(opts);
  mockClient = mock.client;
  return mock;
}

const ENROLLED_LEVEL = "level-enrolled";
const OTHER_LEVEL = "level-other";
const SUBJECT = "subject-matematica";

function lessonRow(id: string, levelId: string, orderIndex: number) {
  return {
    id,
    title: `Lección ${id}`,
    order_index: orderIndex,
    subject_id: SUBJECT,
    level_id: levelId,
    levels: { name: levelId, order_index: levelId === ENROLLED_LEVEL ? 1 : 2 },
  };
}

// Banco simulado: 2 lecciones del nivel inscrito + 2 lecciones de otro nivel,
// misma asignatura -- la única señal que distingue un grupo del otro es
// `level_id`.
const allLessonRows = [
  lessonRow("lesson-own-1", ENROLLED_LEVEL, 0),
  lessonRow("lesson-own-2", ENROLLED_LEVEL, 1),
  lessonRow("lesson-other-1", OTHER_LEVEL, 0),
  lessonRow("lesson-other-2", OTHER_LEVEL, 1),
];

function lessonsHandler(): TableHandler {
  return (state) => {
    const rows = allLessonRows.filter(
      (l) =>
        l.subject_id === state.filters.subject_id &&
        l.level_id === state.filters.level_id
    );
    return { data: rows };
  };
}

describe("getLearningPath", () => {
  it("solo trae lecciones del nivel exacto en que está inscrito el estudiante, aunque compartan asignatura con otro nivel", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: ENROLLED_LEVEL } }),
        lessons: lessonsHandler(),
        lesson_progress: () => ({ data: [] }),
        diagnostics: () => ({ data: null }),
      },
    });

    const path = await getLearningPath(SUBJECT);
    expect(path.map((l) => l.id).sort()).toEqual(["lesson-own-1", "lesson-own-2"]);
    expect(path.some((l) => l.id.startsWith("lesson-other"))).toBe(false);
    expect(callsToTable(mock.calls, "lessons")).toHaveLength(1);
  });

  it("envía únicamente el filtro level_id del perfil (uuid), nunca por nombre/texto", async () => {
    const seenFilters: Record<string, unknown>[] = [];
    setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: ENROLLED_LEVEL } }),
        lessons: (state) => {
          seenFilters.push({ ...state.filters });
          return { data: [] };
        },
        lesson_progress: () => ({ data: [] }),
        diagnostics: () => ({ data: null }),
      },
    });

    await getLearningPath(SUBJECT);

    expect(seenFilters).toHaveLength(1);
    expect(seenFilters[0]).toEqual({
      subject_id: SUBJECT,
      level_id: ENROLLED_LEVEL,
    });
  });

  it("no trae ninguna lección si el perfil todavía no tiene nivel objetivo asignado (defensivo)", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: null } }),
        lessons: lessonsHandler(),
      },
    });

    const path = await getLearningPath(SUBJECT);
    expect(path).toEqual([]);
    // Ni siquiera se llega a consultar `lessons` sin nivel objetivo.
    expect(callsToTable(mock.calls, "lessons")).toHaveLength(0);
  });

  it("devuelve una ruta vacía si el estudiante no está autenticado", async () => {
    const mock = setMock({ user: null });
    const path = await getLearningPath(SUBJECT);
    expect(path).toEqual([]);
    expect(callsToTable(mock.calls, "lessons")).toHaveLength(0);
  });

  // Prueba de regresión de un bug encontrado en la auditoría de QA de la
  // restricción total por inscripción: antes de la corrección, si el
  // diagnóstico más reciente del estudiante para esta asignatura tenía un
  // `estimated_level_id` con `order_index` MAYOR que el del nivel
  // actualmente inscrito (p. ej. un diagnóstico rendido antes de que el
  // estudiante bajara de nivel en "Mi perfil", o de antes de esta
  // restricción), `getLearningPath` marcaba TODAS las lecciones del nivel
  // inscrito como "completada" sin que existiera ninguna fila real en
  // `lesson_progress` -- progreso falso. Ahora el estado de cada lección
  // depende únicamente de `lesson_progress` y del desbloqueo secuencial.
  it("no marca lecciones como completadas por un diagnóstico de un nivel superior al inscrito (progreso falso)", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: ENROLLED_LEVEL } }),
        lessons: lessonsHandler(),
        lesson_progress: () => ({ data: [] }),
        // `estimated_level.order_index` (2) es mayor que el del nivel
        // inscrito (1, ver `lessonRow`): simula un diagnóstico desalineado
        // con la inscripción actual del estudiante.
        diagnostics: () => ({
          data: { estimated_level: { order_index: 2 } },
        }),
      },
    });

    const path = await getLearningPath(SUBJECT);
    expect(path.every((l) => l.status === "disponible" || l.status === "bloqueada")).toBe(
      true
    );
    expect(path.some((l) => l.status === "completada")).toBe(false);
    // Ya no se consulta `diagnostics` en absoluto para calcular el estado de
    // la ruta: el mock de la tabla queda sin invocar.
    expect(callsToTable(mock.calls, "diagnostics")).toHaveLength(0);
  });
});
