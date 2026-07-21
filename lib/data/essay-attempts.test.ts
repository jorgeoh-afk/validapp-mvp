// Pruebas locales del flujo de ensayos tras el endurecimiento de RLS
// (migración 0019_questions_rls_hardening.sql). Cubren "iniciar intento",
// "responder" y "recuperar resultado" usando las nuevas funciones RPC
// (`get_attempt_question_choices`, `grade_essay_answer`,
// `get_attempt_result_answers`) en vez de leer `questions` directamente.
//
// No se conecta a una base de datos real: se simula el cliente de Supabase
// con `__test-helpers__/supabase-mock.ts`. El objetivo NO es probar la
// lógica SQL de las funciones (eso requiere una instancia real de Postgres,
// fuera del alcance de una prueba local), sino verificar que el código
// TypeScript de la Server Action llama a la función correcta, con los
// argumentos correctos, y que jamás vuelve a tocar `.from("questions")`.
import { describe, it, expect, vi } from "vitest";
import {
  createSupabaseMock,
  callsToTable,
  callsToRpc,
  type TableHandler,
  type RpcHandler,
} from "./__test-helpers__/supabase-mock";

let mockClient: ReturnType<typeof createSupabaseMock>["client"];

vi.mock("@/lib/supabase/server", () => ({
  createClient: async () => mockClient,
}));

vi.mock("next/navigation", () => ({
  redirect: (url: string) => {
    throw new Error(`REDIRECT:${url}`);
  },
}));

const {
  startEssayAttempt,
  submitEssayAnswer,
  getAttemptResult,
  getAttemptView,
  listAvailableEssaysForStudent,
  getEssayStartInfo,
} = await import("./essay-attempts");

function setMock(opts: {
  user?: { id: string } | null;
  from?: Record<string, TableHandler>;
  rpc?: Record<string, RpcHandler>;
}) {
  const mock = createSupabaseMock(opts);
  mockClient = mock.client;
  return mock;
}

describe("startEssayAttempt", () => {
  it("crea el intento y trae las preguntas vía get_attempt_question_choices, sin tocar questions", async () => {
    let insertedAnswerRows: unknown[] = [];

    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essays: () => ({
          data: {
            id: "essay-1",
            status: "publicado",
            available_from: null,
            order_mode: "fijo",
            max_attempts: null,
            level_id: "level-1",
          },
        }),
        profiles: () => ({ data: { target_level_id: "level-1" } }),
        essay_attempts: (state) => {
          if (state.method === "insert") {
            return { data: { id: "attempt-1" }, error: null };
          }
          return { data: [] }; // no hay intentos previos
        },
        essay_questions: () => ({ count: 2 }),
        essay_attempt_answers: (state) => {
          if (state.method === "insert") {
            insertedAnswerRows = state.payload as unknown[];
          }
          return { data: null, error: null };
        },
      },
      rpc: {
        get_attempt_question_choices: (args) => {
          expect(args?.p_attempt_id).toBe("attempt-1");
          return {
            data: [
              {
                question_id: "q1",
                question_position: 0,
                prompt: "P1",
                choices: ["a", "b"],
                resource_url: null,
                points: 1,
              },
              {
                question_id: "q2",
                question_position: 1,
                prompt: "P2",
                choices: ["a", "b", "c"],
                resource_url: null,
                points: 2,
              },
            ],
          };
        },
      },
    });

    const formData = new FormData();
    formData.set("essayId", "essay-1");

    await expect(startEssayAttempt(null, formData)).rejects.toThrow(
      "REDIRECT:/ensayos/essay-1/intento/attempt-1"
    );

    // La única vía de acceso a la pregunta fue la función RPC.
    expect(callsToRpc(mock.calls, "get_attempt_question_choices")).toHaveLength(1);
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);

    // Las filas de respuesta se construyeron con los datos devueltos por la
    // función (correct_index/explanation nunca llegaron a este código).
    expect(insertedAnswerRows).toHaveLength(2);
    const rows = insertedAnswerRows as {
      question_id: string;
      display_position: number;
      shuffled_choice_order: number[];
      selected_index: number | null;
      is_correct: boolean | null;
    }[];
    expect(rows.map((r) => r.question_id)).toEqual(["q1", "q2"]);
    expect(rows[0].shuffled_choice_order).toHaveLength(2); // choices de q1
    expect(rows[1].shuffled_choice_order).toHaveLength(3); // choices de q2
    expect(rows.every((r) => r.selected_index === null && r.is_correct === null)).toBe(true);
  });

  it("no crea el intento si el ensayo no tiene preguntas generadas", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essays: () => ({
          data: {
            id: "essay-1",
            status: "publicado",
            available_from: null,
            order_mode: "fijo",
            max_attempts: null,
            level_id: "level-1",
          },
        }),
        profiles: () => ({ data: { target_level_id: "level-1" } }),
        essay_attempts: () => ({ data: [] }),
        essay_questions: () => ({ count: 0 }),
      },
    });

    const formData = new FormData();
    formData.set("essayId", "essay-1");

    const result = await startEssayAttempt(null, formData);
    expect(result).toEqual({ error: "Este ensayo todavía no tiene preguntas generadas." });
    expect(callsToTable(mock.calls, "essay_attempts").some((c) => c.type === "insert")).toBe(
      false
    );
  });
});

describe("getAttemptView", () => {
  it("combina essay_attempt_answers (propio) con get_attempt_question_choices (sin correct_index)", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essay_attempts: () => ({
          data: {
            id: "attempt-1",
            essay_id: "essay-1",
            student_id: "student-1",
            status: "en_curso",
            started_at: "2026-01-01T00:00:00Z",
            essays: { name: "Ensayo 1", feedback_mode: "al_finalizar", time_limit_minutes: null },
          },
        }),
        essay_attempt_answers: () => ({
          data: [
            {
              id: "answer-1",
              question_id: "q1",
              display_position: 0,
              shuffled_choice_order: [1, 0],
              selected_index: null,
              is_correct: null,
            },
          ],
        }),
      },
      rpc: {
        get_attempt_question_choices: () => ({
          data: [
            {
              question_id: "q1",
              question_position: 0,
              prompt: "¿Cuánto es 2+2?",
              choices: ["3", "4"],
              resource_url: null,
              points: 1,
            },
          ],
        }),
      },
    });

    const view = await getAttemptView("attempt-1");
    expect(view).not.toBeNull();
    expect(view?.questions).toHaveLength(1);
    // El orden barajado [1,0] invierte las alternativas.
    expect(view?.questions[0].choices).toEqual(["4", "3"]);
    expect(view?.questions[0].prompt).toBe("¿Cuánto es 2+2?");
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
  });
});

// Prueba de regresión para el bug de QA "la expiración por tiempo límite
// dependía únicamente del reloj del cliente" (ver commit 295a0bd):
// `getAttemptView` ahora repite la verificación de vencimiento en el
// servidor y cierra el intento (reutilizando `submitEssayAttempt` con motivo
// "expirado") si `started_at + time_limit_minutes` ya pasó, en vez de
// confiar solo en el `setInterval` del cliente.
describe("getAttemptView - expiración server-side", () => {
  it("cierra como expirado un intento en_curso cuyo tiempo límite ya venció", async () => {
    const updatePayloads: unknown[] = [];

    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essay_attempts: (state) => {
          if (state.method === "update") {
            updatePayloads.push(state.payload);
            return { data: null, error: null };
          }
          // Mismo intento devuelto tanto para la lectura de `getAttemptView`
          // como para la relectura que hace `submitEssayAttempt` al
          // cerrarlo: `started_at` muy en el pasado + un límite de 30
          // minutos, así que el plazo ya venció sin importar cuándo corra
          // esta prueba.
          return {
            data: {
              id: "attempt-1",
              essay_id: "essay-1",
              student_id: "student-1",
              status: "en_curso",
              started_at: "2020-01-01T00:00:00Z",
              essays: {
                name: "Ensayo 1",
                feedback_mode: "al_finalizar",
                time_limit_minutes: 30,
              },
            },
          };
        },
        essay_attempt_answers: () => ({
          data: [
            {
              id: "answer-1",
              question_id: "q1",
              display_position: 0,
              shuffled_choice_order: [0, 1],
              selected_index: 0,
              is_correct: true,
            },
          ],
        }),
      },
      rpc: {
        get_attempt_question_choices: () => ({
          data: [
            {
              question_id: "q1",
              question_position: 0,
              prompt: "P1",
              choices: ["a", "b"],
              resource_url: null,
              points: 1,
            },
          ],
        }),
      },
    });

    const view = await getAttemptView("attempt-1");

    expect(view?.status).toBe("expirado");
    // El cierre se hizo a través de la misma vía que el corte manual del
    // cliente: un update a essay_attempts con status "expirado".
    expect(updatePayloads).toHaveLength(1);
    expect(updatePayloads[0]).toMatchObject({ status: "expirado" });
    expect(
      callsToTable(mock.calls, "essay_attempts").filter((c) => c.type === "update")
    ).toHaveLength(1);
  });

  it("mantiene en_curso un intento cuyo tiempo límite todavía no vence", async () => {
    const updatePayloads: unknown[] = [];

    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essay_attempts: (state) => {
          if (state.method === "update") {
            updatePayloads.push(state.payload);
            return { data: null, error: null };
          }
          return {
            data: {
              id: "attempt-1",
              essay_id: "essay-1",
              student_id: "student-1",
              status: "en_curso",
              started_at: new Date().toISOString(), // recién empezado
              essays: {
                name: "Ensayo 1",
                feedback_mode: "al_finalizar",
                time_limit_minutes: 60,
              },
            },
          };
        },
        essay_attempt_answers: () => ({
          data: [
            {
              id: "answer-1",
              question_id: "q1",
              display_position: 0,
              shuffled_choice_order: [0, 1],
              selected_index: null,
              is_correct: null,
            },
          ],
        }),
      },
      rpc: {
        get_attempt_question_choices: () => ({
          data: [
            {
              question_id: "q1",
              question_position: 0,
              prompt: "P1",
              choices: ["a", "b"],
              resource_url: null,
              points: 1,
            },
          ],
        }),
      },
    });

    const view = await getAttemptView("attempt-1");

    expect(view?.status).toBe("en_curso");
    expect(updatePayloads).toHaveLength(0);
    expect(
      callsToTable(mock.calls, "essay_attempts").filter((c) => c.type === "update")
    ).toHaveLength(0);
  });
});

describe("submitEssayAnswer", () => {
  it("traduce la posición visual y delega la calificación en grade_essay_answer", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essay_attempt_answers: () => ({
          data: { id: "answer-1", question_id: "q1", shuffled_choice_order: [1, 0] },
        }),
      },
      rpc: {
        grade_essay_answer: (args) => {
          expect(args).toEqual({
            p_attempt_id: "attempt-1",
            p_question_id: "q1",
            p_selected_original_index: 1, // shuffledOrder[0] === 1
          });
          return { data: { is_correct: true, correct_index: 1, explanation: "Porque sí." } };
        },
      },
    });

    const result = await submitEssayAnswer("attempt-1", "answer-1", 0);
    expect(result).toEqual({
      correct: true,
      correctVisualPosition: 0, // índice de 1 dentro de [1, 0]
      explanation: "Porque sí.",
    });
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
    expect(callsToRpc(mock.calls, "grade_essay_answer")).toHaveLength(1);
  });

  it("propaga el error si grade_essay_answer rechaza (p. ej. intento cerrado)", async () => {
    setMock({
      user: { id: "student-1" },
      from: {
        essay_attempt_answers: () => ({
          data: { id: "answer-1", question_id: "q1", shuffled_choice_order: [0, 1] },
        }),
      },
      rpc: {
        grade_essay_answer: () => ({
          data: null,
          error: { message: "Este intento ya fue cerrado." },
        }),
      },
    });

    const result = await submitEssayAnswer("attempt-1", "answer-1", 0);
    expect(result).toEqual({ error: "Este intento ya fue cerrado." });
  });
});

describe("getAttemptResult", () => {
  it("no llama a get_attempt_result_answers si el intento sigue en curso", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essay_attempts: () => ({
          data: {
            id: "attempt-1",
            student_id: "student-1",
            status: "en_curso",
            score: null,
            total_points: null,
            time_spent_seconds: null,
            essays: { name: "Ensayo 1" },
          },
        }),
      },
    });

    const result = await getAttemptResult("attempt-1");
    expect(result).toBeNull();
    expect(callsToRpc(mock.calls, "get_attempt_result_answers")).toHaveLength(0);
  });

  it("trae el detalle completo (incluye correct_index) para un intento cerrado", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        essay_attempts: () => ({
          data: {
            id: "attempt-1",
            student_id: "student-1",
            status: "enviado",
            score: 1,
            total_points: 1,
            time_spent_seconds: 30,
            essays: { name: "Ensayo 1" },
          },
        }),
      },
      rpc: {
        get_attempt_result_answers: (args) => {
          expect(args?.p_attempt_id).toBe("attempt-1");
          return {
            data: [
              {
                question_id: "q1",
                display_position: 0,
                shuffled_choice_order: [0, 1],
                selected_index: 0,
                is_correct: true,
                prompt: "P1",
                choices: ["a", "b"],
                correct_index: 0,
                explanation: "porque a es correcta",
                points: 1,
              },
            ],
          };
        },
      },
    });

    const result = await getAttemptResult("attempt-1");
    expect(result?.questions).toHaveLength(1);
    expect(result?.questions[0].isCorrect).toBe(true);
    expect(result?.questions[0].explanation).toBe("porque a es correcta");
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
  });
});

// Pruebas de la restricción total por inscripción (decisión explícita del
// usuario, ver 0028_regular_epja_curriculum_hierarchy.sql y
// 0029_diagnostic_scoped_to_enrolled_level.sql): un estudiante solo debe ver
// y poder rendir ensayos de su `profiles.target_level_id` exacto.
describe("listAvailableEssaysForStudent", () => {
  const essaysOfBothLevels = [
    {
      id: "essay-own-level",
      name: "Ensayo de mi nivel",
      essay_type: "general_curso",
      level_id: "level-enrolled",
      total_questions: 10,
      time_limit_minutes: null,
      max_attempts: null,
      available_from: null,
      status: "publicado",
      levels: { name: "Mi nivel", order_index: 1 },
    },
    {
      id: "essay-other-level",
      name: "Ensayo de otro nivel",
      essay_type: "general_curso",
      level_id: "level-other",
      total_questions: 10,
      time_limit_minutes: null,
      max_attempts: null,
      available_from: null,
      status: "publicado",
      levels: { name: "Otro nivel", order_index: 2 },
    },
  ];

  it("solo trae ensayos del nivel exacto en que está inscrito el estudiante, aunque haya otros publicados", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: "level-enrolled" } }),
        essays: (state) => {
          const rows = essaysOfBothLevels.filter(
            (e) => e.level_id === state.filters.level_id
          );
          return { data: rows };
        },
        essay_attempts: () => ({ data: [] }),
        diagnostics: () => ({ data: null }),
      },
    });

    const list = await listAvailableEssaysForStudent();
    expect(list.map((e) => e.id)).toEqual(["essay-own-level"]);
    expect(list.some((e) => e.levelId === "level-other")).toBe(false);
    expect(callsToTable(mock.calls, "essays")).toHaveLength(1);
  });

  it("no muestra ningún ensayo si el perfil todavía no tiene nivel objetivo asignado", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: null } }),
        essays: () => ({ data: essaysOfBothLevels }),
      },
    });

    const list = await listAvailableEssaysForStudent();
    expect(list).toEqual([]);
    // Defensivo: ni siquiera se llega a consultar `essays` sin nivel objetivo.
    expect(callsToTable(mock.calls, "essays")).toHaveLength(0);
  });
});

describe("getEssayStartInfo - restricción por inscripción", () => {
  it("devuelve null si el ensayo pedido es de un nivel distinto al inscrito, aunque exista y esté publicado", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: "level-enrolled" } }),
        essays: () => ({
          data: {
            id: "essay-other-level",
            name: "Ensayo de otro nivel",
            essay_type: "general_curso",
            status: "publicado",
            available_from: null,
            total_questions: 10,
            time_limit_minutes: null,
            total_points: 10,
            feedback_mode: "al_finalizar",
            max_attempts: null,
            level_id: "level-other",
            levels: { name: "Otro nivel" },
          },
        }),
      },
    });

    const info = await getEssayStartInfo("essay-other-level");
    expect(info).toBeNull();
    // No se llegó a consultar intentos: se corta antes, en el chequeo de nivel.
    expect(callsToTable(mock.calls, "essay_attempts")).toHaveLength(0);
  });

  it("devuelve el detalle normal si el ensayo es del nivel inscrito", async () => {
    setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: "level-enrolled" } }),
        essays: () => ({
          data: {
            id: "essay-own-level",
            name: "Ensayo de mi nivel",
            essay_type: "general_curso",
            status: "publicado",
            available_from: null,
            total_questions: 10,
            time_limit_minutes: null,
            total_points: 10,
            feedback_mode: "al_finalizar",
            max_attempts: null,
            level_id: "level-enrolled",
            levels: { name: "Mi nivel" },
          },
        }),
        essay_attempts: () => ({ data: [] }),
      },
    });

    const info = await getEssayStartInfo("essay-own-level");
    expect(info).not.toBeNull();
    expect(info?.id).toBe("essay-own-level");
    expect(info?.canStart).toBe(true);
  });
});

describe("startEssayAttempt - restricción por inscripción", () => {
  it("rechaza iniciar un intento nuevo de un ensayo de otro nivel, tratándolo como 'no encontrado'", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: "level-enrolled" } }),
        essays: () => ({
          data: {
            id: "essay-other-level",
            status: "publicado",
            available_from: null,
            order_mode: "fijo",
            max_attempts: null,
            level_id: "level-other",
          },
        }),
      },
    });

    const formData = new FormData();
    formData.set("essayId", "essay-other-level");

    const result = await startEssayAttempt(null, formData);
    expect(result).toEqual({ error: "No se encontró el ensayo." });
    // No se llegó a crear ningún intento.
    expect(
      callsToTable(mock.calls, "essay_attempts").some((c) => c.type === "insert")
    ).toBe(false);
  });

  it("rechaza iniciar un intento si el perfil todavía no tiene nivel objetivo asignado", async () => {
    setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: null } }),
        essays: () => ({
          data: {
            id: "essay-1",
            status: "publicado",
            available_from: null,
            order_mode: "fijo",
            max_attempts: null,
            level_id: "level-1",
          },
        }),
      },
    });

    const formData = new FormData();
    formData.set("essayId", "essay-1");

    const result = await startEssayAttempt(null, formData);
    expect(result).toEqual({ error: "No se encontró el ensayo." });
  });
});
