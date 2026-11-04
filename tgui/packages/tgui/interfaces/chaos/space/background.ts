// Space background of PixelSpace by Deep-Fold (https://github.com/Deep-Fold/PixelSpace, MIT, see the license in
// backgroundShaders.ts): BackgroundGenerator.gd's generate_new() drawn into a canvas, with a seed instead of randomize().
// The layers, from the bottom: background color, dust (StarStuff), small stars (StarParticles), nebulae, big stars
// (BigStar) and distant planets (Planet). Without WebGL2 only the color and the stars are drawn.
import { BACKGROUND_COLORSCHEMES } from './backgroundColorschemes';
import {
  DISTANT_PLANET_SHADER,
  DISTANT_PLANET_SHADER_DEFAULTS,
  NEBULAE_SHADER,
  NEBULAE_SHADER_DEFAULTS,
  STAR_STUFF_SHADER,
  STAR_STUFF_SHADER_DEFAULTS,
} from './backgroundShaders';
import { BIG_STARS_SPRITE, STARS_SPRITE } from './backgroundSprites';
import { type Color, parseHexColor } from './planetColors';
import { createRandom, type Random, randomInt, randomRange } from './random';
import { type DrawLayer, drawLayers, type Gradient } from './webgl';

export type BackgroundOptions = {
  /** Any whole number; the same seed gives the same background */
  seed: number;
  /** Size in the background's own pixels */
  width: number;
  height: number;
  /** Name of a BACKGROUND_COLORSCHEMES colorscheme, or 9 "#rrggbb" colors: the background, then the gradient */
  colorscheme: string | string[];
  /** The generator's "darken" (reduce_background): dimmer dust and nebulae */
  darken?: boolean;
  /** The generator's "planets": a few small distant planets; off unless set */
  planets?: boolean;
};

const SMALL_STAR_SIZE = 9;
const SMALL_STAR_FRAMES = 16;
const BIG_STAR_SIZE = 25;
/** BigStar.gd picks one of the first 5 big stars */
const BIG_STAR_FRAMES = 5;
/** Size of the distant planet sprite (100x100.png) before its scale */
const DISTANT_PLANET_SPRITE = 100;
/** Gradient steps the sprites pick from: round(value * 7) / 7 */
const GRADIENT_STEPS = 7;

const DEFAULT_COLORSCHEME = 'NYX8';

const loadImage = (source: string) =>
  new Promise<HTMLImageElement>((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = reject;
    image.src = source;
  });

const createCanvas = (width: number, height: number) => {
  const canvas = document.createElement('canvas');
  canvas.width = Math.max(1, Math.round(width));
  canvas.height = Math.max(1, Math.round(height));
  return canvas;
};

/** Returns the background color and the 8 gradient colors of the colorscheme, the default one if it is unknown */
const getColors = (colorscheme: BackgroundOptions['colorscheme']) => {
  const hexes =
    typeof colorscheme === 'string'
      ? BACKGROUND_COLORSCHEMES[colorscheme]
      : colorscheme;
  const colors = (hexes ?? []).map(parseHexColor);
  if (colors.length !== 9 || !colors.every(Boolean)) {
    return getColors(DEFAULT_COLORSCHEME);
  }
  return {
    background: colors[0] as Color,
    gradient: colors.slice(1) as Color[],
  };
};

/** Recolors a sprite pixel by pixel; recolor returns [r, g, b, a] from 0 to 255 for a source pixel */
const recolorSprite = (
  image: HTMLImageElement,
  recolor: (red: number, alpha: number) => number[],
) => {
  const canvas = createCanvas(image.width, image.height);
  const context = canvas.getContext('2d') as CanvasRenderingContext2D;
  context.drawImage(image, 0, 0);
  const pixels = context.getImageData(0, 0, canvas.width, canvas.height);
  const data = pixels.data;
  for (let index = 0; index < data.length; index += 4) {
    const [red, green, blue, alpha] = recolor(data[index], data[index + 3]);
    data[index] = red;
    data[index + 1] = green;
    data[index + 2] = blue;
    data[index + 3] = alpha;
  }
  context.putImageData(pixels, 0, 0);
  return canvas;
};

const to255 = (color: Color) =>
  color.map((channel) => Math.round(channel * 255));

/** Draws a full-size shader layer over the background; does nothing without WebGL2 */
const drawShaderLayer = (
  target: CanvasRenderingContext2D,
  layer: Omit<DrawLayer, 'x' | 'y' | 'width' | 'height'>,
  x: number,
  y: number,
  width: number,
  height: number,
) => {
  const canvas = createCanvas(width, height);
  const context = canvas.getContext('2d');
  if (
    context &&
    drawLayers(context, [
      { ...layer, x: 0, y: 0, width: canvas.width, height: canvas.height },
    ])
  ) {
    target.drawImage(canvas, Math.round(x), Math.round(y));
  }
};

/** A random point of the background (generate_new() without tiling places everything so) */
const randomPoint = (random: Random, width: number, height: number) => [
  Math.floor(randomRange(random, 0, width)),
  Math.floor(randomRange(random, 0, height)),
];

/** Draws the background into the canvas of the context, which is resized to the background's size */
export const drawBackground = async (
  target: CanvasRenderingContext2D,
  options: BackgroundOptions,
) => {
  const [smallStars, bigStars] = await Promise.all([
    loadImage(STARS_SPRITE),
    loadImage(BIG_STARS_SPRITE),
  ]);
  const width = Math.max(1, Math.round(options.width));
  const height = Math.max(1, Math.round(options.height));
  target.canvas.width = width;
  target.canvas.height = height;
  const random = createRandom(options.seed);
  const { background, gradient } = getColors(options.colorscheme);
  const gradients: Record<string, Gradient> = { colorscheme: gradient };
  const darken = options.darken ? 1 : 0;
  const pixels = Math.max(width, height);
  const uvCorrect = width > height ? [width / height, 1] : [1, height / width];

  target.fillStyle = `rgb(${to255(background).slice(0, 3).join(',')})`;
  target.fillRect(0, 0, width, height);

  // Dust
  drawShaderLayer(
    target,
    {
      shader: STAR_STUFF_SHADER,
      uniforms: {
        ...STAR_STUFF_SHADER_DEFAULTS,
        size: 10,
        OCTAVES: 8,
        seed: randomRange(random, 1, 10),
        pixels,
        uv_correct: uvCorrect,
        should_tile: 0,
        reduce_background: darken,
      },
      gradients,
    },
    0,
    0,
    width,
    height,
  );

  // Small stars: generate_new() spawns this many particles, each a random star tinted with a random gradient color
  const nebulaeSeed = randomRange(random, 1, 10);
  const particleArea = (width * height) / 150;
  const particles =
    randomInt(random, Math.max(1, Math.floor(particleArea * 0.75))) +
    Math.floor(particleArea * 0.25);
  const tintedStars = gradient.slice(0, GRADIENT_STEPS).map((color) => {
    const [red, green, blue] = to255(color);
    return recolorSprite(smallStars, (value, alpha) => [
      (value * red) / 255,
      (value * green) / 255,
      (value * blue) / 255,
      alpha,
    ]);
  });
  for (let index = 0; index < particles; index++) {
    const [x, y] = randomPoint(random, width, height);
    const frame = randomInt(random, SMALL_STAR_FRAMES);
    const sprite = tintedStars[randomInt(random, GRADIENT_STEPS)];
    target.drawImage(
      sprite,
      frame * SMALL_STAR_SIZE,
      0,
      SMALL_STAR_SIZE,
      SMALL_STAR_SIZE,
      x - Math.floor(SMALL_STAR_SIZE / 2),
      y - Math.floor(SMALL_STAR_SIZE / 2),
      SMALL_STAR_SIZE,
      SMALL_STAR_SIZE,
    );
  }

  // Nebulae; the material keeps should_tile on until the generator's tile toggle turns it off
  drawShaderLayer(
    target,
    {
      shader: NEBULAE_SHADER,
      uniforms: {
        ...NEBULAE_SHADER_DEFAULTS,
        size: 5,
        OCTAVES: 3,
        seed: nebulaeSeed,
        pixels,
        uv_correct: uvCorrect,
        background_color: background,
        should_tile: 1,
        reduce_background: darken,
      },
      gradients,
    },
    0,
    0,
    width,
    height,
  );

  // Distant planets, made before the big stars as generate_new() does and drawn over them
  const planetCount = randomInt(random, 5);
  const planets = Array.from({ length: planetCount }, () => {
    const scale =
      randomRange(random, 0.2, 0.7) *
      randomRange(random, 0.5, 1) *
      Math.min(width, height) *
      0.005;
    const [x, y] = randomPoint(random, width, height);
    return {
      scale,
      x,
      y,
      seed: randomRange(random, 1, 10),
      light: [randomRange(random, 0, 1), randomRange(random, 0, 1)],
    };
  });

  // Big stars, gray levels turned into gradient colors
  const recoloredBigStars = recolorSprite(bigStars, (value, alpha) => [
    ...to255(gradient[Math.round((value / 255) * GRADIENT_STEPS)]).slice(0, 3),
    alpha,
  ]);
  const bigStarCount = randomInt(
    random,
    Math.max(1, Math.floor(Math.max(width, height) / 20)),
  );
  for (let index = 0; index < bigStarCount; index++) {
    const [x, y] = randomPoint(random, width, height);
    const frame = randomInt(random, BIG_STAR_FRAMES);
    target.drawImage(
      recoloredBigStars,
      frame * BIG_STAR_SIZE,
      0,
      BIG_STAR_SIZE,
      BIG_STAR_SIZE,
      x - Math.floor(BIG_STAR_SIZE / 2),
      y - Math.floor(BIG_STAR_SIZE / 2),
      BIG_STAR_SIZE,
      BIG_STAR_SIZE,
    );
  }

  if (!options.planets) {
    return;
  }
  for (const planet of planets) {
    const size = Math.round(DISTANT_PLANET_SPRITE * planet.scale);
    drawShaderLayer(
      target,
      {
        shader: DISTANT_PLANET_SHADER,
        uniforms: {
          ...DISTANT_PLANET_SHADER_DEFAULTS,
          size: 5.365,
          OCTAVES: 3,
          seed: planet.seed,
          pixels: Math.floor(planet.scale * DISTANT_PLANET_SPRITE),
          light_origin: planet.light,
        },
        gradients,
      },
      planet.x - size / 2,
      planet.y - size / 2,
      size,
      size,
    );
  }
};
