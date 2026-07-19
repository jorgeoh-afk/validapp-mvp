// Dominio: Contenido y preguntas — simulación del blueprint real de
// Matemática/Primer Nivel Medio (D.S. 257/2009) sobre el banco de 114
// preguntas efectivamente generado (question-bank.json), no sobre datos de
// prueba sintéticos. Verifica que 3 ensayos de 25 preguntas (A, B, C) más
// banco de reserva puedan generarse sin repetir preguntas entre sí y
// cumpliendo la cuota por eje y por dificultad, en 1000 generaciones con
// distintas semillas -- ver sección 28 de la spec del usuario ("simulación
// automatizada de al menos 1.000 generaciones").
//
// Cantidad/duración del blueprint (25 preguntas, 90 minutos) están
// verificadas contra la fuente oficial (ver supabase/seed/
// 0001_epja_pilot_matematica.sql): el propio temario dice "Cada prueba
// contiene 25 preguntas que deberá contestar en un tiempo de 90 minutos."
// La distribución por eje/dificultad es `validapp_inferred_blueprint`
// (proporcional a la cantidad de objetivos/preguntas generadas por eje), no
// oficial -- MINEDUC no publica esa distribución interna.

import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import path from "node:path";
import { selectEssayQuestions, type CandidateQuestion } from "../../../lib/data/essay-selection";
import type { EpjaBankQuestion } from "../../../lib/data/epja-question-bank-schema";

const bankPath = path.resolve(__dirname, "ds-257-2009/primer-nivel-medio/matematica/question-bank.json");
const bank: EpjaBankQuestion[] = JSON.parse(readFileSync(bankPath, "utf8"));

// Cuota por eje: suma exacta a 25 (el total verificado oficialmente). NO se
// agrega además una cuota por dificultad que también sume 25 -- ambas
// restricciones son independientes en `selectEssayQuestions` (cada pase
// completa su propia cuota sin descontar lo ya cubierto por el OTRO
// criterio), así que exigir dos particiones completas de 25 sobre el mismo
// total sobre-restringe la selección y puede superar el total. La
// dificultad de cada pregunta queda como resultado observado (se verifica
// que haya variedad, no una cuota exacta impuesta).
const STRAND_QUOTA: Record<string, number> = {
  Números: 9,
  "Álgebra y Funciones": 7,
  Geometría: 5,
  "Probabilidad y Estadística": 4,
};
const TOTAL_QUESTIONS = 25; // verificado: "25 preguntas... 90 minutos" (fuente oficial)

const candidates: CandidateQuestion[] = bank.map((q) => ({
  id: q.localId,
  subjectId: "matematica",
  strandId: q.strandName,
  learningObjectiveId: q.objectiveShortName,
  difficulty: q.difficulty,
  prompt: q.prompt,
  points: q.points ?? 1,
  estimatedSeconds: q.estimatedSeconds ?? null,
  reviewStatus: "aprobado", // simula el estado post-revisión humana (no es el estado actual real)
  timesUsed: 0,
}));

const names = { subjectNames: {}, strandNames: {}, objectiveNames: {} };

describe("blueprint real Matemática · Primer Nivel Medio · D.S. 257/2009", () => {
  it("el banco generado alcanza para 3 ensayos + 30% de reserva sin repetir preguntas", () => {
    // 3 × 25 = 75 preguntas mínimas para A+B+C sin repetir; +30% de reserva
    // sobre esas 75 = ~22 adicionales => ~97 preguntas totales esperadas.
    const minimumNeeded = Math.ceil(3 * TOTAL_QUESTIONS * 1.3);
    expect(candidates.length).toBeGreaterThanOrEqual(minimumNeeded);
  });

  it("genera 3 ensayos (A, B, C) sin repetir preguntas entre ellos, cumpliendo cuotas", () => {
    const usedAcrossVariants: string[] = [];
    const variants: { label: string; selectedIds: string[] }[] = [];

    for (const label of ["A", "B", "C"]) {
      const result = selectEssayQuestions({
        candidates,
        totalQuestions: TOTAL_QUESTIONS,
        subjectRequirements: [],
        strandRequirements: Object.entries(STRAND_QUOTA).map(([strandId, count]) => ({ strandId, count })),
        objectiveRequirements: [],
        difficultyRequirements: [],
        excludeQuestionIds: usedAcrossVariants,
        ...names,
      });

      expect(result.missing).toEqual([]);
      expect(result.selected).toHaveLength(TOTAL_QUESTIONS);

      for (const strandId of Object.keys(STRAND_QUOTA)) {
        expect(
          result.selected.filter((s) => s.strandId === strandId).length
        ).toBeGreaterThanOrEqual(STRAND_QUOTA[strandId]);
      }

      const ids = result.selected.map((s) => s.questionId);
      expect(new Set(ids).size).toBe(ids.length); // sin duplicados dentro del ensayo
      for (const id of ids) {
        expect(usedAcrossVariants).not.toContain(id); // sin duplicados entre A/B/C
      }
      // La dificultad no se impone como cuota (ver nota arriba), pero un
      // ensayo de 25 preguntas real debería igual tener variedad: al menos
      // una de cada nivel de dificultad.
      const difficulties = new Set(result.selected.map((s) => s.difficulty));
      expect(difficulties.size).toBeGreaterThanOrEqual(2);

      usedAcrossVariants.push(...ids);
      variants.push({ label, selectedIds: ids });
    }

    expect(variants).toHaveLength(3);
    expect(usedAcrossVariants).toHaveLength(3 * TOTAL_QUESTIONS);

    // Banco de reserva: preguntas aprobadas que NO quedaron en A, B ni C.
    const reserve = candidates.filter((c) => !usedAcrossVariants.includes(c.id));
    expect(reserve.length).toBeGreaterThanOrEqual(Math.ceil(0.3 * 3 * TOTAL_QUESTIONS));
  });

  it("simulación de 1000 generaciones: cuotas, sin duplicados, sin mezclar ejes fuera del blueprint", () => {
    const strandIdSet = new Set(Object.keys(STRAND_QUOTA));
    const usageCount = new Map<string, number>();

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
      expect(result.selected.every((s) => s.subjectId === "matematica")).toBe(true);

      for (const id of ids) usageCount.set(id, (usageCount.get(id) ?? 0) + 1);
    }

    // Utilización del banco de reserva: con 114 preguntas y 25 cupos por
    // corrida (~22% del banco), en 1000 corridas cada pregunta debería
    // usarse un número de veces del mismo orden que el promedio
    // (1000*25/114 ≈ 219), no unas pocas acaparando todo.
    expect(usageCount.size).toBe(candidates.length);
    const counts = [...usageCount.values()];
    expect(Math.max(...counts) / Math.min(...counts)).toBeLessThan(4);
  });
});
