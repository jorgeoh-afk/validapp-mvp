// Prueba mínima #7 del pedido original (sección 9, aislamiento
// Regular/EPJA): "Los ensayos filtran preguntas por programa y nivel."
//
// Verifica que `buildCandidatePool` -- el único punto de `essays.ts` que lee
// `questions` para armar el pool de un ensayo -- filtra estrictamente por
// `level_id` (uuid, comparación exacta de fila) y jamás por `levels.name` ni
// por el texto de `equivalence`. No se conecta a una base de datos real: se
// simula `questions` con filas de dos niveles reales del proyecto dev que
// comparten asignatura -- un nivel EPJA condensado ("Segundo Nivel Medio",
// id real a62eb30a-79bc-4087-9b45-cb49482ce66e) y un curso regular
// individual ("3° Medio", sin contenido propio aún, pero ya existe la fila
// en el seed 0009) -- para comprobar que pedir el pool de un nivel jamás
// arrastra preguntas del otro, aunque ambos compartan `subject_id`.
//
// Mismo patrón de mock que `diagnostics.test.ts`/`essay-attempts.test.ts`
// (`__test-helpers__/supabase-mock.ts`): no se prueba SQL real, solo que el
// código TypeScript envía el filtro correcto y no confía en ningún otro
// criterio (nombre, texto de equivalencia, o "caída" implícita hacia
// `equivalent_grade_from_level_id`/`equivalent_grade_to_level_id`).
import { describe, it, expect, vi } from "vitest";
import {
  createSupabaseMock,
  type TableHandler,
} from "./__test-helpers__/supabase-mock";

let mockClient: ReturnType<typeof createSupabaseMock>["client"];

vi.mock("@/lib/supabase/server", () => ({
  createClient: async () => mockClient,
}));

const { buildCandidatePool } = await import("./essays");

// Ids reales verificados en dev (ver 0028_regular_epja_curriculum_hierarchy.sql).
const EPJA_SEGUNDO_NIVEL_MEDIO = "a62eb30a-79bc-4087-9b45-cb49482ce66e";
const REGULAR_3_MEDIO = "regular-3-medio-id"; // fila nueva del seed 0009, sin contenido real todavía
const SHARED_SUBJECT = "subject-matematica";

function questionRow(id: string, levelId: string, prompt: string) {
  return {
    id,
    subject_id: SHARED_SUBJECT,
    level_id: levelId,
    learning_objective_id: null,
    difficulty: "intermedia",
    prompt,
    points: 1,
    estimated_seconds: 60,
    review_status: "aprobado",
    question_usage_stats: [],
    learning_objectives: null,
  };
}

// Banco simulado: 2 preguntas EPJA + 2 preguntas de 3° Medio regular, misma
// asignatura y mismo `review_status` -- la única señal que distingue un
// grupo del otro es `level_id`.
const allQuestionRows = [
  questionRow("epja-q1", EPJA_SEGUNDO_NIVEL_MEDIO, "Pregunta EPJA 1"),
  questionRow("epja-q2", EPJA_SEGUNDO_NIVEL_MEDIO, "Pregunta EPJA 2"),
  questionRow("reg-q1", REGULAR_3_MEDIO, "Pregunta Regular 1"),
  questionRow("reg-q2", REGULAR_3_MEDIO, "Pregunta Regular 2"),
];

function makeQuestionsHandler(): TableHandler {
  return (state) => {
    const levelFilter = state.filters.level_id;
    const rows = allQuestionRows.filter((q) => q.level_id === levelFilter);
    return { data: rows };
  };
}

describe("buildCandidatePool", () => {
  it("filtra por level_id exacto y nunca mezcla preguntas de otro nivel, aunque compartan asignatura", async () => {
    const mock = createSupabaseMock({ from: { questions: makeQuestionsHandler() } });
    mockClient = mock.client;

    const epjaPool = await buildCandidatePool(EPJA_SEGUNDO_NIVEL_MEDIO);
    expect(epjaPool.map((q) => q.id).sort()).toEqual(["epja-q1", "epja-q2"]);

    const regularPool = await buildCandidatePool(REGULAR_3_MEDIO);
    expect(regularPool.map((q) => q.id).sort()).toEqual(["reg-q1", "reg-q2"]);

    // Ningún pool contiene preguntas del otro nivel, pese a compartir
    // `subject_id`.
    expect(epjaPool.some((q) => regularPool.some((r) => r.id === q.id))).toBe(
      false
    );
  });

  it("envía únicamente el filtro level_id (uuid recibido como parámetro), nunca por nombre/texto", async () => {
    const seenFilters: Record<string, unknown>[] = [];
    const mock = createSupabaseMock({
      from: {
        questions: (state) => {
          seenFilters.push({ ...state.filters });
          return { data: [] };
        },
      },
    });
    mockClient = mock.client;

    await buildCandidatePool(EPJA_SEGUNDO_NIVEL_MEDIO);

    expect(seenFilters).toHaveLength(1);
    // El único filtro es `level_id` con el uuid recibido tal cual -- no hay
    // ningún filtro por `name`, `equivalence`,
    // `equivalent_grade_from_level_id` ni `equivalent_grade_to_level_id`.
    expect(seenFilters[0]).toEqual({ level_id: EPJA_SEGUNDO_NIVEL_MEDIO });
  });

  it("con requirePublishable=true, agrega filtros de publicación sin perder el filtro de nivel", async () => {
    const seenFilters: Record<string, unknown>[] = [];
    const mock = createSupabaseMock({
      from: {
        questions: (state) => {
          seenFilters.push({ ...state.filters });
          return { data: [] };
        },
      },
    });
    mockClient = mock.client;

    await buildCandidatePool(EPJA_SEGUNDO_NIVEL_MEDIO, {
      requirePublishable: true,
      frameworkId: "framework-1",
    });

    expect(seenFilters[0]).toMatchObject({
      level_id: EPJA_SEGUNDO_NIVEL_MEDIO,
      is_active: true,
      validation_status: "approved_for_exam",
      framework_id: "framework-1",
    });
  });
});
