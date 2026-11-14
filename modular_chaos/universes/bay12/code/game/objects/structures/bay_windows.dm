//Windows of Baystation 12: reinforced glass on a low wall (/obj/structure/wall_frame and /obj/structure/window/reinforced/full in the source)

/**
 * Corner states of a Bay low wall or the glass on it
 *
 * Bay joins these by corners in all eight directions, like walls, and draws an "_other" variant on the corners of a
 * side that ends against a wall or a door. Returns list(connections, edge connections), each four corner states in the
 * order dirs_to_corner_states() gives.
 *
 * * source - the window or window frame
 * * join_types - types of the neighbours that continue the same row; ones being deleted are ignored
 */
/proc/bay_low_wall_connections(atom/source, list/join_types)
	var/list/joined_dirs = list()
	var/list/edge_dirs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/neighbor = get_step(source, direction)
		if(!neighbor)
			continue
		var/joined = FALSE
		for(var/obj/structure/thing in neighbor)
			if(!QDELETED(thing) && is_type_in_list(thing, join_types))
				joined = TRUE
				break
		if(joined)
			joined_dirs += direction
			continue
		if(!(direction in GLOB.cardinals))
			continue
		var/ends_here = istype(neighbor, /turf/closed/wall)
		for(var/obj/structure/machinery/door/door in neighbor)
			if(!istype(door, /obj/structure/machinery/door/window))
				ends_here = TRUE
				break
		if(ends_here)
			joined_dirs += direction
			edge_dirs += direction
	return list(dirs_to_corner_states(joined_dirs), dirs_to_corner_states(edge_dirs))

/// Redraws the Bay windows and window frames around source, whose corners depend on their neighbours in all eight directions
/proc/update_bay_low_walls_around(atom/source)
	for(var/obj/structure/thing in orange(1, source))
		if(istype(thing, /obj/structure/window/framed/bay) || istype(thing, /obj/structure/window_frame/bay))
			thing.relativewall()

/// What the health of a Bay window in the source is multiplied by here: a reinforced one has the health of a CM one
#define BAY_WINDOW_HEALTH_SCALE 0.8

/**
 * The health, name and description of a Bay window of the given materials, as /obj/structure/window/Initialize() of
 * the source works them out
 *
 * Returns list(health, name, description).
 * * glass - the material of the pane
 * * reinforcement - the material it is reinforced with, null for none
 */
/proc/bay_window_stats(material/glass, material/reinforcement)
	var/health = glass.integrity
	if(reinforcement)
		health += 0.5 * reinforcement.integrity
	var/name = "[reinforcement ? "[reinforcement.display_name]-reinforced " : ""][glass.display_name] window"
	var/desc = "A window pane made from [glass.display_name][reinforcement ? " and reinforced with [reinforcement.display_name]" : ""]."
	return list(round(health * BAY_WINDOW_HEALTH_SCALE), name, desc)

/**
 * A Bay window on its low wall
 *
 * The pane is of a glass material, reinforced with another, which give it its name, colour and health as in the
 * source; the low wall under it is of a material of its own and may be painted, and shows its stripe colour, else the
 * colour of its material (/obj/structure/wall_frame of the source). Drawn from overlays, one per corner as Bay draws
 * them: the greyscale low wall, then the glass, both from windows.dmi. The map editor shows the preview of the type.
 * The materials and paint pass to the low wall left when the glass breaks, and back to the window made on it. junction
 * is still set the CM way, for the weeds that grow on the window and the frame it leaves.
 */
/obj/structure/window/framed/bay
	name = "reinforced window"
	desc = "A window pane made from glass and reinforced with steel."
	icon = 'modular_chaos/universes/bay12/icons/turf/walls/windows.dmi'
	icon_state = "rwindow"
	basestate = "rwindow"
	health = 100
	reinf = TRUE
	window_frame = /obj/structure/window_frame/bay
	/// The material of the pane, a material name until resolve_materials(), then the /material
	var/material/glass_material = MATERIAL_GLASS
	/// The material the pane is reinforced with, a material name until resolve_materials(), then the /material; null for none
	var/material/glass_reinf_material = MATERIAL_STEEL
	/// The material of the low wall, a material name until resolve_materials(), then the /material
	var/material/frame_material = MATERIAL_STEEL
	/// Colour the low wall is painted, null if it is not; the low walls of the Torch are (/obj/structure/wall_frame/standard)
	var/frame_paint_color = COLOR_WALL_GUNMETAL
	/// Colour of the stripe of the low wall, which it shows; null if it has none
	var/frame_stripe_color = COLOR_GUNMETAL
	/// Whether buttons with the same id tint the glass (/obj/structure/window/reinforced/polarized in the source)
	var/polarized = FALSE
	/// Id of the window tint buttons that tint a polarized window
	var/id

/obj/structure/window/framed/bay/Initialize()
	var/obj/structure/window_frame/bay/frame = locate() in loc
	if(frame)
		frame.resolve_materials()
		frame_material = frame.frame_material
		frame_paint_color = frame.frame_paint_color
		frame_stripe_color = frame.frame_stripe_color
		if(frame.glass_material)
			glass_material = frame.glass_material
			glass_reinf_material = frame.glass_reinf_material
	resolve_materials()
	update_window_material()
	return ..()

/**
 * Turns the material names the window is mapped with into the materials
 *
 * Windows next to it draw it before it initializes, so they call this too.
 */
/obj/structure/window/framed/bay/proc/resolve_materials()
	if(istext(glass_material))
		glass_material = get_bay_material(glass_material)
	if(istext(glass_reinf_material))
		glass_reinf_material = get_bay_material(glass_reinf_material)
	if(istext(frame_material))
		frame_material = get_bay_material(frame_material)

/// Sets the health, name and description of the window from the materials of its pane
/obj/structure/window/framed/bay/proc/update_window_material()
	var/list/stats = bay_window_stats(glass_material, glass_reinf_material)
	health = stats[1]
	name = stats[2]
	desc = stats[3]
	reinf = !!glass_reinf_material

/// The colour the low wall shows: its stripe, else its material
/obj/structure/window/framed/bay/proc/frame_color()
	resolve_materials()
	return frame_stripe_color || frame_material.icon_colour

/obj/structure/window/framed/bay/handle_icon_junction(jun_1, jun_2)
	junction = jun_2 ? jun_2 : jun_1
	resolve_materials()
	icon_state = "blank"
	overlays.Cut()
	var/list/frame_corners = bay_low_wall_connections(src, list(/obj/structure/window/framed/bay, /obj/structure/window_frame/bay))
	var/list/glass_corners = bay_low_wall_connections(src, list(/obj/structure/window/framed/bay))
	var/list/frame_connections = frame_corners[1]
	var/list/glass_connections = glass_corners[1]
	var/list/edge_connections = frame_corners[2]
	var/glass_state = glass_reinf_material ? "rwindow" : "window"
	for(var/i in 1 to 4)
		var/image/frame = image(icon, "frame[edge_connections[i] != "0" ? "_other" : ""][frame_connections[i]]", dir = 1<<(i-1))
		frame.color = frame_color()
		overlays += frame
	for(var/i in 1 to 4)
		var/image/glass = image(icon, "[glass_state][edge_connections[i] != "0" ? "_other" : ""][glass_connections[i]]", dir = 1<<(i-1))
		glass.color = opacity ? GLASS_COLOR_TINTED : glass_material.icon_colour
		overlays += glass

/obj/structure/window/framed/bay/relativewall_neighbours()
	..()
	update_bay_low_walls_around(src)

/// Tints a polarized window or clears it, as /obj/structure/window/proc/toggle() does in the source
/obj/structure/window/framed/bay/proc/toggle_tint()
	if(!polarized)
		return
	set_opacity(!opacity)
	relativewall()

/**
 * A hull window: reinforced glass on a low wall in the blue of /turf/closed/wall/bay/reinforced/hull, which nothing gets
 * through, like the hull windows of CM ships
 */
/obj/structure/window/framed/bay/hull
	name = "hull window"
	desc = "A glass window with a rod matrix inside, set on a low wall. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	icon_state = "hull_rwindow"
	frame_paint_color = COLOR_SOL
	frame_stripe_color = COLOR_SOL
	window_frame = /obj/structure/window_frame/bay/hull
	not_damageable = TRUE
	not_deconstructable = TRUE
	unslashable = TRUE
	unacidable = TRUE

/obj/structure/window/framed/bay/hull/update_window_material()
	health = 1000000 //Failsafe, shouldn't matter

/// Plain glass on a low wall, /obj/structure/window/basic/full in the source
/obj/structure/window/framed/bay/basic
	icon_state = "window"
	basestate = "window"
	glass_reinf_material = null
	health = 40
	reinf = FALSE

/// Electrochromic glass, which window tint buttons of its id darken
/obj/structure/window/framed/bay/polarized
	polarized = TRUE

/// A reinforced window on a low wall of titanium
/obj/structure/window/framed/bay/titanium
	icon_state = "titanium_rwindow"
	frame_material = MATERIAL_TITANIUM
	frame_paint_color = null
	frame_stripe_color = null

/// Reinforced borosilicate glass, /obj/structure/window/boron_reinforced/full in the source: tougher, with a darker tint
/obj/structure/window/framed/bay/boron
	icon_state = "boron_rwindow"
	glass_material = MATERIAL_BORON_GLASS

/obj/structure/window/framed/bay/boron/titanium
	icon_state = "titanium_boron_rwindow"
	frame_material = MATERIAL_TITANIUM
	frame_paint_color = null
	frame_stripe_color = null

/// Borosilicate glass on a low wall of osmium-carbide plasteel
/obj/structure/window/framed/bay/boron/ocp
	icon_state = "ocp_boron_rwindow"
	frame_material = MATERIAL_OSMIUM_CARBIDE_PLASTEEL
	frame_paint_color = null
	frame_stripe_color = null

/**
 * The low wall of a Bay window, /obj/structure/wall_frame of the source: of a material, painted or not, and left when
 * the glass of a window breaks; reinforced glass makes it a window again
 */
/obj/structure/window_frame/bay
	name = "low wall"
	desc = "A low wall section which serves as the base of windows. Can be vaulted over."
	icon = 'modular_chaos/universes/bay12/icons/turf/walls/windows.dmi'
	icon_state = "frame"
	basestate = "frame"
	window_type = /obj/structure/window/framed/bay
	/// The material of the low wall, a material name until resolve_materials(), then the /material
	var/material/frame_material = MATERIAL_STEEL
	/// Colour the low wall is painted, null if it is not
	var/frame_paint_color
	/// Colour of its stripe, which it shows; null if it has none
	var/frame_stripe_color
	/// The material of the pane of the window that broke into it, which a window made on it gets; null if none did
	var/material/glass_material
	/// The material that pane was reinforced with
	var/material/glass_reinf_material

/obj/structure/window_frame/bay/Initialize(mapload, ...)
	var/obj/structure/window/framed/bay/window = locate() in loc // The window that broke into this frame
	if(window)
		window.resolve_materials()
		frame_material = window.frame_material
		frame_paint_color = window.frame_paint_color
		frame_stripe_color = window.frame_stripe_color
		glass_material = window.glass_material
		glass_reinf_material = window.glass_reinf_material
	resolve_materials()
	name = "[frame_material.use_name] [initial(name)]"
	return ..()

/// Turns the material name the low wall is mapped with into the material
/obj/structure/window_frame/bay/proc/resolve_materials()
	if(istext(frame_material))
		frame_material = get_bay_material(frame_material)

/obj/structure/window_frame/bay/handle_icon_junction(jun_1, jun_2)
	junction = jun_2 ? jun_2 : jun_1
	resolve_materials()
	icon_state = "blank"
	overlays.Cut()
	var/list/corners = bay_low_wall_connections(src, list(/obj/structure/window/framed/bay, /obj/structure/window_frame/bay))
	var/list/connections = corners[1]
	var/list/edge_connections = corners[2]
	for(var/i in 1 to 4)
		var/image/frame = image(icon, "frame[edge_connections[i] != "0" ? "_other" : ""][connections[i]]", dir = 1<<(i-1))
		frame.color = frame_stripe_color || frame_material.icon_colour
		overlays += frame

/obj/structure/window_frame/bay/relativewall_neighbours()
	..()
	update_bay_low_walls_around(src)

/// The low wall of a hull window
/obj/structure/window_frame/bay/hull
	icon_state = "hull_frame"
	frame_paint_color = COLOR_SOL
	frame_stripe_color = COLOR_SOL
	window_type = /obj/structure/window/framed/bay/hull

/**
 * A pane of Bay glass on one edge of a tile (/obj/structure/window in the source, not full-tile)
 *
 * Of a glass material reinforced with another, which give it its name, health and colour; the sprites are greyscale.
 */
/obj/structure/window/bay
	icon = 'modular_chaos/universes/bay12/icons/turf/walls/windows.dmi'
	icon_state = "window_border"
	basestate = "window_border"
	color = GLASS_COLOR
	/// The material of the pane, a material name until Initialize(), then the /material
	var/material/glass_material = MATERIAL_GLASS
	/// The material the pane is reinforced with, a material name until Initialize(), then the /material; null for none
	var/material/glass_reinf_material

/obj/structure/window/bay/Initialize(mapload, ...)
	if(istext(glass_material))
		glass_material = get_bay_material(glass_material)
	if(istext(glass_reinf_material))
		glass_reinf_material = get_bay_material(glass_reinf_material)
	var/list/stats = bay_window_stats(glass_material, glass_reinf_material)
	health = stats[1]
	name = stats[2]
	desc = stats[3]
	reinf = !!glass_reinf_material
	color = glass_material.icon_colour
	return ..()

/obj/structure/window/bay/reinforced
	icon_state = "rwindow_border"
	basestate = "rwindow_border"
	glass_reinf_material = MATERIAL_STEEL

/obj/structure/window/bay/reinforced/boron
	color = GLASS_COLOR_BORON
	glass_material = MATERIAL_BORON_GLASS

/// A full-tile electrochromic pane without a low wall, /obj/structure/window/reinforced/polarized/full in the source
/obj/structure/window/bay/reinforced/polarized_full
	icon_state = "rwindow_full"
	basestate = "rwindow_full"
	flags_atom = FPRINT
	/// Id of the window tint buttons that tint it
	var/id

/// Tints the pane or clears it, as /obj/structure/window/proc/toggle() does in the source
/obj/structure/window/bay/reinforced/polarized_full/proc/toggle_tint()
	animate(src, color = opacity ? glass_material.icon_colour : GLASS_COLOR_TINTED, time = 0.5 SECONDS)
	set_opacity(!opacity)

/**
 * A Bay grille (/obj/structure/grille in the source)
 *
 * Drawn by corners like a low wall: it joins other grilles and ends with an edge against walls and doors, and has
 * states of its own when it stands on a low wall, as the grilles under Bay windows do. The sprites are greyscale and
 * take the colour of steel. A destroyed one stays as a broken grille until it takes more damage, as CM grilles do.
 */
/obj/structure/grille/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/grille.dmi'
	icon_state = "grille"
	color = COLOR_STEEL

/obj/structure/grille/bay/Initialize(mapload, ...)
	. = ..()
	update_icon()
	for(var/obj/structure/grille/bay/neighbor in orange(1, src))
		neighbor.update_icon()

/obj/structure/grille/bay/Destroy()
	var/turf/old_loc = loc
	. = ..()
	for(var/obj/structure/grille/bay/neighbor in orange(1, old_loc))
		neighbor.update_icon()

/obj/structure/grille/bay/update_icon()
	. = ..()
	overlays.Cut()
	var/on_frame = (locate(/obj/structure/window_frame/bay) in loc) || (locate(/obj/structure/window/framed/bay) in loc)
	if(destroyed)
		icon_state = on_frame ? "broken_onframe" : "broken"
		return
	icon_state = "blank"
	var/list/corners = bay_low_wall_connections(src, list(/obj/structure/grille/bay))
	var/list/connections = corners[1]
	var/list/edge_connections = corners[2]
	for(var/i in 1 to 4)
		overlays += image(icon, "grille[edge_connections[i] != "0" ? "_other" : ""][on_frame ? "_onframe" : ""][connections[i]]", dir = 1<<(i-1))

/obj/structure/grille/bay/healthcheck()
	var/was_destroyed = destroyed
	. = ..()
	if(!QDELETED(src) && destroyed != was_destroyed)
		update_icon()
		for(var/obj/structure/grille/bay/neighbor in orange(1, src))
			neighbor.update_icon()

/obj/structure/grille/bay/broken
	icon_state = "broken"
	density = FALSE
	destroyed = TRUE
	health = 0

#undef BAY_WINDOW_HEALTH_SCALE
