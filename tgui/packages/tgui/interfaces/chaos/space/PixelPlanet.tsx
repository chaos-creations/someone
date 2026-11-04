// A planet of PixelPlanets (see planetTypes.ts) drawn live with WebGL2, in pixel art one canvas pixel big.
import { type CSSProperties, useEffect, useMemo, useRef } from 'react';

import { createPlanet, type PlanetOptions } from './planet';
import { drawLayers } from './webgl';

type Props = PlanetOptions & {
  /** Speed of the planet's own movement (its turn, clouds, flares), 1 for the PixelPlanets speed */
  readonly speed?: number;
  /** Returns where the light comes from each frame, as PixelPlanet light ([x, y] in the planet's UV); null for its own */
  readonly getLight?: () => number[] | null;
  /** Called if the planet can't be drawn: no WebGL2, an unknown type or a shader that doesn't compile */
  readonly onUnsupported?: () => void;
  /** Applied to the canvas, which is the planet's size times the type's relativeScale */
  readonly style?: CSSProperties;
};

/**
 * Draws the planet centered on a box of options.pixels px: put it into a positioned box of that size
 *
 * Rings and flares go out of the box.
 */
export const PixelPlanet = (props: Props) => {
  const {
    type,
    seed,
    pixels,
    colors,
    randomColors,
    tilt,
    speed = 1,
    getLight,
    onUnsupported,
    style,
  } = props;
  const canvasRef = useRef<HTMLCanvasElement>(null);
  // Callbacks change every render; the drawing loop reads the current ones
  const getLightRef = useRef(getLight);
  getLightRef.current = getLight;
  const onUnsupportedRef = useRef(onUnsupported);
  onUnsupportedRef.current = onUnsupported;

  const colorsKey = colors?.join(',');
  const planet = useMemo(
    () => createPlanet({ type, seed, pixels, colors, randomColors, tilt }),
    // colors compared by value
    [type, seed, pixels, colorsKey, randomColors, tilt],
  );

  useEffect(() => {
    const context = canvasRef.current?.getContext('2d');
    if (!planet || !context) {
      onUnsupportedRef.current?.();
      return;
    }
    let frame = 0;
    const startTime = performance.now();
    const draw = (time: number) => {
      const seconds = ((time - startTime) / 1000) * speed;
      const drawn = drawLayers(
        context,
        planet.getLayers(seconds, getLightRef.current?.() ?? null),
      );
      if (!drawn) {
        onUnsupportedRef.current?.();
        return;
      }
      frame = requestAnimationFrame(draw);
    };
    frame = requestAnimationFrame(draw);
    return () => cancelAnimationFrame(frame);
  }, [planet, speed]);

  if (!planet) {
    return null;
  }
  const offset = -(planet.size - Math.round(pixels)) / 2;
  return (
    <canvas
      ref={canvasRef}
      width={planet.size}
      height={planet.size}
      style={{
        position: 'absolute',
        left: `${offset}px`,
        top: `${offset}px`,
        width: `${planet.size}px`,
        height: `${planet.size}px`,
        imageRendering: 'pixelated',
        pointerEvents: 'none',
        ...style,
      }}
    />
  );
};
