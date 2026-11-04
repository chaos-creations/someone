// A planet of a PixelPlanets type (planetTypes.ts) with its own seed, size and colors, as layers to draw.
import { type Color, parseHexColor } from './planetColors';
import { getColorCount, PLANET_TYPES } from './planetTypes';
import { createRandom } from './random';
import type { DrawLayer, Uniforms } from './webgl';

export type PlanetOptions = {
  /** Key of PLANET_TYPES */
  type: string;
  /** Any whole number; the same seed gives the same planet */
  seed: number;
  /** Diameter of the planet in its own pixels */
  pixels: number;
  /** Colors as "#rrggbb", in the order of the type's set_colors(); null for the type's own */
  colors?: string[] | null;
  /** Colors made from the seed by the type's randomize_colors(), if it has one; colors win over this */
  randomColors?: boolean;
  /** Turn of the planet's axis, in radians */
  tilt?: number;
};

export type Planet = {
  /** Width and height of the drawing in px: the planet with its rings or flares */
  size: number;
  /**
   * Returns the layers as they are at the time in seconds since the planet appeared, lit from the light
   * ([x, y] in the planet's UV, 0,0 at its top left) or from the type's own light if null
   */
  getLayers: (seconds: number, light: number[] | null) => DrawLayer[];
};

/** Planet.gd starts its time here */
const START_TIME = 1000;

/** set_seed(): the seed uniform is seed % 1000 / 100, kept above 0, which would flatten the noise */
const getShaderSeed = (seed: number) =>
  1 + (Math.abs(Math.trunc(seed)) % 900) / 100;

/** Returns the colors to put into the planet, or null for the type's own */
const getColors = (options: PlanetOptions, random: () => number) => {
  const type = PLANET_TYPES[options.type];
  if (options.colors?.length) {
    const colors = options.colors.map(parseHexColor);
    return colors.length >= getColorCount(type) && colors.every(Boolean)
      ? (colors as Color[])
      : null;
  }
  if (options.randomColors && type.randomizeColors) {
    return type.randomizeColors(random);
  }
  return null;
};

/** Returns the planet, or null if the type is unknown */
export const createPlanet = (options: PlanetOptions): Planet | null => {
  const type = PLANET_TYPES[options.type];
  if (!type) {
    return null;
  }
  const random = createRandom(options.seed);
  const pixels = Math.max(1, Math.round(options.pixels));
  const size = Math.round(pixels * type.relativeScale);
  const tilt = options.tilt ?? 0;

  const layerUniforms: Uniforms[] = type.layers.map((layer) => ({
    ...layer.uniforms,
    seed: getShaderSeed(options.seed),
    pixels: pixels * (layer.scale ?? 1),
    rotation: ((layer.uniforms.rotation as number) ?? 0) + tilt,
  }));
  type.applySeed?.(random, layerUniforms);
  const colors = getColors(options, random);
  if (colors) {
    for (const [layer, uniform, from, count] of type.colorSlots) {
      layerUniforms[layer][uniform] = colors.slice(from, from + count).flat();
    }
  }

  const drawLayers: DrawLayer[] = type.layers.map((layer, index) => {
    const layerSize = Math.round(pixels * (layer.scale ?? 1));
    const offset = Math.round((size - layerSize) / 2);
    return {
      shader: layer.shader,
      uniforms: layerUniforms[index],
      x: offset,
      y: offset,
      width: layerSize,
      height: layerSize,
    };
  });
  const baseRotations = layerUniforms.map((uniforms) => uniforms.rotation);
  const baseLights = layerUniforms.map((uniforms) => uniforms.light_origin);

  return {
    size,
    getLayers: (seconds, light) => {
      const time = START_TIME + seconds;
      type.layers.forEach((layer, index) => {
        const uniforms = layerUniforms[index];
        if (layer.time) {
          uniforms.time = layer.time(time, uniforms);
        }
        if (layer.spin) {
          uniforms.rotation =
            (baseRotations[index] as number) + time * layer.spin * Math.PI * 2;
        }
        if (layer.lit) {
          uniforms.light_origin = light ?? baseLights[index];
        }
      });
      return drawLayers;
    },
  };
};
