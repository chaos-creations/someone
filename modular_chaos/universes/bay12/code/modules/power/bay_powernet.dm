//The power networks of Baystation 12 (code/modules/power/powernet.dm and power.dm in the source)

/area
	/**
	 * Whether the power machines of the area join networks along Bay cables, as in the source, instead of the network
	 * named by powernet_name that every machine of the area joins wherever it is. Set on the areas of Bay maps.
	 */
	var/bay_power = FALSE

/**
 * A Bay power network: the cables joined to each other and the power machines on their knots
 *
 * CM machines draw from it and feed it through the same procs as a CM network, which it shares the rationing between
 * APCs and the refund to SMES units with. On top of that, the SMES units charging from it (/obj/structure/machinery/power/smes/bay,
 * through their terminals) are given only what is left over once everything else drew, as in the source. A network is
 * made on demand when a machine looks for one on a cable that has none (bay_propagate_network()), and goes when its last
 * cable is cut.
 */
/datum/powernet/bay
	powernet_name = "bay"
	/// Every cable of the network
	var/list/cables = list()
	/// Power the SMES units charging from the network asked for this tick, in watts
	var/smes_demand = 0
	/// The SMES units charging from the network this tick
	var/list/inputting = list()

/datum/powernet/bay/New()
	. = ..()
	GLOB.powernets += src

/datum/powernet/bay/Destroy()
	for(var/obj/structure/cable/bay/cable as anything in cables)
		cable.powernet = null
	cables.Cut()
	for(var/obj/structure/machinery/power/machine as anything in nodes)
		machine.powernet = null
	nodes.Cut()
	inputting.Cut()
	GLOB.powernets -= src
	return ..()

/datum/powernet/bay/process()
	. = ..()
	// The SMES units charging from the network share what the rest of it left, as in /datum/powernet/proc/reset() of the source
	if(length(inputting) && smes_demand)
		var/percentage = clamp(max(avail - load, 0) / smes_demand * 100, 0, 100)
		for(var/obj/structure/machinery/power/smes/bay/smes as anything in inputting)
			if(!QDELETED(smes))
				load += smes.input_power(percentage)
	inputting.Cut()
	smes_demand = 0

/// Adds a cable to the network, taking it out of the network it was in
/datum/powernet/bay/proc/add_cable(obj/structure/cable/bay/cable)
	if(cable.powernet == src)
		return
	if(cable.powernet)
		var/datum/powernet/bay/old_network = cable.powernet
		old_network.remove_cable(cable)
	cable.powernet = src
	cables += cable

/// Takes a cable out of the network, which goes if nothing is left in it
/datum/powernet/bay/proc/remove_cable(obj/structure/cable/bay/cable)
	cables -= cable
	cable.powernet = null
	if(!length(cables) && !length(nodes))
		qdel(src)

/**
 * The cables and power machines on a turf that join a cable or machine there in a direction, /proc/power_list() of the source
 *
 * Arguments:
 * * target_turf - the turf searched
 * * source - the cable or machine searching, left out
 * * direction - the direction the things found must point: towards it or away from it, or 0 for knots and machines
 * * unmarked - if TRUE, only things without a network are returned
 * * cable_only - if TRUE, machines are left out
 */
/proc/bay_power_list(turf/target_turf, source, direction, unmarked = FALSE, cable_only = FALSE)
	. = list()
	var/reverse = direction ? REVERSE_DIR(direction) : 0
	for(var/atom/movable/thing as anything in target_turf)
		if(thing == source)
			continue
		if(!cable_only && istype(thing, /obj/structure/machinery/power))
			var/obj/structure/machinery/power/machine = thing
			if((!unmarked || !machine.powernet) && !direction)
				. += machine
		else if(istype(thing, /obj/structure/cable/bay))
			var/obj/structure/cable/bay/cable = thing
			if(unmarked && cable.powernet)
				continue
			if(cable.d1 == direction || cable.d2 == direction || cable.d1 == reverse || cable.d2 == reverse)
				. += cable

/**
 * Puts everything joined to a cable or machine into a network, then connects the machines found to it
 *
 * Arguments:
 * * start - the cable or machine to start from
 * * network - the network everything goes in
 */
/proc/bay_propagate_network(atom/start, datum/powernet/bay/network)
	var/list/worklist = list(start)
	var/list/found_machines = list()
	var/index = 1
	while(index <= length(worklist))
		var/atom/thing = worklist[index]
		index++
		if(istype(thing, /obj/structure/cable/bay))
			var/obj/structure/cable/bay/cable = thing
			network.add_cable(cable)
			worklist |= cable.get_bay_connections()
		else if(istype(thing, /obj/structure/machinery/power))
			var/obj/structure/machinery/power/machine = thing
			if(machine.anchored)
				found_machines |= machine
	for(var/obj/structure/machinery/power/machine as anything in found_machines)
		if(!machine.connect_to_network())
			machine.disconnect_from_network()

/**
 * Merges two networks, the one with more cables taking in the other, /proc/merge_powernets() of the source
 *
 * Returns the merged network.
 */
/proc/bay_merge_powernets(datum/powernet/bay/first, datum/powernet/bay/second)
	if(!first || !second || first == second)
		return first || second
	if(length(first.cables) < length(second.cables))
		var/datum/powernet/bay/swap = first
		first = second
		second = swap
	for(var/obj/structure/machinery/power/machine as anything in second.nodes.Copy())
		machine.disconnect_from_network()
		first.nodes |= machine
		machine.powernet = first
	for(var/obj/structure/cable/bay/cable as anything in second.cables.Copy())
		first.add_cable(cable)
	return first

/**
 * The turf a cable leads to in a direction: the next one on the same level, or the one above or below it for UP and DOWN
 *
 * Arguments:
 * * source - where the cable is
 * * direction - a direction, UP or DOWN
 */
/proc/bay_cable_step(atom/source, direction)
	switch(direction)
		if(UP)
			return SSmapping.get_turf_above(get_turf(source))
		if(DOWN)
			return SSmapping.get_turf_below(get_turf(source))
	return get_step(source, direction)

/// In an area with Bay power, the machine joins the network of the cable knot on its turf, as in the source
/obj/structure/machinery/power/connect_to_network()
	CAN_BE_REDEFINED(TRUE)
	var/area/machine_area = get_area(src)
	if(!machine_area?.bay_power)
		return ..()
	current_area = machine_area
	var/obj/structure/cable/bay/knot
	for(var/obj/structure/cable/bay/cable in loc)
		if(cable.d1 == 0)
			knot = cable
			break
	if(!knot)
		return FALSE
	if(!knot.powernet)
		bay_propagate_network(knot, new /datum/powernet/bay())
	if(powernet == knot.powernet)
		return TRUE
	if(powernet)
		disconnect_from_network()
	powernet = knot.powernet
	powernet.nodes |= src
	return TRUE
