//Floors of Baystation 12 (/turf/simulated/floor and /singleton/flooring in the source)

/**
 * A Bay floor
 *
 * A CM floor drawn the way /turf/simulated/floor/on_update_icon() draws a floor with a flooring in the source. Floors
 * that do not join their neighbours (carpets, grass, the pool) draw edges on the sides where they meet another kind of
 * floor, a wall or space, and corners where those meet; the smooth_* vars say what they join. Cracks and scorch marks
 * are overlays from damage.dmi, as in the source.
 *
 * Bay colours some floors through the turf's colour; here the colour is baked into the icon states of floors.dmi
 * (tools/bake_floors.py), as a coloured turf would tint the decals on it too (CM decals are overlays of their turf).
 */
/turf/open/floor/bay
	name = "floor"
	desc = "A solid, heavy set of flooring plates."
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/floors.dmi'
	icon_state = "steel"
	plating_type = /turf/open/floor/plating/bay
	/// BAY_FLOOR_* flags: the borders the floor draws and the damage it takes
	var/flooring_flags = BAY_FLOOR_CAN_BREAK|BAY_FLOOR_CAN_BURN
	/// Prefix of the floor's states: its edges are "[flooring_base]_edges" and its corners "[flooring_base]_corners"; icon_state if null
	var/flooring_base
	/// If set, the floor picks its look at random from "[flooring_base]0" to "[flooring_base][has_base_range]"
	var/has_base_range
	/// Highest crack overlay ("broken[n]") break_tile() picks from; 0 is the only one if null
	var/has_damage_range
	/// Whether the floor joins other kinds of floor instead of drawing edges against them
	var/smooth_floors = TRUE
	/// Whether the floor joins walls and low walls instead of drawing edges against them
	var/smooth_walls = TRUE
	/// Whether the floor joins space and open space instead of drawing edges against them
	var/smooth_space = TRUE
	/// Edge and corner overlays the floor has now
	var/list/flooring_overlays
	/// Crack and scorch overlays the floor has now
	var/list/damage_overlays

/turf/open/floor/bay/Initialize(mapload, ...)
	. = ..()
	if(!flooring_base)
		flooring_base = icon_state
	if(!isnull(has_base_range))
		icon_state = "[flooring_base][rand(0, has_base_range)]"
	if(light_range)
		set_light_on(TRUE)
	update_flooring_overlays()

/**
 * Redraws the edges and corners of the floor from its neighbours
 *
 * Floors that join everything draw none, so they skip the checks.
 */
/turf/open/floor/bay/proc/update_flooring_overlays()
	if(length(flooring_overlays))
		overlays -= flooring_overlays
	flooring_overlays = null
	if(smooth_floors && smooth_walls && smooth_space)
		return
	var/list/new_overlays = list()
	var/border_dirs = NONE
	for(var/direction in GLOB.cardinals)
		if(!joins(get_step(src, direction)))
			border_dirs |= direction
			new_overlays += flooring_overlay("[flooring_base]_edges", direction, external = flooring_flags & BAY_FLOOR_HAS_EDGES)
	var/smooth_dirs = ~border_dirs & (NORTH|SOUTH|EAST|WEST)
	if(smooth_dirs && (flooring_flags & BAY_FLOOR_HAS_INNER_CORNERS))
		for(var/direction in GLOB.diagonals)
			if((smooth_dirs & direction) == direction && !joins(get_step(src, direction)))
				new_overlays += flooring_overlay("[flooring_base]_corners", direction)
	if(border_dirs && (flooring_flags & BAY_FLOOR_HAS_CORNERS))
		for(var/direction in GLOB.diagonals)
			if((border_dirs & direction) == direction && !joins(get_step(src, direction)))
				new_overlays += flooring_overlay("[flooring_base]_edges", direction, external = flooring_flags & BAY_FLOOR_HAS_EDGES)
	if(!length(new_overlays))
		return
	flooring_overlays = new_overlays
	overlays += flooring_overlays

/**
 * Whether the floor and the turf join, so that neither draws an edge between them: each must join the other
 *
 * Arguments:
 * * neighbor - the turf next to the floor
 */
/turf/open/floor/bay/proc/joins(turf/neighbor)
	if(!neighbor)
		return FALSE
	if(!joins_one_way(neighbor))
		return FALSE
	var/turf/open/floor/bay/neighbor_floor = neighbor
	return !istype(neighbor_floor) || neighbor_floor.joins_one_way(src)

/**
 * Whether the floor joins the turf from its own side, /singleton/flooring/proc/test_link() in the source
 *
 * Arguments:
 * * neighbor - the turf next to the floor
 */
/turf/open/floor/bay/proc/joins_one_way(turf/neighbor)
	if(istype(neighbor, /turf/closed) || (locate(/obj/structure/window_frame) in neighbor) || (locate(/obj/structure/window/framed) in neighbor))
		return smooth_walls
	if(istype(neighbor, /turf/open/space) || istype(neighbor, /turf/open_space))
		return smooth_space
	if(!istype(neighbor, /turf/open/floor))
		return FALSE
	// The same kind of floor, or a kind it comes from (a blue carpet joins brown carpet, not the other way round)
	if(istype(src, neighbor.type))
		return TRUE
	return smooth_floors

/**
 * An edge or corner overlay of the floor; the images are cached, as every floor of a kind uses the same few
 *
 * Arguments:
 * * icon_state - the state of the edges or corners
 * * direction - the side or corner it is drawn on
 * * external - whether it is drawn out over the turf on that side, as grass is
 */
/turf/open/floor/bay/proc/flooring_overlay(icon_state, direction, external = FALSE)
	var/static/list/overlay_cache = list()
	var/key = "[icon]-[icon_state]-[direction]-[external]"
	var/image/overlay = overlay_cache[key]
	if(overlay)
		return overlay
	overlay = image(icon, icon_state, dir = direction)
	if(external)
		overlay.layer = ABOVE_TURF_LAYER
		if(direction & NORTH)
			overlay.pixel_y = world.icon_size
		else if(direction & SOUTH)
			overlay.pixel_y = -world.icon_size
		if(direction & EAST)
			overlay.pixel_x = world.icon_size
		else if(direction & WEST)
			overlay.pixel_x = -world.icon_size
	overlay_cache[key] = overlay
	return overlay

/// Cracks the floor with a "broken[n]" overlay of the source, which multiplies the floor under it
/turf/open/floor/bay/break_tile()
	if(!(flooring_flags & BAY_FLOOR_CAN_BREAK) || (turf_flags & (TURF_HULL|TURF_BROKEN)))
		return
	turf_flags |= TURF_BROKEN
	// damage.dmi has cracks up to broken4; the source asks for up to 6 on wood and shows nothing over 4
	var/image/crack = image(icon, "broken[rand(0, min(has_damage_range || 0, 4))]")
	crack.blend_mode = BLEND_MULTIPLY
	add_damage_overlay(crack)

/// Scorches the floor with the "burned0" overlay of the source
/turf/open/floor/bay/burn_tile()
	if(!(flooring_flags & BAY_FLOOR_CAN_BURN) || (turf_flags & (TURF_HULL|TURF_BURNT)))
		return
	turf_flags |= TURF_BURNT
	add_damage_overlay(image(icon, "burned0"))

/// Adds a crack or scorch overlay, kept in damage_overlays
/turf/open/floor/bay/proc/add_damage_overlay(image/damage)
	LAZYADD(damage_overlays, damage)
	overlays += damage

/// Redraws the borders of the Bay floors around a turf that changed, as the source does when a floor updates its icon
/turf/ChangeTurf(path, list/new_baseturfs, flags)
	CAN_BE_REDEFINED(TRUE)
	var/turf/new_turf = ..()
	// While a map loads, its floors draw their borders as they initialize
	if(!new_turf || SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)
		return new_turf
	for(var/direction in GLOB.alldirs)
		var/turf/open/floor/bay/neighbor = get_step(new_turf, direction)
		if(istype(neighbor))
			neighbor.update_flooring_overlays()
	return new_turf

// Tiles (/singleton/flooring/tiling in the source)

/turf/open/floor/bay/tiled
	has_damage_range = 4

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
	flooring_flags = NONE
	has_damage_range = null

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
	flooring_flags = NONE

/// /turf/simulated/floor/shuttle_ceiling in the source: the light hull plating on the roof of a ship or shuttle
/turf/open/floor/bay/hull_plating
	name = "hull plating"
	desc = "Sturdy exterior hull plating."
	icon_state = "reinforced_light"
	turf_flags = NO_FLAGS
	tool_flags = NO_FLAGS
	flooring_flags = NONE

// Carpets (/singleton/flooring/carpet in the source), which join only carpet of their own colour

/turf/open/floor/bay/carpet
	name = "brown carpet"
	desc = "Comfy and fancy carpeting."
	icon_state = "brown"
	flooring_flags = BAY_FLOOR_HAS_CORNERS|BAY_FLOOR_HAS_INNER_CORNERS|BAY_FLOOR_CAN_BURN
	smooth_floors = FALSE
	smooth_walls = FALSE
	smooth_space = FALSE

/turf/open/floor/bay/carpet/blue
	name = "blue carpet"
	icon_state = "blue1"

/turf/open/floor/bay/carpet/blue2
	name = "pale blue carpet"
	icon_state = "blue2"

/turf/open/floor/bay/carpet/green
	name = "green carpet"
	icon_state = "green"

/turf/open/floor/bay/carpet/orange
	name = "orange carpet"
	icon_state = "orange"

/turf/open/floor/bay/carpet/purple
	name = "purple carpet"
	icon_state = "purple"

// Other floors

/turf/open/floor/bay/linoleum
	name = "linoleum"
	desc = "It's like the 2090's all over again."
	icon_state = "lino"
	tool_flags = REMOVE_SCREWDRIVER
	flooring_flags = NONE

/turf/open/floor/bay/wood
	name = "wooden floor"
	desc = "Polished wood planks."
	icon_state = "wood"
	tool_flags = REMOVE_SCREWDRIVER
	flooring_flags = BAY_FLOOR_CAN_BREAK
	has_damage_range = 6

/turf/open/floor/bay/wood/maple
	icon_state = "wood_maple"

/turf/open/floor/bay/wood/walnut
	icon_state = "wood_walnut"

/// Grass, which draws its edges out over the floors around it and joins only walls
/turf/open/floor/bay/grass
	name = "grass"
	desc = "Do they smoke grass out in space, Bowie? Or do they smoke AstroTurf?"
	icon_state = "grass0"
	flooring_base = "grass"
	has_base_range = 3
	tool_flags = NO_FLAGS
	flooring_flags = BAY_FLOOR_HAS_EDGES|BAY_FLOOR_HAS_CORNERS
	smooth_floors = FALSE
	smooth_space = FALSE

/// Sunken pool floor, with a rim where it meets anything else
/turf/open/floor/bay/pool
	name = "pool floor"
	desc = "Sunken flooring designed to hold liquids."
	icon_state = "pool"
	flooring_flags = BAY_FLOOR_HAS_CORNERS|BAY_FLOOR_HAS_INNER_CORNERS
	smooth_floors = FALSE
	smooth_walls = FALSE
	smooth_space = FALSE

/// Mainframe floor that glows with the colour of its circuits
/turf/open/floor/bay/circuit
	name = "processing strata"
	desc = "Heavily reinforced with steel plating."
	icon_state = "bcircuit"
	tool_flags = NO_FLAGS
	flooring_flags = BAY_FLOOR_CAN_BREAK
	light_range = 2
	light_power = 1
	light_color = COLOR_BLUE

/turf/open/floor/bay/circuit/green
	icon_state = "gcircuit"
	light_power = 3
	light_color = COLOR_GREEN

/// The mainframe floor of the self-destruct terminal
/turf/open/floor/bay/circuit/self_destruct
	icon_state = "rcircuit_off"
	flooring_flags = NONE
	light_power = 2
	light_color = COLOR_BLACK

/turf/open/floor/bay/crystal
	name = "crystal floor"
	icon_state = "crystal"
	flooring_flags = BAY_FLOOR_CAN_BREAK

// Plating

/// Bare plating, /turf/simulated/floor in the source; cracked and scorched plating shows one of its "dmg" states
/turf/open/floor/plating/bay
	name = "plating"
	desc = "The naked hull."
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/floors.dmi'
	icon_state = "plating"

/turf/open/floor/plating/bay/break_tile()
	if(turf_flags & (TURF_HULL|TURF_BROKEN))
		return
	turf_flags |= TURF_BROKEN
	icon_state = "dmg[rand(1, 4)]"

/turf/open/floor/plating/bay/burn_tile()
	if(turf_flags & (TURF_HULL|TURF_BURNT))
		return
	turf_flags |= TURF_BURNT
	icon_state = "dmg[rand(1, 4)]"
