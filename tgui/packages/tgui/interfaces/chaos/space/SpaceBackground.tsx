// A space background of PixelSpace (see background.ts) generated into a canvas, in pixel art PIXEL_SCALE px a pixel.
import { type CSSProperties, useEffect, useRef } from 'react';

import { type BackgroundOptions, drawBackground } from './background';

type Props = Omit<BackgroundOptions, 'width' | 'height'> & {
  /** Size on screen in px; the background has PIXEL_SCALE times fewer pixels */
  readonly width: number;
  readonly height: number;
  readonly style?: CSSProperties;
};

/** Screen px a background pixel is drawn as, like the 2x background picture the window had */
const PIXEL_SCALE = 2;

export const SpaceBackground = (props: Props) => {
  const { seed, colorscheme, darken, planets, width, height, style } = props;
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const colorschemeKey =
    typeof colorscheme === 'string' ? colorscheme : colorscheme.join(',');

  useEffect(() => {
    const context = canvasRef.current?.getContext('2d');
    if (!context || width <= 0 || height <= 0) {
      return;
    }
    drawBackground(context, {
      seed,
      colorscheme,
      darken,
      planets,
      width: Math.ceil(width / PIXEL_SCALE),
      height: Math.ceil(height / PIXEL_SCALE),
    });
    // colorscheme compared by value
  }, [seed, colorschemeKey, darken, planets, width, height]);

  return (
    <canvas
      ref={canvasRef}
      style={{
        width: `${width}px`,
        height: `${height}px`,
        imageRendering: 'pixelated',
        ...style,
      }}
    />
  );
};
