// One WebGL2 context shared by everything the window draws with shaders (planets, the star, the background).
// A layer is drawn into a region of the shared canvas and copied from there into the 2D canvas it belongs to,
// so any number of planets needs one context (browsers keep about 16 per page).

/** Shader uniforms by name: a number for float, int and bool, an array for vectors and vector arrays (flattened) */
export type Uniforms = Record<string, number | number[]>;

/** Colors of a gradient texture for a sampler2D uniform, at even steps from 0 to 1, as [r, g, b, a] from 0 to 1 */
export type Gradient = number[][];

export type DrawLayer = {
  /** Fragment shader source; the vertex shader passes uv_godot (0,0 at the top left) */
  shader: string;
  uniforms: Uniforms;
  /** Gradients of the sampler2D uniforms by name */
  gradients?: Record<string, Gradient>;
  /** Where the layer goes in the target canvas, in px */
  x: number;
  y: number;
  width: number;
  height: number;
};

type Program = {
  program: WebGLProgram;
  /** Active uniforms by name ("colors" for "colors[0]") */
  uniforms: Map<string, { location: WebGLUniformLocation; type: number }>;
  position: number;
};

type SharedContext = {
  canvas: HTMLCanvasElement;
  gl: WebGL2RenderingContext;
  programs: Map<string, Program | null>;
  textures: Map<string, WebGLTexture>;
  quad: WebGLBuffer;
};

/** Width of the gradient textures in texels */
const GRADIENT_WIDTH = 256;

const VERTEX_SHADER = `#version 300 es
in vec2 position;
out vec2 uv_godot;

void main() {
	uv_godot = vec2(position.x * 0.5 + 0.5, 0.5 - position.y * 0.5);
	gl_Position = vec4(position, 0.0, 1.0);
}
`;

let shared: SharedContext | null | undefined;

/** Returns the shared context, or null if the browser has no WebGL2 */
const getSharedContext = () => {
  if (shared !== undefined) {
    return shared;
  }
  const canvas = document.createElement('canvas');
  const gl = canvas.getContext('webgl2', {
    premultipliedAlpha: true,
    preserveDrawingBuffer: true,
    antialias: false,
  });
  const quad = gl?.createBuffer();
  if (!gl || !quad) {
    shared = null;
    return shared;
  }
  gl.bindBuffer(gl.ARRAY_BUFFER, quad);
  gl.bufferData(
    gl.ARRAY_BUFFER,
    new Float32Array([-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]),
    gl.STATIC_DRAW,
  );
  shared = { canvas, gl, programs: new Map(), textures: new Map(), quad };
  return shared;
};

/** Whether the browser of the window can draw with shaders */
export const isWebGL2Supported = () => !!getSharedContext();

const compileShader = (
  gl: WebGL2RenderingContext,
  type: number,
  source: string,
) => {
  const shader = gl.createShader(type);
  if (!shader) {
    return null;
  }
  gl.shaderSource(shader, source);
  gl.compileShader(shader);
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.error('Shader compilation:', gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
    return null;
  }
  return shader;
};

/** Returns the linked program of the fragment shader, compiled once per source; null if it doesn't compile */
const getProgram = (context: SharedContext, source: string) => {
  const { gl, programs } = context;
  const cached = programs.get(source);
  if (cached !== undefined) {
    return cached;
  }
  const vertex = compileShader(gl, gl.VERTEX_SHADER, VERTEX_SHADER);
  const fragment = compileShader(gl, gl.FRAGMENT_SHADER, source);
  let program: WebGLProgram | null = gl.createProgram();
  if (program && vertex && fragment) {
    gl.attachShader(program, vertex);
    gl.attachShader(program, fragment);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      console.error('Shader linking:', gl.getProgramInfoLog(program));
      gl.deleteProgram(program);
      program = null;
    }
  }
  if (vertex) {
    gl.deleteShader(vertex);
  }
  if (fragment) {
    gl.deleteShader(fragment);
  }
  if (!program) {
    programs.set(source, null);
    return null;
  }
  const uniforms: Program['uniforms'] = new Map();
  const count = gl.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
  for (let index = 0; index < count; index++) {
    const info = gl.getActiveUniform(program, index);
    const location = info && gl.getUniformLocation(program, info.name);
    if (info && location) {
      uniforms.set(info.name.replace(/\[0\]$/, ''), {
        location,
        type: info.type,
      });
    }
  }
  const linked = {
    program,
    uniforms,
    position: gl.getAttribLocation(program, 'position'),
  };
  programs.set(source, linked);
  return linked;
};

/** Returns the texture of the gradient, made once per gradient; colors are interpolated linearly */
const getGradientTexture = (context: SharedContext, gradient: Gradient) => {
  const { gl, textures } = context;
  const key = JSON.stringify(gradient);
  const cached = textures.get(key);
  if (cached) {
    return cached;
  }
  const data = new Uint8Array(GRADIENT_WIDTH * 4);
  const steps = gradient.length - 1;
  for (let texel = 0; texel < GRADIENT_WIDTH; texel++) {
    const position = steps > 0 ? (texel / (GRADIENT_WIDTH - 1)) * steps : 0;
    const from = gradient[Math.floor(position)];
    const to = gradient[Math.min(Math.floor(position) + 1, steps)];
    const part = position - Math.floor(position);
    for (let channel = 0; channel < 4; channel++) {
      const value = from[channel] + (to[channel] - from[channel]) * part;
      data[texel * 4 + channel] = Math.round(value * 255);
    }
  }
  const texture = gl.createTexture();
  if (!texture) {
    return null;
  }
  gl.bindTexture(gl.TEXTURE_2D, texture);
  gl.texImage2D(
    gl.TEXTURE_2D,
    0,
    gl.RGBA,
    GRADIENT_WIDTH,
    1,
    0,
    gl.RGBA,
    gl.UNSIGNED_BYTE,
    data,
  );
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  textures.set(key, texture);
  return texture;
};

const setUniforms = (
  context: SharedContext,
  program: Program,
  layer: DrawLayer,
) => {
  const { gl } = context;
  let textureUnit = 0;
  program.uniforms.forEach(({ location, type }, name) => {
    if (type === gl.SAMPLER_2D) {
      const gradient = layer.gradients?.[name];
      const texture = gradient && getGradientTexture(context, gradient);
      if (texture) {
        gl.activeTexture(gl.TEXTURE0 + textureUnit);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.uniform1i(location, textureUnit);
        textureUnit++;
      }
      return;
    }
    const value = layer.uniforms[name];
    if (value === undefined) {
      return;
    }
    const values = typeof value === 'number' ? [value] : value;
    switch (type) {
      case gl.INT:
      case gl.BOOL:
        gl.uniform1i(location, Math.trunc(values[0]));
        break;
      case gl.FLOAT:
        gl.uniform1f(location, values[0]);
        break;
      case gl.FLOAT_VEC2:
        gl.uniform2fv(location, values);
        break;
      case gl.FLOAT_VEC3:
        gl.uniform3fv(location, values);
        break;
      case gl.FLOAT_VEC4:
        gl.uniform4fv(location, values);
        break;
    }
  });
};

/**
 * Draws the layers over each other, the first one at the bottom, into the 2D canvas, replacing what was there
 *
 * Returns false if it can't: no WebGL2, or a shader doesn't compile.
 */
export const drawLayers = (
  target: CanvasRenderingContext2D,
  layers: DrawLayer[],
) => {
  const context = getSharedContext();
  if (!context) {
    return false;
  }
  const { canvas, gl } = context;
  const programs = layers.map((layer) => getProgram(context, layer.shader));
  if (programs.some((program) => !program)) {
    return false;
  }

  const width = target.canvas.width;
  const height = target.canvas.height;
  // The shared canvas only grows, as resizing it is slow
  if (canvas.width < width || canvas.height < height) {
    canvas.width = Math.max(canvas.width, width);
    canvas.height = Math.max(canvas.height, height);
  }
  // Draws at the top left of the shared canvas; WebGL counts y from the bottom
  const top = canvas.height - height;
  gl.viewport(0, top, width, height);
  gl.enable(gl.SCISSOR_TEST);
  gl.scissor(0, top, width, height);
  gl.clearColor(0, 0, 0, 0);
  gl.clear(gl.COLOR_BUFFER_BIT);
  gl.enable(gl.BLEND);
  // The shaders put out premultiplied alpha
  gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA);
  gl.bindBuffer(gl.ARRAY_BUFFER, context.quad);

  layers.forEach((layer, index) => {
    const program = programs[index] as Program;
    gl.viewport(
      layer.x,
      canvas.height - layer.y - layer.height,
      layer.width,
      layer.height,
    );
    gl.useProgram(program.program);
    gl.enableVertexAttribArray(program.position);
    gl.vertexAttribPointer(program.position, 2, gl.FLOAT, false, 0, 0);
    setUniforms(context, program, layer);
    gl.drawArrays(gl.TRIANGLES, 0, 6);
  });
  gl.disable(gl.SCISSOR_TEST);

  target.clearRect(0, 0, width, height);
  target.drawImage(canvas, 0, 0, width, height, 0, 0, width, height);
  return true;
};
