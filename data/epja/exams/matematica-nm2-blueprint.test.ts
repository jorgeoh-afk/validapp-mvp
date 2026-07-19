// Ver matematica-nm1-blueprint.test.ts para el criterio completo. Misma
// lógica, aplicada al banco de Matemática · Segundo Nivel Medio (98
// preguntas, 14 objetivos × 7). 25 preguntas / 90 minutos: mismo texto
// oficial verificado que NM1 (el temario NM2 dice literalmente "Cada
// prueba contiene 25 preguntas que deberá contestar en un tiempo de 90
// minutos").

import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import path from "node:path";
import { selectEssayQuestions, type CandidateQuestion } from "../../../lib/data/essay-selection";
import type { EpjaBankQuestion } from "../../../lib/data/epja-question-bank-schema";

const bankPath = path.resolve(__dirname, "ds-257-2009/segundo-nivel-medio/matematica/question-bank.json");
const bank: EpjaBankQuestion[] = JSON.parse(readFileSync(bankPath, "utf8"));

const STRAND_QUOTA: Record<string, number> = {
  "Funciones y Ecuaciones": 16,
  "Geometría y Trigonometría": 4,
  "Probabilidad y Estadística": 5,
};
const TOTAL_QUESTIONS = 25;

const candidates: CandidateQuestion[] = bank.map((q) => ({
  id: q.localId,
  subjectId: "matematica",
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

describe("blueprint real Matemática · Segundo Nivel Medio · D.S. 257/2009", () => {
  it("el banco generado alcanza para 3 ensayos + 30% de reserva", () => {
    expect(candidates.length).toBeGreaterThanOrEqual(Math.ceil(3 * TOTAL_QUESTIONS * 1.3));
  });

  it("genera 3 ensayos (A, B, C) sin repetir preguntas entre ellos, cumpliendo cuotas", () => {
    const used: string[] = [];
    for (let i = 0; i < 3; i++) {
      const result = selectEssayQuestions({
        candidates,
        totalQuestions: TOTAL_QUESTIONS,
        subjectRequirements: [],
        strandRequirements: Object.entries(STRAND_QUOTA).map(([strandId, count]) => ({ strandId, count })),
        objectiveRequirements: [],
        difficultyRequirements: [],
        excludeQuestionIds: used,
        ...names,
      });
      expect(result.missing).toEqual([]);
      expect(result.selected).toHaveLength(TOTAL_QUESTIONS);
      for (const strandId of Object.keys(STRAND_QUOTA)) {
        expect(result.selected.filter((s) => s.strandId === strandId).length).toBeGreaterThanOrEqual(
          STRAND_QUOTA[strandId]
        );
      }
      const ids = result.selected.map((s) => s.questionId);
      expect(new Set(ids).size).toBe(ids.length);
      for (const idVal of ids) expect(used).not.toContain(idVal);
      used.push(...ids);
    }
    expect(used).toHaveLength(3 * TOTAL_QUESTIONS);
  });

  it("simulación de 1000 generaciones: cuotas, sin duplicados, sin mezclar ejes", () => {
    const strandIdSet = new Set(Object.keys(STRAND_QUOTA));
    for (let run = 0; run < 1000; run++) {
      let s = run + 1;
      const rng = () => {
        s = (s * 9301 + 49297) % 233280;
        return s / 233280;
      };
      const result = selectEssayQuestions({
        candidates,
        totalQuestions: TOTAL_QUESTIONS,
        subjectRequirements: [],
        strandRequirements: Object.entries(STRAND_QUOTA).map(([strandId, count]) => ({ strandId, count })),
        objectiveRequirements: [],
        difficultyRequirements: [],
        rng,
        ...names,
      });
      expect(result.missing).toEqual([]);
      expect(result.selected).toHaveLength(TOTAL_QUESTIONS);
      const ids = result.selected.map((s) => s.questionId);
      expect(new Set(ids).size).toBe(ids.length);
      expect(result.selected.every((s) => strandIdSet.has(s.strandId ?? ""))).toBe(true);
    }
  });
});
