"""Reading and writing BYOND .dmi files, for the scripts that convert Baystation 12 icons into this universe's.

A .dmi is a PNG sheet of 32x32 frames with a zTXt "Description" that lists its states. Needs Pillow.
"""
import os

from PIL import Image, PngImagePlugin


class State:
	def __init__(self, name, dirs=1, frames=1, delays=None, loop=0, rewind=0):
		self.name = name
		self.dirs = dirs
		self.frames = frames
		self.delays = delays
		self.loop = loop
		self.rewind = rewind
		self.images = []  # images[dir index][frame], dirs in the DMI order S, N, E, W

	def renamed(self, name, delays=None):
		copy = State(name, self.dirs, self.frames, delays or self.delays, self.loop, self.rewind)
		copy.images = self.images
		return copy


class Dmi:
	def __init__(self, states=None):
		self.states = states or []

	def get(self, name):
		for state in self.states:
			if state.name == name:
				return state
		return None

	@staticmethod
	def load(path):
		sheet = Image.open(path)
		description = sheet.info["Description"]
		sheet = sheet.convert("RGBA")
		dmi = Dmi()
		width = height = 32
		entries = []
		for line in description.splitlines():
			key, _, value = line.strip().partition(" = ")
			if key == "width":
				width = int(value)
			elif key == "height":
				height = int(value)
			elif key == "state":
				entries.append({"name": value[1:-1]})
			elif entries:
				entries[-1][key] = value
		columns = sheet.width // width
		index = 0
		for entry in entries:
			state = State(entry["name"], int(entry.get("dirs", 1)), int(entry.get("frames", 1)),
				[float(x) for x in entry["delay"].split(",")] if "delay" in entry else None,
				int(entry.get("loop", 0)), int(entry.get("rewind", 0)))
			state.images = [[None] * state.frames for _ in range(state.dirs)]
			for frame in range(state.frames):
				for dir_index in range(state.dirs):
					x, y = (index % columns) * width, (index // columns) * height
					state.images[dir_index][frame] = sheet.crop((x, y, x + width, y + height))
					index += 1
			dmi.states.append(state)
		return dmi

	def save(self, path):
		count = sum(state.dirs * state.frames for state in self.states)
		columns = max(1, round(count ** 0.5 + 0.5))
		rows = -(-count // columns)
		sheet = Image.new("RGBA", (columns * 32, rows * 32), (0, 0, 0, 0))
		lines = ["# BEGIN DMI", "version = 4.0", "\twidth = 32", "\theight = 32"]
		index = 0
		for state in self.states:
			lines += [f'state = "{state.name}"', f"\tdirs = {state.dirs}", f"\tframes = {state.frames}"]
			if state.frames > 1:
				lines.append("\tdelay = " + ",".join(f"{x:g}" for x in state.delays))
			if state.loop:
				lines.append(f"\tloop = {state.loop}")
			if state.rewind:
				lines.append(f"\trewind = {state.rewind}")
			for frame in range(state.frames):
				for dir_index in range(state.dirs):
					sheet.paste(state.images[dir_index][frame], ((index % columns) * 32, (index // columns) * 32))
					index += 1
		lines.append("# END DMI")
		info = PngImagePlugin.PngInfo()
		info.add_text("Description", "\n".join(lines) + "\n", zip=True)
		os.makedirs(os.path.dirname(path), exist_ok=True)
		sheet.save(path, format="PNG", pnginfo=info, optimize=True)


def multiply(image, color):
	"""The image with its colour channels multiplied by color, as the color var of an overlay does."""
	if image is None or color is None:
		return image
	red, green, blue = (int(color[i:i + 2], 16) for i in (1, 3, 5))
	r, g, b, a = image.split()
	return Image.merge("RGBA", (r.point(lambda v: v * red // 255), g.point(lambda v: v * green // 255),
		b.point(lambda v: v * blue // 255), a))


def stack(*layers):
	"""Layers drawn bottom to top; None ones are skipped."""
	image = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
	for item in layers:
		if item is not None:
			image.alpha_composite(item)
	return image


def make_state(name, dirs, frames, painter, delays=None, loop=0):
	"""A state whose images painter(dir index, frame) draws."""
	state = State(name, dirs, frames, delays if frames > 1 else None, loop)
	state.images = [[painter(dir_index, frame) for frame in range(frames)] for dir_index in range(dirs)]
	return state


def blank_state():
	"""The empty state that atoms drawn wholly from overlays (walls, windows) set as their icon_state."""
	return make_state("blank", 1, 1, lambda _d, _f: stack())
