import { describe, expect, it } from "vitest";
import {
  computeContentHash,
  textSimilarity,
  findDuplicate,
  validateQuestion,
  validateCurricularConsistency,
  type ValidatableQuestion,
} from "./question-validators";

function baseMc(overrides: Partial<ValidatableQuestion> = {}): ValidatableQuestion {
  return {
    prompt: "¿Cuál es el resultado de 2 + 2?",
    questionType: "seleccion_multiple",
    choices: ["3", "4", "5", "6"],
    correctIndex: 1,
    learningObjectiveId: "obj-1",
    subjectId: "subj-1",
    levelId: "level-1",
    frameworkId: "fw-1",
    ...overrides,
  };
}

describe("computeContentHash", () => {
  it("es estable frente a mayúsculas, tildes y espacios", () => {
    const a = computeContentHash("¿Cuánto es 2+2?");
    const b = computeContentHash("  cuanto es 2+2?  ");
    expect(a).toBe(b);
  });
  it("difiere para enunciados distintos", () => {
    expect(computeContentHash("2+2")).not.toBe(computeContentHash("3+3"));
  });
});

describe("textSimilarity", () => {
  it("detecta alta similitud entre variantes casi idénticas", () => {
    const s = textSimilarity(
      "Resuelve el problema que involucra calcular el perímetro de un triángulo",
      "Resuelve el problema que involucra calcular el área de un triángulo"
    );
    expect(s).toBeGreaterThan(0.5);
  });
  it("detecta baja similitud entre enunciados distintos", () => {
    const s = textSimilarity(
      "Identifica el sujeto de la oración subrayada",
      "Calcula la probabilidad de obtener cara al lanzar una moneda"
    );
    expect(s).toBeLessThan(0.3);
  });
});

describe("findDuplicate", () => {
  it("encuentra duplicado exacto por hash", () => {
    const existing = [{ id: "q1", prompt: "¿Cuánto es 2+2?", contentHash: computeContentHash("¿Cuánto es 2+2?") }];
    const dup = findDuplicate("cuanto es 2+2", existing);
    expect(dup?.kind).toBe("exact");
  });
  it("encuentra casi-duplicado por similitud", () => {
    const existing = [
      {
        id: "q1",
        prompt: "Resuelve un problema que involucra calcular el perímetro de un rectángulo dado su largo y ancho",
        contentHash: computeContentHash("otra cosa"),
      },
    ];
    const dup = findDuplicate(
      "Resuelve un problema que involucra calcular el área de un rectángulo dado su largo y ancho",
      existing
    );
    expect(dup?.kind).toBe("near");
  });
  it("no marca duplicado cuando no hay coincidencia", () => {
    const existing = [{ id: "q1", prompt: "Pregunta totalmente distinta sobre historia", contentHash: computeContentHash("x") }];
    expect(findDuplicate("¿Cuánto es 2+2?", existing)).toBeNull();
  });
});

describe("validateQuestion — selección múltiple", () => {
  it("acepta una pregunta bien formada", () => {
    const result = validateQuestion(baseMc());
    expect(result.valid).toBe(true);
  });
  it("rechaza menos de 3 alternativas", () => {
    const result = validateQuestion(baseMc({ choices: ["4", "5"] }));
    expect(result.valid).toBe(false);
    expect(result.issues.map((i) => i.code)).toContain("too_few_choices");
  });
  it("rechaza índice de respuesta correcta fuera de rango", () => {
    const result = validateQuestion(baseMc({ correctIndex: 9 }));
    expect(result.issues.map((i) => i.code)).toContain("invalid_correct_index");
  });
  it("rechaza alternativas duplicadas", () => {
    const result = validateQuestion(baseMc({ choices: ["4", "4", "5", "6"] }));
    expect(result.issues.map((i) => i.code)).toContain("duplicate_choices");
  });
  it("rechaza alternativa vacía", () => {
    const result = validateQuestion(baseMc({ choices: ["4", "", "5", "6"] }));
    expect(result.issues.map((i) => i.code)).toContain("empty_choice");
  });
  it("marca 'todas las anteriores' para revisión", () => {
    const result = validateQuestion(
      baseMc({ choices: ["4", "5", "6", "Todas las anteriores"], correctIndex: 3 })
    );
    expect(result.issues.map((i) => i.code)).toContain("catch_all_choice");
  });
  it("detecta pista de longitud cuando la correcta es mucho más larga", () => {
    const result = validateQuestion(
      baseMc({
        choices: ["4", "5", "6", "Cuatro, que es el resultado exacto de sumar dos más dos según la aritmética básica"],
        correctIndex: 3,
      })
    );
    expect(result.issues.map((i) => i.code)).toContain("length_hint");
  });
  it("detecta que la respuesta aparece filtrada en el enunciado", () => {
    const result = validateQuestion(
      baseMc({ prompt: "¿Cuál es el resultado de 2 + 2, que es 4?", choices: ["3", "4", "5", "6"], correctIndex: 1 })
    );
    expect(result.issues.map((i) => i.code)).toContain("answer_leaked_in_prompt");
  });
  it("rechaza sin objetivo de aprendizaje", () => {
    const result = validateQuestion(baseMc({ learningObjectiveId: null }));
    expect(result.issues.map((i) => i.code)).toContain("missing_curricular_link");
  });
});

describe("validateQuestion — respuesta abierta", () => {
  it("exige answerKey y rubric", () => {
    const result = validateQuestion(
      baseMc({
        questionType: "respuesta_abierta_breve",
        choices: null,
        correctIndex: null,
        answerKey: null,
        rubric: null,
      })
    );
    expect(result.issues.map((i) => i.code)).toEqual(
      expect.arrayContaining(["missing_answer_key", "missing_rubric"])
    );
  });
  it("acepta cuando answerKey y rubric están presentes", () => {
    const result = validateQuestion(
      baseMc({
        questionType: "respuesta_abierta_breve",
        choices: null,
        correctIndex: null,
        answerKey: "La capital de Chile es Santiago.",
        rubric: [{ criterio: "Menciona Santiago", puntaje_maximo: 1 }],
      })
    );
    expect(result.valid).toBe(true);
  });
});

describe("validateCurricularConsistency", () => {
  it("detecta mezcla de asignatura, nivel o framework", () => {
    const base = {
      questionSubjectId: "s1",
      questionLevelId: "l1",
      questionFrameworkId: "f1",
      essaySubjectId: "s1",
      essayLevelId: "l1",
      essayFrameworkId: "f1",
    };
    expect(validateCurricularConsistency(base).valid).toBe(true);
    expect(validateCurricularConsistency({ ...base, questionSubjectId: "s2" }).valid).toBe(false);
    expect(validateCurricularConsistency({ ...base, questionLevelId: "l2" }).valid).toBe(false);
    expect(validateCurricularConsistency({ ...base, questionFrameworkId: "f2" }).valid).toBe(false);
  });
});
