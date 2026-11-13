//Power cables of Baystation 12 (code/modules/power/cable_structure.dm in the source)

/**
 * A Bay power cable
 *
 * A CM cable, hidden under floor tiles and cut with wirecutters as those are, that carries power as in the source: it
 * joins the cables pointing at it on the next turf, the cables sharing a direction with it on its own turf, and through
 * UP and DOWN the cables of the decks above and below. A knot (a cable starting in the middle of its turf, d1 0) joins
 * the power machines on its turf. Its network (/datum/powernet/bay) is made when a machine asks for one; a cable cut out
 * of a network splits it.
 */
/obj/structure/cable/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/power_cond_white.dmi'
	color = CABLE_COLOR_RED

/obj/structure/cable/bay/Destroy()
	if(powernet)
		cut_cable_from_powernet()
	return ..()

/**
 * The cables and machines joined to this cable, /obj/structure/cable/proc/get_connections() of the source
 *
 * Arguments:
 * * unmarked_only - if TRUE, only the ones without a network
 */
/obj/structure/cable/bay/proc/get_bay_connections(unmarked_only = FALSE)
	. = list()
	for(var/cable_dir in list(d1, d2))
		if(!cable_dir)
			continue
		var/reverse = REVERSE_DIR(cable_dir)
		var/turf/next = bay_cable_step(src, cable_dir)
		if(next)
			for(var/obj/structure/cable/bay/cable in next)
				if(cable.d1 == reverse || cable.d2 == reverse)
					. += cable
		if(cable_dir & (cable_dir - 1)) // A diagonal also joins the cables along the two cardinal turfs beside it
			for(var/pair in list(NORTH|SOUTH, EAST|WEST))
				var/turf/side = get_step(src, cable_dir & pair)
				if(!side)
					continue
				var/required_dir = cable_dir ^ pair
				for(var/obj/structure/cable/bay/cable in side)
					if(cable.d1 == required_dir || cable.d2 == required_dir)
						. += cable
	for(var/obj/structure/cable/bay/cable in loc)
		if(cable != src && (cable.d1 == d1 || cable.d2 == d1 || cable.d1 == d2 || cable.d2 == d2))
			. += cable
	if(d1 == 0)
		for(var/obj/structure/machinery/power/machine in loc)
			if(!unmarked_only || !machine.powernet)
				. += machine
	if(unmarked_only)
		for(var/obj/structure/cable/bay/cable in .)
			if(cable.powernet)
				. -= cable

/// Takes the cable out of its network, splitting what it joined, /obj/structure/cable/proc/cut_cable_from_powernet() of the source
/obj/structure/cable/bay/proc/cut_cable_from_powernet()
	var/datum/powernet/bay/old_network = powernet
	var/list/joined = get_bay_connections()
	var/turf/old_loc = loc
	old_network.remove_cable(src)
	if(!length(joined))
		return
	// Leave the turf so the new networks do not run through this cable, then rebuild each side that is not joined yet
	moveToNullspace()
	for(var/atom/thing as anything in joined)
		if(QDELETED(thing))
			continue
		var/obj/structure/cable/bay/cable = thing
		if(istype(cable) && (!cable.powernet || cable.powernet == old_network))
			bay_propagate_network(cable, new /datum/powernet/bay())
	if(d1 == 0)
		for(var/obj/structure/machinery/power/machine in old_loc)
			if(!machine.connect_to_network())
				machine.disconnect_from_network()
	if(!QDELETED(old_network) && !length(old_network.cables))
		qdel(old_network)

/obj/structure/cable/bay/yellow
	color = CABLE_COLOR_YELLOW

/obj/structure/cable/bay/green
	color = CABLE_COLOR_GREEN

/obj/structure/cable/bay/blue
	color = CABLE_COLOR_BLUE

/obj/structure/cable/bay/orange
	color = CABLE_COLOR_ORANGE

/obj/structure/cable/bay/cyan
	color = CABLE_COLOR_CYAN

/obj/structure/cable/bay/white
	color = CABLE_COLOR_WHITE

/obj/structure/cable/bay/black
	color = CABLE_COLOR_BLACK
