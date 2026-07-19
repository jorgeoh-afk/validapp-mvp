// Pruebas locales de la práctica de lección tras el endurecimiento de RLS
// (migración 0019_questions_rls_hardening.sql). Ver cabecera de
// `essay-attempts.test.ts` para el criterio general.
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

vi.mock("next/cache", () => ({
  revalidatePath: vi.fn(),
}));

// `submitLessonPractice` depende de `getLearningPath` (dominio "Resultados y
// progreso", con su propia lógica de bloqueo de lecciones) y de
// `recordLessonCompleted` (gamificación). Ninguna de las dos toca
// `questions`; se simulan aquí para aislar la prueba al comportamiento que
// interesa a esta migración (uso de las funciones RPC de preguntas).
vi.mock("@/lib/data/progress", () => ({
  getLearningPath: vi.fn(async () => [{ id: "lesson-1", status: "disponible" }]),
}));
vi.mock("@/lib/data/gamification", () => ({
  recordLessonCompleted: vi.fn(async () => {}),
}));

const { getLessonQuestions, checkPracticeAnswer, submitLessonPractice } = await import(
  "./lessons"
);

function setMock(opts: {
  user?: { id: string } | null;
  from?: Record<string, TableHandler>;
  rpc?: Record<string, RpcHandler>;
}) {
  const mock = createSupabaseMock(opts);
  mockClient = mock.client;
  return mock;
}

describe("getLessonQuestions", () => {
  it("trae las preguntas vía get_lesson_questions, sin correct_index y sin tocar questions", async () => {
    const mock = setMock({
      rpc: {
        get_lesson_questions: (args) => {
          expect(args?.p_lesson_id).toBe("lesson-1");
          return {
            data: [
              { id: "q1", prompt: "P1", choices: ["a", "b"] },
              { id: "q2", prompt: "P2", choices: ["a", "b"] },
            ],
          };
        },
      },
    });

    const questions = await getLessonQuestions("lesson-1");
    expect(questions).toHaveLength(2);
    expect(questions.every((q) => !("correct_index" in q))).toBe(true);
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
    expect(callsToRpc(mock.calls, "get_lesson_questions")).toHaveLength(1);
  });
});

describe("checkPracticeAnswer", () => {
  it("delega la calificación en grade_practice_question", async () => {
    const mock = setMock({
      rpc: {
        grade_practice_question: (args) => {
          expect(args).toEqual({ p_question_id: "q1", p_selected_index: 1 });
          return { data: { is_correct: false, correct_index: 0 } };
        },
      },
    });

    const result = await checkPracticeAnswer("q1", 1);
    expect(result).toEqual({ correct: false, correctIndex: 0 });
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
  });

  it("devuelve error si la función no encuentra la pregunta", async () => {
    setMock({
      rpc: {
        grade_practice_question: () => ({
          data: null,
          error: { message: "Pregunta no encontrada." },
        }),
      },
    });

    const result = await checkPracticeAnswer("q-inexistente", 0);
    expect(result).toEqual({ error: "Pregunta no encontrada." });
  });
});

describe("submitLessonPractice", () => {
  it("califica en bloque vía grade_lesson_practice_questions y guarda el puntaje agregado", async () => {
    let upsertedProgress: Record<string, unknown> | null = null;

    const mock = setMock({
      user: { id: "student-1" },
      from: {
        lessons: () => ({
          data: {
            id: "lesson-1",
            title: "Lección 1",
            content: "...",
            subject_id: "subject-1",
            levels: { name: "Nivel 1" },
          },
        }),
        lesson_progress: (state) => {
          if (state.method === "upsert") {
            upsertedProgress = state.payload as Record<string, unknown>;
          }
          return { data: null, error: null };
        },
      },
      rpc: {
        grade_lesson_practice_questions: (args) => {
          expect(args?.p_question_ids).toEqual(["q1", "q2"]);
          expect(args?.p_selected_indexes).toEqual([0, 2]);
          return {
            data: [
              {
                question_id: "q1",
                prompt: "P1",
                choices: ["a", "b"],
                correct_index: 0,
                is_correct: true,
              },
              {
                question_id: "q2",
                prompt: "P2",
                choices: ["a", "b", "c"],
                correct_index: 1,
                is_correct: false,
              },
            ],
          };
        },
      },
    });

    const formData = new FormData();
    formData.set("lessonId", "lesson-1");
    formData.set("questionIds", "q1,q2");
    formData.set("answer_q1", "0");
    formData.set("answer_q2", "2");

    const result = await submitLessonPractice(null, formData);

    expect(result).toEqual({
      score: 1,
      total: 2,
      results: [
        {
          id: "q1",
          prompt: "P1",
          choices: ["a", "b"],
          selectedIndex: 0,
          correctIndex: 0,
          isCorrect: true,
        },
        {
          id: "q2",
          prompt: "P2",
          choices: ["a", "b", "c"],
          selectedIndex: 2,
          correctIndex: 1,
          isCorrect: false,
        },
      ],
    });
    expect(upsertedProgress).toMatchObject({
      student_id: "student-1",
      lesson_id: "lesson-1",
      score: 1,
      total_questions: 2,
    });
    expect(callsToTable(mock.calls, "questions")).toHaveLength(0);
    expect(callsToRpc(mock.calls, "grade_lesson_practice_questions")).toHaveLength(1);
  });

  it("bloquea el envío si la lección está bloqueada para el estudiante", async () => {
    const progressModule = await import("@/lib/data/progress");
    vi.mocked(progressModule.getLearningPath).mockResolvedValueOnce([
      { id: "lesson-1", status: "bloqueada" },
    ] as never);

    setMock({
      user: { id: "student-1" },
      from: {
        lessons: () => ({
          data: {
            id: "lesson-1",
            title: "Lección 1",
            content: "...",
            subject_id: "subject-1",
            levels: { name: "Nivel 1" },
          },
        }),
      },
    });

    const formData = new FormData();
    formData.set("lessonId", "lesson-1");
    formData.set("questionIds", "q1");
    formData.set("answer_q1", "0");

    const result = await submitLessonPractice(null, formData);
    expect(result).toEqual({ error: "Esta lección todavía está bloqueada." });
  });
});
