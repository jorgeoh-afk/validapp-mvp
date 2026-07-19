// Prueba de regresión para el bug de QA "el intento de ensayo reiniciaba en
// la pregunta 1 al recargar en vez de retomar donde quedó el estudiante"
// (ver commit 295a0bd). Solo se prueba `findResumeIndex`, una función pura
// exportada únicamente para testing: el repo no tiene infraestructura de
// testing de componentes React (no hay @testing-library/react ni un entorno
// jsdom/happy-dom configurado en `vitest.config.ts`, que corre con
// `environment: "node"`), así que montar `EssayAttemptForm` completo queda
// fuera de alcance por ahora. Queda pendiente como tarea aparte si se decide
// agregar esa infraestructura.
import { describe, it, expect } from "vitest";
import { findResumeIndex } from "./essay-attempt-form";
import type { AttemptView } from "@/lib/data/essay-attempts";

type Question = NonNullable<AttemptView>["questions"][number];

function makeQuestion(overrides: Partial<Question>): Question {
  return {
    answerId: "answer-1",
    questionId: "q1",
    displayPosition: 0,
    prompt: "¿Pregunta?",
    choices: ["a", "b"],
    points: 1,
    selectedVisualPosition: null,
    isCorrect: null,
    answered: false,
    ...overrides,
  };
}

describe("findResumeIndex", () => {
  it("devuelve el índice de la primera pregunta sin responder", () => {
    const questions = [
      makeQuestion({ questionId: "q1", answered: true }),
      makeQuestion({ questionId: "q2", answered: true }),
      makeQuestion({ questionId: "q3", answered: false }),
      makeQuestion({ questionId: "q4", answered: false }),
    ];

    expect(findResumeIndex(questions)).toBe(2);
  });

  it("devuelve el índice de la última pregunta si todas están respondidas", () => {
    const questions = [
      makeQuestion({ questionId: "q1", answered: true }),
      makeQuestion({ questionId: "q2", answered: true }),
      makeQuestion({ questionId: "q3", answered: true }),
    ];

    expect(findResumeIndex(questions)).toBe(2);
  });
});
