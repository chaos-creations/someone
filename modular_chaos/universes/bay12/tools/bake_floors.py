"""Adds the floors and floor decals of Baystation 12 that the ported maps place to icons/turf/floors/.

Bay colours some floors through the turf's color (wood, crystal); here the colour is baked into the state, as a coloured
turf would tint the decals on it too (see code/game/turfs/bay_floors.dm). The other floors are copied as they are,
with the edge and corner states of the ones that draw borders (carpets, grass, the pool). The damage overlays of
icons/turf/flooring/damage.dmi go in as well, and the states of upstream's Almayer floors that the tiles used to break
into are removed.

floors.dmi is shared with other maps, so this only replaces, adds or removes the states it names and keeps the rest.
The states keep their names in the source, except the woods, which share one state there ("wood", "wood_maple",
"wood_walnut"), and the crystal floor, whose state has no name ("crystal").

The decals go into decals.dmi the same way, as they are. The floor logos, which maps put together from pieces they
pick by icon_state, are copied whole into files of their own.

Usage: python bake_floors.py <Baystation 12 checkout>
Needs Pillow. The colours must match the defines in code/__DEFINES/colors.dm.
"""
import os
import sys

from dmi_files import Dmi, multiply

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "icons", "turf", "floors")
FLOORS = os.path.join(OUT, "floors.dmi")
DECALS = os.path.join(OUT, "decals.dmi")

WOOD_COLOR_GENERIC = "#d5a66e"
WOOD_COLOR_PALE = "#d2bc9d"
WOOD_COLOR_CHOCOLATE = "#543c30"
CRYSTAL_COLOR = "#00ffe1"

# (file under icons/turf/flooring/ in the source, state there, state in floors.dmi, colour baked in or None)
STATES = [
	("plating.dmi", "plating", "plating", None),
	*[("plating.dmi", f"dmg{index}", f"dmg{index}", None) for index in range(1, 5)],
	*[("carpet.dmi", f"{carpet}{suffix}", f"{carpet}{suffix}", None)
		for carpet in ("brown", "blue1", "blue2", "green", "orange", "purple") for suffix in ("", "_edges", "_corners")],
	("linoleum.dmi", "lino", "lino", None),
	("wood.dmi", "wood", "wood", WOOD_COLOR_GENERIC),
	("wood.dmi", "wood", "wood_maple", WOOD_COLOR_PALE),
	("wood.dmi", "wood", "wood_walnut", WOOD_COLOR_CHOCOLATE),
	*[("grass.dmi", f"grass{index}", f"grass{index}", None) for index in range(4)],
	("grass.dmi", "grass_edges", "grass_edges", None),
	("grass.dmi", "grass_corners", "grass_corners", None),
	("pool.dmi", "pool", "pool", None),
	("pool.dmi", "pool_edges", "pool_edges", None),
	("pool.dmi", "pool_corners", "pool_corners", None),
	("circuit.dmi", "bcircuit", "bcircuit", None),
	("circuit.dmi", "gcircuit", "gcircuit", None),
	("circuit.dmi", "rcircuit_off", "rcircuit_off", None),
	("crystal.dmi", "", "crystal", CRYSTAL_COLOR),
	("tiles.dmi", "reinforced_light", "reinforced_light", None),
	*[("damage.dmi", f"broken{index}", f"broken{index}", None) for index in range(5)],
	*[("damage.dmi", f"burned{index}", f"burned{index}", None) for index in range(2)],
]

# States of icons/turf/flooring/decals.dmi in the source added to decals.dmi
DECAL_STATES = [
	"chapel", "shutoff", "edge", "solarpanel", "spline_fancy_cee", "spline_plain", "techfloororange_edges",
	*[f"white_{sign}" for sign in ("d", "ex", "or1", "or2", "pop", "tr")],
]

# (file in the source, relative to the checkout; file under icons/turf/floors/ here): the floor logos
LOGOS = [
	("maps/torch/icons/obj/solgov_floor.dmi", "solgov_floor.dmi"),
	("icons/turf/flooring/corp_floor.dmi", "corp_floor.dmi"),
]

# States of floors.dmi that nothing uses any more: the damage of upstream's Almayer floors
REMOVED = ["damaged1", "damaged2", "damaged3", "damaged4", "damaged5", "floorscorched1", "floorscorched2"]


def main():
	if len(sys.argv) < 2:
		sys.exit(__doc__)
	flooring = os.path.join(sys.argv[1], "icons", "turf", "flooring")
	floors = Dmi.load(FLOORS)
	sources = {}
	for file_name, source_name, name, color in STATES:
		if file_name not in sources:
			sources[file_name] = Dmi.load(os.path.join(flooring, file_name))
		source = sources[file_name].get(source_name)
		if source is None:
			sys.exit(f"{file_name} has no state \"{source_name}\"")
		state = source.renamed(name)
		state.images = [[multiply(image, color) for image in frames] for frames in source.images]
		replace_state(floors, state)
	floors.states = [state for state in floors.states if state.name not in REMOVED]
	floors.save(FLOORS)
	print(f"wrote {os.path.relpath(FLOORS)}: {len(floors.states)} states")

	source_decals = Dmi.load(os.path.join(flooring, "decals.dmi"))
	decals = Dmi.load(DECALS)
	for name in DECAL_STATES:
		state = source_decals.get(name)
		if state is None:
			sys.exit(f"decals.dmi has no state \"{name}\"")
		replace_state(decals, state)
	decals.save(DECALS)
	print(f"wrote {os.path.relpath(DECALS)}: {len(decals.states)} states")

	for source_path, name in LOGOS:
		logo = Dmi.load(os.path.join(sys.argv[1], source_path))
		logo.save(os.path.join(OUT, name))
		print(f"wrote {name}: {len(logo.states)} states")


def replace_state(dmi, state):
	"""Puts the state into the dmi in place of the one of the same name, or at its end if it has none."""
	existing = dmi.get(state.name)
	if existing:
		dmi.states[dmi.states.index(existing)] = state
	else:
		dmi.states.append(state)


if __name__ == "__main__":
	main()
