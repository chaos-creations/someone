//The coat of paint of Baystation 12 (/obj/paint in code/game/objects/effects/misc.dm of the source)

/**
 * A mapping helper that paints the Bay wall or low wall it is placed on in its colour, then deletes itself
 *
 * A wall takes the colour as its paint and stripe where its material takes them; a low wall, with or without glass,
 * as its paint and stripe. The walls and low walls around are redrawn, as their edges depend on the paint.
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
		wall.paint(color)
	for(var/obj/structure/window/framed/bay/window in loc)
		window.frame_paint_color = color
		window.frame_stripe_color = color
		window.relativewall()
	for(var/obj/structure/window_frame/bay/frame in loc)
		frame.frame_paint_color = color
		frame.frame_stripe_color = color
		frame.relativewall()
	qdel(src)

/// The blue of the hulls of the Sol Central Government
/obj/effect/bay_paint/hull
	color = COLOR_SOL

/obj/effect/bay_paint/red
	color = COLOR_RED

/obj/effect/bay_paint/silver
	color = COLOR_SILVER
