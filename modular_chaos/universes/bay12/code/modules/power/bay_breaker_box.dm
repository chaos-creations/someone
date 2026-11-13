//Breaker boxes of Baystation 12 (code/modules/power/breaker_box.dm in the source)

/**
 * A Bay breaker box
 *
 * Switched on, it lays Bay cables from its middle to every cable next to it that points at it, joining their networks
 * into one; switched off, it takes them up again. The substations of the Torch have activated ones, which feed the
 * decks straight from the main bus until engineers bring the substation SMES units online.
 */
/obj/structure/machinery/power/breakerbox/bay
	name = "breaker box"
	desc = "Large machine with heavy duty switching circuits used for advanced grid control."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/breakerbox.dmi'
	icon_state = "bbox"
	icon_state_on = "bbox"
	icon_state_off = "bbox"

/obj/structure/machinery/power/breakerbox/bay/set_state(state)
	on = state
	if(!on)
		for(var/obj/structure/cable/bay/cable in loc)
			if(cable.breaker_box == src)
				qdel(cable)
		update_icon()
		return
	var/list/links = list()
	var/list/old_networks = list()
	for(var/direction in directions)
		var/reverse = REVERSE_DIR(direction)
		for(var/obj/structure/cable/bay/cable in get_step(src, direction))
			if(cable.d1 != reverse && cable.d2 != reverse)
				continue
			var/obj/structure/cable/bay/link = new(loc)
			link.d1 = 0
			link.d2 = direction
			link.updateicon()
			link.breaker_box = src
			links += link
			if(cable.powernet)
				old_networks |= cable.powernet
			break
	// Before the networks are first made, the links are taken in with the rest; after, they join what they touch
	if(length(links) && length(old_networks))
		bay_propagate_network(links[1], new /datum/powernet/bay())
		for(var/datum/powernet/bay/old_network as anything in old_networks)
			if(!QDELETED(old_network) && !length(old_network.cables))
				qdel(old_network)
	update_icon()

/obj/structure/machinery/power/breakerbox/bay/update_icon()
	overlays.Cut()
	if(on)
		overlays += image(icon, "bbox_lights")

/// A breaker box switched on when the map loads, which keeps its substation bypassed
/obj/structure/machinery/power/breakerbox/bay/activated

/obj/structure/machinery/power/breakerbox/bay/activated/Initialize()
	. = ..()
	set_state(TRUE)
