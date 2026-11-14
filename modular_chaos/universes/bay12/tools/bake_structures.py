"""Converts the walls, windows, doors and floor structures of Baystation 12 into the icons of this universe.

Bay draws these at runtime from greyscale layers that it colours with the paint of the type: wall masks, low wall
frames and glass, airlock panels and stripes. The code here does the same, so the layers are copied greyscale; this
script only renames their states to the ones the CM types use, and lines up the airlock layers so that each has every
state of the door (an overlay without an icon_state shows the state its door shows, flicks included). It writes, under
icons/:

- turf/walls/walls.dmi: the wall masks of every material, and the map editor previews of the wall types, a lone wall
  of each in its colours;
- turf/walls/windows.dmi: low wall frames, the glass on them, and panes on their own;
- obj/structures/grille.dmi: grilles, on their own and on low walls;
- obj/structures/: catwalks, lattices, railings, handrails, ladders and stairs, in doors/ the windoors, the morgue
  door and the plastic door, and in machinery/ breaker boxes, portable generators, solar panels and trackers, the
  solar control console and power sensors, as they are, with lighting.dmi (light fixtures, their frames and bulbs) and
  buttons.dmi (light switches and buttons), fire alarms and cameras; obj/items/circuitboards.dmi, electronics;
- obj/structures/props/wall_decorations/: signs, the signs of the Sol Central Government and the memorial rock of the
  Torch, bar signs and posters, as they are;
- obj/structures/tables.dmi and furniture.dmi: tables, racks, chairs, beds and stools, in greyscale for the colours of
  their materials;
- obj/pipes/disposal.dmi: disposal units, chutes, outlets and pipes, as they are;
- misc/security_state.dmi: what alarms, status displays and the screen border show for each alert level, the default
  ones and the Torch's own;
- obj/structures/machinery/apc.dmi: APCs, their lights coloured into the states CM draws, and power terminals;
- obj/structures/machinery/smes.dmi and power_cond_white.dmi: SMES units and power cables, as they are;
- obj/structures/doors/airlocks/<frame>/: for each airlock frame, door.dmi (the frame, its panel and welds) and the
  layers drawn over it: lights.dmi (bolt, deny and opening lights, sparks, the panel while opening) and the paint
  layers Bay has for that frame;
- obj/structures/doors/airlocks/previews.dmi (previews_double.dmi for the two-tile ones, 64x64) and the preview states
  of windows.dmi: the colour schemes of the types,
  baked, for the map editor only;
- obj/structures/doors/firedoor.dmi and blastdoors_shutters.dmi: firedoors, blast doors and shutters, renamed only.

Usage: python bake_structures.py <Baystation 12 checkout>
Needs Pillow. It overwrites the files it writes. The colours of the previews must match the types in
code/game/machinery/doors/bay_doors.dm and code/game/objects/structures/bay_windows.dm.
"""
import os
import re
import sys

from PIL import Image

from dmi_files import Dmi, blank_state, make_state, multiply, stack

# The icons/ folder of the Baystation 12 checkout, set by main()
BAY = None
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons")

GLASS_COLOR = "#aaccff"
# Bay plays the opening and closing of airlocks and firedoors at 2 ds a frame; here at 1, which openspeed matches
ANIMATION_DELAY = 1


# --- Source icons --------------------------------------------------------------------------------------------------

# Path under icons/ -> the Dmi read from the checkout
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


def write(dmi, path):
	dmi.save(os.path.join(OUT, path))
	print(f"wrote {path}: {len(dmi.states)} states")


# --- Walls ---------------------------------------------------------------------------------------------------------

# Map editor previews of the wall types: state, material, reinforcement, paint, stripe; the materials are the defines of
# code/__DEFINES/materials.dm. They must match code/game/turfs/walls/bay_walls.dm.
WALL_PREVIEWS = [
	("steel", "MATERIAL_STEEL", None, None, None),
	("steel_prepainted", "MATERIAL_STEEL", None, "#353a42", "#545c68"),
	("steel_fleet", "MATERIAL_STEEL", None, "#3e4855", "#353a42"),
	("r_steel", "MATERIAL_STEEL", "MATERIAL_PLASTEEL", None, None),
	("r_steel_prepainted", "MATERIAL_STEEL", "MATERIAL_PLASTEEL", "#353a42", "#545c68"),
	("r_steel_fleet", "MATERIAL_STEEL", "MATERIAL_PLASTEEL", "#3e4855", "#353a42"),
	("r_steel_hull", "MATERIAL_STEEL", "MATERIAL_PLASTEEL", "#436b8e", "#436b8e"),
	("titanium", "MATERIAL_TITANIUM", None, None, None),
	("r_titanium", "MATERIAL_TITANIUM", "MATERIAL_TITANIUM", None, None),
	("r_ocp", "MATERIAL_OSMIUM_CARBIDE_PLASTEEL", "MATERIAL_OSMIUM_CARBIDE_PLASTEEL", None, None),
	("r_glass", "MATERIAL_GLASS", "MATERIAL_STEEL", None, None),
	*[(name.lower(), f"MATERIAL_{name}", None, None, None) for name in ("IRON", "URANIUM", "DIAMOND", "GOLD", "SILVER",
		"PHORON", "SANDSTONE", "RUTILE", "MAHOGANY", "MAPLE", "EBONY", "WALNUT", "CRYSTAL", "CONCRETE")],
	("wood", "BAY_MATERIAL_WOOD", None, None, None),
	("r_iron_phoron", "MATERIAL_IRON", "MATERIAL_PHORON", None, None),
	("r_gold_diamond", "MATERIAL_GOLD", "MATERIAL_DIAMOND", None, None),
	("r_silver_gold", "MATERIAL_SILVER", "MATERIAL_GOLD", None, None),
	("r_sandstone_diamond", "MATERIAL_SANDSTONE", "MATERIAL_DIAMOND", None, None),
]


def read_materials():
	"""The materials of code/modules/materials/definitions/ here, by the define their name is written with: dicts of
	their vars, inherited from their parents and from the defaults of /material."""
	code = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "code")
	by_path = {"/material": {"wall_icon_base": "metal", "wall_icon_reinf": "reinf_metal"}}
	definitions = os.path.join(code, "modules", "materials", "definitions")
	for file_name in sorted(os.listdir(definitions)):
		path = None
		with open(os.path.join(definitions, file_name), encoding="utf-8") as file:
			for line in file:
				if line.startswith("/material"):
					path = line.strip()
					by_path[path] = {}
				elif path:
					match = re.match(r"\t(\w+) = (.*)$", line.rstrip("\n"))
					if match:
						by_path[path][match.group(1)] = match.group(2).strip('"')
	by_define = {}
	for path, own_vars in by_path.items():
		if not own_vars.get("name"):
			continue
		merged = {}
		parts = path.split("/")
		for end in range(2, len(parts) + 1):
			merged.update(by_path.get("/".join(parts[:end]), {}))
		by_define[own_vars["name"]] = merged
	return by_define


def bake_walls():
	"""The wall masks of every material, and the map editor previews of the types: a lone wall drawn from its masks in
	the colours of its materials and paint, as it shows in game."""
	masks = source("turf/wall_masks.dmi")
	materials = read_materials()
	dmi = Dmi([blank_state()] + [state for state in masks.states if state.name and state.name != "blank"])
	for name, material, reinforcement, paint, stripe in WALL_PREVIEWS:
		base = materials[material]
		reinf = materials[reinforcement] if reinforcement else None
		wall_icon_base = base["wall_icon_base"]
		layers = []
		for dir_index in range(4):
			layers.append(multiply(layer("turf/wall_masks.dmi", f"{wall_icon_base}0", dir_index, 0),
				paint or base["icon_colour"]))
			if paint:
				layers.append(multiply(layer("turf/wall_masks.dmi", f"{wall_icon_base}_paint0", dir_index, 0), paint))
			if stripe:
				layers.append(multiply(layer("turf/wall_masks.dmi", f"{wall_icon_base}_stripe0", dir_index, 0), stripe))
		if reinf:
			reinf_state = base["wall_icon_reinf"]
			directional = masks.get(f"{reinf_state}0") is not None
			for dir_index in range(4 if directional else 1):
				layers.append(multiply(layer("turf/wall_masks.dmi", f"{reinf_state}0" if directional else reinf_state,
					dir_index, 0), paint or reinf["icon_colour"]))
		dmi.states.append(make_state(f"preview_{name}", 1, 1, lambda _d, _f, layers=layers: stack(*layers)))
	write(dmi, "turf/walls/walls.dmi")


# --- Windows -------------------------------------------------------------------------------------------------------

WALL_FRAME = "obj/structures/wall_frame.dmi"
WINDOW = "obj/structures/window.dmi"

GRILLE = "obj/structures/grille.dmi"
GLASS_COLOR_BORON = "#899ebd"
FRAME_COLORS = {
	"": "#545c68",  # COLOR_GUNMETAL, the stripe of /obj/structure/wall_frame/standard
	"hull_": "#436b8e",  # COLOR_SOL
	"titanium_": "#d1e6e3",  # COLOR_TITANIUM
	"ocp_": "#9bc6f2",  # COLOR_OSMIUM_CARBIDE_PLASTEEL
}
# Map editor previews of the window types: state, frame prefix in FRAME_COLORS, glass state on the frame (None for the
# low wall alone), glass colour. They must match code/game/objects/structures/bay_windows.dm.
WINDOW_PREVIEWS = [
	("frame", "", None, None),
	("rwindow", "", "rwindow", GLASS_COLOR),
	("hull_frame", "hull_", None, None),
	("hull_rwindow", "hull_", "rwindow", GLASS_COLOR),
	("window", "", "window", GLASS_COLOR),
	("titanium_rwindow", "titanium_", "rwindow", GLASS_COLOR),
	("boron_rwindow", "", "rwindow", GLASS_COLOR_BORON),
	("titanium_boron_rwindow", "titanium_", "rwindow", GLASS_COLOR_BORON),
	("ocp_boron_rwindow", "ocp_", "rwindow", GLASS_COLOR_BORON),
]


def bake_windows():
	frames = source(WALL_FRAME)
	windows = source(WINDOW)
	dmi = Dmi([blank_state()])
	for name, frame, glass, glass_color in WINDOW_PREVIEWS:
		def isolated(_d, _f, frame=frame, glass=glass, glass_color=glass_color):
			return stack(*(multiply(layer(WALL_FRAME, "frame0", d, 0), FRAME_COLORS[frame]) for d in range(4)),
				*(multiply(layer(WINDOW, f"{glass}_onframe0", d, 0), glass_color) for d in range(4) if glass))
		dmi.states.append(make_state(name, 1, 1, isolated))
	for kind in ("frame", "frame_other"):
		dmi.states += [frames.get(f"{kind}{corner_state}") for corner_state in range(8)]
	for glass in ("rwindow", "window"):
		for kind in ("", "_other"):
			dmi.states += [windows.get(f"{glass}{kind}_onframe{corner_state}").renamed(f"{glass}{kind}{corner_state}")
				for corner_state in range(8)]
	# Panes on the edge of a tile, and the full-tile pane without a low wall; greyscale, coloured by the type
	dmi.states += [windows.get("window").renamed("window_border"), windows.get("rwindow").renamed("rwindow_border"),
		windows.get("rwindow_full")]
	write(dmi, "turf/walls/windows.dmi")


def bake_grilles():
	"""Grilles as they are: corner states on their own and on a low wall, the broken ones, and the map editor state."""
	grilles = source(GRILLE)
	dmi = Dmi([blank_state(), grilles.get("grille"), grilles.get("broken"), grilles.get("broken_onframe")])
	for kind in ("grille", "grille_other", "grille_onframe", "grille_other_onframe"):
		dmi.states += [grilles.get(f"{kind}{corner_state}") for corner_state in range(8)]
	write(dmi, "obj/structures/grille.dmi")


# --- Icons copied as they are -------------------------------------------------------------------------------------

# (file under icons/ in the source, states taken, file under icons/ here)
COPIED_ICONS = [
	("obj/structures/catwalks.dmi", ["catwalk", *[f"catwalk{n}" for n in range(8)], "plated", "catwalk_plated",
		"catwalk_plateddark", "catwalk_platedwhite"], "obj/structures/catwalks.dmi"),
	("obj/structures/smoothlattice.dmi", [f"lattice{n}" for n in range(16)], "obj/structures/lattice.dmi"),
	("obj/structures/railing.dmi", ["railing_preview", "railing0-0", "railing0-1", "railing1-0", "railing1-1",
		"_railing0-1", "_railing1-1", "corneroverlay0", "corneroverlay1", "frontoverlay_l0", "frontoverlay_l1",
		"frontoverlay_r0", "frontoverlay_r1", "_frontoverlay_l1", "_frontoverlay_r1", "mcorneroverlay0",
		"mcorneroverlay1", "_mcorneroverlay1"], "obj/structures/railing.dmi"),
	("obj/structures/handrail.dmi", ["handrail"], "obj/structures/handrail.dmi"),
	("obj/structures/structures.dmi", ["ladder00", "ladder01", "ladder10", "ladder11"], "obj/structures/ladders.dmi"),
	("obj/structures/stairs.dmi", ["above"], "obj/structures/stairs.dmi"),
	("obj/doors/windoor.dmi", [f"{side}{kind}{state}" for side in ("left", "right") for kind in ("", "secure")
		for state in ("", "open", "opening", "closing", "deny", "spark")], "obj/structures/doors/windoor.dmi"),
	("obj/doors/doormorgue.dmi", ["door1", "door0", "doorc0", "doorc1", "door_deny", "door_spark"],
		"obj/structures/doors/doormorgue.dmi"),
	("obj/doors/material_doors.dmi", ["plastic", "plasticopen", "plasticopening", "plasticclosing"],
		"obj/structures/doors/material_doors.dmi"),
	("obj/machines/power/breakerbox.dmi", ["bbox", "bbox_lights", "bbox_panel"], "obj/structures/machinery/breakerbox.dmi"),
	("obj/structures/portgen.dmi", ["portgen0", "portgen0on", "portgen1", "portgen1on", "portgen1rad", "portgen2",
		"portgen2on"], "obj/structures/machinery/portgen.dmi"),
	("obj/machines/power/solar_panels.dmi", ["sp_base", "solar_panel", "solar_panel-b", "tracker"],
		"obj/structures/machinery/solar_panels.dmi"),
	("obj/machines/computer.dmi", ["computer", "solar", "broken", "solcon-o"], "obj/structures/machinery/computer.dmi"),
	("obj/structures/floor_magnet.dmi", ["floor_beacon"], "obj/structures/machinery/power_sensor.dmi"),
	("obj/doors/door_assembly.dmi", ["door_electronics"], "obj/items/circuitboards.dmi"),
	("obj/structures/lighting.dmi", [f"{fitting}{state}" for fitting in ("tube", "bulb") for state in ("_map", "_empty",
		"0", "1", "_burned", "_broken", "-construct-stage1", "-construct-stage2")] + [f"{bulb}{state}"
		for bulb in ("ltube", "lbulb") for state in ("", "_burned", "_broken", "_attachment", "_attachment_broken")],
		"obj/structures/lighting.dmi"),
	("obj/structures/buttons.dmi", ["light0", "light1", "light-p", "light0-overlay", "light1-overlay", "launcherbtt",
		"launcheract", "doorctrl", "doorctrl1", "doorctrl2", "blastctrl", "blastctrl1"], "obj/structures/buttons.dmi"),
	("obj/machines/firealarm.dmi", ["casing", "fire0", "fire1", "unpowered", "broken", "b0", "b1", "b2"],
		"obj/structures/machinery/firealarm.dmi"),
	("obj/structures/cameras.dmi", ["camera", "cameraemp", "camera1", "camerax", "xraycam", "xraycamemp", "xraycam1",
		"xraycamx"], "obj/structures/machinery/cameras.dmi"),
	("obj/structures/decals.dmi", None, "obj/structures/props/wall_decorations/signs.dmi"),
	("../maps/torch/icons/obj/solgov-decals.dmi", None, "obj/structures/props/wall_decorations/solgov.dmi"),
	("../maps/torch/icons/obj/solgov-64x.dmi", None, "obj/structures/props/wall_decorations/solgov_64x64.dmi"),
	("obj/structures/barsigns.dmi", None, "obj/structures/props/wall_decorations/barsigns.dmi"),
	("obj/structures/contraband.dmi", None, "obj/structures/props/wall_decorations/bay_posters.dmi"),
	("obj/structures/tables.dmi", None, "obj/structures/tables.dmi"),
	("obj/structures/furniture.dmi", None, "obj/structures/furniture.dmi"),
	("obj/structures/toilets.dmi", None, "obj/structures/props/toilets.dmi"),
	("obj/showers.dmi", None, "obj/structures/props/showers.dmi"),
	("obj/sinks.dmi", None, "obj/structures/props/sinks.dmi"),
	("obj/structures/drain.dmi", None, "obj/structures/props/drain.dmi"),
	("obj/structures/faucets.dmi", None, "obj/structures/props/faucets.dmi"),
	("obj/flora/plants.dmi", None, "obj/structures/props/natural/vegetation/plants.dmi"),
	("obj/structures/curtain.dmi", None, "obj/structures/props/curtain.dmi"),
	("obj/structures/drawers.dmi", None, "obj/structures/props/furniture/drawers.dmi"),
	("obj/structures/extinguisher.dmi", None, "obj/structures/props/extinguisher.dmi"),
	("obj/structures/structures.dmi", ["fireaxe", "fireaxe_item", "fireaxe_window", "fireaxe_window_broken"],
		"obj/structures/props/fireaxe_cabinet.dmi"),
	("obj/structures/noticeboard.dmi", None, "obj/structures/props/furniture/noticeboard.dmi"),
	("obj/library.dmi", [f"book-{count}" for count in range(6)], "obj/structures/props/furniture/bookcase.dmi"),
	("obj/structures/structures.dmi", ["linenbin-full", "linenbin-half", "linenbin-empty"],
		"obj/structures/props/linen_bin.dmi"),
	("obj/showcases.dmi", ["glassbox", "glassboxb"], "obj/structures/props/furniture/display_case.dmi"),
	("obj/pipes/disposal.dmi", ["disposal", "disposal-flush", "dispover-charge", "dispover-full", "dispover-handle",
		"dispover-ready", "condisposal", "intake", "intake-closing", "outlet", "outlet-open", "trashcan",
		*[f"{part}{suffix}" for part in ("pipe-s", "pipe-c", "pipe-j1", "pipe-j2", "pipe-y", "pipe-t", "pipe-j1s",
		"pipe-j2s", "pipe-b") for suffix in ("", "f")], "pipe-u", "pipe-d", "pipe-tagger", "pipe-tagger-partial",
		*[f"conpipe-{part}" for part in ("s", "c", "j1", "j2", "y", "t", "j1s", "j2s")]], "obj/pipes/disposal.dmi"),
]


def bake_copied_icons():
	"""Icons that need no conversion: catwalks, lattices, railings, handrails, ladders, stairs, doors, machines and
	furniture; those drawn from overlays (catwalks, tables) also get "blank". A list of names of None takes every
	named state."""
	for path, names, out in COPIED_ICONS:
		states = source(path)
		blank = [blank_state()] if out in ("obj/structures/catwalks.dmi", "obj/structures/tables.dmi") else []
		picked = [state for state in states.states if state.name] if names is None else [states.get(name) for name in names]
		write(Dmi(blank + picked, states.width, states.height), out)


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
	"vault": dict(STATION, door="obj/doors/vault/door.dmi", fill_steel="obj/doors/vault/fill_steel.dmi"),
	# Two tiles wide (64x64); it has no sparks of its own, and the station ones are of another size
	"double": dict(STATION, sparks=None, **{key: f"obj/doors/double/{name}.dmi" for key, name in (("door", "door"),
		("fill_steel", "fill_steel"), ("color", "color"), ("fill_color", "fill_color"), ("stripe", "stripe"),
		("fill_stripe", "fill_stripe"), ("fill_glass", "fill_glass"), ("bolts", "lights_bolts"), ("deny", "lights_deny"),
		("lights", "lights_green"), ("panel", "panel"), ("welded", "welded"))}),
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
	("chaplain", "station", None, "#333333", False),
	("crystal", "station", "#00c8a5", None, False),
	("vault", "vault", None, None, False),
]

# The same for the two-tile airlocks, which have a preview file of their own as they are 64x64
DOUBLE_AIRLOCK_PREVIEWS = [
	("double", "double", None, None, False),
	("double_glass", "double", None, None, True),
	("double_engineering", "double", "#ffbf00", None, False),
	("double_civilian", "double", None, "#b7f27d", False),
	("double_civilian_glass", "double", None, "#b7f27d", True),
	("double_command_glass", "double", "#46698c", "#5ca1cc", True),
	("double_security_glass", "double", "#9d2300", "#ff9900", True),
	("double_medical_glass", "double", "#ffffff", "#00e1ff", True),
	("double_research_glass", "double", "#ffffff", "#a2819e", True),
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
	timing = {name: (1, None) for name in DOOR_STATES}
	for name in ("door_opening", "door_closing", "o_door_opening", "o_door_closing"):
		timing[name] = (animation, [ANIMATION_DELAY] * animation)
	timing["door_deny"] = (deny.frames, deny.delays)
	if files["sparks"]:
		sparks = source(files["sparks"]).get("closed")
		timing["door_spark"] = (sparks.frames, sparks.delays)
	return timing


def bake_airlock_frame(frame_name, files):
	timing = airlock_timing(files)
	folder = f"obj/structures/doors/airlocks/{frame_name}/"
	size = (source(files["door"]).width, source(files["door"]).height)
	door = Dmi([door_state(files["door"], name, *timing[name]) for name in DOOR_STATES], *size)
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
	if files["sparks"]:
		light_states.append(make_state("door_spark", 4, timing["door_spark"][0],
			lambda d, f: layer(files["sparks"], "closed", d, f), timing["door_spark"][1]))
	# The states without lights are empty, so a layer set to any state of the door has it, which map editors need
	for name in ("door_closed", "door_open", "door_spark"):
		if not any(state.name == name for state in light_states):
			light_states.append(make_state(name, 4, 1, lambda _d, _f: stack(Image.new("RGBA", size, (0, 0, 0, 0)))))
	write(Dmi(light_states, *size), folder + "lights.dmi")
	for key in PAINT_LAYERS:
		if frame_name != "station" and files[key] == STATION[key]:
			continue
		states = [door_state(files[key], name, *timing[name]) for name in DOOR_STATES]
		write(Dmi([state for state in states if state], *size), folder + f"{key}.dmi")


def airlock_look(files, door_color, stripe_color, glass, dir_index=0):
	"""A closed airlock with its paint, as set_airlock_overlays() stacks it, facing the dir of the index."""
	def part(key, color=None):
		return multiply(layer(files[key], "closed", dir_index, 0), color)
	return stack(
		part("door"),
		part("color", door_color) if door_color else None,
		part("fill_glass", GLASS_COLOR) if glass else part("fill_color", door_color) if door_color else part("fill_steel"),
		part("stripe", stripe_color) if stripe_color else None,
		part("fill_stripe", stripe_color) if stripe_color and not glass else None,
	)


def bake_airlock_previews():
	for previews, out in ((AIRLOCK_PREVIEWS, "previews.dmi"), (DOUBLE_AIRLOCK_PREVIEWS, "previews_double.dmi")):
		# Every dir, as the doors turn along their walls and map editors draw the dir a door is mapped with
		dmi = Dmi([make_state(name, 4, 1, lambda dir_index, _f, frame=frame, door_color=door_color,
			stripe_color=stripe_color, glass=glass: airlock_look(FRAMES[frame], door_color, stripe_color, glass, dir_index))
			for name, frame, door_color, stripe_color, glass in previews])
		dmi.width, dmi.height = source(FRAMES[previews[0][1]]["door"]).width, source(FRAMES[previews[0][1]]["door"]).height
		write(dmi, f"obj/structures/doors/airlocks/{out}")


# --- Power ---------------------------------------------------------------------------------------------------------

APC = "obj/machines/apc.dmi"
# The colours the source gives the channel lights of an APC at runtime, in the order of the CM channel states:
# off, off by the APC, on, on by the APC (COLOR_RED_LIGHT, COLOR_ORANGE_LIGHT, COLOR_GREEN_LIGHT, COLOR_BLUE_LIGHT)
APC_CHANNEL_COLORS = ["#ff3333", "#ffcc33", "#33ff33", "#33ccff"]
# The colours of the cover lock light, unlocked then locked
APC_LOCK_COLORS = ["#33ff33", "#ff3333"]


def bake_apc():
	"""APCs with their lights coloured into the states CM draws ("apco<channel>-<state>", "apcox-<locked>"), the map
	editor states CM APCs have, and the terminal."""
	apc = source(APC)
	dmi = Dmi([apc.get(name) for name in ("apc0", "apcewires", "apc-spark", "apcemag", "apcmaint", "apc1-b-nocover",
		"apc1", "apc1-nocover", "apc2", "apc2-nocover", "apc2-b-nocover", "apc-b", "apco3-0", "apco3-1", "apco3-2",
		"term")])
	for channel in range(3):
		for index, color in enumerate(APC_CHANNEL_COLORS):
			dmi.states.append(make_state(f"apco{channel}-{index}", 4, 1,
				lambda d, _f, channel=channel, color=color: multiply(layer(APC, f"apco{channel}", d, 0), color)))
	for index, color in enumerate(APC_LOCK_COLORS):
		dmi.states.append(make_state(f"apcox-{index}", 4, 1,
			lambda d, _f, color=color: multiply(layer(APC, "apcox", d, 0), color)))
	# A working APC with a cell, its channels on and its cover locked, for the map editor
	dmi.states.append(make_state("apc_mapicon", 4, 1, lambda d, _f: stack(layer(APC, "apc2", d, 0),
		*(multiply(layer(APC, f"apco{channel}", d, 0), APC_CHANNEL_COLORS[3]) for channel in range(3)),
		layer(APC, "apco3-2", d, 0), multiply(layer(APC, "apcox", d, 0), APC_LOCK_COLORS[1]))))
	for name, base in (("apcewires_mapicon", "apcewires"), ("apc2_mapicon", "apc2"), ("apc1_mapicon", "apc1")):
		dmi.states.append(apc.get(base).renamed(name))
	write(dmi, "obj/structures/machinery/apc.dmi")


def bake_power():
	"""SMES units and cables as they are."""
	smes = source("obj/machines/power/smes.dmi")
	write(Dmi([smes.get(name) for name in ("smes", *[f"smes-og{n}" for n in range(1, 6)],
		*[f"smes-op{n}" for n in range(3)], *[f"smes-oc{n}" for n in range(3)], "smes-panel")]),
		"obj/structures/machinery/smes.dmi")
	cables = source("obj/machines/power/power_cond_white.dmi")
	write(Dmi([state for state in cables.states if state.name]), "obj/structures/machinery/power_cond_white.dmi")


# The overlays of the alert levels, of the default ones and of the Torch's own
SECURITY_STATE_KINDS = ("alarm", "status_display", "alert_border")


def bake_security_state():
	"""The overlays alarms, status displays and the screen border show for each alert level."""
	default = source("misc/security_state.dmi")
	torch = source(os.path.join("..", "maps", "torch", "icons", "security_state.dmi"))
	write(Dmi([default.get(f"{kind}_{level}") for kind in SECURITY_STATE_KINDS for level in ("green", "blue", "red",
		"delta")] + [torch.get(f"{kind}_{level}") for kind in SECURITY_STATE_KINDS for level in ("violet", "orange")]),
		"misc/security_state.dmi")


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


def main():
	global BAY
	if len(sys.argv) < 2:
		sys.exit(__doc__)
	BAY = os.path.join(sys.argv[1], "icons")
	bake_walls()
	bake_windows()
	bake_grilles()
	bake_copied_icons()
	bake_apc()
	bake_power()
	bake_security_state()
	for frame_name, frame_files in FRAMES.items():
		bake_airlock_frame(frame_name, frame_files)
	bake_airlock_previews()
	bake_firedoor()
	bake_blast_doors()


if __name__ == "__main__":
	main()
