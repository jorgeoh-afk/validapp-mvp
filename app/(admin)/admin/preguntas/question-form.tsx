"use client";

import { useActionState, useMemo, useRef, useState } from "react";
import { upsertQuestion } from "@/lib/data/content";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";

const STEP_LABELS = [
  "Curso y asignatura",
  "Ubicación curricular",
  "Enunciado",
  "Alternativas",
  "Detalles pedagógicos",
  "Revisión y guardado",
];

const DIFFICULTY_LABEL: Record<string, string> = {
  inicial: "Inicial",
  intermedia: "Intermedia",
  avanzada: "Avanzada",
};

export type Editing = {
  id: string;
  subject_id: string;
  level_id: string;
  lesson_id: string | null;
  strand_id: string;
  unit_id: string;
  learning_objective_id: string;
  skill_id: string;
  prompt: string;
  resource_url: string;
  explanation: string;
  choices: string[];
  correct_index: number;
  difficulty: string;
  points: number;
  estimated_seconds: number | null;
  source: string;
  review_status: string;
  tags: string;
} | null;

type Duplicate = { id: string; subject_id: string; prompt: string };

export function QuestionForm({
  editing,
  subjects,
  levels,
  lessons,
  strands,
  units,
  learningObjectives,
  skills,
  tagSuggestions,
  existingQuestions,
}: {
  editing?: Editing;
  subjects: { id: string; name: string }[];
  levels: { id: string; name: string }[];
  lessons: { id: string; title: string }[];
  strands: { id: string; name: string; subject_id: string }[];
  units: { id: string; name: string; strand_id: string }[];
  learningObjectives: {
    id: string;
    short_name: string;
    unit_id: string;
    level_id: string;
  }[];
  skills: { id: string; name: string }[];
  tagSuggestions: string[];
  existingQuestions: Duplicate[];
}) {
  const [state, formAction, pending] = useActionState(upsertQuestion, null);
  const formRef = useRef<HTMLFormElement>(null);
  const key = editing?.id ?? "new";

  const [step, setStep] = useState(0);
  const [stepError, setStepError] = useState<string | null>(null);

  const [subjectId, setSubjectId] = useState(editing?.subject_id ?? "");
  const [levelId, setLevelId] = useState(editing?.level_id ?? "");
  const [lessonId, setLessonId] = useState(editing?.lesson_id ?? "");
  const [strandId, setStrandId] = useState(editing?.strand_id ?? "");
  const [unitId, setUnitId] = useState(editing?.unit_id ?? "");
  const [learningObjectiveId, setLearningObjectiveId] = useState(
    editing?.learning_objective_id ?? ""
  );
  const [prompt, setPrompt] = useState(editing?.prompt ?? "");
  const [resourceUrl, setResourceUrl] = useState(editing?.resource_url ?? "");
  const [choices, setChoices] = useState<string[]>(
    editing?.choices && editing.choices.length >= 2
      ? editing.choices
      : ["", ""]
  );
  const [correctIndex, setCorrectIndex] = useState(
    editing?.correct_index ?? -1
  );
  const [explanation, setExplanation] = useState(editing?.explanation ?? "");
  const [difficulty, setDifficulty] = useState(
    editing?.difficulty ?? "intermedia"
  );
  const [skillId, setSkillId] = useState(editing?.skill_id ?? "");
  const [tags, setTags] = useState(editing?.tags ?? "");
  const [source, setSource] = useState(editing?.source ?? "");
  const [points, setPoints] = useState(editing?.points ?? 1);
  const [estimatedSeconds, setEstimatedSeconds] = useState(
    editing?.estimated_seconds != null ? String(editing.estimated_seconds) : ""
  );

  // Después de guardar una pregunta nueva (sin edición en curso), limpia el
  // formulario para el siguiente registro. Se ajusta durante el render (no en
  // un efecto) siguiendo el patrón de React para "resetear estado cuando cambia
  // una prop/valor externo", comparando contra la última acción procesada.
  const [lastHandledActionState, setLastHandledActionState] = useState(state);
  if (state !== lastHandledActionState) {
    setLastHandledActionState(state);
    if (!state && !editing) {
      setStep(0);
      setSubjectId("");
      setLevelId("");
      setLessonId("");
      setStrandId("");
      setUnitId("");
      setLearningObjectiveId("");
      setPrompt("");
      setResourceUrl("");
      setChoices(["", ""]);
      setCorrectIndex(-1);
      setExplanation("");
      setDifficulty("intermedia");
      setSkillId("");
      setTags("");
      setSource("");
      setPoints(1);
      setEstimatedSeconds("");
    }
  }

  const filteredStrands = useMemo(
    () => strands.filter((s) => s.subject_id === subjectId),
    [strands, subjectId]
  );
  const filteredUnits = useMemo(
    () => units.filter((u) => u.strand_id === strandId),
    [units, strandId]
  );
  const filteredObjectives = useMemo(
    () =>
      learningObjectives.filter(
        (o) => o.unit_id === unitId && (!levelId || o.level_id === levelId)
      ),
    [learningObjectives, unitId, levelId]
  );

  const normalizedPrompt = prompt.trim().toLowerCase();
  const possibleDuplicate = existingQuestions.find(
    (q) =>
      q.id !== editing?.id &&
      q.subject_id === subjectId &&
      q.prompt.trim().toLowerCase() === normalizedPrompt &&
      normalizedPrompt.length > 0
  );

  function updateChoice(index: number, value: string) {
    setChoices((prev) => prev.map((c, i) => (i === index ? value : c)));
  }

  function addChoice() {
    if (choices.length >= 6) return;
    setChoices((prev) => [...prev, ""]);
  }

  function removeChoice(index: number) {
    if (choices.length <= 2) return;
    setChoices((prev) => prev.filter((_, i) => i !== index));
    setCorrectIndex((prev) => {
      if (prev === index) return -1;
      if (prev > index) return prev - 1;
      return prev;
    });
  }

  function validateStep(current: number): string | null {
    if (current === 0) {
      if (!subjectId || !levelId) {
        return "Selecciona curso y asignatura para continuar.";
      }
    }
    if (current === 2) {
      if (!prompt.trim()) return "Escribe el enunciado de la pregunta.";
    }
    if (current === 3) {
      const trimmed = choices.map((c) => c.trim());
      if (trimmed.some((c) => !c)) {
        return "No puede haber alternativas vacías.";
      }
      const normalized = trimmed.map((c) => c.toLowerCase());
      if (new Set(normalized).size !== normalized.length) {
        return "No puede haber alternativas repetidas.";
      }
      if (correctIndex < 0 || correctIndex >= trimmed.length) {
        return "Marca cuál alternativa es la correcta.";
      }
    }
    return null;
  }

  function goNext() {
    const error = validateStep(step);
    if (error) {
      setStepError(error);
      return;
    }
    setStepError(null);
    setStep((s) => Math.min(s + 1, STEP_LABELS.length - 1));
  }

  function goBack() {
    setStepError(null);
    setStep((s) => Math.max(s - 1, 0));
  }

  return (
    <form
      ref={formRef}
      action={formAction}
      className="flex flex-col gap-4"
    >
      <input type="hidden" name="id" defaultValue={editing?.id ?? ""} />
      <input type="hidden" name="subjectId" value={subjectId} />
      <input type="hidden" name="levelId" value={levelId} />
      <input type="hidden" name="lessonId" value={lessonId} />
      <input
        type="hidden"
        name="learningObjectiveId"
        value={learningObjectiveId}
      />
      <input type="hidden" name="skillId" value={skillId} />
      <input type="hidden" name="prompt" value={prompt} />
      <input type="hidden" name="resourceUrl" value={resourceUrl} />
      <input type="hidden" name="choices" value={choices.join("\n")} />
      <input type="hidden" name="correctIndex" value={correctIndex} />
      <input type="hidden" name="explanation" value={explanation} />
      <input type="hidden" name="difficulty" value={difficulty} />
      <input type="hidden" name="tags" value={tags} />
      <input type="hidden" name="source" value={source} />
      <input type="hidden" name="points" value={points} />
      <input type="hidden" name="estimatedSeconds" value={estimatedSeconds} />

      <nav
        aria-label="Pasos de creación de la pregunta"
        className="flex flex-wrap gap-2 text-xs"
      >
        {STEP_LABELS.map((label, index) => (
          <span
            key={label}
            className={
              "rounded-full px-2.5 py-1 " +
              (index === step
                ? "bg-primary text-primary-foreground"
                : index < step
                  ? "bg-success/15 text-success"
                  : "bg-muted text-muted-foreground")
            }
          >
            {index + 1}. {label}
          </span>
        ))}
      </nav>

      {/* Paso 1: curso y asignatura */}
      {step === 0 && (
        <div className="flex flex-wrap gap-3">
          <div className="flex flex-col gap-1">
            <Label htmlFor="subjectId-select">Asignatura</Label>
            <select
              id="subjectId-select"
              value={subjectId}
              onChange={(e) => {
                setSubjectId(e.target.value);
                setStrandId("");
                setUnitId("");
                setLearningObjectiveId("");
              }}
              key={`${key}-subject`}
              className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            >
              <option value="" disabled>
                Selecciona...
              </option>
              {subjects.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}
                </option>
              ))}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <Label htmlFor="levelId-select">Nivel / curso</Label>
            <select
              id="levelId-select"
              value={levelId}
              onChange={(e) => setLevelId(e.target.value)}
              key={`${key}-level`}
              className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            >
              <option value="" disabled>
                Selecciona...
              </option>
              {levels.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.name}
                </option>
              ))}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <Label htmlFor="lessonId-select">Lección (opcional)</Label>
            <select
              id="lessonId-select"
              value={lessonId ?? ""}
              onChange={(e) => setLessonId(e.target.value)}
              key={`${key}-lesson`}
              className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
            >
              <option value="">— Solo diagnóstico —</option>
              {lessons.map((l) => (
                <option key={l.id} value={l.id}>
                  {l.title}
                </option>
              ))}
            </select>
          </div>
        </div>
      )}

      {/* Paso 2: eje, unidad y objetivo de aprendizaje */}
      {step === 1 && (
        <div className="flex flex-col gap-3">
          <p className="text-sm text-muted-foreground">
            Opcional: asocia la pregunta a la jerarquía curricular si ya
            existe para esta asignatura y curso.
          </p>
          <div className="flex flex-wrap gap-3">
            <div className="flex flex-col gap-1">
              <Label htmlFor="strandId-select">Eje temático</Label>
              <select
                id="strandId-select"
                value={strandId}
                onChange={(e) => {
                  setStrandId(e.target.value);
                  setUnitId("");
                  setLearningObjectiveId("");
                }}
                className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
              >
                <option value="">— Sin eje —</option>
                {filteredStrands.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
              </select>
              {subjectId && filteredStrands.length === 0 && (
                <p className="text-xs text-muted-foreground">
                  Esta asignatura aún no tiene ejes creados.
                </p>
              )}
            </div>
            <div className="flex flex-col gap-1">
              <Label htmlFor="unitId-select">Unidad</Label>
              <select
                id="unitId-select"
                value={unitId}
                onChange={(e) => {
                  setUnitId(e.target.value);
                  setLearningObjectiveId("");
                }}
                disabled={!strandId}
                className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
              >
                <option value="">— Sin unidad —</option>
                {filteredUnits.map((u) => (
                  <option key={u.id} value={u.id}>
                    {u.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <Label htmlFor="objectiveId-select">
                Objetivo de aprendizaje
              </Label>
              <select
                id="objectiveId-select"
                value={learningObjectiveId}
                onChange={(e) => setLearningObjectiveId(e.target.value)}
                disabled={!unitId}
                className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
              >
                <option value="">— Sin objetivo —</option>
                {filteredObjectives.map((o) => (
                  <option key={o.id} value={o.id}>
                    {o.short_name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>
      )}

      {/* Paso 3: enunciado y recurso */}
      {step === 2 && (
        <div className="flex flex-col gap-3">
          <div className="flex flex-col gap-1">
            <Label htmlFor="prompt-input">Enunciado de la pregunta</Label>
            <textarea
              id="prompt-input"
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              rows={3}
              className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
            />
          </div>
          <div className="flex flex-col gap-1">
            <Label htmlFor="resource-input">
              Recurso asociado (imagen o enlace, opcional)
            </Label>
            <Input
              id="resource-input"
              value={resourceUrl}
              onChange={(e) => setResourceUrl(e.target.value)}
              placeholder="https://..."
            />
          </div>
        </div>
      )}

      {/* Paso 4: alternativas */}
      {step === 3 && (
        <div className="flex flex-col gap-3">
          <p className="text-sm text-muted-foreground">
            Marca cuál alternativa es la correcta.
          </p>
          <ul className="flex flex-col gap-2">
            {choices.map((choice, index) => (
              <li key={index} className="flex items-center gap-2">
                <input
                  type="radio"
                  name="correctIndexRadio"
                  aria-label={`Marcar alternativa ${index + 1} como correcta`}
                  checked={correctIndex === index}
                  onChange={() => setCorrectIndex(index)}
                  className="h-4 w-4 shrink-0"
                />
                <Input
                  value={choice}
                  onChange={(e) => updateChoice(index, e.target.value)}
                  placeholder={`Alternativa ${index + 1}`}
                />
                {choices.length > 2 && (
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon-sm"
                    aria-label="Quitar alternativa"
                    onClick={() => removeChoice(index)}
                  >
                    ×
                  </Button>
                )}
              </li>
            ))}
          </ul>
          {choices.length < 6 && (
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="w-fit"
              onClick={addChoice}
            >
              + Agregar alternativa
            </Button>
          )}
        </div>
      )}

      {/* Paso 5: detalles pedagógicos */}
      {step === 4 && (
        <div className="flex flex-col gap-3">
          <div className="flex flex-col gap-1">
            <Label htmlFor="explanation-input">
              Explicación educativa (se muestra al estudiante)
            </Label>
            <textarea
              id="explanation-input"
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
              rows={2}
              className="rounded-lg border border-input bg-transparent px-2.5 py-1.5 text-sm dark:bg-input/30"
            />
            {!explanation.trim() && (
              <p className="text-xs text-warning-foreground">
                Sin explicación, el estudiante no recibirá retroalimentación
                educativa para esta pregunta.
              </p>
            )}
          </div>
          <div className="flex flex-wrap gap-3">
            <div className="flex flex-col gap-1">
              <Label htmlFor="difficulty-select">Dificultad</Label>
              <select
                id="difficulty-select"
                value={difficulty}
                onChange={(e) => setDifficulty(e.target.value)}
                className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
              >
                <option value="inicial">Inicial</option>
                <option value="intermedia">Intermedia</option>
                <option value="avanzada">Avanzada</option>
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <Label htmlFor="skillId-select">Habilidad evaluada</Label>
              <select
                id="skillId-select"
                value={skillId}
                onChange={(e) => setSkillId(e.target.value)}
                className="h-8 rounded-lg border border-input bg-transparent px-2.5 text-sm dark:bg-input/30"
              >
                <option value="">— Sin habilidad —</option>
                {skills.map((s) => (
                  <option key={s.id} value={s.id}>
                    {s.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex flex-col gap-1">
              <Label htmlFor="points-input">Puntaje</Label>
              <Input
                id="points-input"
                type="number"
                min={1}
                value={points}
                onChange={(e) => setPoints(Number(e.target.value) || 1)}
                className="w-24"
              />
            </div>
            <div className="flex flex-col gap-1">
              <Label htmlFor="seconds-input">Tiempo estimado (segundos)</Label>
              <Input
                id="seconds-input"
                type="number"
                min={0}
                value={estimatedSeconds}
                onChange={(e) => setEstimatedSeconds(e.target.value)}
                className="w-32"
              />
            </div>
          </div>
          <div className="flex flex-col gap-1">
            <Label htmlFor="tags-input">Etiquetas (separadas por coma)</Label>
            <Input
              id="tags-input"
              list="tag-suggestions"
              value={tags}
              onChange={(e) => setTags(e.target.value)}
              placeholder="p. ej. fracciones, ecuaciones"
            />
            <datalist id="tag-suggestions">
              {tagSuggestions.map((t) => (
                <option key={t} value={t} />
              ))}
            </datalist>
          </div>
          <div className="flex flex-col gap-1">
            <Label htmlFor="source-input">Fuente (opcional)</Label>
            <Input
              id="source-input"
              value={source}
              onChange={(e) => setSource(e.target.value)}
            />
          </div>
        </div>
      )}

      {/* Paso 6: revisión y guardado */}
      {step === 5 && (
        <div className="flex flex-col gap-3">
          {possibleDuplicate && (
            <p className="rounded-lg bg-warning/20 px-3 py-2 text-sm text-warning-foreground">
              Posible duplicado: ya existe una pregunta muy parecida en esta
              asignatura. Revisa antes de guardar.
            </p>
          )}
          <div className="rounded-lg border border-border p-3 text-sm">
            <p className="font-medium">{prompt || "(sin enunciado)"}</p>
            <ul className="mt-2 flex flex-col gap-1">
              {choices.map((c, i) => (
                <li
                  key={i}
                  className={
                    i === correctIndex
                      ? "text-success font-medium"
                      : "text-muted-foreground"
                  }
                >
                  {i === correctIndex ? "✓ " : "• "}
                  {c || "(vacía)"}
                </li>
              ))}
            </ul>
            <div className="mt-3 flex flex-wrap gap-1.5">
              <Badge variant="outline">
                {subjects.find((s) => s.id === subjectId)?.name ?? "—"}
              </Badge>
              <Badge variant="outline">
                {levels.find((l) => l.id === levelId)?.name ?? "—"}
              </Badge>
              <Badge>{DIFFICULTY_LABEL[difficulty]}</Badge>
              {skillId && (
                <Badge variant="muted">
                  {skills.find((s) => s.id === skillId)?.name}
                </Badge>
              )}
              {tags
                .split(",")
                .map((t) => t.trim())
                .filter(Boolean)
                .map((t) => (
                  <Badge key={t} variant="muted">
                    {t}
                  </Badge>
                ))}
            </div>
            {!explanation.trim() && (
              <p className="mt-2 text-xs text-warning-foreground">
                Recuerda: esta pregunta se guardará sin explicación educativa.
              </p>
            )}
          </div>
        </div>
      )}

      {state?.error && <p className="text-sm text-destructive">{state.error}</p>}
      {stepError && <p className="text-sm text-destructive">{stepError}</p>}

      <div className="flex items-center justify-between gap-2">
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={step === 0}
          onClick={goBack}
        >
          Atrás
        </Button>
        {step < STEP_LABELS.length - 1 ? (
          <Button type="button" size="sm" onClick={goNext}>
            Siguiente
          </Button>
        ) : (
          <div className="flex gap-2">
            <Button
              type="submit"
              name="reviewStatus"
              value="borrador"
              variant="outline"
              size="sm"
              disabled={pending}
            >
              Guardar como borrador
            </Button>
            <Button
              type="submit"
              name="reviewStatus"
              value="en_revision"
              size="sm"
              disabled={pending}
            >
              Enviar a aprobación
            </Button>
          </div>
        )}
      </div>
    </form>
  );
}
