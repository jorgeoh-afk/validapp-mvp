import { describe, expect, it } from "vitest";
import {
  selectEssayQuestions,
  replaceEssaySelectionSlot,
  buildErrorPracticeRequirements,
  buildReinforcementRequirements,
  type CandidateQuestion,
} from "./essay-selection";

function candidate(overrides: Partial<CandidateQuestion>): CandidateQuestion {
  return {
    id: overrides.id ?? crypto.randomUUID(),
    subjectId: "subject-math",
    strandId: null,
    learningObjectiveId: null,
    difficulty: "intermedia",
    prompt: overrides.id ?? "pregunta",
    points: 1,
    estimatedSeconds: 60,
    reviewStatus: "aprobado",
    timesUsed: 0,
    ...overrides,
  };
}

const names = { subjectNames: {}, strandNames: {}, objectiveNames: {} };

describe("selectEssayQuestions", () => {
  it("respeta la cantidad exacta pedida por asignatura", () => {
    const candidates = Array.from({ length: 10 }, (_, i) =>
      candidate({ id: `q${i}` })
    );
    const result = selectEssayQuestions({
      candidates,
      totalQuestions: 5,
      subjectRequirements: [{ subjectId: "subject-math", count: 5 }],
      objectiveRequirements: [],
      difficultyRequirements: [],
      ...names,
    });
    expect(result.selected).toHaveLength(5);
    expect(result.missing).toHaveLength(0);
  });

  it("reporta faltante cuando no hay banco suficiente para un requisito", () => {
    const candidates = [candidate({ id: "q1" }), candidate({ id: "q2" })];
    const result = selectEssayQuestions({
      candidates,
      totalQuestions: 5,
      subjectRequirements: [{ subjectId: "subject-math", count: 5 }],
      objectiveRequirements: [],
      difficultyRequirements: [],
      ...names,
    });
    expect(result.selected).toHaveLength(2);
    expect(result.missing).toHaveLength(1);
    expect(result.missing[0].missing).toBe(3);
  });

  it("selecciona por eje (strand) sin repetir lo ya cubierto por objetivo", () => {
    const candidates = [
      candidate({ id: "q1", strandId: "strand-numeros", learningObjectiveId: "obj-1" }),
      candidate({ id: "q2", strandId: "strand-numeros" }),
      candidate({ id: "q3", strandId: "strand-numeros" }),
      candidate({ id: "q4", strandId: "strand-geometria" }),
    ];
    const result = selectEssayQuestions({
      candidates,
      totalQuestions: 3,
      subjectRequirements: [],
      strandRequirements: [{ strandId: "strand-numeros", count: 3 }],
      objectiveRequirements: [{ learningObjectiveId: "obj-1", subjectId: "subject-math", count: 1 }],
      difficultyRequirements: [],
      ...names,
    });
    expect(result.selected).toHaveLength(3);
    expect(result.selected.every((s) => s.strandId === "strand-numeros")).toBe(true);
    expect(result.missing).toHaveLength(0);
    // q1 se cuenta una sola vez (cubrió el objetivo, no se repite en el eje).
    const ids = result.selected.map((s) => s.questionId);
    expect(new Set(ids).size).toBe(3);
  });

  it("nunca selecciona la misma pregunta dos veces, en 200 corridas con distintas semillas", () => {
    const candidates = Array.from({ length: 30 }, (_, i) =>
      candidate({ id: `q${i}`, difficulty: i % 3 === 0 ? "avanzada" : "intermedia" })
    );
    for (let seed = 0; seed < 200; seed++) {
      let s = seed + 1;
      const rng = () => {
        s = (s * 9301 + 49297) % 233280;
        return s / 233280;
      };
      const result = selectEssayQuestions({
        candidates,
        totalQuestions: 15,
        subjectRequirements: [{ subjectId: "subject-math", count: 10 }],
        objectiveRequirements: [],
        difficultyRequirements: [{ difficulty: "avanzada", count: 5 }],
        rng,
        ...names,
      });
      const ids = result.selected.map((s) => s.questionId);
      expect(new Set(ids).size).toBe(ids.length);
      expect(result.selected.length).toBeLessThanOrEqual(30);
    }
  });
});

describe("replaceEssaySelectionSlot", () => {
  it("reemplaza respetando el eje de la pregunta original", () => {
    const candidates = [
      candidate({ id: "q1", strandId: "strand-numeros" }),
      candidate({ id: "q2", strandId: "strand-numeros" }),
      candidate({ id: "q3", strandId: "strand-geometria" }),
    ];
    const currentSelection = [
      { ...candidate({ id: "q1", strandId: "strand-numeros" }), questionId: "q1", matchedAxis: "eje" as const },
    ];
    const replacement = replaceEssaySelectionSlot({
      candidates,
      currentSelection,
      slotToReplace: currentSelection[0],
    });
    expect(replacement?.questionId).toBe("q2");
    expect(replacement?.strandId).toBe("strand-numeros");
  });
});

describe("buildErrorPracticeRequirements", () => {
  it("prioriza los objetivos con más errores", () => {
    const answers = [
      { learningObjectiveId: "obj-a", subjectId: "s1", isCorrect: false },
      { learningObjectiveId: "obj-a", subjectId: "s1", isCorrect: false },
      { learningObjectiveId: "obj-a", subjectId: "s1", isCorrect: false },
      { learningObjectiveId: "obj-b", subjectId: "s1", isCorrect: false },
      { learningObjectiveId: "obj-c", subjectId: "s1", isCorrect: true },
    ];
    const result = buildErrorPracticeRequirements(answers, 4);
    const total = result.reduce((sum, r) => sum + r.count, 0);
    expect(total).toBe(4);
    const objA = result.find((r) => r.learningObjectiveId === "obj-a");
    const objB = result.find((r) => r.learningObjectiveId === "obj-b");
    expect(objA!.count).toBeGreaterThan(objB!.count);
    expect(result.find((r) => r.learningObjectiveId === "obj-c")).toBeUndefined();
  });

  it("devuelve arreglo vacío cuando el estudiante no tiene errores", () => {
    const answers = [{ learningObjectiveId: "obj-a", subjectId: "s1", isCorrect: true }];
    expect(buildErrorPracticeRequirements(answers, 5)).toHaveLength(0);
  });
});

describe("simulación estadística del blueprint piloto (1000 generaciones)", () => {
  // Escenario del ensayo piloto: Matemática, Primer Nivel Medio, 10
  // preguntas, distribuidas en 3 ejes (con cuota) + 1 requisito de
  // dificultad avanzada, sobre un banco de 40 preguntas aprobadas. Verifica
  // las reglas pedidas por el usuario (sección 28 de la spec EPJA): se
  // cumplen las cuotas, no hay duplicados dentro de un intento, ninguna
  // pregunta es de otro eje/asignatura, y la selección no se concentra
  // injustificadamente en las mismas preguntas siempre (gracias a
  // `prioritizeByUsage`, que reparte por `timesUsed`).
  const strandIds = ["strand-numeros", "strand-algebra", "strand-geometria"];
  const pool: CandidateQuestion[] = Array.from({ length: 40 }, (_, i) =>
    candidate({
      id: `pilot-q${i}`,
      strandId: strandIds[i % 3],
      difficulty: i % 5 === 0 ? "avanzada" : "intermedia",
      timesUsed: 0,
    })
  );

  it("cumple las cuotas y no duplica preguntas en 1000 generaciones", () => {
    const usageCount = new Map<string, number>();
    for (let run = 0; run < 1000; run++) {
      let s = run + 1;
      const rng = () => {
        s = (s * 9301 + 49297) % 233280;
        return s / 233280;
      };
      const result = selectEssayQuestions({
        candidates: pool,
        totalQuestions: 10,
        subjectRequirements: [],
        strandRequirements: strandIds.map((strandId) => ({ strandId, count: 3 })),
        objectiveRequirements: [],
        difficultyRequirements: [{ difficulty: "avanzada", count: 1 }],
        rng,
        ...names,
      });

      expect(result.missing).toHaveLength(0);
      expect(result.selected).toHaveLength(10);

      const ids = result.selected.map((s) => s.questionId);
      expect(new Set(ids).size).toBe(10);
      expect(result.selected.every((s) => s.subjectId === "subject-math")).toBe(true);
      expect(
        result.selected.filter((s) => s.difficulty === "avanzada").length
      ).toBeGreaterThanOrEqual(1);

      for (const strandId of strandIds) {
        expect(
          result.selected.filter((s) => s.strandId === strandId).length
        ).toBeGreaterThanOrEqual(3);
      }

      for (const id of ids) {
        usageCount.set(id, (usageCount.get(id) ?? 0) + 1);
      }
    }

    // No concentración injustificada: con 40 preguntas y 10 cupos por
    // generación (25% del banco por corrida), sobre 1000 corridas cada
    // pregunta debería aparecer un número de veces del mismo orden de
    // magnitud que el promedio (1000*10/40 = 250) — no unas pocas preguntas
    // acaparando todo mientras otras nunca se usan.
    expect(usageCount.size).toBe(40); // todas las preguntas se usaron al menos una vez
    const counts = [...usageCount.values()];
    const max = Math.max(...counts);
    const min = Math.min(...counts);
    expect(max / min).toBeLessThan(3);
  });
});

describe("buildReinforcementRequirements", () => {
  it("prioriza los objetivos con menor tasa de acierto", () => {
    const answers = [
      { learningObjectiveId: "obj-weak", subjectId: "s1", isCorrect: false },
      { learningObjectiveId: "obj-weak", subjectId: "s1", isCorrect: false },
      { learningObjectiveId: "obj-weak", subjectId: "s1", isCorrect: true },
      { learningObjectiveId: "obj-strong", subjectId: "s1", isCorrect: true },
      { learningObjectiveId: "obj-strong", subjectId: "s1", isCorrect: true },
      { learningObjectiveId: "obj-strong", subjectId: "s1", isCorrect: true },
      { learningObjectiveId: "obj-perfect", subjectId: "s1", isCorrect: true },
    ];
    const result = buildReinforcementRequirements(answers, 3);
    expect(result.find((r) => r.learningObjectiveId === "obj-perfect")).toBeUndefined();
    const weak = result.find((r) => r.learningObjectiveId === "obj-weak");
    expect(weak).toBeDefined();
    expect(weak!.count).toBeGreaterThan(0);
  });
});
