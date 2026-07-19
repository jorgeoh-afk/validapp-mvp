// Pruebas locales del flujo de diagnóstico tras el endurecimiento de RLS
// (migración 0019_questions_rls_hardening.sql). Ver cabecera de
// `essay-attempts.test.ts` para el criterio general: se simula el cliente
// de Supabase, no se conecta a una base real, y se verifica que el código
// use `get_diagnostic_questions`/`grade_diagnostic_questions` en vez de
// leer `questions` directamente.
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

vi.mock("@/lib/data/gamification", () => ({
  recordDiagnosticCompleted: vi.fn(async () => {}),
}));

const { getDiagnosticQuestions, submitDiagnostic } = await import("./diagnostics");

function setMock(opts: {
  user?: { id: string } | null;
  from?: Record<string, TableHandler>;
  rpc?: Record<string, RpcHandler>;
}) {
  const mock = createSupabaseMock(opts);
  mockClient = mock.client;
  return mock;
}

describe("getDiagnosticQuestions", () => {
  it("trae las preguntas vía get_diagnostic_questions, sin correct_index y sin tocar questions", async () => {
    const mock = setMock({
      rpc: {
        get_diagnostic_questions: (args) => {
          expect(args?.p_subject_id).toBe("subject-1");
          return {
            data: [
              { id: "q1", prompt: "P1", choices: ["a", "b"], level_id: "lvl1" },
              { id: "q2", prompt: "P2", choices: ["a", "b"], level_id: "lvl1" },
            ],
          };
        },
      },
    });

    const questions = await getDiagnosticQuestions("subject-1");
    expect(questions.map((q) => q.id).sort()).toEqual(["q1", "q2"]);
    // Las filas devueltas por la función no tienen `correct_index` en
    // absoluto: no hay forma de que este código lo filtre por error.
    expect(questions.every((q) => !("correct_index" in q))).toBe(true);
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
    expect(callsToRpc(mock.calls, "get_diagnostic_questions")).toHaveLength(1);
  });
});

describe("submitDiagnostic", () => {
  it("califica vía grade_diagnostic_questions y guarda el resultado sin haber leído correct_index", async () => {
    let insertedDiagnostic: Record<string, unknown> | null = null;
    let insertedAnswers: unknown[] = [];

    const mock = setMock({
      user: { id: "student-1" },
      from: {
        levels: () => ({ data: [{ id: "lvl1", order_index: 0 }] }),
        diagnostics: (state) => {
          if (state.method === "insert") {
            insertedDiagnostic = state.payload as Record<string, unknown>;
            return { data: { id: "diag-1" }, error: null };
          }
          return { data: null, error: null };
        },
        diagnostic_answers: (state) => {
          if (state.method === "insert") {
            insertedAnswers = state.payload as unknown[];
          }
          return { data: null, error: null };
        },
      },
      rpc: {
        grade_diagnostic_questions: (args) => {
          expect(args?.p_question_ids).toEqual(["q1", "q2"]);
          expect(args?.p_selected_indexes).toEqual([0, 1]);
          return {
            data: [
              { question_id: "q1", level_id: "lvl1", is_correct: true },
              { question_id: "q2", level_id: "lvl1", is_correct: false },
            ],
          };
        },
      },
    });

    const formData = new FormData();
    formData.set("subjectId", "subject-1");
    formData.set("questionIds", "q1,q2");
    formData.set("answer_q1", "0");
    formData.set("answer_q2", "1");

    await expect(submitDiagnostic(null, formData)).rejects.toThrow(
      "REDIRECT:/diagnostico/resultado/diag-1"
    );

    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
    expect(callsToRpc(mock.calls, "grade_diagnostic_questions")).toHaveLength(1);

    expect(insertedDiagnostic).toMatchObject({
      student_id: "student-1",
      subject_id: "subject-1",
      score: 1, // solo q1 fue correcta según el fixture de la RPC
      total_questions: 2,
    });
    expect(insertedAnswers).toEqual([
      { question_id: "q1", selected_index: 0, is_correct: true, diagnostic_id: "diag-1" },
      { question_id: "q2", selected_index: 1, is_correct: false, diagnostic_id: "diag-1" },
    ]);
  });

  it("devuelve error si grade_diagnostic_questions no encuentra preguntas", async () => {
    setMock({
      user: { id: "student-1" },
      rpc: {
        grade_diagnostic_questions: () => ({ data: [] }),
      },
    });

    const formData = new FormData();
    formData.set("subjectId", "subject-1");
    formData.set("questionIds", "q1");
    formData.set("answer_q1", "0");

    const result = await submitDiagnostic(null, formData);
    expect(result).toEqual({ error: "No se pudieron cargar las preguntas." });
  });
});
