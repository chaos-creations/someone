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
		var/image/glass = image(icon, "rwindow[edge_connections[i] != "0" ? "_other" : ""][glass_connections[i]]", dir = 1<<(i-1))
		glass.color = glass_color
		overlays += glass

/obj/structure/window/framed/bay/relativewall_neighbours()
	..()
	update_bay_low_walls_around(src)

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
