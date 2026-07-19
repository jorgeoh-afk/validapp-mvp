// Ver ingles-nm1-blueprint.test.ts para el criterio. Cubre Estudios
// Sociales en ambos niveles (25 preguntas cada uno, sin reserva).

import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import path from "node:path";
import { selectEssayQuestions, type CandidateQuestion } from "../../../lib/data/essay-selection";
import type { EpjaBankQuestion } from "../../../lib/data/epja-question-bank-schema";

const TOTAL_QUESTIONS = 25;
const names = { subjectNames: {}, strandNames: {}, objectiveNames: {} };

function loadCandidates(relativeBankPath: string): CandidateQuestion[] {
  const bankPath = path.resolve(__dirname, relativeBankPath);
  const bank: EpjaBankQuestion[] = JSON.parse(readFileSync(bankPath, "utf8"));
  return bank.map((q) => ({
    id: q.localId,
    subjectId: "estudios-sociales",
    strandId: q.strandName,
    learningObjectiveId: q.objectiveShortName,
    difficulty: q.difficulty,
    prompt: q.prompt,
    points: q.points ?? 1,
    estimatedSeconds: q.estimatedSeconds ?? null,
    reviewStatus: "aprobado",
    timesUsed: 0,
  }));
}

for (const [label, relativePath] of [
  ["Primer Nivel Medio", "ds-257-2009/primer-nivel-medio/estudios-sociales/question-bank.json"],
  ["Segundo Nivel Medio", "ds-257-2009/segundo-nivel-medio/estudios-sociales/question-bank.json"],
] as const) {
  describe(`blueprint real Estudios Sociales · ${label} · D.S. 257/2009`, () => {
    const candidates = loadCandidates(relativePath);

    it("documenta cuántos ensayos de 25 preguntas soporta el banco actual sin repetir", () => {
      const supportedEssays = Math.floor(candidates.length / TOTAL_QUESTIONS);
      console.log(
        `[estudios-sociales · ${label}] Banco: ${candidates.length} preguntas. Soporta ${supportedEssays} ensayo(s) (objetivo ideal: ${Math.ceil(3 * TOTAL_QUESTIONS * 1.3)}).`
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
        used.push(...ids);
      }
      expect(used).toHaveLength(supportedEssays * TOTAL_QUESTIONS);
    });
  });
}
