// Shaders of PixelSpace by Deep-Fold (https://github.com/Deep-Fold/PixelSpace), converted from Godot canvas_item
// shaders to WebGL2 (GLSL ES 3.00): uniform defaults moved to the *_DEFAULTS objects (GLSL ES has no uniform
// initializers), fragment() renamed to fragment_godot() and called from main(), which puts out color_godot
// (Godot's COLOR) with premultiplied alpha, and int literals passed to float parameters of the shader functions
// written as floats (Godot converts them, GLSL ES doesn't). The rest is as in the original. Under its license:
//
// MIT License
//
// Copyright (c) 2021 Deep-Fold
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import type { Uniforms } from './webgl';

/** BackgroundGenerator/Nebulae.shader */
export const NEBULAE_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float pixels;
uniform sampler2D colorscheme;
uniform vec4 background_color;
uniform bool should_tile;
uniform bool reduce_background;
uniform vec2 uv_correct;

float rand(vec2 coord, float tilesize) {
	if (should_tile) {
		coord = mod(coord / uv_correct, tilesize);
	}

	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * (15.5453 + seed));
}

float noise(vec2 coord, float tilesize){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
		
	float a = rand(i, tilesize);
	float b = rand(i + vec2(1.0, 0.0), tilesize);
	float c = rand(i + vec2(0.0, 1.0), tilesize);
	float d = rand(i + vec2(1.0, 1.0), tilesize);

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord, float tilesize){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord, tilesize ) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.y+uv2.x,2.0/pixels) <= 1.0 / pixels;
}

float circleNoise(vec2 uv, float tilesize) {
	if (should_tile) {
		uv = mod(uv, tilesize / uv_correct);
	}
	
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)), tilesize);
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
}

float cloud_alpha(vec2 uv, float tilesize) {
	float c_noise = 0.0;
	
	// more iterations for more turbulence
	int iters = 2;
	for (int i = 0; i < iters; i++) {
		c_noise += circleNoise(uv * 0.5 + (float(i+1)) + vec2(-0.3, 0.0), ceil(tilesize * 0.5));
	}
	float fbm = fbm(uv+c_noise, tilesize);
	
	return fbm;
}

void fragment_godot() {
	// pixelizing and dithering
	vec2 uv = floor((uv_godot) * pixels) / pixels;
	
	// distance from center
	float d =  distance(uv, vec2(0.5)) * 0.4;
	
	uv *= uv_correct;
	bool dith = dither(uv, uv_godot);
	
	// noise for the inside of the nebulae
	float n = cloud_alpha(uv * size, size);
	float n2 = fbm(uv * size + vec2(1, 1), size);
	float n_lerp = n2 * n;
	float n_dust = cloud_alpha(uv * size, size);
	float n_dust_lerp = n_dust * n_lerp;

	// apply dithering
	if (dith) {
		n_dust_lerp *= 0.95;
		n_lerp *= 0.95;
		d*= 0.98;
	}

	// slightly offset alpha values to create thin bands around the nebulae
	float a = step(n2, 0.1 + d);
	float a2 = step(n2, 0.115 + d);
	if (should_tile) {
		a = step(n2, 0.3);
		a2 = step(n2, 0.315);
	}

	// choose colors
	if (reduce_background) {
		n_dust_lerp = pow(n_dust_lerp, 1.2) * 0.7;
	}
	float col_value = 0.0;
	if (a2 > a) {
		col_value = floor(n_dust_lerp * 35.0) / 7.0;
	} else {
		col_value = floor(n_dust_lerp * 14.0) / 7.0;
	}
	
	// apply colors
	vec3 col = texture(colorscheme, vec2(col_value, 0.0)).rgb;
	if (col_value < 0.1) {
		col = background_color.rgb;
	}

	color_godot = vec4(col, a2);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const NEBULAE_SHADER_DEFAULTS: Uniforms = {
  size: 50.0,
  pixels: 100.0,
  should_tile: 0,
  reduce_background: 0,
  uv_correct: [1.0, 1.0],
};

/** BackgroundGenerator/StarStuff.shader */
export const STAR_STUFF_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float pixels;
uniform bool should_tile;
uniform bool reduce_background;
uniform sampler2D colorscheme;
uniform vec2 uv_correct;

float rand(vec2 coord, float tilesize) {
	if (should_tile) {
		coord = mod(coord / uv_correct, tilesize );
	}

	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * (15.5453 + seed));
}

float noise(vec2 coord, float tilesize){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
		
	float a = rand(i, tilesize);
	float b = rand(i + vec2(1.0, 0.0), tilesize);
	float c = rand(i + vec2(0.0, 1.0), tilesize);
	float d = rand(i + vec2(1.0, 1.0), tilesize);

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord, float tilesize){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord, tilesize ) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.y+uv2.x,2.0/pixels) <= 1.0 / pixels;
}

float circleNoise(vec2 uv, float tilesize) {
	if (should_tile) {
		uv = mod(uv, tilesize);
	}
	
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)), tilesize);
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}


vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
}

float cloud_alpha(vec2 uv, float tilesize) {
	float c_noise = 0.0;
	
	// more iterations for more turbulence
	int iters = 2;
	for (int i = 0; i < iters; i++) {
		c_noise += circleNoise(uv * 0.5 + (float(i+1)) + vec2(-0.3, 0.0), ceil(tilesize * 0.5));
	}
	float fbm = fbm(uv+c_noise, tilesize);
	
	return fbm;
}

void fragment_godot() {
	// pixelizing and dithering
	vec2 uv = floor((uv_godot) * pixels) / pixels * uv_correct;
	bool dith = dither(uv, uv_godot);
	
	// noise for the dust
	// the + vec2(x,y) is to create an offset in noise values
	float n_alpha = fbm(uv * ceil(size * 0.5) +vec2(2,2), ceil(size * 0.5));
	float n_dust = cloud_alpha(uv * size, size);
	float n_dust2 = fbm(uv * ceil(size * 0.2)  -vec2(2,2),ceil(size * 0.2));
	float n_dust_lerp = n_dust2 * n_dust;

	// apply dithering
	if (dith) {
		n_dust_lerp *= 0.95;
	}

	// choose alpha value
	float a_dust = step(n_alpha , n_dust_lerp * 1.8);
	n_dust_lerp = pow(n_dust_lerp, 3.2) * 56.0;
	if (dith) {
		n_dust_lerp *= 1.1;
	}
	
	// choose & apply colors
	if (reduce_background) {
		n_dust_lerp = pow(n_dust_lerp, 0.8) * 0.7;
	}
	
	float col_value = floor(n_dust_lerp) / 7.0;
	vec3 col = texture(colorscheme, vec2(col_value, 0.0)).rgb;
	
	
	
	color_godot = vec4(col, a_dust);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const STAR_STUFF_SHADER_DEFAULTS: Uniforms = {
  size: 50.0,
  pixels: 100.0,
  should_tile: 0,
  reduce_background: 0,
  uv_correct: [1.0, 1.0],
};

/** BackgroundGenerator/Planet.tscn (embedded) */
export const DISTANT_PLANET_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float pixels;
uniform sampler2D colorscheme;
uniform vec2 light_origin;


float rand(vec2 coord) {
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
		
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.y+uv2.x,2.0/pixels) <= 1.0 / pixels;
}

float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
}

vec2 spherify(vec2 uv) {
	vec2 centered = uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
//	float z = pow(1.0 - dot(centered.xy, centered.xy), 0.5);
	vec2 sphere = centered/(z + 1.0);
	
	return sphere * 0.5+0.5;
}

float cloud_alpha(vec2 uv) {
	float c_noise = 0.0;
	
	// more iterations for more turbulence
	int iters = 2;
	for (int i = 0; i < iters; i++) {
		float relative = (float(i)/float(iters));
		vec2 c_uv = rotate(uv, relative * 6.28);
		c_noise += circleNoise((uv * 0.3) + (float(i+1)+10.));
	}
	float fbm = fbm(uv+c_noise);
	
	return fbm;
}


void fragment_godot() {
	/// pixelzing and dithering
	vec2 uv = floor(uv_godot * pixels) / pixels;
	bool dith = dither(uv_godot, uv);
	
	// distance from center, to create a circle
	float d_to_center = distance(uv , vec2(0.5));
	uv = spherify(uv);
	
	// distance from light source, to create shading
	float d_to_light = distance(uv, light_origin);
	// bit of contrast
	d_to_light += pow(d_to_center * 3.0, 4.0) * 0.05;
	
	// noise for the planet
	float n = fbm(uv * size);
	float n2 = fbm(uv * size + n*3.0);
	float mixed = n2 * d_to_light;
	
	// optionally create some contrast with this
//	mixed = pow(mixed, 1.0);

	// apply dithering
	if (dith) {
		mixed *= 0.95;
	}
	
	// choose and apply colors
	float col_val = floor(mixed * 15.0) / 7.0;
	vec3 col = texture(colorscheme, vec2(col_val, 0.0)).rgb;
	
	// apply alpha
	float a = step(d_to_center, 0.5);
	color_godot = vec4(col, a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const DISTANT_PLANET_SHADER_DEFAULTS: Uniforms = {
  size: 50.0,
  pixels: 100.0,
};
