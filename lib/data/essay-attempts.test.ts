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
          },
        }),
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
                position: 0,
                prompt: "P1",
                choices: ["a", "b"],
                resource_url: null,
                points: 1,
              },
              {
                question_id: "q2",
                position: 1,
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
          },
        }),
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
              position: 0,
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
