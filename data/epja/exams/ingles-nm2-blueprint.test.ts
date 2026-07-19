// Ver ingles-nm1-blueprint.test.ts. Banco de 48 preguntas: soporta 1
// ensayo completo de 25 sin repetir (23 quedan de reserva). NO alcanza
// para 3 ensayos + 30% de reserva (se necesitarían ~98).

import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import path from "node:path";
import { selectEssayQuestions, type CandidateQuestion } from "../../../lib/data/essay-selection";
import type { EpjaBankQuestion } from "../../../lib/data/epja-question-bank-schema";

const bankPath = path.resolve(__dirname, "ds-257-2009/segundo-nivel-medio/ingles/question-bank.json");
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

describe("blueprint real Inglés · Segundo Nivel Medio · D.S. 257/2009", () => {
  it("documenta cuántos ensayos de 25 preguntas soporta el banco actual sin repetir", () => {
    const supportedEssays = Math.floor(candidates.length / TOTAL_QUESTIONS);
    console.log(
      `[ingles-nm2] Banco: ${candidates.length} preguntas. Soporta ${supportedEssays} ensayo(s) completo(s) de ${TOTAL_QUESTIONS} sin repetir (objetivo ideal: 3 + 30% reserva = ${Math.ceil(3 * TOTAL_QUESTIONS * 1.3)}).`
    );
    expect(supportedEssays).toBeGreaterThanOrEqual(1);
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
