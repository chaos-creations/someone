// Shaders of PixelPlanets by Deep-Fold (https://github.com/Deep-Fold/PixelPlanets), converted from Godot canvas_item
// shaders to WebGL2 (GLSL ES 3.00): uniform defaults moved to the *_DEFAULTS objects (GLSL ES has no uniform
// initializers), fragment() renamed to fragment_godot() and called from main(), which puts out color_godot
// (Godot's COLOR) with premultiplied alpha, and int literals passed to float parameters of the shader functions
// written as floats (Godot converts them, GLSL ES doesn't). The rest is as in the original. Under its license:
//
// MIT License
//
// Copyright (c) 2020 Deep-Fold
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

/** Planets/Asteroids/Asteroids.gdshader */
export const ASTEROIDS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform vec4 colors[3];
uniform float size;
uniform int octaves;
uniform float seed;
uniform bool should_dither;

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

	for(int i = 0; i < octaves ; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return m = smoothstep(r-.10*r,r,m);
}

float crater(vec2 uv) {
	float c = 1.0;
	for (int i = 0; i < 2; i++) {
		c *= circleNoise((uv * size) + (float(i+1)+10.));
	}
	return 1.0 - c;
}

void fragment_godot() {
	//pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	// we use this val later to interpolate between shades
	bool dith = dither(uv, uv_godot);
	
	// distance from center
	float d = distance(uv, vec2(0.5));
	
	// optional rotation, do this after the dither or the dither will look very messed up
	uv = rotate(uv, rotation);
	
	// two noise values with one slightly offset according to light source, to create shadows later
	float n = fbm(uv * size);
	float n2 = fbm(uv * size + (rotate(light_origin, rotation)-0.5) * 0.5);
	
	// step noise values to determine where the edge of the asteroid is
	// step cutoff value depends on distance from center
	float n_step = step(0.2, n - d);
	float n2_step = step(0.2, n2 - d);
	
	// with this val we can determine where the shadows should be
	float noise_rel = (n2_step + n2) - (n_step + n);
	
	// two crater values, again one extra for the shadows
	float c1 = crater(uv );
	float c2 = crater(uv + (light_origin-0.5)*0.03);

	// now we just assign colors depending on noise values and crater values
	// base
	vec4 col = colors[1];
	
	// noise
	if (noise_rel < -0.06 || (noise_rel < -0.04 && (dith || !should_dither))) {
		col = colors[0];
	}
	if (noise_rel > 0.05 || (noise_rel > 0.03 && (dith || !should_dither))) {
		col = colors[2];
	}
	
	// crater
	if (c1 > 0.4)  {
		col = colors[1];
	}
	if (c2<c1) {
		col = colors[2];
	}
	
	color_godot = vec4(col.rgb, n_step * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const ASTEROIDS_SHADER_DEFAULTS: Uniforms = {
  rotation: 1.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  size: 50.0,
  should_dither: 1,
};

/** Planets/BlackHole/BlackHoleRing.gdshader */
export const BLACK_HOLE_RING_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float disk_width;
uniform float ring_perspective;
uniform bool should_dither;
uniform vec4 colors[5];
uniform int n_colors;

uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;

float rand(vec2 coord) {
	coord = mod(coord, vec2(2.0,1.0)*round(size));
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

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

bool dither(vec2 uv_pixel, vec2 uv_real) {
	return mod(uv_pixel.x+uv_real.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	// we use this value later to dither between colors
	bool dith = dither(uv_godot, uv);
	
	uv = rotate(uv, rotation);
	
	// keep an undistored version of the current uvs
	vec2 uv2 = uv;
	
	// compress uv along the x axis, or the accretion disk will look to stretched out
	uv.x -= 0.5;
	uv.x *= 1.3;
	uv.x += 0.5;
	
	// add a bit of movement to the accretion disk by wobbling it, completely optional and can be disabled.
	uv = rotate(uv, sin(time * time_speed * 2.0) * 0.01);
	
	// l_origin will be used to determine how to color the pixels
	vec2 l_origin = vec2(0.5);
	// d_width will be the final width of the accretion disk
	float d_width = disk_width;
	
	// here we distort the uvs to achieve the shape of the accretion disk
	if (uv.y < 0.5) { 
		// if we are in the top half of the image, then add to the uv.y based on how close we are to the center
		uv.y += smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
		// and also the ring width has to be adjusted or it will look to stretched out
		d_width += smoothstep(distance(vec2(0.5), uv), 0.5, 0.3);
		
		// another optional thing that changes the color distribution, I like it, but can be disabled.
		l_origin.y -= smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
	} 
	// we don't check for exactly uv.y > 0.5 because we want a small area where the ring
	// is unaffected by stretching, the middle part that goes over the black hole.
	else if (uv.y > 0.53) {

		// same steps as before, but uv.y and light is stretched the other way, the disk width is slightly smaller here for visual effect.
		uv.y -= smoothstep(distance(vec2(0.5), uv), 0.4, 0.17);
		d_width += smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
		l_origin.y += smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
	}
	
	// get distance to light origin based on unaltered uv's we saved earlier, some math to account for perspective
	float light_d = distance(uv2 * vec2(1.0, ring_perspective), l_origin * vec2(1.0, ring_perspective)) * 0.3;

	// center is used to determine ring position
	vec2 uv_center = uv - vec2(0.0, 0.5);

	// tilt ring
	uv_center *= vec2(1.0, ring_perspective);
	float center_d = distance(uv_center,vec2(0.5, 0.0));
	
	// cut out 2 circles of different sizes and only intersection of the 2.
	// this actually makes the disk
	float disk = smoothstep(0.1-d_width*2.0, 0.5-d_width, center_d);
	disk *= smoothstep(center_d-d_width, center_d, 0.4);
	
	// rotate noise in the disk
	uv_center = rotate(uv_center+vec2(0, 0.5), time*time_speed*3.0);
	
	// some noise
	disk *= pow(fbm(uv_center*size), 0.5);
	
	// apply dithering
	if (dith || !should_dither) {
		disk *= 1.2;
	}
	
	// apply some colors based on final value
	float n_posterized = float(n_colors - 1);
	float posterized = floor((disk+light_d)*n_posterized);
	posterized = min(posterized, n_posterized);
	vec4 col = colors[int(posterized)];
	
	// this can be toggled on to achieve a more "realistic" black hole, with red and blue shifting. This was just me messing around so can probably be more optimized and done cleaner
	//col.rgb *= 1.0 - pow(uv.x, 1.0);
	//col.gb *= 1.0 - pow(uv.x, 2.0);
	//col.b *= 3.0 - pow(uv.x, 4.0);
	//col.gb *= 2.0 - pow(uv.x, 2.0);
	//col.rgb *= pow(uv.x, 0.15);
	
	float disk_a = step(0.15, disk);
	color_godot = vec4(col.rgb, disk_a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const BLACK_HOLE_RING_SHADER_DEFAULTS: Uniforms = {
  pixels: 100.0,
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  disk_width: 0.1,
  ring_perspective: 4.0,
  should_dither: 1,
  n_colors: 5.0,
  size: 50.0,
  time: 0.0,
};

/** Planets/BlackHole/BlackHole.gdshader */
export const BLACK_HOLE_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;

uniform vec4 colors[3];

uniform float radius;
uniform float light_width;


void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	// distance from center
	float d_to_center = distance(uv, vec2(0.5));
	
	vec4 col = colors[0];	
	if (d_to_center > radius - light_width) {
		col = colors[1];
	}	
	if (d_to_center > radius - light_width * 0.5) {
		col = colors[2];
	}
	
	float a = step(d_to_center, radius);
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const BLACK_HOLE_SHADER_DEFAULTS: Uniforms = {
  pixels: 100.0,
  radius: 0.5,
  light_width: 0.05,
};

/** Planets/LandMasses/Clouds.gdshader */
export const CLOUDS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform float cloud_cover;
uniform vec2 light_origin;
uniform float time_speed;
uniform float stretch;
uniform float cloud_curve;
uniform float light_border_1;
uniform float light_border_2;

uniform vec4 colors[4];

uniform float size;
uniform int OCTAVES;
uniform float seed;

uniform float time;

float rand(vec2 coord) {
	coord = mod(coord, vec2(1.0,1.0)*round(size));
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


// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

float cloud_alpha(vec2 uv) {
	float c_noise = 0.0;
	
	// more iterations for more turbulence
	for (int i = 0; i < 9; i++) {
		c_noise += circleNoise((uv * size * 0.3) + (float(i+1)+10.) + (vec2(time*time_speed, 0.0)));
	}
	float fbm = fbm(uv*size+c_noise + vec2(time*time_speed, 0.0));
	
	return fbm;//step(a_cutoff, fbm);
}

bool dither(vec2 uv_pixel, vec2 uv_real) {
	return mod(uv_pixel.x+uv_real.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	// distance to light source
	float d_light = distance(uv , light_origin);
	
	
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(length(uv-vec2(0.5)), 0.49999);
	// cut out a circle
	float d_to_center = distance(uv, vec2(0.5));
	
	uv = rotate(uv, rotation);
	
	// map to sphere
	uv = spherify(uv);
	// slightly make uv go down on the right, and up in the left
	uv.y += smoothstep(0.0, cloud_curve, abs(uv.x-0.4));
	
	
	float c = cloud_alpha(uv*vec2(1.0, stretch));
	
	// assign some colors based on cloud depth & distance from light
	vec4 col = colors[0];
	if (c < cloud_cover + 0.03) {
		col = colors[1];
	}
	if (d_light + c*0.2 > light_border_1) {
		col = colors[2];

	}
	if (d_light + c*0.2 > light_border_2) {
		col = colors[3];
	}
	
	c *= step(d_to_center, 0.5);
	color_godot = vec4(col.rgb, step(cloud_cover, c) * a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const CLOUDS_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  stretch: 2.0,
  cloud_curve: 1.3,
  light_border_1: 0.52,
  light_border_2: 0.62,
  size: 50.0,
  time: 0.0,
};

/** Planets/NoAtmosphere/Craters.gdshader */
export const CRATERS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float light_border;
uniform vec4 colors[2];
uniform float size;
uniform float seed;
uniform float time;

float rand(vec2 coord) {
	coord = mod(coord, vec2(1.0,1.0)*round(size));
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return m = smoothstep(r-.10*r,r,m);
}

float crater(vec2 uv) {
	float c = 1.0;
	for (int i = 0; i < 2; i++) {
		c *= circleNoise((uv * size) + (float(i+1)+10.) + vec2(time*time_speed,0.0));
	}
	return 1.0 - c;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	//pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	// check distance from center & distance to light
	float d_circle = distance(uv, vec2(0.5));
	float d_light = distance(uv , vec2(light_origin));
	// cut out a circle
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	uv = rotate(uv, rotation);
	uv = spherify(uv);
		
	float c1 = crater(uv );
	float c2 = crater(uv +(light_origin-0.5)*0.03);
	vec4 col = colors[0];
	
	a *= step(0.5, c1);
	if (c2<c1-(0.5-d_light)*2.0) {
		col = colors[1];
	}
	if (d_light > light_border) {
		col = colors[1];
	} 

	// cut out a circle
	a*= step(d_circle, 0.5);
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const CRATERS_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  light_border: 0.4,
  size: 50.0,
  time: 0.0,
};

/** Planets/DryTerran/DryTerran.tscn (embedded) */
export const DRY_TERRAN_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float light_distance1;
uniform float light_distance2;
uniform float time_speed;
uniform float dither_size;
uniform vec4 colors[5];
uniform int n_colors;
uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;
uniform bool should_dither;

float rand(vec2 coord) {
	// land has to be tiled
	// tiling only works for integer values, thus the rounding
	// it would probably be better to only allow integer sizes
	// multiply by vec2(2,1) to simulate planet having another side
	coord = mod(coord, vec2(2.0,1.0)*round(size));
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 43758.5453 * seed);
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
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}


void fragment_godot() {
	//pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	bool dith = dither(uv, uv_godot);
	
	// cut out a circle
	float d_circle = distance(uv, vec2(0.5));
	float a = step(d_circle, 0.49999);
	
	uv = spherify(uv);
	
	// check distance distance to light
	float d_light = distance(uv , vec2(light_origin));
	
	uv = rotate(uv, rotation);
	
	// noise
	float f = fbm(uv*size+vec2(time*time_speed, 0.0));
	
	// remap light
	d_light = smoothstep(-0.3, 1.2, d_light);
	
	if (d_light < light_distance1) {
		d_light *= 0.9;
	}
	if (d_light < light_distance2) {
		d_light *= 0.9;
	}
	
	
	float c = d_light*pow(f,0.8)*3.5; // change the magic nums here for different light strengths
	
	// apply dithering
	if (dith || !should_dither) {
		c += 0.02;
		c *= 1.05;
	}
	
	// now we can assign colors based on distance to light origin
	float posterize = floor(c*4.0)/4.0;
	posterize = min(posterize, 1.0);
	vec4 col = colors[int(posterize * float(n_colors-1))];
	
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const DRY_TERRAN_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  light_distance1: 0.5,
  light_distance2: 0.75,
  time_speed: 0.2,
  dither_size: 2.0,
  n_colors: 5.0,
  size: 50.0,
  time: 0.0,
  should_dither: 1,
};

/** Planets/Galaxy/Galaxy.gdshader */
export const GALAXY_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform float time_speed;
uniform float dither_size;
uniform bool should_dither;
uniform vec4 colors[7];
uniform int n_colors;

uniform float size;
uniform int OCTAVES;
uniform float seed;

uniform float time;
uniform float tilt;
uniform float n_layers;
uniform float layer_height;
uniform float zoom;
uniform float swirl;

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

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

void fragment_godot() {
	vec2 uv = uv_godot;
	uv = floor(uv * pixels) / pixels;
	bool dith = dither(uv, uv_godot);
	
	// I added a little zooming functionality so I dont have to mess with other values to get correct sizing.
	uv *= zoom;
	uv -= (zoom - 1.0) / 2.0;
	
	// overall rotation of galaxy
	uv = rotate(uv, rotation);
	vec2 uv2 = uv; // save a copy of untranslated uv for later

	// this uv is used to determine where the "layers" will be
	uv.y *= tilt;
	uv.y -= (tilt - 1.0) / 2.0;

	float d_to_center = distance(uv, vec2(0.5, 0.5));
	// swirl uv around the center, the further from the center the more rotated.
	float rot = swirl * pow(d_to_center, 0.4);
	vec2 rotated_uv = rotate(uv, rot + time * time_speed);

	// fbm will decide where the layers are
	float f1 = fbm(rotated_uv * size);
	// quantize to a few different values, so layers don't blur through each other
	f1 = floor(f1 * n_layers) / n_layers;

	// use the unaltered second uv for the actual galaxy
	// tilt so it looks like it's an angle.
	uv2.y *= tilt;
	uv2.y -= (tilt - 1.0) / 2.0 + f1 * layer_height;

	// now do the same stuff as before, but for the actual galaxy image, not the layers
	float d_to_center2 = distance(uv2, vec2(0.5, 0.5));
    float rot2 = swirl * pow(d_to_center2, 0.4);
	vec2 rotated_uv2 = rotate(uv2, rot2 + time * time_speed);
	// I offset the second fbm by some amount so the don't all use the same noise, try it wihout and the layers are very obvious
	float f2 = fbm(rotated_uv2 * size + vec2(f1) * 10.0);

	// alpha
	float a = step(f2 + d_to_center2, 0.7);
	
	// some final steps to choose a nice color
	f2 *= 2.3;
	if(should_dither && dith) { // dithering
		f2 *= 0.94;
	}

	f2 = floor(f2 * (float(n_colors)));
	f2 = min(f2, float(n_colors));
	vec4 col = colors[int(f2)];
	
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const GALAXY_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  time_speed: 0.2,
  dither_size: 2.0,
  should_dither: 1,
  n_colors: 6.0,
  size: 50.0,
  time: 0.0,
  tilt: 4.0,
  n_layers: 4.0,
  layer_height: 0.4,
  zoom: 2.0,
  swirl: -9.0,
};

/** Planets/GasPlanetLayers/GasLayers.gdshader */
export const GAS_LAYERS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform float cloud_cover;
uniform vec2 light_origin;
uniform float time_speed;
uniform float stretch;
uniform float cloud_curve;
uniform float light_border_1;
uniform float light_border_2;
uniform float bands;
uniform bool should_dither;

uniform int n_colors;
uniform vec4 colors[3];
uniform vec4 dark_colors[3];

uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;

float rand(vec2 coord) {
	coord = mod(coord, vec2(2.0,1.0)*round(size));
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

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

float turbulence(vec2 uv) {
	float c_noise = 0.0;
	
	
	// more iterations for more turbulence
	for (int i = 0; i < 10; i++) {
		c_noise += circleNoise((uv * size *0.3) + (float(i+1)+10.) + (vec2(time * time_speed, 0.0)));
	}
	return c_noise;
}

bool dither(vec2 uv_pixel, vec2 uv_real) {
	return mod(uv_pixel.x+uv_real.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	float light_d = distance(uv, light_origin);
	
	// we use this value later to dither between colors
	bool dith = dither(uv, uv_godot);
	
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(length(uv-vec2(0.5)), 0.49999);
	
	// rotate planet
	uv = rotate(uv, rotation);
	
	// map to sphere
	uv = spherify(uv);

	// a band is just one dimensional noise
	float band = fbm(vec2(0.0, uv.y*size*bands));
	
	// turbulence value is circles on top of each other
	float turb = turbulence(uv);

	// by layering multiple noise values & combining with turbulence and bands
	// we get some dynamic looking shape	
	float fbm1 = fbm(uv*size);
	float fbm2 = fbm(uv*vec2(1.0, 2.0)*size+fbm1+vec2(-time*time_speed,0.0)+turb);
	
	// all of this is just increasing some contrast & applying light
	fbm2 *= pow(band,2.0)*7.0;
	float light = fbm2 + light_d*1.8;
	fbm2 += pow(light_d, 1.0)-0.3;
	fbm2 = smoothstep(-0.2, 4.0-fbm2, light);
	
	// apply the dither value
	if (dith && should_dither) {
		fbm2 *= 1.1;
	}
	
	// finally add colors
	float posterized = floor(fbm2*4.0)/2.0;
	vec4 col = vec4(vec3(0.0), 1.0);
	if (fbm2 < 0.625) {
		col = colors[int(posterized * float(n_colors - 1))];
	} else {
		col = dark_colors[int((posterized-1.0) * float(n_colors - 1))];
	}
		
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const GAS_LAYERS_SHADER_DEFAULTS: Uniforms = {
  pixels: 100.0,
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  stretch: 2.0,
  cloud_curve: 1.3,
  light_border_1: 0.52,
  light_border_2: 0.62,
  bands: 1.0,
  should_dither: 1,
  n_colors: 3.0,
  size: 50.0,
  time: 0.0,
};

/** Planets/GasPlanet/GasPlanet.gdshader */
export const GAS_PLANET_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float cloud_cover;
uniform vec2 light_origin;
uniform float time_speed;
uniform float stretch;
uniform float cloud_curve;
uniform float light_border_1;
uniform float light_border_2;
uniform float rotation;

uniform vec4 colors[4];

uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;

float rand(vec2 coord) {
	coord = mod(coord, vec2(1.0,1.0)*round(size));
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

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

float cloud_alpha(vec2 uv) {
	float c_noise = 0.0;
	
	// more iterations for more turbulence
	for (int i = 0; i < 9; i++) {
		c_noise += circleNoise((uv * size * 0.3) + (float(i+1)+10.) + (vec2(time*time_speed, 0.0)));
	}
	float fbm = fbm(uv*size+c_noise + vec2(time*time_speed, 0.0));
	
	return fbm;//step(a_cutoff, fbm);
}

bool dither(vec2 uv_pixel, vec2 uv_real) {
	return mod(uv_pixel.x+uv_real.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	// distance to light source
	float d_light = distance(uv , light_origin);
	
	// cut out a circle
	float d_circle = distance(uv, vec2(0.5));
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	uv = rotate(uv, rotation);
	
	// map to sphere
	uv = spherify(uv);
	
	// slightly make uv go down on the right, and up in the left
	uv.y += smoothstep(0.0, cloud_curve, abs(uv.x-0.4));
	
	float c = cloud_alpha(uv*vec2(1.0, stretch));
	
	// assign some colors based on cloud depth & distance from light
	vec4 col = colors[0];
	if (c < cloud_cover + 0.03) {
		col = colors[1];
	}
	if (d_light + c*0.2 > light_border_1) {
		col = colors[2];
	}
	if (d_light + c*0.2 > light_border_2) {
		col = colors[3];
	}
	
	color_godot = vec4(col.rgb, step(cloud_cover, c) * a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const GAS_PLANET_SHADER_DEFAULTS: Uniforms = {
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  stretch: 2.0,
  cloud_curve: 1.3,
  light_border_1: 0.52,
  light_border_2: 0.62,
  rotation: 0.0,
  size: 50.0,
  time: 0.0,
};

/** Planets/IceWorld/IceWorld.tscn (embedded) */
export const ICE_LAKES_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float light_border_1;
uniform float light_border_2;
uniform float lake_cutoff;

uniform vec4 colors[3];

uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;


float rand(vec2 coord) {
	coord = mod(coord, vec2(2.0,1.0)*round(size));
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 43758.5453 * seed);
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

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	float d_light = distance(uv , light_origin);
	
	// give planet a tilt
	uv = rotate(uv, rotation);
	float d_circle = distance(uv, vec2(0.5));
//	// map to sphere
	uv = spherify(uv);
	
	// some scrolling noise for landmasses
	float fbm1 = fbm(uv*size+vec2(time*time_speed,0.0));
	float lake = fbm(uv*size+vec2(time*time_speed,0.0));
	
	// increase contrast on d_light
	d_light = pow(d_light, 2.0)*0.4;
	d_light -= d_light * lake;

	
	vec4 col = colors[0];
	if (d_light > light_border_1) {
		col = colors[1];
	}
	if (d_light > light_border_2) {
		col = colors[2];
	}
	
	float a = step(lake_cutoff, lake);
	a *= step(d_circle, 0.5);
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const ICE_LAKES_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  light_border_1: 0.4,
  light_border_2: 0.5,
  size: 50.0,
  time: 0.0,
};

/** Planets/Rivers/LandRivers.gdshader */
export const LAND_RIVERS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float dither_size;
uniform bool should_dither;
uniform float light_border_1;
uniform float light_border_2;
uniform float river_cutoff;

uniform vec4 colors[6];

uniform float size;
uniform int OCTAVES;
uniform float seed;

uniform float time;


float rand(vec2 coord) {
	// land has to be tiled (or the contintents on this planet have to be changing very fast)
	// tiling only works for integer values, thus the rounding
	// it would probably be better to only allow integer sizes
	// multiply by vec2(2,1) to simulate planet having another side
	coord = mod(coord, vec2(2.0,1.0)*round(size));
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

vec2 spherify(vec2 uv) {
	vec2 centered = uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
//	float z = pow(1.0 - dot(centered.xy, centered.xy), 0.5);
	vec2 sphere = centered/(z + 1.0);
	
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	bool dith = dither(uv, uv_godot);
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(length(uv-vec2(0.5)), 0.49999);
	
	// map to sphere
	uv = spherify(uv);
	float d_light = distance(uv , light_origin);
	
	// give planet a tilt
	uv = rotate(uv, rotation);
	
	// some scrolling noise for landmasses
	vec2 base_fbm_uv = (uv)*size+vec2(time*time_speed,0.0);
	
	// use multiple fbm's at different places so we can determine what color land gets
	float fbm1 = fbm(base_fbm_uv);
	float fbm2 = fbm(base_fbm_uv - light_origin*fbm1);
	float fbm3 = fbm(base_fbm_uv - light_origin*1.5*fbm1);
	float fbm4 = fbm(base_fbm_uv - light_origin*2.0*fbm1);
	
	float river_fbm = fbm(base_fbm_uv+fbm1*6.0);
	river_fbm = step(river_cutoff, river_fbm);
	
	// size of edge in which colors should be dithered
	float dither_border = (1.0/pixels)*dither_size;
	// lots of magic numbers here
	// you can mess with them, it changes the color distribution
	if (d_light < light_border_1) {
		fbm4 *= 0.9;
	}
	if (d_light > light_border_1) {
		fbm2 *= 1.05;
		fbm3 *= 1.05;
		fbm4 *= 1.05;
	} 
	if (d_light > light_border_2) {
		fbm2 *= 1.3;
		fbm3 *= 1.4;
		fbm4 *= 1.8;
		
		if (d_light < light_border_2 + dither_border) {
			if (dith || !should_dither) {
				fbm4 *= 0.5;
			}
		}
		
	} 
	
	// increase contrast on d_light
	d_light = pow(d_light, 2.0)*0.4;
	vec4 col = colors[3];
	if (fbm4 + d_light < fbm1*1.5) {
		col = colors[2];
	}
	if (fbm3 + d_light < fbm1*1.0) {
		col = colors[1];
	}
	if (fbm2 + d_light < fbm1) {
		col = colors[0];
	}
	if (river_fbm < fbm1*0.5) {
		col = colors[5];
		if (fbm4 + d_light < fbm1*1.5) {
			col = colors[4];
		}
	}

	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const LAND_RIVERS_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  dither_size: 2.0,
  should_dither: 1,
  light_border_1: 0.4,
  light_border_2: 0.5,
  size: 50.0,
  time: 0.0,
};

/** Planets/LavaWorld/Rivers.gdshader */
export const LAVA_RIVERS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float light_border_1;
uniform float light_border_2;
uniform float river_cutoff;

uniform vec4 colors[3];

uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;


float rand(vec2 coord) {
	coord = mod(coord, vec2(2.0,1.0)*round(size));
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

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	float d_light = distance(uv , light_origin);
	
	// cut out a circle
	float d_circle = distance(uv, vec2(0.5));
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	// give planet a tilt
	uv = rotate(uv, rotation);
	
	// map to sphere
	uv = spherify(uv);
	
	// some scrolling noise for landmasses
	float fbm1 = fbm(uv*size+vec2(time*time_speed,0.0));
	float river_fbm = fbm(uv + fbm1*2.5);
	
	// increase contrast on d_light
	d_light = pow(d_light, 2.0)*0.4;
	d_light -= d_light * river_fbm;
	
	river_fbm = step(river_cutoff, river_fbm);
	
	// apply colors
	vec4 col = colors[0];
	if (d_light > light_border_1) {
		col = colors[1];
	}
	if (d_light > light_border_2) {
		col = colors[2];
	}
	
	a *= step(river_cutoff, river_fbm);
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const LAVA_RIVERS_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  light_border_1: 0.4,
  light_border_2: 0.5,
  size: 50.0,
  time: 0.0,
};

/** Planets/NoAtmosphere/NoAtmosphere.gdshader */
export const NO_ATMOSPHERE_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float dither_size;
uniform float light_border_1;
uniform float light_border_2;
uniform vec4 colors[3];
uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;
uniform bool should_dither;

float rand(vec2 coord) {
	coord = mod(coord, vec2(1.0,1.0)*round(size));
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
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	//pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	// check distance from center & distance to light
	float d_circle = distance(uv, vec2(0.5));
	float d_light = distance(uv , vec2(light_origin));
	// cut out a circle
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	bool dith = dither(uv ,uv_godot);
	uv = rotate(uv, rotation);

	// get a noise value with light distance added
	// this creates a moving dynamic shape
	float fbm1 = fbm(uv);
	d_light += fbm(uv*size+fbm1+vec2(time*time_speed, 0.0))*0.3; // change the magic 0.3 here for different light strengths
	
	// size of edge in which colors should be dithered
	float dither_border = (1.0/pixels)*dither_size;

	// now we can assign colors based on distance to light origin
	vec4 col = colors[0];
	if (d_light > light_border_1) {
		col = colors[1];
		if (d_light < light_border_1 + dither_border && (dith || !should_dither)) {
			col = colors[0];
		}
	}
	if (d_light > light_border_2) {
		col = colors[2];
		if (d_light < light_border_2 + dither_border && (dith || !should_dither)) {
			col = colors[1];
		}
	}
	
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const NO_ATMOSPHERE_SHADER_DEFAULTS: Uniforms = {
  rotation: 1.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  dither_size: 2.0,
  light_border_1: 0.4,
  light_border_2: 0.6,
  size: 50.0,
  time: 0.0,
  should_dither: 1,
};

/** Planets/LandMasses/PlanetLandmass.gdshader */
export const PLANET_LANDMASS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float dither_size;
uniform float light_border_1;
uniform float light_border_2;
uniform float land_cutoff;

uniform vec4 colors[4];

uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;


float rand(vec2 coord) {
	// land has to be tiled (or the contintents on this planet have to be changing very fast)
	// tiling only works for integer values, thus the rounding
	// it would probably be better to only allow integer sizes
	// multiply by vec2(2,1) to simulate planet having another side
	coord = mod(coord, vec2(2.0,1.0)*round(size));
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

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	float d_light = distance(uv , light_origin);
	// cut out a circle
	float d_circle = distance(uv, vec2(0.5));
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	// give planet a tilt
	uv = rotate(uv, rotation);
	
	// map to sphere
	uv = spherify(uv);
	
	// some scrolling noise for landmasses
	vec2 base_fbm_uv = (uv)*size+vec2(time*time_speed,0.0);
	
	// use multiple fbm's at different places so we can determine what color land gets
	float fbm1 = fbm(base_fbm_uv);
	float fbm2 = fbm(base_fbm_uv - light_origin*fbm1);
	float fbm3 = fbm(base_fbm_uv - light_origin*1.5*fbm1);
	float fbm4 = fbm(base_fbm_uv - light_origin*2.0*fbm1);
	
	// lots of magic numbers here
	// you can mess with them, it changes the color distribution
	if (d_light < light_border_1) {
		fbm4 *= 0.9;
	}
	if (d_light > light_border_1) {
		fbm2 *= 1.05;
		fbm3 *= 1.05;
		fbm4 *= 1.05;
	} 
	if (d_light > light_border_2) {
		fbm2 *= 1.3;
		fbm3 *= 1.4;
		fbm4 *= 1.8;
	} 
	
	// increase contrast on d_light
	d_light = pow(d_light, 2.0)*0.1;
	vec4 col = colors[3];
	// assign colors based on if there is noise to the top-left of noise
	// and also based on how far noise is from light
	if (fbm4 + d_light < fbm1) {
		col = colors[2];
	}
	if (fbm3 + d_light < fbm1) {
		col = colors[1];
	}
	if (fbm2 + d_light < fbm1) {
		col = colors[0];
	}
	
	color_godot = vec4(col.rgb, step(land_cutoff, fbm1) * a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const PLANET_LANDMASS_SHADER_DEFAULTS: Uniforms = {
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  dither_size: 2.0,
  light_border_1: 0.4,
  light_border_2: 0.5,
  size: 50.0,
  time: 0.0,
};

/** Planets/LandMasses/PlanetUnder.gdshader */
export const PLANET_UNDER_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float dither_size;
uniform float light_border_1;
uniform float light_border_2;
uniform vec4 colors[3];
uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;
uniform bool should_dither;

float rand(vec2 coord) {
	// land has to be tiled
	// tiling only works for integer values, thus the rounding
	// it would probably be better to only allow integer sizes
	// multiply by vec2(2,1) to simulate planet having another side
	coord = mod(coord, vec2(2.0,1.0)*round(size));
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
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}


void fragment_godot() {
	//pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	bool dith = dither(uv, uv_godot);
	
	// check distance distance to light
	float d_light = distance(uv , vec2(light_origin));
	
	// cut out a circle
	float d_circle = distance(uv, vec2(0.5));
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(d_circle, 0.49999);
	
	uv = spherify(uv);
	uv = rotate(uv, rotation);
	
	// get a noise value with light distance added
	d_light += fbm(uv*size+vec2(time*time_speed, 0.0))*0.3; // change the magic 0.3 here for different light strengths
	
	// size of edge in which colors should be dithered
	float dither_border = (1.0/pixels)*dither_size;

	// now we can assign colors based on distance to light origin
	vec4 col = colors[0];
	if (d_light > light_border_1) {
		col = colors[1];
		if (d_light < light_border_1 + dither_border && (dith || !should_dither)) {
			col = colors[0];
		}
	}
	if (d_light > light_border_2) {
		col = colors[2];
		if (d_light < light_border_2 + dither_border && (dith || !should_dither)) {
			col = colors[1];
		}
	}
	
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const PLANET_UNDER_SHADER_DEFAULTS: Uniforms = {
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  dither_size: 2.0,
  light_border_1: 0.4,
  light_border_2: 0.6,
  size: 50.0,
  time: 0.0,
  should_dither: 1,
};

/** Planets/GasPlanetLayers/Ring.gdshader */
export const RING_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float rotation;
uniform vec2 light_origin;
uniform float time_speed;
uniform float light_border_1;
uniform float light_border_2;
uniform float ring_width;
uniform float ring_perspective;
uniform float scale_rel_to_planet;

uniform int n_colors;
uniform vec4 colors[3];
uniform vec4 dark_colors[3];

uniform float size;
uniform int OCTAVES;
uniform float seed;
uniform float time;

float rand(vec2 coord) {
	coord = mod(coord, vec2(2.0,1.0)*round(size));
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

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 uv = floor(uv_godot*pixels)/pixels;
	
	float light_d = distance(uv, light_origin);
	uv = rotate(uv, rotation);
	
	// center is used to determine ring position
	vec2 uv_center = uv - vec2(0.0, 0.5);
	
	// tilt ring
	uv_center *= vec2(1.0, ring_perspective);
	float center_d = distance(uv_center,vec2(0.5, 0.0));
	
	
	// cut out 2 circles of different sizes and only intersection of the 2.
	float ring = smoothstep(0.5-ring_width*2.0, 0.5-ring_width, center_d);
	ring *= smoothstep(center_d-ring_width, center_d, 0.4);
	
	// pretend like the ring goes behind the planet by removing it if it's in the upper half.
	if (uv.y < 0.5) {
		ring *= step(1.0/scale_rel_to_planet, distance(uv,vec2(0.5)));
	}
	
	// rotate material in the ring
	uv_center = rotate(uv_center+vec2(0, 0.5), time*time_speed);
	// some noise
	ring *= fbm(uv_center*size);
	
	// apply some colors based on final value
	float posterized = floor((ring+pow(light_d, 2.0)*2.0)*4.0)/4.0;
	posterized = min(posterized, 2.0);
	vec4 col;
	if (posterized <= 1.0) {
		col = colors[int(posterized * float(n_colors - 1))];
	} else {
		col = dark_colors[int((posterized-1.0) * float(n_colors - 1))];
	}
	
	float ring_a = step(0.28, ring);
	color_godot = vec4(col.rgb, ring_a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const RING_SHADER_DEFAULTS: Uniforms = {
  pixels: 100.0,
  rotation: 0.0,
  light_origin: [0.39, 0.39],
  time_speed: 0.2,
  light_border_1: 0.52,
  light_border_2: 0.62,
  ring_width: 0.1,
  ring_perspective: 4.0,
  scale_rel_to_planet: 6.0,
  n_colors: 3.0,
  size: 50.0,
  time: 0.0,
};

/** Planets/Star/StarBlobs.gdshader */
export const STAR_BLOBS_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform vec4 colors[1];
uniform float time_speed;
uniform float time;
uniform float rotation;


uniform float seed;
uniform float circle_amount;
uniform float circle_size;

uniform float size;
uniform int OCTAVES;


float rand(vec2 co){
	co = mod(co, vec2(1.0,1.0)*round(size));
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}


vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
}

float circle(vec2 uv) {
	float invert = 1.0 / circle_amount;
	
	if (mod(uv.y, invert*2.0) < invert) {
		uv.x += invert*0.5;
	}
	vec2 rand_co = floor(uv*circle_amount)/circle_amount;
	uv = mod(uv, invert)*circle_amount;
	
	float r = rand(rand_co);
	r = clamp(r, invert, 1.0 - invert);
	float circle = distance(uv, vec2(r));
	return smoothstep(circle, circle+0.5, invert * circle_size * rand(rand_co*1.5));
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
	float scl = 0.5;

	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord) * scl;
		coord *= 2.0;
		scl *= 0.5;
	}
	return value;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

void fragment_godot() {
	vec2 pixelized = floor(uv_godot*pixels)/pixels;

	vec2 uv = rotate(pixelized, rotation);

	// angle from centered uv's
	float angle = atan(uv.x - 0.5, uv.y - 0.5);
	float d = distance(pixelized, vec2(0.5));
	
	
	float c = 0.0;
	for(int i = 0; i < 15; i++) {
		float r = rand(vec2(float(i)));
		vec2 circleUV = vec2(d, angle);
		c += circle(circleUV*size -time * time_speed - (1.0/d) * 0.1 + r);
	}
	
	c *= 0.37 - d;
	c = step(0.07, c - d);
	
	color_godot = vec4(colors[0].rgb, c * colors[0].a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const STAR_BLOBS_SHADER_DEFAULTS: Uniforms = {
  time_speed: 0.05,
  time: 0.0,
  rotation: 0.0,
  circle_amount: 5.0,
  circle_size: 1.0,
  size: 50.0,
};

/** Planets/Star/StarFlares.gdshader */
export const STAR_FLARES_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform vec4 colors[2];
uniform float time_speed;
uniform float time;
uniform float rotation;
uniform bool should_dither;

uniform float storm_width;
uniform float storm_dither_width;

uniform float scale;
uniform float seed;
uniform float circle_amount;
uniform float circle_scale;

uniform float size;
uniform int OCTAVES;


float rand(vec2 co){
	co = mod(co, vec2(1.0,1.0)*round(size));
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}


vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
}

float circle(vec2 uv) {
	float invert = 1.0 / circle_amount;
	
	if (mod(uv.y, invert*2.0) < invert) {
		uv.x += invert*0.5;
	}
	vec2 rand_co = floor(uv*circle_amount)/circle_amount;
	uv = mod(uv, invert)*circle_amount;
	
	float r = rand(rand_co);
	r = clamp(r, invert, 1.0 - invert);
	float circle = distance(uv, vec2(r));
	return smoothstep(circle, circle+0.5, invert * circle_scale * rand(rand_co*1.5));
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
	float scl = 0.5;

	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord) * scl;
		coord *= 2.0;
		scl *= 0.5;
	}
	return value;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}


void fragment_godot() {
	// pixelize uv
	vec2 pixelized = floor(uv_godot*pixels)/pixels;
	
	// use dither val later to interpolate between alpha
	bool dith = dither(uv_godot, pixelized);
	
	pixelized = rotate(pixelized, rotation);
	
	// counter rotation against rotation caused by the way uv's are made later
	vec2 uv = pixelized;//rotate(pixelized, -time  * time_speed);
	
	// angle from centered uv's
	float angle = atan(uv.x - 0.5, uv.y - 0.5) * 0.4;
	// distance from center
	float d = distance(pixelized, vec2(0.5));
	
	// we make uv circular here to have eternally outward moving stuff
	vec2 circleUV = vec2(d, angle);
	
	// two types of noise values
	float n = fbm(circleUV*size -time * time_speed);
	float nc = circle(circleUV*scale -time * time_speed + n);
	
	nc *= 1.5;
	float n2 = fbm(circleUV*size -time + vec2(100, 100));
	nc -= n2 * 0.1;
	
	// our alpha, default 0
	float a = 0.0;
	if (1.0 - d > nc) {
		// now we generate very thin strips of positive alpha if our noise has certain values and is close enough to center
		if (nc > storm_width - storm_dither_width + d && (dith || !should_dither)) {
			a = 1.0;
		} else if (nc > storm_width + d) { // could use an or statement instead, but this looks more clear to me
			a = 1.0;
		}
	}
	
	// use our two noise values to assign colors
	float interpolate = floor(n2 + nc);
	vec4 col = colors[int(interpolate)];
	
	// final step to not have everything appear from the center
	a *= step(n2 * 0.25, d);
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const STAR_FLARES_SHADER_DEFAULTS: Uniforms = {
  time_speed: 0.05,
  rotation: 0.0,
  should_dither: 1,
  storm_width: 0.3,
  storm_dither_width: 0.07,
  scale: 1.0,
  circle_amount: 5.0,
  circle_scale: 1.0,
  size: 50.0,
};

/** Planets/Star/Star.gdshader */
export const STAR_SHADER = `#version 300 es
precision highp float;
precision highp int;

in vec2 uv_godot;
out vec4 out_color;
vec4 color_godot;
uniform float pixels;
uniform float time_speed;
uniform float time;
uniform float rotation;
uniform vec4 colors[4];
uniform int n_colors;
uniform bool should_dither;

uniform float seed;
uniform float size;
uniform int OCTAVES;
uniform float TILES;


float rand(vec2 co) {
	co = mod(co, vec2(1.0,1.0)*round(size));
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}

vec2 rotate(vec2 vec, float angle) {
	vec -=vec2(0.5);
	vec *= mat2(vec2(cos(angle),-sin(angle)), vec2(sin(angle),cos(angle)));
	vec += vec2(0.5);
	return vec;
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

vec2 Hash2(vec2 p) {
	float r = 523.0*sin(dot(p, vec2(53.3158, 43.6143)));
	return vec2(fract(15.32354 * r), fract(17.25865 * r));
	
}

// Tileable cell noise by Dave_Hoskins from shadertoy: https://www.shadertoy.com/view/4djGRh
float Cells(in vec2 p, in float numCells) {
	p *= numCells;
	float d = 1.0e10;
	for (int xo = -1; xo <= 1; xo++)
	{
		for (int yo = -1; yo <= 1; yo++)
		{
			vec2 tp = floor(p) + vec2(float(xo), float(yo));
			tp = p - tp - Hash2(mod(tp, numCells / TILES));
			d = min(d, dot(tp, tp));
		}
	}
	return sqrt(d);
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

void fragment_godot() {
	// pixelize uv
	vec2 pixelized = floor(uv_godot*pixels)/pixels;
	
	// cut out a circle
	// stepping over 0.5 instead of 0.49999 makes some pixels a little buggy
	float a = step(distance(pixelized, vec2(0.5)), .49999);
	
	// use dither val later to mix between colors
	bool dith = dither(uv_godot, pixelized);
	
	pixelized = rotate(pixelized, rotation);
	
	// spherify has to go after dither
	pixelized = spherify(pixelized);
	
	// use two different sized cells for some variation
	float n = Cells(pixelized - vec2(time * time_speed * 2.0, 0), 10.0);
	n *= Cells(pixelized - vec2(time * time_speed * 1.0, 0), 20.0);

	
	// adjust cell value to get better looking stuff
	n*= 2.;
	n = clamp(n, 0.0, 1.0);
	if (dith || !should_dither) { // here we dither
		n *= 1.3;
	}
	
	// constrain values 4 possibilities and then choose color based on those
	float interpolate = floor(n * float(n_colors - 1)) / float(n_colors - 1);
	vec4 col = colors[int(interpolate * float(n_colors-1))];
	
	color_godot = vec4(col.rgb, a * col.a);
}

void main() {
	color_godot = vec4(1.0);
	fragment_godot();
	out_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);
}
`;

export const STAR_SHADER_DEFAULTS: Uniforms = {
  time_speed: 0.05,
  rotation: 0.0,
  n_colors: 4.0,
  should_dither: 1,
  size: 50.0,
};
