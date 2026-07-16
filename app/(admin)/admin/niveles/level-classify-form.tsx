"use client";

import { useActionState, useRef } from "react";
import { classifyLevel } from "@/lib/data/curriculum";

export function LevelClassifyForm({
  levelId,
  programId,
  educationLevelId,
  programs,
  educationLevels,
}: {
  levelId: string;
  programId: string | null;
  educationLevelId: string | null;
  programs: { id: string; name: string }[];
  educationLevels: { id: string; name: string }[];
}) {
  const [state, formAction] = useActionState(classifyLevel, null);
  const formRef = useRef<HTMLFormElement>(null);

  return (
    <form
      ref={formRef}
      action={formAction}
      className="flex flex-wrap items-center gap-2 text-sm"
    >
      <input type="hidden" name="id" value={levelId} />
      <select
        name="programId"
        defaultValue={programId ?? ""}
        onChange={(e) => e.currentTarget.form?.requestSubmit()}
        className="h-7 rounded-md border border-input bg-transparent px-2 text-xs dark:bg-input/30"
      >
        <option value="">— Sin programa —</option>
        {programs.map((p) => (
          <option key={p.id} value={p.id}>
            {p.name}
          </option>
        ))}
      </select>
      <select
        name="educationLevelId"
        defaultValue={educationLevelId ?? ""}
        onChange={(e) => e.currentTarget.form?.requestSubmit()}
        className="h-7 rounded-md border border-input bg-transparent px-2 text-xs dark:bg-input/30"
      >
        <option value="">— Sin nivel educativo —</option>
        {educationLevels.map((l) => (
          <option key={l.id} value={l.id}>
            {l.name}
          </option>
        ))}
      </select>
      {state?.error && <span className="text-red-600">{state.error}</span>}
    </form>
  );
}
