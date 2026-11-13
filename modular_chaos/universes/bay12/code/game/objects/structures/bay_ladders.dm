//Ladders and stairs between the decks of Baystation 12 (code/modules/multiz/structures.dm in the source)

/**
 * A Bay ladder
 *
 * A CM ladder that links to the ladders straight above and below it, as the source links them, instead of by id and
 * height: one that goes down (the default) to a ladder on the deck below, one that goes up to a ladder on the deck
 * above.
 */
/obj/structure/ladder/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/ladders.dmi'
	icon_state = "ladder01"
	/// UP and DOWN: the ways the ladder goes, /obj/structure/ladder/var/allowed_directions in the source
	var/allowed_directions = DOWN

/// Links the ladders on the same tile of the decks above and below; the parent's linking by id is not used
/obj/structure/ladder/bay/LateInitialize()
	if(allowed_directions & UP)
		up = locate(/obj/structure/ladder/bay) in SSmapping.get_turf_above(loc)
	if(allowed_directions & DOWN)
		down = locate(/obj/structure/ladder/bay) in SSmapping.get_turf_below(loc)
	update_icon()

/obj/structure/ladder/bay/up
	icon_state = "ladder10"
	allowed_directions = UP

/obj/structure/ladder/bay/updown
	icon_state = "ladder11"
	allowed_directions = UP|DOWN

/**
 * Bay stairs: the top step of a flight going up in their dir
 *
 * CM stairs up, which take a mob walking off them in their dir to the deck above, drawn with the 64x64 sprite of the
 * source over both steps. The source lets mobs walk back down onto the stairs; here the landing above gets the CM
 * stairs down, which have no sprite as the flight shows from above.
 */
/obj/structure/stairs/multiz/up/bay
	name = "stairs"
	desc = "Stairs leading to another deck.  Not too useful if the gravity goes out."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/stairs.dmi'
	icon_state = "above"

/obj/structure/stairs/multiz/up/bay/LateInitialize()
	. = ..()
	var/turf/landing = SSmapping.get_turf_above(get_step(src, dir))
	if(landing && !(locate(/obj/structure/stairs/multiz/down) in landing))
		var/obj/structure/stairs/multiz/down/bay/down = new(landing)
		down.setDir(dir)

/obj/structure/stairs/multiz/up/bay/north
	dir = NORTH
	pixel_y = -32

/obj/structure/stairs/multiz/up/bay/south
	dir = SOUTH

/obj/structure/stairs/multiz/up/bay/east
	dir = EAST
	pixel_x = -32

/obj/structure/stairs/multiz/up/bay/west
	dir = WEST

/// The way down at the top of Bay stairs, made by them; it has no sprite of its own
/obj/structure/stairs/multiz/down/bay
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
