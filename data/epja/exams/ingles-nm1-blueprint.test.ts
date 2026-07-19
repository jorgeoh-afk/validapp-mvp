// Ver matematica-nm1-blueprint.test.ts para el criterio general. Inglés
// (Comprensión Lectora en Inglés) es un único eje sin subdivisión oficial
// -- no hay cuota por eje que verificar aquí, solo que el banco alcance
// para la cantidad de ensayos que realmente soporta sin repetir preguntas.
// A diferencia de Matemática, el banco de Inglés (56 preguntas NM1) NO
// alcanza para 3 ensayos de 25 + 30% de reserva (se necesitarían ~98) --
// alcanza para 2 ensayos completos sin repetir, con 6 de reserva. Esto se
// documenta explícitamente en vez de forzar un tercer ensayo con preguntas
// repetidas o reducir el tamaño oficial verificado (25 preguntas).

import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import path from "node:path";
import { selectEssayQuestions, type CandidateQuestion } from "../../../lib/data/essay-selection";
import type { EpjaBankQuestion } from "../../../lib/data/epja-question-bank-schema";

const bankPath = path.resolve(__dirname, "ds-257-2009/primer-nivel-medio/ingles/question-bank.json");
const bank: EpjaBankQuestion[] = JSON.parse(readFileSync(bankPath, "utf8"));
const TOTAL_QUESTIONS = 25;

const candidates: CandidateQuestion[] = bank.map((q) => ({
  id: q.localId,
  subjectId: "ingles",
  strandId: q.strandName,
  learningObjectiveId: q.objectiveShortName,
  difficulty: q.difficulty,
  prompt: q.prompt,
  points: q.points ?? 1,
  estimatedSeconds: q.estimatedSeconds ?? null,
  reviewStatus: "aprobado",
  timesUsed: 0,
}));

const names = { subjectNames: {}, strandNames: {}, objectiveNames: {} };

describe("blueprint real Inglés · Primer Nivel Medio · D.S. 257/2009", () => {
  it("documenta cuántos ensayos de 25 preguntas soporta el banco actual sin repetir", () => {
    const supportedEssays = Math.floor(candidates.length / TOTAL_QUESTIONS);
    console.log(
      `[ingles-nm1] Banco: ${candidates.length} preguntas. Soporta ${supportedEssays} ensayo(s) completo(s) de ${TOTAL_QUESTIONS} sin repetir (objetivo ideal: 3 + 30% reserva = ${Math.ceil(3 * TOTAL_QUESTIONS * 1.3)}).`
    );
    expect(supportedEssays).toBeGreaterThanOrEqual(2);
  });

  it("genera la cantidad de ensayos soportada sin repetir preguntas entre ellos", () => {
    const supportedEssays = Math.min(3, Math.floor(candidates.length / TOTAL_QUESTIONS));
    const used: string[] = [];
    for (let i = 0; i < supportedEssays; i++) {
      const result = selectEssayQuestions({
        candidates,
        totalQuestions: TOTAL_QUESTIONS,
        subjectRequirements: [],
        strandRequirements: [],
        objectiveRequirements: [],
        difficultyRequirements: [],
        excludeQuestionIds: used,
        ...names,
      });
      expect(result.selected).toHaveLength(TOTAL_QUESTIONS);
      const ids = result.selected.map((s) => s.questionId);
      expect(new Set(ids).size).toBe(ids.length);
      for (const idVal of ids) expect(used).not.toContain(idVal);
      used.push(...ids);
    }
    expect(used).toHaveLength(supportedEssays * TOTAL_QUESTIONS);
  });
});
