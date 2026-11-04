// Planet types of PixelPlanets by Deep-Fold (https://github.com/Deep-Fold/PixelPlanets, MIT, see the license in
// planetShaders.ts). Each type is a planet scene of Planets/<Scene>/: the layers (ColorRects) of <Scene>.tscn with their
// shader parameters, and what <Scene>.gd does: update_time() for the time, set_seed() for the seed, set_colors() and
// randomize_colors() for the colors. Keys match the PLANET_TYPE_* defines of modular_chaos/code/__DEFINES/origins.dm.
import {
  type Color,
  darkened,
  generateColorscheme,
  lightened,
  shiftHue,
} from './planetColors';
import * as shaders from './planetShaders';
import { type Random, randomInt, randomRange } from './random';
import type { Uniforms } from './webgl';

type LayerType = {
  shader: string;
  /** Parameters of the layer's ShaderMaterial in the scene, over the shader's defaults */
  uniforms: Uniforms;
  /** Size of the layer to the planet; rings, disks and star flares are larger */
  scale?: number;
  /** Shader time at the planet's time in seconds, as update_time() sets it; none keeps the time uniform */
  time?: (seconds: number, uniforms: Uniforms) => number;
  /** Turns of rotation per second, for layers update_time() doesn't move */
  spin?: number;
  /** Whether set_light() sets the layer's light_origin */
  lit?: boolean;
};

/** Where set_colors() puts the colors of the flat list: the layer, the uniform, the first color and how many */
type ColorSlot = [layer: number, uniform: string, from: number, count: number];

export type PlanetType = {
  /** Size of the drawing to the planet, to fit the largest layer */
  relativeScale: number;
  layers: LayerType[];
  /** set_seed()'s changes besides the seed uniform, by layer */
  applySeed?: (random: Random, uniforms: Uniforms[]) => void;
  colorSlots: ColorSlot[];
  /** randomize_colors(): colors in the order of colorSlots */
  randomizeColors?: (random: Random) => Color[];
};

/** Godot's get_multiplier(): the planet's pattern loops in the same time whatever the layer's time_speed */
const godotTime = (factor: number) => (seconds: number, uniforms: Uniforms) =>
  seconds *
  ((Math.round(uniforms.size as number) * 2) /
    (uniforms.time_speed as number)) *
  factor;

/** Rings and disks: update_time() sets their time without get_multiplier() */
const ringTime = (seconds: number) => seconds * 314.15 * 0.004;

const withShader = (
  shader: string,
  defaults: Uniforms,
  uniforms: Uniforms,
): Pick<LayerType, 'shader' | 'uniforms'> => ({
  shader,
  uniforms: { ...defaults, ...uniforms },
});

/** set_seed() of scenes that pick a random cloud cover for their clouds */
const randomCloudCover =
  (layer: number, min: number, max: number) =>
  (random: Random, uniforms: Uniforms[]) => {
    uniforms[layer].cloud_cover = randomRange(random, min, max);
  };

/** The randomize_colors() loops that darken or lighten the seed colors by step and shift their hue */
const shades = (count: number, make: (index: number) => Color): Color[] =>
  Array.from({ length: count }, (_, index) => make(index));

export const PLANET_TYPES: Record<string, PlanetType> = {
  // Rivers ("Terran Wet" in PixelPlanets): land with rivers and clouds
  terran_wet: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.LAND_RIVERS_SHADER,
          shaders.LAND_RIVERS_SHADER_DEFAULTS,
          {
            rotation: 0.2,
            light_origin: [0.39, 0.39],
            time_speed: 0.1,
            dither_size: 3.951,
            should_dither: 1,
            light_border_1: 0.287,
            light_border_2: 0.476,
            river_cutoff: 0.368,
            // prettier-ignore
            colors: [
            0.388235, 0.670588, 0.247059, 1,
            0.231373, 0.490196, 0.309804, 1,
            0.184314, 0.341176, 0.32549, 1,
            0.156863, 0.207843, 0.25098, 1,
            0.309804, 0.643137, 0.721569, 1,
            0.25098, 0.286275, 0.45098, 1,
          ],
            size: 4.6,
            OCTAVES: 6,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(shaders.CLOUDS_SHADER, shaders.CLOUDS_SHADER_DEFAULTS, {
          rotation: 0,
          cloud_cover: 0.47,
          light_origin: [0.39, 0.39],
          time_speed: 0.1,
          stretch: 2,
          cloud_curve: 1.3,
          light_border_1: 0.52,
          light_border_2: 0.62,
          // prettier-ignore
          colors: [
            0.960784, 1, 0.909804, 1,
            0.87451, 0.878431, 0.909804, 1,
            0.407843, 0.435294, 0.6, 1,
            0.25098, 0.286275, 0.45098, 1,
          ],
          size: 7.315,
          OCTAVES: 2,
        }),
        time: godotTime(0.01),
        lit: true,
      },
    ],
    applySeed: randomCloudCover(1, 0.35, 0.6),
    colorSlots: [
      [0, 'colors', 0, 6],
      [1, 'colors', 6, 4],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        randomInt(random, 2) + 3,
        randomRange(random, 0.7, 1),
        randomRange(random, 0.45, 0.55),
      );
      const land = shades(4, (index) =>
        shiftHue(darkened(seedColors[0], index / 4), 0.2 * (index / 4)),
      );
      const rivers = shades(2, (index) =>
        shiftHue(darkened(seedColors[1], index / 2), 0.2 * (index / 2)),
      );
      const clouds = shades(4, (index) =>
        shiftHue(
          lightened(seedColors[2], (1 - index / 4) * 0.8),
          0.2 * (index / 4),
        ),
      );
      return [...land, ...rivers, ...clouds];
    },
  },

  // DryTerran ("Terran Dry"): bare land in bands of color
  terran_dry: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.DRY_TERRAN_SHADER,
          shaders.DRY_TERRAN_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0.4, 0.3],
            light_distance1: 0.362,
            light_distance2: 0.525,
            time_speed: 0.1,
            dither_size: 2,
            // prettier-ignore
            colors: [
            1, 0.537255, 0.2, 1,
            0.901961, 0.270588, 0.223529, 1,
            0.678431, 0.184314, 0.270588, 1,
            0.321569, 0.2, 0.247059, 1,
            0.239216, 0.160784, 0.211765, 1,
          ],
            n_colors: 5,
            size: 8,
            OCTAVES: 3,
            should_dither: 1,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
    ],
    colorSlots: [[0, 'colors', 0, 5]],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        5 + randomInt(random, 3),
        randomRange(random, 0.3, 0.65),
        1,
      );
      return shades(5, (index) =>
        lightened(
          darkened(seedColors[index], index / 5),
          (1 - index / 5) * 0.2,
        ),
      );
    },
  },

  // LandMasses ("Islands"): water, land masses and clouds
  islands: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.PLANET_UNDER_SHADER,
          shaders.PLANET_UNDER_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0.39, 0.39],
            time_speed: 0.1,
            dither_size: 2,
            light_border_1: 0.4,
            light_border_2: 0.6,
            // prettier-ignore
            colors: [
            0.572549, 0.909804, 0.752941, 1,
            0.309804, 0.643137, 0.721569, 1,
            0.172549, 0.207843, 0.301961, 1,
          ],
            size: 5.228,
            OCTAVES: 3,
            should_dither: 1,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(
          shaders.PLANET_LANDMASS_SHADER,
          shaders.PLANET_LANDMASS_SHADER_DEFAULTS,
          {
            rotation: 0.2,
            light_origin: [0.39, 0.39],
            time_speed: 0.2,
            dither_size: 2,
            light_border_1: 0.32,
            light_border_2: 0.534,
            land_cutoff: 0.633,
            // prettier-ignore
            colors: [
            0.784314, 0.831373, 0.364706, 1,
            0.388235, 0.670588, 0.247059, 1,
            0.184314, 0.341176, 0.32549, 1,
            0.156863, 0.207843, 0.25098, 1,
          ],
            size: 4.292,
            OCTAVES: 6,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(shaders.CLOUDS_SHADER, shaders.CLOUDS_SHADER_DEFAULTS, {
          rotation: 0,
          cloud_cover: 0.415,
          light_origin: [0.39, 0.39],
          time_speed: 0.47,
          stretch: 2,
          cloud_curve: 1.3,
          light_border_1: 0.52,
          light_border_2: 0.62,
          // prettier-ignore
          colors: [
            0.87451, 0.878431, 0.909804, 1,
            0.639216, 0.654902, 0.760784, 1,
            0.407843, 0.435294, 0.6, 1,
            0.25098, 0.286275, 0.45098, 1,
          ],
          size: 7.745,
          OCTAVES: 2,
        }),
        time: godotTime(0.01),
        lit: true,
      },
    ],
    applySeed: randomCloudCover(2, 0.35, 0.6),
    colorSlots: [
      [0, 'colors', 0, 3],
      [1, 'colors', 3, 4],
      [2, 'colors', 7, 4],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        randomInt(random, 2) + 3,
        randomRange(random, 0.7, 1),
        randomRange(random, 0.45, 0.55),
      );
      const land = shades(4, (index) =>
        shiftHue(darkened(seedColors[0], index / 4), 0.2 * (index / 4)),
      );
      const water = shades(3, (index) =>
        shiftHue(darkened(seedColors[1], index / 5), 0.1 * (index / 2)),
      );
      const clouds = shades(4, (index) =>
        shiftHue(
          lightened(seedColors[2], (1 - index / 4) * 0.8),
          0.2 * (index / 4),
        ),
      );
      return [...water, ...land, ...clouds];
    },
  },

  // NoAtmosphere: cratered rock, like a moon
  no_atmosphere: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.NO_ATMOSPHERE_SHADER,
          shaders.NO_ATMOSPHERE_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0.25, 0.25],
            time_speed: 0.4,
            dither_size: 2,
            light_border_1: 0.615,
            light_border_2: 0.729,
            // prettier-ignore
            colors: [
            0.639216, 0.654902, 0.760784, 1,
            0.298039, 0.407843, 0.521569, 1,
            0.227451, 0.247059, 0.368627, 1,
          ],
            size: 8,
            OCTAVES: 4,
            should_dither: 1,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(shaders.CRATERS_SHADER, shaders.CRATERS_SHADER_DEFAULTS, {
          rotation: 0,
          light_origin: [0.25, 0.25],
          time_speed: 0.001,
          light_border: 0.465,
          // prettier-ignore
          colors: [
            0.298039, 0.407843, 0.521569, 1,
            0.227451, 0.247059, 0.368627, 1,
          ],
          size: 5,
        }),
        time: godotTime(0.02),
        lit: true,
      },
    ],
    colorSlots: [
      [0, 'colors', 0, 3],
      [1, 'colors', 3, 2],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        3 + randomInt(random, 2),
        randomRange(random, 0.3, 0.6),
        0.7,
      );
      const colors = shades(3, (index) =>
        lightened(
          darkened(seedColors[index], index / 3),
          (1 - index / 3) * 0.2,
        ),
      );
      return [...colors, colors[1], colors[2]];
    },
  },

  // GasPlanet ("Gas giant 1"): dark lower clouds under lighter upper ones
  gas_giant: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.GAS_PLANET_SHADER,
          shaders.GAS_PLANET_SHADER_DEFAULTS,
          {
            cloud_cover: 0,
            light_origin: [0.25, 0.25],
            time_speed: 0.7,
            stretch: 1,
            cloud_curve: 1.3,
            light_border_1: 0.692,
            light_border_2: 0.666,
            rotation: 0,
            // prettier-ignore
            colors: [
            0.231373, 0.12549, 0.152941, 1,
            0.231373, 0.12549, 0.152941, 1,
            0, 0, 0, 1,
            0.129412, 0.0941176, 0.105882, 1,
          ],
            size: 9,
            OCTAVES: 5,
          },
        ),
        time: godotTime(0.005),
        lit: true,
      },
      {
        ...withShader(
          shaders.GAS_PLANET_SHADER,
          shaders.GAS_PLANET_SHADER_DEFAULTS,
          {
            cloud_cover: 0.538,
            light_origin: [0.25, 0.25],
            time_speed: 0.47,
            stretch: 1,
            cloud_curve: 1.3,
            light_border_1: 0.439,
            light_border_2: 0.746,
            rotation: 0,
            // prettier-ignore
            colors: [
            0.941176, 0.709804, 0.254902, 1,
            0.811765, 0.458824, 0.168627, 1,
            0.670588, 0.317647, 0.188235, 1,
            0.490196, 0.219608, 0.2, 1,
          ],
            size: 9,
            OCTAVES: 5,
          },
        ),
        time: godotTime(0.005),
        lit: true,
      },
    ],
    applySeed: randomCloudCover(1, 0.28, 0.5),
    colorSlots: [
      [0, 'colors', 0, 4],
      [1, 'colors', 4, 4],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        8 + randomInt(random, 4),
        randomRange(random, 0.3, 0.8),
        1,
      );
      const lower = shades(4, (index) =>
        darkened(darkened(seedColors[index], index / 6), 0.7),
      );
      const upper = shades(4, (index) =>
        lightened(
          darkened(seedColors[index + 4], index / 4),
          (1 - index / 4) * 0.5,
        ),
      );
      return [...lower, ...upper];
    },
  },

  // GasPlanetLayers ("Gas giant 2"): bands of gas and a ring
  gas_giant_ringed: {
    relativeScale: 3,
    layers: [
      {
        ...withShader(
          shaders.GAS_LAYERS_SHADER,
          shaders.GAS_LAYERS_SHADER_DEFAULTS,
          {
            rotation: 0,
            cloud_cover: 0.61,
            light_origin: [-0.1, 0.3],
            time_speed: 0.05,
            stretch: 2.204,
            cloud_curve: 1.376,
            light_border_1: 0.52,
            light_border_2: 0.62,
            bands: 0.892,
            should_dither: 1,
            n_colors: 3,
            // prettier-ignore
            colors: [
            0.933333, 0.764706, 0.603922, 1,
            0.85098, 0.627451, 0.4, 1,
            0.560784, 0.337255, 0.231373, 1,
          ],
            // prettier-ignore
            dark_colors: [
            0.4, 0.223529, 0.192157, 1,
            0.270588, 0.156863, 0.235294, 1,
            0.133333, 0.12549, 0.203922, 1,
          ],
            size: 10.107,
            OCTAVES: 3,
          },
        ),
        time: godotTime(0.004),
        lit: true,
      },
      {
        ...withShader(shaders.RING_SHADER, shaders.RING_SHADER_DEFAULTS, {
          rotation: 0.7,
          light_origin: [-0.1, 0.3],
          time_speed: 0.2,
          light_border_1: 0.52,
          light_border_2: 0.62,
          ring_width: 0.127,
          ring_perspective: 6,
          scale_rel_to_planet: 6,
          n_colors: 3,
          // prettier-ignore
          colors: [
            0.933333, 0.764706, 0.603922, 1,
            0.701961, 0.478431, 0.313726, 1,
            0.560784, 0.337255, 0.231373, 1,
          ],
          // prettier-ignore
          dark_colors: [
            0.333333, 0.188235, 0.211765, 1,
            0.196078, 0.137255, 0.215686, 1,
            0.133333, 0.12549, 0.203922, 1,
          ],
          size: 15,
          OCTAVES: 4,
        }),
        scale: 3,
        time: ringTime,
        lit: true,
      },
    ],
    colorSlots: [
      [0, 'colors', 0, 3],
      [1, 'colors', 0, 3],
      [0, 'dark_colors', 3, 3],
      [1, 'dark_colors', 3, 3],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        6 + randomInt(random, 4),
        randomRange(random, 0.3, 0.55),
        1.4,
      );
      return shades(6, (index) =>
        lightened(
          darkened(seedColors[index], index / 7),
          (1 - index / 6) * 0.3,
        ),
      );
    },
  },

  // IceWorld: ice with lakes and clouds
  ice_world: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.PLANET_UNDER_SHADER,
          shaders.PLANET_UNDER_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0.3, 0.3],
            time_speed: 0.25,
            dither_size: 2,
            light_border_1: 0.48,
            light_border_2: 0.632,
            // prettier-ignore
            colors: [
            0.980392, 1, 1, 1,
            0.780392, 0.831373, 0.882353, 1,
            0.572549, 0.560784, 0.721569, 1,
          ],
            size: 8,
            OCTAVES: 2,
            should_dither: 1,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(
          shaders.ICE_LAKES_SHADER,
          shaders.ICE_LAKES_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0.3, 0.3],
            time_speed: 0.2,
            light_border_1: 0.024,
            light_border_2: 0.047,
            lake_cutoff: 0.55,
            // prettier-ignore
            colors: [
            0.309804, 0.643137, 0.721569, 1,
            0.298039, 0.407843, 0.521569, 1,
            0.227451, 0.247059, 0.368627, 1,
          ],
            size: 10,
            OCTAVES: 3,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(shaders.CLOUDS_SHADER, shaders.CLOUDS_SHADER_DEFAULTS, {
          rotation: 0,
          cloud_cover: 0.546,
          light_origin: [0.3, 0.3],
          time_speed: 0.1,
          stretch: 2.5,
          cloud_curve: 1.3,
          light_border_1: 0.566,
          light_border_2: 0.781,
          // prettier-ignore
          colors: [
            0.882353, 0.94902, 1, 1,
            0.752941, 0.890196, 1, 1,
            0.368627, 0.439216, 0.647059, 1,
            0.25098, 0.286275, 0.45098, 1,
          ],
          size: 4,
          OCTAVES: 4,
        }),
        time: godotTime(0.01),
        lit: true,
      },
    ],
    colorSlots: [
      [0, 'colors', 0, 3],
      [1, 'colors', 3, 3],
      [2, 'colors', 6, 4],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        randomInt(random, 2) + 3,
        randomRange(random, 0.7, 1),
        randomRange(random, 0.45, 0.55),
      );
      const land = shades(3, (index) =>
        shiftHue(darkened(seedColors[0], index / 3), 0.2 * (index / 4)),
      );
      const lakes = shades(3, (index) =>
        shiftHue(darkened(seedColors[1], index / 3), 0.2 * (index / 3)),
      );
      const clouds = shades(4, (index) =>
        shiftHue(
          lightened(seedColors[2], (1 - index / 4) * 0.8),
          0.2 * (index / 4),
        ),
      );
      return [...land, ...lakes, ...clouds];
    },
  },

  // LavaWorld: dark rock with craters and rivers of lava
  lava_world: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.NO_ATMOSPHERE_SHADER,
          shaders.NO_ATMOSPHERE_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0.3, 0.3],
            time_speed: 0.2,
            dither_size: 2,
            light_border_1: 0.4,
            light_border_2: 0.6,
            // prettier-ignore
            colors: [
            0.560784, 0.301961, 0.341176, 1,
            0.321569, 0.2, 0.247059, 1,
            0.239216, 0.160784, 0.211765, 1,
          ],
            size: 10,
            OCTAVES: 3,
            should_dither: 1,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(shaders.CRATERS_SHADER, shaders.CRATERS_SHADER_DEFAULTS, {
          rotation: 0,
          light_origin: [0.3, 0.3],
          time_speed: 0.2,
          light_border: 0.4,
          // prettier-ignore
          colors: [
            0.321569, 0.2, 0.247059, 1,
            0.239216, 0.160784, 0.211765, 1,
          ],
          size: 3.5,
        }),
        time: godotTime(0.02),
        lit: true,
      },
      {
        ...withShader(
          shaders.LAVA_RIVERS_SHADER,
          shaders.LAVA_RIVERS_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0.3, 0.3],
            time_speed: 0.2,
            light_border_1: 0.019,
            light_border_2: 0.036,
            river_cutoff: 0.579,
            // prettier-ignore
            colors: [
            1, 0.537255, 0.2, 1,
            0.901961, 0.270588, 0.223529, 1,
            0.678431, 0.184314, 0.270588, 1,
          ],
            size: 10,
            OCTAVES: 4,
          },
        ),
        time: godotTime(0.02),
        lit: true,
      },
    ],
    colorSlots: [
      [0, 'colors', 0, 3],
      [1, 'colors', 3, 2],
      [2, 'colors', 5, 3],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        randomInt(random, 3) + 2,
        randomRange(random, 0.6, 1),
        randomRange(random, 0.7, 0.8),
      );
      const land = shades(3, (index) =>
        shiftHue(darkened(seedColors[0], index / 3), 0.2 * (index / 4)),
      );
      const lava = shades(3, (index) =>
        shiftHue(darkened(seedColors[1], index / 3), 0.2 * (index / 3)),
      );
      return [...land, land[1], land[2], ...lava];
    },
  },

  // Asteroid: a lumpy rock; the scene never moves it, here it turns slowly
  asteroid: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(
          shaders.ASTEROIDS_SHADER,
          shaders.ASTEROIDS_SHADER_DEFAULTS,
          {
            rotation: 0,
            light_origin: [0, 0],
            time_speed: 0.4,
            // prettier-ignore
            colors: [
            0.639216, 0.654902, 0.760784, 1,
            0.298039, 0.407843, 0.521569, 1,
            0.227451, 0.247059, 0.368627, 1,
          ],
            size: 5.294,
            octaves: 2,
            should_dither: 1,
          },
        ),
        spin: 0.02,
        lit: true,
      },
    ],
    colorSlots: [[0, 'colors', 0, 3]],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        3 + randomInt(random, 2),
        randomRange(random, 0.3, 0.6),
        0.7,
      );
      return shades(3, (index) =>
        lightened(
          darkened(seedColors[index], index / 3),
          (1 - index / 3) * 0.2,
        ),
      );
    },
  },

  // BlackHole: a black hole in an accretion disk
  black_hole: {
    relativeScale: 3,
    layers: [
      withShader(
        shaders.BLACK_HOLE_SHADER,
        shaders.BLACK_HOLE_SHADER_DEFAULTS,
        {
          // prettier-ignore
          colors: [
          0.152941, 0.152941, 0.211765, 1,
          1, 1, 0.921569, 1,
          0.929412, 0.482353, 0.223529, 1,
        ],
          radius: 0.247,
          light_width: 0.028,
        },
      ),
      {
        ...withShader(
          shaders.BLACK_HOLE_RING_SHADER,
          shaders.BLACK_HOLE_RING_SHADER_DEFAULTS,
          {
            rotation: 0.766,
            light_origin: [0.607, 0.444],
            time_speed: 0.2,
            disk_width: 0.065,
            ring_perspective: 14,
            should_dither: 1,
            // prettier-ignore
            colors: [
            1, 1, 0.921569, 1,
            1, 0.960784, 0.25098, 1,
            1, 0.721569, 0.290196, 1,
            0.929412, 0.482353, 0.223529, 1,
            0.741176, 0.25098, 0.207843, 1,
          ],
            n_colors: 5,
            size: 6.598,
            OCTAVES: 3,
          },
        ),
        scale: 3,
        time: ringTime,
      },
    ],
    colorSlots: [
      [0, 'colors', 0, 3],
      [1, 'colors', 3, 5],
    ],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        5 + randomInt(random, 2),
        randomRange(random, 0.3, 0.5),
        2,
      );
      const colors = shades(5, (index) =>
        lightened(
          darkened(seedColors[index], (index / 5) * 0.7),
          (1 - index / 5) * 0.9,
        ),
      );
      return [
        [0.152941, 0.152941, 0.211765, 1],
        colors[0],
        colors[3],
        ...colors,
      ];
    },
  },

  // Galaxy: a spiral galaxy
  galaxy: {
    relativeScale: 1,
    layers: [
      {
        ...withShader(shaders.GALAXY_SHADER, shaders.GALAXY_SHADER_DEFAULTS, {
          rotation: 0.674,
          time_speed: 1,
          dither_size: 2,
          should_dither: 1,
          // prettier-ignore
          colors: [
            1, 1, 0.921569, 1,
            1, 0.913725, 0.552941, 1,
            0.709804, 0.878431, 0.4, 1,
            0.396078, 0.647059, 0.4, 1,
            0.223529, 0.364706, 0.392157, 1,
            0.196078, 0.223529, 0.301961, 1,
            0.196078, 0.160784, 0.278431, 1,
          ],
          n_colors: 6,
          size: 7,
          OCTAVES: 1,
          tilt: 3,
          n_layers: 4,
          layer_height: 0.4,
          zoom: 1.375,
          swirl: -9,
        }),
        time: godotTime(0.04),
      },
    ],
    colorSlots: [[0, 'colors', 0, 7]],
    randomizeColors: (random) => {
      const seedColors = generateColorscheme(
        random,
        6,
        randomRange(random, 0.5, 0.8),
        1.4,
      );
      return shades(6, (index) =>
        lightened(
          darkened(seedColors[index], index / 7),
          (1 - index / 6) * 0.6,
        ),
      );
    },
  },

  // Star: the star, with blobs around it and storm flares; set_light() doesn't touch it
  star: {
    relativeScale: 2,
    layers: [
      {
        ...withShader(
          shaders.STAR_BLOBS_SHADER,
          shaders.STAR_BLOBS_SHADER_DEFAULTS,
          {
            // prettier-ignore
            colors: [
            1, 1, 0.894118, 1,
          ],
            time_speed: 0.05,
            rotation: 0,
            circle_amount: 2,
            circle_size: 1,
            size: 4.93,
            OCTAVES: 4,
          },
        ),
        scale: 2,
        time: godotTime(0.01),
      },
      {
        ...withShader(shaders.STAR_SHADER, shaders.STAR_SHADER_DEFAULTS, {
          time_speed: 0.05,
          rotation: 0,
          // prettier-ignore
          colors: [
            0.960784, 1, 0.909804, 1,
            0.466667, 0.839216, 0.756863, 1,
            0.109804, 0.572549, 0.654902, 1,
            0.0117647, 0.243137, 0.368627, 1,
          ],
          n_colors: 4,
          should_dither: 1,
          size: 4.463,
          OCTAVES: 4,
          TILES: 1,
        }),
        time: godotTime(0.005),
      },
      {
        ...withShader(
          shaders.STAR_FLARES_SHADER,
          shaders.STAR_FLARES_SHADER_DEFAULTS,
          {
            // prettier-ignore
            colors: [
            0.466667, 0.839216, 0.756863, 1,
            1, 1, 0.894118, 1,
          ],
            time_speed: 0.05,
            rotation: 0,
            should_dither: 1,
            storm_width: 0.3,
            storm_dither_width: 0,
            scale: 1,
            circle_amount: 2,
            circle_scale: 1,
            size: 1.6,
            OCTAVES: 4,
          },
        ),
        scale: 2,
        time: godotTime(0.015),
      },
    ],
    // The blobs, the star's 4 colors from the brightest, and the flares
    colorSlots: [
      [0, 'colors', 0, 1],
      [1, 'colors', 1, 4],
      [2, 'colors', 5, 2],
    ],
  },
};

/** How many colors set_colors() of the type takes */
export const getColorCount = (type: PlanetType) =>
  Math.max(...type.colorSlots.map(([, , from, count]) => from + count));
