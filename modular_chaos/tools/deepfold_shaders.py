"""Converts the Godot canvas_item shaders of Deep-Fold's PixelPlanets and PixelSpace (both MIT) to the WebGL2 (GLSL ES 3.00)
modules of the origin picker: tgui/packages/tgui/interfaces/chaos/space/planetShaders.ts and backgroundShaders.ts.

Usage:
	git clone https://github.com/Deep-Fold/PixelPlanets <dir>/PixelPlanets
	git clone https://github.com/Deep-Fold/PixelSpace <dir>/PixelSpace
	python modular_chaos/tools/deepfold_shaders.py <dir> tgui/packages/tgui/interfaces/chaos/space
	then format the two files with prettier (tgui: bun x prettier --write packages/tgui/interfaces/chaos/space).

It also prints the shader parameters of every planet scene (.tscn) as JSON, which planetTypes.ts takes its layers from.
"""
import json
import re
import sys
from pathlib import Path

SRC = Path(sys.argv[1])
OUT = Path(sys.argv[2])

PLANETS_LICENSE = 'Copyright (c) 2020 Deep-Fold'
SPACE_LICENSE = 'Copyright (c) 2021 Deep-Fold'

MIT_BODY = '''Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.'''


def godot_value_to_ts(value):
	value = value.strip()
	if value in ('true', 'false'):
		return 1 if value == 'true' else 0
	match = re.fullmatch(r'(?:vec[234]|Vector[23]|Color|PackedColorArray|PoolColorArray|PoolRealArray)\s*\((.*)\)', value, re.S)
	if match:
		numbers = [float(part) for part in match.group(1).split(',') if part.strip()]
		if value.startswith('vec') and len(numbers) == 1:
			numbers = numbers * int(value[3])
		return numbers
	return float(value)


def float_literal_args(body):
	"""Godot converts an int literal passed to a float parameter of a shader function (Cells(uv, 10)); GLSL ES doesn't,
	and ANGLE compiles such a call into one that returns garbage. Rewrites those literals as floats."""
	signatures = {}
	for match in re.finditer(r'\b(?:float|vec[234]|bool|int|void)\s+(\w+)\s*\(([^)]*)\)\s*\{', body):
		params = [part.split() for part in match.group(2).split(',') if part.strip()]
		signatures[match.group(1)] = [param[-2] if len(param) >= 2 else '' for param in params]
	out = []
	index = 0
	call = re.compile(r'\b(' + '|'.join(map(re.escape, signatures)) + r')\s*\(') if signatures else None
	while call:
		match = call.search(body, index)
		if not match:
			break
		# skip the definitions
		before = body[max(0, match.start() - 12):match.start()]
		start = match.end()
		depth = 1
		position = start
		while depth:
			if body[position] == '(':
				depth += 1
			elif body[position] == ')':
				depth -= 1
			position += 1
		args_text = body[start:position - 1]
		out.append(body[index:start])
		if re.search(r'\b(?:float|vec[234]|bool|int|void)\s+$', before):
			out.append(args_text)
		else:
			args = []
			depth = 0
			current = ''
			for char in args_text:
				if char == ',' and depth == 0:
					args.append(current)
					current = ''
					continue
				depth += char == '('
				depth -= char == ')'
				current += char
			args.append(current)
			types = signatures[match.group(1)]
			for arg_index, arg in enumerate(args):
				if arg_index < len(types) and types[arg_index] == 'float' and re.fullmatch(r'\s*-?\d+\s*', arg):
					args[arg_index] = arg.rstrip() + '.0'
			out.append(','.join(args))
		out.append(')')
		index = position
	out.append(body[index:])
	return ''.join(out)


def convert(code):
	"""Returns (glsl, defaults) for Godot shader code"""
	defaults = {}
	lines = []
	for line in code.splitlines():
		stripped = line.strip()
		if stripped.startswith(('shader_type', 'render_mode')):
			continue
		match = re.match(r'\s*uniform\s+(\w+)(\[\d+\])?\s+(\w+)(\[\d+\])?\s*(?::[^=;]*)?(?:=\s*([^;]+))?;', line)
		if match:
			gl_type, type_array, name, name_array, default = match.groups()
			array = type_array or name_array or ''
			if default is not None:
				defaults[name] = godot_value_to_ts(default)
			lines.append(f'uniform {gl_type} {name}{array};')
			continue
		lines.append(line)
	body = '\n'.join(lines)
	body = float_literal_args(body)
	body = re.sub(r'\bvoid\s+fragment\s*\(\s*\)', 'void fragment_godot()', body)
	body = re.sub(r'\bUV\b', 'uv_godot', body)
	body = re.sub(r'\bCOLOR\b', 'color_godot', body)
	assert 'TEXTURE' not in body and 'TIME' not in re.sub(r'\w+TIME|TIME\w+', '', body), 'unsupported built-in'
	header = '#version 300 es\nprecision highp float;\nprecision highp int;\n\nin vec2 uv_godot;\nout vec4 out_color;\nvec4 color_godot;\n'
	footer = '\nvoid main() {\n\tcolor_godot = vec4(1.0);\n\tfragment_godot();\n\tout_color = vec4(color_godot.rgb * color_godot.a, color_godot.a);\n}\n'
	glsl = header + body.strip('\n') + '\n' + footer
	return glsl.replace('\r', ''), defaults


def embedded_shaders(tscn_path):
	"""Shader sub_resources of a tscn by id"""
	text = tscn_path.read_text(encoding='utf-8')
	shaders = {}
	for match in re.finditer(r'\[sub_resource type="Shader" id="?(\w+)"?\]\s*code = "(.*?)"\n', text, re.S):
		shaders[match.group(1)] = match.group(2).replace('\\"', '"')
	return shaders


def materials(tscn_path):
	"""ShaderMaterial parameters of a tscn by node name"""
	text = tscn_path.read_text(encoding='utf-8')
	params_by_id = {}
	for match in re.finditer(r'\[sub_resource type="ShaderMaterial" id="?(\w+)"?\](.*?)(?=\n\[)', text, re.S):
		params = {}
		for param in re.finditer(r'shader_param(?:eter)?/(\w+) = (.+)', match.group(2)):
			name, value = param.groups()
			if value.strip() == 'null' or 'Resource' in value:
				continue
			params[name] = godot_value_to_ts(value)
		params_by_id[match.group(1)] = params
	nodes = {}
	for match in re.finditer(r'\[node name="(\w+)" type="ColorRect"[^\]]*\](.*?)(?=\n\[|\Z)', text, re.S):
		material = re.search(r'material = SubResource\(\s*"?(\w+)"?\s*\)', match.group(2))
		if material:
			nodes[match.group(1)] = params_by_id[material.group(1)]
	return nodes


def module(shaders, copyright_line, project):
	out = [
		f'// Shaders of {project} by Deep-Fold (https://github.com/Deep-Fold/{project}), converted from Godot canvas_item',
		'// shaders to WebGL2 (GLSL ES 3.00): uniform defaults moved to the *_DEFAULTS objects (GLSL ES has no uniform',
		'// initializers), fragment() renamed to fragment_godot() and called from main(), which puts out color_godot',
		'// (Godot\'s COLOR) with premultiplied alpha, and int literals passed to float parameters of the shader functions',
		'// written as floats (Godot converts them, GLSL ES doesn\'t). The rest is as in the original. Under its license:',
		'//',
		'// MIT License',
		'//',
		f'// {copyright_line}',
		'//',
	]
	out += [f'// {line}'.rstrip() for line in MIT_BODY.splitlines()]
	out.append('')
	out.append("import type { Uniforms } from './webgl';")
	for const_name, (path, code) in shaders.items():
		glsl, defaults = convert(code)
		glsl = glsl.replace('\\', '\\\\').replace('`', '\\`').replace('${', '\\${')
		out.append('')
		out.append(f'/** {path} */')
		out.append(f'export const {const_name} = `{glsl}`;')
		out.append('')
		out.append(f'export const {const_name}_DEFAULTS: Uniforms = {json.dumps(defaults)};')
	return '\n'.join(out) + '\n'


planets = SRC / 'PixelPlanets' / 'Planets'
planet_shaders = {}
for path in sorted(planets.glob('*/*.gdshader')):
	const_name = re.sub(r'(?<!^)(?=[A-Z])', '_', path.stem).upper() + '_SHADER'
	if path.parent.name == 'LavaWorld':
		const_name = 'LAVA_RIVERS_SHADER'
	planet_shaders[const_name] = (f'Planets/{path.parent.name}/{path.name}', path.read_text(encoding='utf-8'))
planet_shaders['DRY_TERRAN_SHADER'] = ('Planets/DryTerran/DryTerran.tscn (embedded)', embedded_shaders(planets / 'DryTerran' / 'DryTerran.tscn')['1'])
planet_shaders['ICE_LAKES_SHADER'] = ('Planets/IceWorld/IceWorld.tscn (embedded)', embedded_shaders(planets / 'IceWorld' / 'IceWorld.tscn')['2'])
(OUT / 'planetShaders.ts').write_text(module(dict(sorted(planet_shaders.items())), PLANETS_LICENSE, 'PixelPlanets'), encoding='utf-8', newline='\n')

space = SRC / 'PixelSpace' / 'BackgroundGenerator'
space_shaders = {
	'NEBULAE_SHADER': ('BackgroundGenerator/Nebulae.shader', (space / 'Nebulae.shader').read_text(encoding='utf-8')),
	'STAR_STUFF_SHADER': ('BackgroundGenerator/StarStuff.shader', (space / 'StarStuff.shader').read_text(encoding='utf-8')),
	'DISTANT_PLANET_SHADER': ('BackgroundGenerator/Planet.tscn (embedded)', embedded_shaders(space / 'Planet.tscn')['1']),
}
(OUT / 'backgroundShaders.ts').write_text(module(space_shaders, SPACE_LICENSE, 'PixelSpace'), encoding='utf-8', newline='\n')

for tscn in sorted(planets.glob('*/*.tscn')):
	for node, params in materials(tscn).items():
		print(f'== {tscn.parent.name}/{node}: {json.dumps(params)}')
