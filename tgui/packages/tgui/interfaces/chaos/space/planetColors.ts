// Colors of PixelPlanets by Deep-Fold (https://github.com/Deep-Fold/PixelPlanets, MIT, see the license in
// planetShaders.ts): Godot's Color operations the planet scripts use, and the colorscheme generator of Planets/Planet.gd.
import { type Random, randomRange } from './random';

/** [r, g, b, a] from 0 to 1, as shader uniforms take them */
export type Color = number[];

/** Color("#rrggbb") or Color("rrggbb"); null for anything else */
export const parseHexColor = (hex: string): Color | null => {
  const match = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(hex.trim());
  if (!match) {
    return null;
  }
  return [
    parseInt(match[1], 16) / 255,
    parseInt(match[2], 16) / 255,
    parseInt(match[3], 16) / 255,
    1,
  ];
};

/** Color.darkened() */
export const darkened = (color: Color, amount: number): Color => [
  color[0] * (1 - amount),
  color[1] * (1 - amount),
  color[2] * (1 - amount),
  color[3],
];

/** Color.lightened() */
export const lightened = (color: Color, amount: number): Color => [
  color[0] + (1 - color[0]) * amount,
  color[1] + (1 - color[1]) * amount,
  color[2] + (1 - color[2]) * amount,
  color[3],
];

/** Color.h, Color.s and Color.v */
export const toHsv = (color: Color) => {
  const [red, green, blue] = color;
  const max = Math.max(red, green, blue);
  const min = Math.min(red, green, blue);
  const delta = max - min;
  let hue = 0;
  if (delta > 0) {
    if (max === red) {
      hue = (green - blue) / delta;
    } else if (max === green) {
      hue = 2 + (blue - red) / delta;
    } else {
      hue = 4 + (red - green) / delta;
    }
    hue /= 6;
    if (hue < 0) {
      hue += 1;
    }
  }
  return { h: hue, s: max > 0 ? delta / max : 0, v: max };
};

/** Color.from_hsv(); the hue wraps around */
export const fromHsv = (
  hue: number,
  saturation: number,
  value: number,
  alpha = 1,
): Color => {
  const sector = (((hue * 6) % 6) + 6) % 6;
  const index = Math.floor(sector);
  const part = sector - index;
  const p = value * (1 - saturation);
  const q = value * (1 - saturation * part);
  const t = value * (1 - saturation * (1 - part));
  const rgb = [
    [value, t, p],
    [q, value, p],
    [p, value, t],
    [p, q, value],
    [t, p, value],
    [value, p, q],
  ][index];
  return [...rgb, alpha];
};

/** The planet scripts' Color.from_hsv(color.h + shift, color.s, color.v) */
export const shiftHue = (color: Color, shift: number) => {
  const { h, s, v } = toHsv(color);
  return fromHsv(h + shift, s, v);
};

/**
 * Planet.gd's _generate_new_colorscheme(): a palette of colors from a cosine gradient
 * (https://www.iquilezles.org/www/articles/palettes/palettes.htm)
 */
export const generateColorscheme = (
  random: Random,
  count: number,
  hueDiff = 0.9,
  saturation = 0.5,
): Color[] => {
  const a = [0.5, 0.5, 0.5];
  const b = [0.5 * saturation, 0.5 * saturation, 0.5 * saturation];
  const c = [0, 0, 0].map(() => randomRange(random, 0.5, 1.5) * hueDiff);
  const d = [0, 0, 0].map(
    () => randomRange(random, 0, 1) * randomRange(random, 1, 3),
  );
  const steps = Math.max(1, count - 1);
  const colors: Color[] = [];
  for (let index = 0; index < count; index++) {
    colors.push([
      ...[0, 1, 2].map(
        (channel) =>
          a[channel] +
          b[channel] *
            Math.cos(6.28318 * (c[channel] * (index / steps) + d[channel])),
      ),
      1,
    ]);
  }
  return colors;
};
