//Railings and handrails of Baystation 12 (code/game/objects/structures/railing.dm and handrail.dm in the source)

/**
 * A Bay railing, /obj/structure/railing/mapped in the source: aluminium, painted gunmetal
 *
 * A CM handrail barricade, so it blocks, takes damage and is climbed over as those do, drawn the way the source draws
 * its railings: it joins the railings beside and around the corner from it, and the part in front of a mob goes above
 * it. It cannot be reinforced into a barricade, as that draws CM sprites.
 */
/obj/structure/barricade/handrail/bay
	name = "aluminium railing"
	desc = "A simple aluminium railing designed to protect against careless trespass."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/railing.dmi'
	icon_state = "railing_preview"
	color = COLOR_GUNMETAL
	health = 70
	maxhealth = 70
	can_be_reinforced = FALSE
	/// Bit flags of the railings joined to this one, as /obj/structure/railing/var/neighbor_status in the source
	var/neighbor_status = 0

/obj/structure/barricade/handrail/bay/Initialize(mapload, ...)
	. = ..()
	update_railings_around()

/obj/structure/barricade/handrail/bay/Destroy()
	var/turf/old_loc = loc
	. = ..()
	for(var/obj/structure/barricade/handrail/bay/neighbor in range(1, old_loc))
		neighbor.update_icon()

/obj/structure/barricade/handrail/bay/setDir(newdir)
	. = ..()
	if(!QDELETED(src))
		update_railings_around()

/// Redraws this railing and the ones around it, which may join it
/obj/structure/barricade/handrail/bay/proc/update_railings_around()
	for(var/obj/structure/barricade/handrail/bay/neighbor in range(1, src))
		neighbor.update_icon()

/// Works out which railings join this one, /obj/structure/railing/proc/NeighborsCheck() in the source
/obj/structure/barricade/handrail/bay/proc/check_neighbors()
	neighbor_status = 0
	var/right_turn = turn(dir, -90)
	var/left_turn = turn(dir, 90)
	for(var/obj/structure/barricade/handrail/bay/railing in loc)
		if(railing.anchored && railing.dir == left_turn)
			neighbor_status |= 32
		if(railing.anchored && railing.dir == right_turn)
			neighbor_status |= 2
	for(var/obj/structure/barricade/handrail/bay/railing in get_step(src, left_turn))
		if(railing.anchored && railing.dir == dir)
			neighbor_status |= 16
	for(var/obj/structure/barricade/handrail/bay/railing in get_step(src, right_turn))
		if(railing.anchored && railing.dir == dir)
			neighbor_status |= 1
	for(var/obj/structure/barricade/handrail/bay/railing in get_step(src, left_turn|dir))
		if(railing.anchored && railing.dir == right_turn)
			neighbor_status |= 64
	for(var/obj/structure/barricade/handrail/bay/railing in get_step(src, right_turn|dir))
		if(railing.anchored && railing.dir == left_turn)
			neighbor_status |= 4

/obj/structure/barricade/handrail/bay/update_icon()
	overlays.Cut()
	layer = OBJ_LAYER
	pixel_y = initial(pixel_y) + (anchored ? 0 : 2)
	check_neighbors()
	if(!neighbor_status || !anchored)
		icon_state = "railing0-1"
		overlays += image(icon, "_railing0-1", layer = ABOVE_MOB_LAYER)
		return
	icon_state = "railing1-1"
	overlays += image(icon, "_railing1-1", layer = ABOVE_MOB_LAYER)
	if(neighbor_status & 32)
		overlays += image(icon, "corneroverlay1")
	if((neighbor_status & 16) || !(neighbor_status & 32) || (neighbor_status & 64))
		overlays += image(icon, "frontoverlay_l1")
		overlays += image(icon, "_frontoverlay_l1", layer = ABOVE_MOB_LAYER)
	if(!(neighbor_status & 2) || (neighbor_status & 1) || (neighbor_status & 4))
		overlays += image(icon, "frontoverlay_r1")
		overlays += image(icon, "_frontoverlay_r1", layer = ABOVE_MOB_LAYER)
		if(neighbor_status & 4)
			var/offset_x = 0
			var/offset_y = 0
			switch(dir)
				if(NORTH)
					offset_x = world.icon_size
				if(SOUTH)
					offset_x = -world.icon_size
				if(EAST)
					offset_y = -world.icon_size
				if(WEST)
					offset_y = world.icon_size
			var/image/corner = image(icon, "mcorneroverlay1")
			corner.pixel_x = offset_x
			corner.pixel_y = offset_y
			overlays += corner
			var/image/corner_front = image(icon, "_mcorneroverlay1", layer = ABOVE_MOB_LAYER)
			corner_front.pixel_x = offset_x
			corner_front.pixel_y = offset_y
			overlays += corner_front

/// A rail on the wall to buckle to when the floor isn't stable, /obj/structure/handrail in the source
/obj/structure/bay_handrail
	name = "handrail"
	desc = "A safety railing with buckles to secure yourself to when floor isn't stable enough."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/handrail.dmi'
	icon_state = "handrail"
	density = FALSE
	anchored = TRUE
	can_buckle = TRUE
