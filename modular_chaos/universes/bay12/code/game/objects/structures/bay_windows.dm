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

/**
 * A Bay reinforced window on its low wall
 *
 * Drawn from overlays, one per corner as Bay draws them: the greyscale low wall in frame_color, then the glass in
 * glass_color, both from windows.dmi. Mappers can recolour a placed one; the map editor shows the preview of the type.
 * The colours pass to the low wall left when the glass breaks, and back to the window made on it. junction is still
 * set the CM way, for the weeds that grow on the window and the frame it leaves.
 */
/obj/structure/window/framed/bay
	name = "reinforced window"
	desc = "A glass window with a rod matrix inside, set on a low wall. It looks rather strong. Might take a few good hits to shatter it."
	icon = 'modular_chaos/universes/bay12/icons/turf/walls/windows.dmi'
	icon_state = "rwindow"
	basestate = "rwindow"
	health = 100
	reinf = TRUE
	window_frame = /obj/structure/window_frame/bay
	/// Colour of the low wall under the glass; Bay colours a low wall with its stripe colour (/obj/structure/wall_frame/standard)
	var/frame_color = COLOR_GUNMETAL
	/// Colour of the glass
	var/glass_color = GLASS_COLOR
	/// Prefix of the corner states of the glass: "rwindow" for reinforced glass, "window" for plain glass
	var/glass_state = "rwindow"
	/// Whether buttons with the same id tint the glass (/obj/structure/window/reinforced/polarized in the source)
	var/polarized = FALSE
	/// Id of the window tint buttons that tint a polarized window
	var/id

/obj/structure/window/framed/bay/Initialize()
	var/obj/structure/window_frame/bay/frame = locate() in loc
	if(frame)
		frame_color = frame.frame_color
		glass_color = frame.glass_color
	return ..()

/obj/structure/window/framed/bay/handle_icon_junction(jun_1, jun_2)
	junction = jun_2 ? jun_2 : jun_1
	icon_state = "blank"
	overlays.Cut()
	var/list/frame_corners = bay_low_wall_connections(src, list(/obj/structure/window/framed/bay, /obj/structure/window_frame/bay))
	var/list/glass_corners = bay_low_wall_connections(src, list(/obj/structure/window/framed/bay))
	var/list/frame_connections = frame_corners[1]
	var/list/glass_connections = glass_corners[1]
	var/list/edge_connections = frame_corners[2]
	for(var/i in 1 to 4)
		var/image/frame = image(icon, "frame[edge_connections[i] != "0" ? "_other" : ""][frame_connections[i]]", dir = 1<<(i-1))
		frame.color = frame_color
		overlays += frame
	for(var/i in 1 to 4)
		var/image/glass = image(icon, "[glass_state][edge_connections[i] != "0" ? "_other" : ""][glass_connections[i]]", dir = 1<<(i-1))
		glass.color = opacity ? GLASS_COLOR_TINTED : glass_color
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

/// A hull window: a low wall in the blue of /turf/closed/wall/bay/reinforced/hull, and glass nothing gets through
/obj/structure/window/framed/bay/hull
	name = "hull window"
	desc = "A glass window with a rod matrix inside, set on a low wall. This one was made out of exotic materials to prevent hull breaches. No way to get through here."
	icon_state = "hull_rwindow"
	frame_color = COLOR_SOL
	window_frame = /obj/structure/window_frame/bay/hull
	not_damageable = TRUE
	not_deconstructable = TRUE
	unslashable = TRUE
	unacidable = TRUE
	health = 1000000 //Failsafe, shouldn't matter

/// Plain glass on a low wall, /obj/structure/window/basic/full in the source
/obj/structure/window/framed/bay/basic
	name = "window"
	desc = "A glass window set on a low wall. It looks thin and flimsy. A few knocks with anything should shatter it."
	icon_state = "window"
	basestate = "window"
	glass_state = "window"
	health = 40
	reinf = FALSE

/// Electrochromic glass, which window tint buttons of its id darken
/obj/structure/window/framed/bay/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	polarized = TRUE

/// A reinforced window on a low wall of titanium
/obj/structure/window/framed/bay/titanium
	icon_state = "titanium_rwindow"
	frame_color = COLOR_TITANIUM

/// Reinforced borosilicate glass, /obj/structure/window/boron_reinforced/full in the source: tougher, with a darker tint
/obj/structure/window/framed/bay/boron
	name = "reinforced borosilicate window"
	desc = "A borosilicate glass window with a rod matrix inside, set on a low wall. It looks very strong."
	icon_state = "boron_rwindow"
	glass_color = GLASS_COLOR_BORON
	health = 150

/obj/structure/window/framed/bay/boron/titanium
	icon_state = "titanium_boron_rwindow"
	frame_color = COLOR_TITANIUM

/// Borosilicate glass on a low wall of osmium-carbide plasteel
/obj/structure/window/framed/bay/boron/ocp
	icon_state = "ocp_boron_rwindow"
	frame_color = COLOR_OSMIUM_CARBIDE_PLASTEEL

/// The low wall of a Bay window, left when its glass breaks; reinforced glass makes it a window again
/obj/structure/window_frame/bay
	name = "low wall"
	desc = "A low wall section which serves as the base of windows. Can be vaulted over."
	icon = 'modular_chaos/universes/bay12/icons/turf/walls/windows.dmi'
	icon_state = "frame"
	basestate = "frame"
	window_type = /obj/structure/window/framed/bay
	/// Colour of the low wall, as /obj/structure/window/framed/bay/var/frame_color
	var/frame_color = COLOR_GUNMETAL
	/// Colour of the glass of the window made on it
	var/glass_color = GLASS_COLOR

/obj/structure/window_frame/bay/Initialize(mapload, ...)
	var/obj/structure/window/framed/bay/window = locate() in loc // The window that broke into this frame
	if(window)
		frame_color = window.frame_color
		glass_color = window.glass_color
	return ..()

/obj/structure/window_frame/bay/handle_icon_junction(jun_1, jun_2)
	junction = jun_2 ? jun_2 : jun_1
	icon_state = "blank"
	overlays.Cut()
	var/list/corners = bay_low_wall_connections(src, list(/obj/structure/window/framed/bay, /obj/structure/window_frame/bay))
	var/list/connections = corners[1]
	var/list/edge_connections = corners[2]
	for(var/i in 1 to 4)
		var/image/frame = image(icon, "frame[edge_connections[i] != "0" ? "_other" : ""][connections[i]]", dir = 1<<(i-1))
		frame.color = frame_color
		overlays += frame

/obj/structure/window_frame/bay/relativewall_neighbours()
	..()
	update_bay_low_walls_around(src)

/// The low wall of a hull window
/obj/structure/window_frame/bay/hull
	icon_state = "hull_frame"
	frame_color = COLOR_SOL
	window_type = /obj/structure/window/framed/bay/hull

/**
 * A pane of Bay glass on one edge of a tile (/obj/structure/window in the source, not full-tile)
 *
 * The sprites are greyscale and take the colour of the glass from color.
 */
/obj/structure/window/bay
	icon = 'modular_chaos/universes/bay12/icons/turf/walls/windows.dmi'
	icon_state = "window_border"
	basestate = "window_border"
	color = GLASS_COLOR

/obj/structure/window/bay/reinforced
	name = "reinforced window"
	desc = "A glass window reinforced with bracing rods. It looks rather strong. Might take a few good hits to shatter it."
	icon_state = "rwindow_border"
	basestate = "rwindow_border"
	health = 40
	reinf = TRUE

/obj/structure/window/bay/reinforced/boron
	name = "reinforced borosilicate window"
	desc = "A borosilicate glass window reinforced with bracing rods. It looks very strong."
	color = GLASS_COLOR_BORON
	health = 80

/// A full-tile electrochromic pane without a low wall, /obj/structure/window/reinforced/polarized/full in the source
/obj/structure/window/bay/reinforced/polarized_full
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	icon_state = "rwindow_full"
	basestate = "rwindow_full"
	flags_atom = FPRINT
	/// Id of the window tint buttons that tint it
	var/id

/// Tints the pane or clears it, as /obj/structure/window/proc/toggle() does in the source
/obj/structure/window/bay/reinforced/polarized_full/proc/toggle_tint()
	animate(src, color = opacity ? initial(color) : GLASS_COLOR_TINTED, time = 0.5 SECONDS)
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
