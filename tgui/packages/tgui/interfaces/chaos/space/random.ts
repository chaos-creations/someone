// Seeded randomness for the generated space: the same seed always gives the same planet or background.

/** Returns a random number generator (mulberry32) that gives the same numbers from 0 (inclusive) to 1 for the same seed */
export const createRandom = (seed: number) => {
  let state = Math.trunc(seed) >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let value = state;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
};

export type Random = ReturnType<typeof createRandom>;

/** Godot's randf_range() */
export const randomRange = (random: Random, min: number, max: number) =>
  min + random() * (max - min);

/** Godot's randi() % count */
export const randomInt = (random: Random, count: number) =>
  Math.floor(random() * count);
