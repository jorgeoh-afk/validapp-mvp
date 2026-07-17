"use client";

import { useActionState, useState } from "react";
import { saveEssayDistributions } from "@/lib/data/essays";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type CountOrPercent = { count: string; percent: string };

type SubjectRow = CountOrPercent & { id: string; subjectId: string };
type ObjectiveRow = CountOrPercent & { id: string; learningObjectiveId: string };
type DifficultyRow = CountOrPercent & { id: string; difficulty: string };

const DIFFICULTY_LABEL: Record<string, string> = {
  inicial: "Inicial",
  intermedia: "Intermedia",
  avanzada: "Avanzada",
};

let rowKeyCounter = 0;
function newKey() {
  rowKeyCounter += 1;
  return `row-${rowKeyCounter}`;
}

export function DistributionForm({
  essayId,
  subjects,
  learningObjectives,
  initialSubjects,
  initialObjectives,
  initialDifficulty,
}: {
  essayId: string;
  subjects: { id: string; name: string }[];
  learningObjectives: { id: string; short_name: string; subjectName: string }[];
  initialSubjects: { subject_id: string; question_count: number | null; question_percent: number | null }[];
  initialObjectives: { learning_objective_id: string; question_count: number | null; question_percent: number | null }[];
  initialDifficulty: { difficulty: string; question_count: number | null; question_percent: number | null }[];
}) {
  const [state, formAction, pending] = useActionState(
    saveEssayDistributions,
    null
  );

  const [subjectRows, setSubjectRows] = useState<SubjectRow[]>(
    initialSubjects.map((s) => ({
      id: newKey(),
      subjectId: s.subject_id,
      count: s.question_count != null ? String(s.question_count) : "",
      percent: s.question_percent != null ? String(s.question_percent) : "",
    }))
  );
  const [objectiveRows, setObjectiveRows] = useState<ObjectiveRow[]>(
    initialObjectives.map((o) => ({
      id: newKey(),
      learningObjectiveId: o.learning_objective_id,
      count: o.question_count != null ? String(o.question_count) : "",
      percent: o.question_percent != null ? String(o.question_percent) : "",
    }))
  );
  const [difficultyRows, setDifficultyRows] = useState<DifficultyRow[]>(
    initialDifficulty.map((d) => ({
      id: newKey(),
      difficulty: d.difficulty,
      count: d.question_count != null ? String(d.question_count) : "",
      percent: d.question_percent != null ? String(d.question_percent) : "",
    }))
  );

  const usedDifficulties = new Set(difficultyRows.map((r) => r.difficulty));

  function buildPayload() {
    return JSON.stringify({
      subjects: subjectRows
        .filter((r) => r.subjectId)
        .map((r) => ({
          subjectId: r.subjectId,
          count: r.count ? Number(r.count) : null,
          percent: r.percent ? Number(r.percent) : null,
        })),
      objectives: objectiveRows
        .filter((r) => r.learningObjectiveId)
        .map((r) => ({
          learningObjectiveId: r.learningObjectiveId,
          count: r.count ? Number(r.count) : null,
          percent: r.percent ? Number(r.percent) : null,
        })),
      difficulty: difficultyRows
        .filter((r) => r.difficulty)
        .map((r) => ({
          difficulty: r.difficulty,
          count: r.count ? Number(r.count) : null,
          percent: r.percent ? Number(r.percent) : null,
        })),
    });
  }

  return (
    <form action={formAction} className="flex flex-col gap-6">
      <input type="hidden" name="essayId" value={essayId} />
      <input type="hidden" name="distributionsJson" value={buildPayload()} />

      <section className="flex flex-col gap-2">
        <h3 className="text-sm font-semibold">Distribución por asignatura</h3>
        {subjectRows.map((row, index) => (
          <div key={row.id} className="flex flex-wrap items-center gap-2">
            <select
              value={row.subjectId}
              onChange={(e) =>
                setSubjectRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, subjectId: e.target.value } : r
                  )
                )
              }
              className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            >
              <option value="">Selecciona asignatura...</option>
              {subjects.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}
                </option>
              ))}
            </select>
            <Input
              type="number"
              min={0}
              placeholder="Cantidad"
              value={row.count}
              onChange={(e) =>
                setSubjectRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, count: e.target.value, percent: "" } : r
                  )
                )
              }
              className="w-24"
            />
            <span className="text-xs text-muted-foreground">o</span>
            <Input
              type="number"
              min={0}
              max={100}
              placeholder="% del total"
              value={row.percent}
              onChange={(e) =>
                setSubjectRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, percent: e.target.value, count: "" } : r
                  )
                )
              }
              className="w-28"
            />
            <Button
              type="button"
              variant="ghost"
              size="icon-sm"
              aria-label="Quitar asignatura"
              onClick={() =>
                setSubjectRows((prev) => prev.filter((_, i) => i !== index))
              }
            >
              ×
            </Button>
          </div>
        ))}
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="w-fit"
          onClick={() =>
            setSubjectRows((prev) => [
              ...prev,
              { id: newKey(), subjectId: "", count: "", percent: "" },
            ])
          }
        >
          + Agregar asignatura
        </Button>
      </section>

      <section className="flex flex-col gap-2">
        <h3 className="text-sm font-semibold">
          Distribución por objetivo de aprendizaje
        </h3>
        {objectiveRows.map((row, index) => (
          <div key={row.id} className="flex flex-wrap items-center gap-2">
            <select
              value={row.learningObjectiveId}
              onChange={(e) =>
                setObjectiveRows((prev) =>
                  prev.map((r, i) =>
                    i === index
                      ? { ...r, learningObjectiveId: e.target.value }
                      : r
                  )
                )
              }
              className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            >
              <option value="">Selecciona objetivo...</option>
              {learningObjectives.map((o) => (
                <option key={o.id} value={o.id}>
                  {o.subjectName} — {o.short_name}
                </option>
              ))}
            </select>
            <Input
              type="number"
              min={0}
              placeholder="Cantidad"
              value={row.count}
              onChange={(e) =>
                setObjectiveRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, count: e.target.value, percent: "" } : r
                  )
                )
              }
              className="w-24"
            />
            <span className="text-xs text-muted-foreground">o</span>
            <Input
              type="number"
              min={0}
              max={100}
              placeholder="% del total"
              value={row.percent}
              onChange={(e) =>
                setObjectiveRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, percent: e.target.value, count: "" } : r
                  )
                )
              }
              className="w-28"
            />
            <Button
              type="button"
              variant="ghost"
              size="icon-sm"
              aria-label="Quitar objetivo"
              onClick={() =>
                setObjectiveRows((prev) => prev.filter((_, i) => i !== index))
              }
            >
              ×
            </Button>
          </div>
        ))}
        <Button
          type="button"
          variant="outline"
          size="sm"
          className="w-fit"
          onClick={() =>
            setObjectiveRows((prev) => [
              ...prev,
              { id: newKey(), learningObjectiveId: "", count: "", percent: "" },
            ])
          }
        >
          + Agregar objetivo
        </Button>
      </section>

      <section className="flex flex-col gap-2">
        <h3 className="text-sm font-semibold">Distribución por dificultad</h3>
        {difficultyRows.map((row, index) => (
          <div key={row.id} className="flex flex-wrap items-center gap-2">
            <select
              value={row.difficulty}
              onChange={(e) =>
                setDifficultyRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, difficulty: e.target.value } : r
                  )
                )
              }
              className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            >
              <option value="">Selecciona dificultad...</option>
              {Object.entries(DIFFICULTY_LABEL)
                .filter(([value]) => value === row.difficulty || !usedDifficulties.has(value))
                .map(([value, label]) => (
                  <option key={value} value={value}>
                    {label}
                  </option>
                ))}
            </select>
            <Input
              type="number"
              min={0}
              placeholder="Cantidad"
              value={row.count}
              onChange={(e) =>
                setDifficultyRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, count: e.target.value, percent: "" } : r
                  )
                )
              }
              className="w-24"
            />
            <span className="text-xs text-muted-foreground">o</span>
            <Input
              type="number"
              min={0}
              max={100}
              placeholder="% del total"
              value={row.percent}
              onChange={(e) =>
                setDifficultyRows((prev) =>
                  prev.map((r, i) =>
                    i === index ? { ...r, percent: e.target.value, count: "" } : r
                  )
                )
              }
              className="w-28"
            />
            <Button
              type="button"
              variant="ghost"
              size="icon-sm"
              aria-label="Quitar dificultad"
              onClick={() =>
                setDifficultyRows((prev) => prev.filter((_, i) => i !== index))
              }
            >
              ×
            </Button>
          </div>
        ))}
        {difficultyRows.length < 3 && (
          <Button
            type="button"
            variant="outline"
            size="sm"
            className="w-fit"
            onClick={() =>
              setDifficultyRows((prev) => [
                ...prev,
                { id: newKey(), difficulty: "", count: "", percent: "" },
              ])
            }
          >
            + Agregar dificultad
          </Button>
        )}
      </section>

      {state?.error && <p className="text-sm text-destructive">{state.error}</p>}

      <Button type="submit" size="sm" className="w-fit" disabled={pending}>
        Guardar distribuciones
      </Button>
    </form>
  );
}
