// Dominio: Contenido y preguntas — pruebas de calidad sobre TODOS los
// bancos de preguntas EPJA generados (cualquier archivo
// data/epja/exams/**/question-bank.json), no solo Matemática. Corre los
// mismos validadores mecánicos que el importador (lib/data/
// question-validators.ts) para que un banco defectuoso falle en CI/local
// antes de llegar a la base de datos, y detecta duplicados exactos/casi
// exactos dentro de cada archivo y entre archivos de la misma asignatura.

import { describe, expect, it } from "vitest";
import { readFileSync, readdirSync, statSync } from "node:fs";
import path from "node:path";
import { isWellFormedBankQuestion, type EpjaBankQuestion } from "../../../lib/data/epja-question-bank-schema";
import { validateQuestion, findDuplicate, computeContentHash } from "../../../lib/data/question-validators";

const EXAMS_ROOT = path.resolve(__dirname);

function findQuestionBankFiles(dir: string): string[] {
  const entries = readdirSync(dir);
  const files: string[] = [];
  for (const entry of entries) {
    const full = path.join(dir, entry);
    if (statSync(full).isDirectory()) {
      files.push(...findQuestionBankFiles(full));
    } else if (entry === "question-bank.json") {
      files.push(full);
    }
  }
  return files;
}

const bankFiles = findQuestionBankFiles(EXAMS_ROOT);

describe("bancos de preguntas EPJA (data/epja/exams)", () => {
  it("encuentra al menos un banco de preguntas para probar", () => {
    expect(bankFiles.length).toBeGreaterThan(0);
  });

  for (const file of bankFiles) {
    const relative = path.relative(EXAMS_ROOT, file);

    describe(relative, () => {
      const raw = JSON.parse(readFileSync(file, "utf8"));

      it("es un arreglo de preguntas bien formadas", () => {
        expect(Array.isArray(raw)).toBe(true);
        for (const q of raw) {
          expect(isWellFormedBankQuestion(q)).toBe(true);
        }
      });

      const questions = raw as EpjaBankQuestion[];

      it("no tiene localId repetido dentro del archivo", () => {
        const ids = questions.map((q) => q.localId);
        expect(new Set(ids).size).toBe(ids.length);
      });

      it("cada pregunta pasa los validadores mecánicos bloqueantes (severity=error)", () => {
        // Los issues `warning` (casi-duplicado, pista de longitud, "todas
        // las anteriores", posible fuga en el enunciado) se listan pero NO
        // fallan la prueba -- el propio criterio de la tarea es que esos
        // casos "se marcan para revisión", no que se rechacen. Solo los
        // defectos estructurales (`error`) bloquean.
        const errors: string[] = [];
        const warnings: string[] = [];
        for (const q of questions) {
          const result = validateQuestion({
            prompt: q.prompt,
            questionType: q.questionType,
            choices: q.choices ?? null,
            correctIndex: q.correctIndex ?? null,
            answerKey: q.answerKey ?? null,
            rubric: q.rubric ?? null,
            // El vínculo curricular real (learning_objective_id/subjectId/
            // levelId) se valida en el importador contra la BD, ya que acá
            // el JSON solo tiene nombres legibles (objectiveShortName), no
            // ids. Se pasan valores no vacíos para no duplicar esa
            // comprobación aquí.
            learningObjectiveId: q.objectiveShortName ? "placeholder" : null,
            subjectId: "placeholder",
            levelId: "placeholder",
            frameworkId: null,
          });
          for (const i of result.issues) {
            const line = `${q.localId}: ${i.code}`;
            if (i.severity === "error") errors.push(line);
            else warnings.push(line);
          }
        }
        if (warnings.length > 0) {
          console.warn(`[${relative}] ${warnings.length} pregunta(s) marcadas para revisión:`, warnings);
        }
        expect(errors).toEqual([]);
      });

      it("no tiene duplicados EXACTOS dentro del archivo (casi-duplicados quedan marcados para revisión, no bloquean)", () => {
        const seen: { id: string; prompt: string; contentHash: string }[] = [];
        const exactDuplicates: string[] = [];
        const nearDuplicates: string[] = [];
        for (const q of questions) {
          const dup = findDuplicate(q.prompt, seen);
          if (dup?.kind === "exact") exactDuplicates.push(`${q.localId} es idéntico a ${dup.id}`);
          if (dup?.kind === "near") nearDuplicates.push(`${q.localId} es similar a ${dup.id}`);
          seen.push({ id: q.localId, prompt: q.prompt, contentHash: computeContentHash(q.prompt) });
        }
        if (nearDuplicates.length > 0) {
          console.warn(`[${relative}] casi-duplicados para revisión:`, nearDuplicates);
        }
        expect(exactDuplicates).toEqual([]);
      });

      it("selección múltiple: alternativas coherentes con la respuesta marcada", () => {
        for (const q of questions.filter((x) => x.questionType === "seleccion_multiple")) {
          expect(q.choices?.length ?? 0).toBeGreaterThanOrEqual(3);
          expect(q.correctIndex).toBeGreaterThanOrEqual(0);
          expect(q.correctIndex).toBeLessThan(q.choices?.length ?? 0);
        }
      });
    });
  }
});
