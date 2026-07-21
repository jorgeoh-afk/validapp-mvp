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

const { getLesson, getLessonQuestions, checkPracticeAnswer, submitLessonPractice } = await import(
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

// Prueba de regresión del Gap 1 (restricción total por inscripción, ver
// `getLearningPath` en `lib/data/progress.ts`): antes de este cambio,
// `getLesson` no verificaba el nivel de la lección contra el nivel inscrito
// del estudiante -- un estudiante podía navegar directo a la URL de una
// lección de otro nivel y VERLA (aunque ya no podía guardar práctica en
// ella). La página `app/(estudiante)/leccion/[lessonId]/page.tsx` ya hace
// `if (!lesson) notFound();`, así que basta con que `getLesson` devuelva
// `null` cuando el nivel no coincide para que el 404 salga gratis, sin tocar
// ningún `.tsx`.
describe("getLesson", () => {
  it("devuelve la lección cuando pertenece al nivel inscrito del estudiante", async () => {
    setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: "level-1" } }),
        lessons: () => ({
          data: {
            id: "lesson-1",
            title: "Lección 1",
            content: "...",
            subject_id: "subject-1",
            level_id: "level-1",
            levels: { name: "Nivel 1" },
          },
        }),
      },
    });

    const lesson = await getLesson("lesson-1");
    expect(lesson).toMatchObject({ id: "lesson-1", level_id: "level-1" });
  });

  it("devuelve null si la lección pertenece a otro nivel distinto del inscrito", async () => {
    setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: "level-1" } }),
        lessons: () => ({
          data: {
            id: "lesson-otro-nivel",
            title: "Lección de otro nivel",
            content: "...",
            subject_id: "subject-1",
            level_id: "level-2",
            levels: { name: "Nivel 2" },
          },
        }),
      },
    });

    const lesson = await getLesson("lesson-otro-nivel");
    expect(lesson).toBeNull();
  });

  it("devuelve null si el estudiante no está autenticado", async () => {
    const mock = setMock({ user: null });
    const lesson = await getLesson("lesson-1");
    expect(lesson).toBeNull();
    expect(callsToTable(mock.calls, "lessons")).toHaveLength(0);
  });

  it("devuelve null si el perfil todavía no tiene nivel objetivo asignado (defensivo)", async () => {
    const mock = setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: null } }),
      },
    });

    const lesson = await getLesson("lesson-1");
    expect(lesson).toBeNull();
    // Ni siquiera se consulta `lessons` sin nivel objetivo.
    expect(callsToTable(mock.calls, "lessons")).toHaveLength(0);
  });
});

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
        profiles: () => ({ data: { target_level_id: "level-1" } }),
        lessons: () => ({
          data: {
            id: "lesson-1",
            title: "Lección 1",
            content: "...",
            subject_id: "subject-1",
            level_id: "level-1",
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
        profiles: () => ({ data: { target_level_id: "level-1" } }),
        lessons: () => ({
          data: {
            id: "lesson-1",
            title: "Lección 1",
            content: "...",
            subject_id: "subject-1",
            level_id: "level-1",
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

  // Prueba de regresión: desde que `getLearningPath` (lib/data/progress.ts)
  // filtra por `profiles.target_level_id` (restricción total por
  // inscripción), una lección puede quedar fuera de la ruta devuelta por
  // `getLearningPath` sin que eso implique necesariamente que `getLesson`
  // también la rechace (p. ej. inconsistencias de datos futuras) -- así que
  // `path.find(...)` puede devolver `undefined` en vez de una fila con
  // `status: "bloqueada"`. Sin este caso cubierto, el bug sería:
  // `status === "bloqueada"` da `false` para `undefined`, y la práctica
  // pasaría sin bloquearse. (El caso más directo y común -- una lección de
  // OTRO nivel inscrito -- ya lo bloquea antes `getLesson` en sí, ver
  // `describe("getLesson")` más arriba: Gap 1 de la restricción total por
  // inscripción.)
  it("bloquea el envío si la lección no aparece en la ruta del estudiante aunque getLesson la haya devuelto", async () => {
    const progressModule = await import("@/lib/data/progress");
    vi.mocked(progressModule.getLearningPath).mockResolvedValueOnce([] as never);

    setMock({
      user: { id: "student-1" },
      from: {
        profiles: () => ({ data: { target_level_id: "level-1" } }),
        lessons: () => ({
          data: {
            id: "lesson-otro-nivel",
            title: "Lección de otro nivel",
            content: "...",
            subject_id: "subject-1",
            level_id: "level-1",
            levels: { name: "Otro nivel" },
          },
        }),
      },
    });

    const formData = new FormData();
    formData.set("lessonId", "lesson-otro-nivel");
    formData.set("questionIds", "q1");
    formData.set("answer_q1", "0");

    const result = await submitLessonPractice(null, formData);
    expect(result).toEqual({ error: "Esta lección todavía está bloqueada." });
  });
});
