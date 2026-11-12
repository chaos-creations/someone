"""Converts the walls, windows and doors of Baystation 12 into the icons of this universe.

Bay draws these at runtime from greyscale layers that it colours with the paint of the type: wall masks, low wall
frames and glass, airlock panels and stripes. The code here does the same, so the layers are copied greyscale; this
script only renames their states to the ones the CM types use, and lines up the airlock layers so that each has every
state of the door (an overlay without an icon_state shows the state its door shows, flicks included). It writes, under
icons/:

- turf/walls/walls.dmi: the wall masks of steel and titanium walls and their map editor states;
- turf/walls/windows.dmi: low wall frames and the reinforced glass on them;
- obj/structures/doors/airlocks/<frame>/: for each airlock frame, door.dmi (the frame, its panel and welds) and the
  layers drawn over it: lights.dmi (bolt, deny and opening lights, sparks, the panel while opening) and the paint
  layers Bay has for that frame;
- obj/structures/doors/airlocks/previews.dmi and the preview states of windows.dmi: the colour schemes of the types,
  baked, for the map editor only;
- obj/structures/doors/firedoor.dmi and blastdoors_shutters.dmi: firedoors, blast doors and shutters, renamed only.

Usage: python bake_structures.py <Baystation 12 checkout>
Needs Pillow. It overwrites the files it writes. The colours of the previews must match the types in
code/game/machinery/doors/bay_doors.dm and code/game/objects/structures/bay_windows.dm.
"""
import os
import sys

from PIL import Image, PngImagePlugin

BAY = os.path.join(sys.argv[1], "icons") if len(sys.argv) > 1 else sys.exit(__doc__)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons")

GLASS_COLOR = "#aaccff"
# Bay plays the opening and closing of airlocks and firedoors at 2 ds a frame; here at 1, which openspeed matches
ANIMATION_DELAY = 1


# --- DMI files -----------------------------------------------------------------------------------------------------

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


_loaded = {}


def source(path):
	if path not in _loaded:
		_loaded[path] = Dmi.load(os.path.join(BAY, path))
	return _loaded[path]


def layer(path, state_name, dir_index, frame):
	"""A frame of a source state, clamping the dir and frame to what it has; None if there is no such state."""
	state = source(path).get(state_name)
	if state is None:
		return None
	return state.images[min(dir_index, state.dirs - 1)][min(frame, state.frames - 1)]


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


def write(dmi, path):
	dmi.save(os.path.join(OUT, path))
	print(f"wrote {path}: {len(dmi.states)} states")


# --- Walls ---------------------------------------------------------------------------------------------------------

def bake_walls():
	masks = source("turf/wall_masks.dmi")
	dmi = Dmi([blank_state()])
	# The map editor states, which the types colour through their color var
	dmi.states += [masks.get(name) for name in ("generic", "r_generic", "titanium", "r_titanium")]
	for prefix in ("solid", "solid_paint", "solid_stripe", "solid_other", "reinf_over", "metal", "metal_paint"):
		dmi.states += [masks.get(f"{prefix}{corner_state}") for corner_state in range(8)]
	dmi.states.append(masks.get("reinf_metal"))
	write(dmi, "turf/walls/walls.dmi")


# --- Windows -------------------------------------------------------------------------------------------------------

WALL_FRAME = "obj/structures/wall_frame.dmi"
WINDOW = "obj/structures/window.dmi"

# preview state prefix, frame colour; /obj/structure/window/framed/bay and its /hull
WINDOW_PREVIEWS = [
	("", "#545c68"),
	("hull_", "#436b8e"),
]


def bake_windows():
	frames = source(WALL_FRAME)
	windows = source(WINDOW)
	dmi = Dmi([blank_state()])
	for prefix, frame_color in WINDOW_PREVIEWS:
		def isolated(with_glass):
			return lambda _d, _f: stack(*(multiply(layer(WALL_FRAME, "frame0", d, 0), frame_color) for d in range(4)),
				*(multiply(layer(WINDOW, "rwindow_onframe0", d, 0), GLASS_COLOR) for d in range(4) if with_glass))
		dmi.states.append(make_state(f"{prefix}frame", 1, 1, isolated(False)))
		dmi.states.append(make_state(f"{prefix}rwindow", 1, 1, isolated(True)))
	for kind in ("frame", "frame_other"):
		dmi.states += [frames.get(f"{kind}{corner_state}") for corner_state in range(8)]
	for kind in ("", "_other"):
		dmi.states += [windows.get(f"rwindow{kind}_onframe{corner_state}").renamed(f"rwindow{kind}{corner_state}")
			for corner_state in range(8)]
	write(dmi, "turf/walls/windows.dmi")


# --- Airlocks ------------------------------------------------------------------------------------------------------

# The CM state of an airlock and the Bay state it is drawn from
DOOR_STATES = {
	"door_closed": "closed",
	"door_locked": "closed",
	"door_opening": "opening",
	"door_closing": "closing",
	"door_open": "open",
	"door_deny": "deny",
	"door_spark": "closed",
	"o_door_opening": "opening",
	"o_door_closing": "closing",
}

# The layer files of /obj/machinery/door/airlock and the frames that have their own; a frame writes only its own
# paint layers, the code falls back to the station ones as Bay does
STATION = {
	"door": "obj/doors/station/door.dmi",
	"fill_steel": "obj/doors/station/fill_steel.dmi",
	"color": "obj/doors/station/color.dmi",
	"fill_color": "obj/doors/station/fill_color.dmi",
	"stripe": "obj/doors/station/stripe.dmi",
	"fill_stripe": "obj/doors/station/fill_stripe.dmi",
	"fill_glass": "obj/doors/station/fill_glass.dmi",
	"bolts": "obj/doors/station/lights_bolts.dmi",
	"deny": "obj/doors/station/lights_deny.dmi",
	"lights": "obj/doors/station/lights_green.dmi",
	"panel": "obj/doors/station/panel.dmi",
	"sparks": "obj/doors/station/sparks_damaged.dmi",
	"welded": "obj/doors/station/welded.dmi",
}
PAINT_LAYERS = ("fill_steel", "color", "fill_color", "stripe", "fill_stripe", "fill_glass")
FRAMES = {
	"station": STATION,
	"external": dict(STATION, **{key: f"obj/doors/external/{name}.dmi" for key, name in (("door", "door"),
		("fill_steel", "fill_steel"), ("color", "color"), ("fill_color", "fill_color"), ("fill_glass", "fill_glass"),
		("bolts", "lights_bolts"), ("deny", "lights_deny"), ("lights", "lights_green"))}),
	"hatch": dict(STATION, **{key: f"obj/doors/hatch/{name}.dmi" for key, name in (("door", "door"),
		("fill_steel", "fill_steel"), ("stripe", "stripe"), ("fill_stripe", "fill_stripe"), ("bolts", "lights_bolts"),
		("deny", "lights_deny"), ("lights", "lights_green"), ("panel", "panel"), ("welded", "welded"))}),
	"secure": dict(STATION, door="obj/doors/secure/door.dmi", fill_steel="obj/doors/secure/fill_steel.dmi"),
}

# preview state, frame, door colour, stripe colour, glass; the types of bay_doors.dm
AIRLOCK_PREVIEWS = [
	("generic", "station", None, None, False),
	("glass", "station", None, None, True),
	("command", "station", "#46698c", None, False),
	("command_glass", "station", "#46698c", "#5ca1cc", True),
	("security", "station", "#9d2300", None, False),
	("security_glass", "station", "#9d2300", "#ff9900", True),
	("engineering", "station", "#ffbf00", None, False),
	("engineering_glass", "station", "#ffbf00", "#ff0000", True),
	("atmos", "station", "#ffbf00", "#00ffff", False),
	("atmos_glass", "station", "#ffbf00", "#00ffff", True),
	("medical", "station", "#ffffff", "#00e1ff", False),
	("medical_glass", "station", "#ffffff", "#00e1ff", True),
	("research", "station", "#ffffff", "#a2819e", False),
	("research_glass", "station", "#ffffff", "#a2819e", True),
	("science", "station", "#ffffff", "#9933ff", False),
	("science_glass", "station", "#ffffff", "#9933ff", True),
	("mining", "station", "#b88a3b", "#663300", False),
	("mining_glass", "station", "#b88a3b", "#663300", True),
	("corporate", "station", "#ffffff", "#1f6b4f", False),
	("sol", "station", "#6a97b0", None, False),
	("sol_glass", "station", "#6a97b0", "#ffbf00", True),
	("civilian", "station", None, "#b7f27d", False),
	("civilian_glass", "station", None, "#b7f27d", True),
	("maintenance", "station", None, "#ffbf00", False),
	("maintenance_glass", "station", None, "#ffbf00", True),
	("freezer", "station", "#ffffff", None, False),
	("external", "external", "#9d2300", None, False),
	("external_glass", "external", "#9d2300", None, True),
	("hatch", "hatch", None, None, False),
	("hatch_maintenance", "hatch", None, "#ffbf00", False),
	("highsecurity", "secure", None, None, False),
]


def door_state(path, cm_name, frames, delays, top=None):
	"""A CM state of an airlock layer, from the Bay state DOOR_STATES gives; None if the layer has nothing there."""
	if source(path).get(DOOR_STATES[cm_name]) is None:
		return None
	return make_state(cm_name, 4, frames, lambda d, f: stack(layer(path, DOOR_STATES[cm_name], d, f),
		layer(top, DOOR_STATES[cm_name], d, f) if top else None), delays, loop=1 if "opening" in cm_name or "closing" in cm_name else 0)


def airlock_timing(files):
	"""Frames and delays of each CM state, the same in every layer so that the overlays keep up with the door."""
	animation = source(files["door"]).get("opening").frames
	deny = source(files["door"]).get("deny")
	sparks = source(files["sparks"]).get("closed")
	timing = {name: (1, None) for name in DOOR_STATES}
	for name in ("door_opening", "door_closing", "o_door_opening", "o_door_closing"):
		timing[name] = (animation, [ANIMATION_DELAY] * animation)
	timing["door_deny"] = (deny.frames, deny.delays)
	timing["door_spark"] = (sparks.frames, sparks.delays)
	return timing


def bake_airlock_frame(frame_name, files):
	timing = airlock_timing(files)
	folder = f"obj/structures/doors/airlocks/{frame_name}/"
	door = Dmi([door_state(files["door"], name, *timing[name]) for name in DOOR_STATES])
	door.states += [
		make_state("panel_open", 4, 1, lambda d, f: layer(files["panel"], "closed", d, f)),
		make_state("welded", 4, 1, lambda d, f: layer(files["welded"], "closed", d, f)),
	]
	write(door, folder + "door.dmi")
	lights = {
		"door_locked": files["bolts"],
		"door_opening": files["lights"],
		"door_closing": files["lights"],
		"door_deny": files["deny"],
		"o_door_opening": files["lights"],
		"o_door_closing": files["lights"],
	}
	light_states = []
	for name, path in lights.items():
		frames, delays = timing[name]
		bay_name = "closed" if name == "door_locked" else DOOR_STATES[name]
		panel = files["panel"] if name.startswith("o_") else None
		light_states.append(make_state(name, 4, frames, lambda d, f: stack(layer(panel, bay_name, d, f) if panel else None,
			layer(path, bay_name, d, f)), delays, loop=1 if "ing" in name and name != "door_deny" else 0))
	light_states.append(make_state("door_spark", 4, timing["door_spark"][0],
		lambda d, f: layer(files["sparks"], "closed", d, f), timing["door_spark"][1]))
	write(Dmi(light_states), folder + "lights.dmi")
	for key in PAINT_LAYERS:
		if frame_name != "station" and files[key] == STATION[key]:
			continue
		states = [door_state(files[key], name, *timing[name]) for name in DOOR_STATES]
		write(Dmi([state for state in states if state]), folder + f"{key}.dmi")


def airlock_look(files, door_color, stripe_color, glass):
	"""A closed airlock with its paint, as set_airlock_overlays() stacks it."""
	def part(key, color=None):
		return multiply(layer(files[key], "closed", 0, 0), color)
	return stack(
		part("door"),
		part("color", door_color) if door_color else None,
		part("fill_glass", GLASS_COLOR) if glass else part("fill_color", door_color) if door_color else part("fill_steel"),
		part("stripe", stripe_color) if stripe_color else None,
		part("fill_stripe", stripe_color) if stripe_color and not glass else None,
	)


def bake_airlock_previews():
	dmi = Dmi([make_state(name, 1, 1, lambda _d, _f: airlock_look(FRAMES[frame], door_color, stripe_color, glass))
		for name, frame, door_color, stripe_color, glass in AIRLOCK_PREVIEWS])
	write(dmi, "obj/structures/doors/airlocks/previews.dmi")


# --- Firedoors, blast doors, shutters ------------------------------------------------------------------------------

def bake_firedoor():
	hazard = source("obj/doors/hazard/door.dmi")
	welded = source("obj/doors/hazard/welded.dmi")
	animation = [ANIMATION_DELAY] * hazard.get("opening").frames
	write(Dmi([
		hazard.get("closed").renamed("door_closed"),
		hazard.get("opening").renamed("door_opening", animation),
		hazard.get("closing").renamed("door_closing", animation),
		hazard.get("open").renamed("door_open"),
		hazard.get("deny").renamed("door_deny"),
		welded.get("closed").renamed("welded"),
		welded.get("open").renamed("welded_open"),
	]), "obj/structures/doors/firedoor.dmi")


def bake_blast_doors():
	doors = source("obj/doors/rapid_pdoor.dmi")
	write(Dmi([doors.get(base + suffix) for base in ("pdoor", "shutter") for suffix in ("1", "0", "c1", "c0")]),
		"obj/structures/doors/blastdoors_shutters.dmi")


bake_walls()
bake_windows()
for frame_name, frame_files in FRAMES.items():
	bake_airlock_frame(frame_name, frame_files)
bake_airlock_previews()
bake_firedoor()
bake_blast_doors()
