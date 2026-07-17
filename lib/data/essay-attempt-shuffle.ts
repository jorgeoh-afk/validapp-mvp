// Dominio: Resultados y progreso — barajado por intento (Fase 6).
//
// Lógica pura (sin llamadas a Supabase), igual que `essay-selection.ts` en
// la Fase 5, para poder probarla de forma aislada. Se usa desde
// `essay-attempts.ts` al iniciar un intento (barajar alternativas y, si
// corresponde, el orden de las preguntas) y al traducir la posición visual
// de una alternativa elegida de vuelta a su índice original.

/** Baraja simple (Fisher-Yates) usando un generador reemplazable para pruebas. */
export function shuffleArray<T>(items: T[], rng: () => number = Math.random): T[] {
  const arr = [...items];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

/** Permutación aleatoria de los índices 0..length-1 (orden barajado de alternativas). */
export function shuffleIndices(
  length: number,
  rng: () => number = Math.random
): number[] {
  return shuffleArray(
    Array.from({ length }, (_, i) => i),
    rng
  );
}

/** Traduce una posición visual (0-based, según `shuffledOrder`) a su índice original. */
export function originalIndexFromVisual(
  shuffledOrder: number[],
  visualPosition: number
): number {
  return shuffledOrder[visualPosition] ?? -1;
}

/** Traduce un índice original a la posición visual en la que se muestra, según `shuffledOrder`. */
export function visualPositionFromOriginal(
  shuffledOrder: number[],
  originalIndex: number
): number {
  return shuffledOrder.indexOf(originalIndex);
}

/** Reordena un arreglo de alternativas según el orden barajado guardado. */
export function applyShuffledOrder<T>(items: T[], shuffledOrder: number[]): T[] {
  if (!shuffledOrder.length) return items;
  return shuffledOrder.map((originalIndex) => items[originalIndex]);
}
