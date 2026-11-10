//Floor tiles of Baystation 12 (/turf/simulated/floor/tiled and /decl/flooring/tiling in the source), as Castelnau places them

/**
 * A Bay floor tile
 *
 * Bay colours its tiles through the turf's colour; here the colour is baked into the icon states of floors.dmi, as a
 * coloured turf would tint the decals on it too (CM decals are overlays of their turf). The damaged and scorched states
 * break_tile() and burn_tile() switch to are the ones of the Almayer floors.
 */
/turf/open/floor/bay
	name = "floor"
	desc = "A solid, heavy set of flooring plates."
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/floors.dmi'
	icon_state = "steel"
	plating_type = /turf/open/floor/plating/almayer

/turf/open/floor/bay/tiled

/turf/open/floor/bay/tiled/monotile
	icon_state = "monotile"

/turf/open/floor/bay/tiled/dark
	desc = "How ominous."
	icon_state = "dark"

/turf/open/floor/bay/tiled/dark/monotile
	icon_state = "monotile_dark"

/turf/open/floor/bay/tiled/white
	desc = "How sterile."
	icon_state = "white"

/turf/open/floor/bay/tiled/white/monotile
	icon_state = "monotile_white"

/turf/open/floor/bay/tiled/freezer
	desc = "Don't slip."
	icon_state = "freezer"

/turf/open/floor/bay/tiled/steel_grid
	icon_state = "steel_grid"

/turf/open/floor/bay/tiled/steel_ridged
	icon_state = "steel_ridged"

/turf/open/floor/bay/tiled/techmaint
	icon_state = "techmaint"

/turf/open/floor/bay/tiled/techfloor
	icon_state = "techfloor"

/turf/open/floor/bay/tiled/techfloor/grid
	icon_state = "techfloor_grid"

/// Heavy steel plating that does not come off or break, like /turf/open/floor/engine
/turf/open/floor/bay/reinforced
	name = "reinforced floor"
	desc = "Heavily reinforced with steel plating."
	icon_state = "reinforced"
	turf_flags = NO_FLAGS
	tool_flags = NO_FLAGS
