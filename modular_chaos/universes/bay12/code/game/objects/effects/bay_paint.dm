//The coat of paint of Baystation 12 (/obj/paint in code/game/objects/effects/misc.dm of the source)

/**
 * A mapping helper that paints the Bay wall or low wall it is placed on in its colour, then deletes itself
 *
 * A wall takes the colour as its paint and, if it can have one, its stripe; a low wall, with or without glass, takes it
 * as its frame colour. The walls and low walls around are redrawn, as their edges depend on the paint.
 */
/obj/effect/bay_paint
	name = "coat of paint"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"

/obj/effect/bay_paint/Initialize(mapload, ...)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/bay_paint/LateInitialize()
	var/turf/closed/wall/bay/wall = loc
	if(istype(wall))
		wall.paint_color = color
		if(wall.paintable_stripe)
			wall.stripe_color = color
		for(var/turf/closed/wall/bay/painted_wall in range(1, wall))
			painted_wall.update_connections()
			painted_wall.update_icon()
	for(var/obj/structure/window/framed/bay/window in loc)
		window.frame_color = color
		window.relativewall()
	for(var/obj/structure/window_frame/bay/frame in loc)
		frame.frame_color = color
		frame.relativewall()
	qdel(src)

/// The blue of the hulls of the Sol Central Government
/obj/effect/bay_paint/hull
	color = COLOR_SOL

/obj/effect/bay_paint/red
	color = COLOR_RED

/obj/effect/bay_paint/silver
	color = COLOR_SILVER
