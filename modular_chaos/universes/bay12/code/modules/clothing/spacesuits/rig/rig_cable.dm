/// Charge of a SMES (/obj/structure/machinery/power/smes/var/charge) worth one charge of a cell; the SMES keeps its own SMESRATE define to itself
#define RIG_SMES_CHARGE_PER_CELL_CHARGE (0.05 / CELLRATE)

/**
 * Charging cable of a rig
 *
 * Pulled out of the rig into a hand (Alt-click on the rig, or its action), it plugs into an APC, a SMES or a working
 * generator next to the user, and then charges the cell of the rig for as long as the rig stays within reach of it,
 * worn or not. Let go of, it winds back into the rig.
 */
/obj/item/rig_cable
	name = "hardsuit charging cable"
	desc = "A reel of insulated cable with a universal power connector, wound into a hardsuit control module. Plug it into an APC, a SMES or a running generator to charge the suit."
	icon = 'icons/obj/structures/machinery/power.dmi'
	icon_state = "coil"
	color = COLOR_ORANGE
	w_class = SIZE_SMALL
	flags_item = NOBLUDGEON
	/// The rig it belongs to
	var/obj/item/rig/rig

/obj/item/rig_cable/Initialize(mapload, ...)
	. = ..()
	if(istype(loc, /obj/item/rig))
		rig = loc

/obj/item/rig_cable/Destroy()
	rig = null
	return ..()

/obj/item/rig_cable/equipped(mob/user, slot, silent)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_PRE_CLICK, PROC_REF(on_holder_click), override = TRUE)

/obj/item/rig_cable/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_PRE_CLICK)
	if(rig && loc != rig)
		INVOKE_ASYNC(rig, TYPE_PROC_REF(/obj/item/rig, retract_cable))

// The click is taken before the machine's own attackby(), which would have its own ideas about an item used on it
/obj/item/rig_cable/proc/on_holder_click(mob/source, atom/target, list/mods)
	SIGNAL_HANDLER
	if(source.get_active_hand() != src || mods[SHIFT_CLICK] || mods[ALT_CLICK] || mods[CTRL_CLICK] || mods[MIDDLE_CLICK])
		return NONE
	if(!istype(target, /obj/structure/machinery/power) || !source.Adjacent(target))
		return NONE
	var/obj/structure/machinery/power/machine = target
	if(!machine.can_charge_rigs())
		to_chat(source, SPAN_WARNING("[machine] has no connector for [src]."))
		return COMPONENT_INTERRUPT_CLICK
	INVOKE_ASYNC(rig, TYPE_PROC_REF(/obj/item/rig, connect_cable), machine, source)
	return COMPONENT_INTERRUPT_CLICK

/**
 * Returns whether a rig's charging cable can be plugged into this machine, see supply_rig_charge()
 */
/obj/structure/machinery/power/proc/can_charge_rigs()
	return FALSE

/**
 * Gives charge to a rig's charging cable or power sink
 *
 * Arguments:
 * * amount - the charge the rig wants, in the charge units of /obj/item/cell
 *
 * Returns how much it gave.
 */
/obj/structure/machinery/power/proc/supply_rig_charge(amount)
	return 0

/obj/structure/machinery/power/apc/can_charge_rigs()
	return TRUE

/obj/structure/machinery/power/apc/supply_rig_charge(amount)
	if(!cell || (stat & BROKEN))
		return 0
	var/given = min(amount, cell.charge)
	cell.use(given)
	return given

/obj/structure/machinery/power/smes/can_charge_rigs()
	return TRUE

/obj/structure/machinery/power/smes/supply_rig_charge(amount)
	if(stat & BROKEN)
		return 0
	var/given = min(amount, charge / RIG_SMES_CHARGE_PER_CELL_CHARGE)
	charge -= given * RIG_SMES_CHARGE_PER_CELL_CHARGE
	return given

/obj/structure/machinery/power/power_generator/can_charge_rigs()
	return TRUE

// A generator gives what it makes, not what it stores: as much as its power output would charge a cell with
/obj/structure/machinery/power/power_generator/supply_rig_charge(amount)
	if(!is_on || crit_fail || power_gen_percent <= 0)
		return 0
	return min(amount, power_gen * power_gen_percent * 0.01 * CELLRATE)

/**
 * Puts the charging cable into the user's hands
 *
 * Arguments:
 * * user - who pulls it out
 */
/obj/item/rig/proc/pull_cable(mob/user)
	if(!ishuman(user) || user.is_mob_incapacitated())
		return
	if(charging_source)
		disconnect_cable()
		to_chat(user, SPAN_NOTICE("You unplug the charging cable of [src] and let it wind back."))
		return
	if(cable.loc != src)
		retract_cable()
		return
	if(!user.put_in_hands(cable))
		to_chat(user, SPAN_WARNING("You need a free hand to pull out the charging cable."))
		return
	to_chat(user, SPAN_NOTICE("You pull the charging cable out of [src]."))

/// Winds the charging cable back into the rig from wherever it is
/obj/item/rig/proc/retract_cable()
	if(QDELETED(cable) || cable.loc == src)
		return
	if(ismob(cable.loc))
		var/mob/holder = cable.loc
		holder.drop_inv_item_to_loc(cable, src, force = TRUE)
	else
		cable.forceMove(src)

/**
 * Plugs the charging cable into a machine
 *
 * Arguments:
 * * machine - the APC, SMES or generator
 * * user - who plugs it in
 */
/obj/item/rig/proc/connect_cable(obj/structure/machinery/power/machine, mob/user)
	disconnect_cable()
	retract_cable()
	charging_source = machine
	RegisterSignal(charging_source, COMSIG_PARENT_QDELETING, PROC_REF(on_charging_source_deleted))
	update_cable_beam()
	playsound(machine, 'sound/machines/click.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] plugs the charging cable of [src] into [machine]."),
		SPAN_NOTICE("You plug the charging cable of [src] into [machine]."))

/// Unplugs the charging cable
/obj/item/rig/proc/disconnect_cable()
	if(!charging_source)
		return
	UnregisterSignal(charging_source, COMSIG_PARENT_QDELETING)
	charging_source = null
	QDEL_NULL(cable_beam)

/obj/item/rig/proc/on_charging_source_deleted(datum/source)
	SIGNAL_HANDLER
	disconnect_cable()

/// Returns what the plugged in cable starts from: the wearer, the rig on the floor, or null if the rig is packed away
/obj/item/rig/proc/get_cable_end()
	if(isturf(loc))
		return src
	if(ismob(loc) && isturf(loc.loc))
		return loc
	return null

/// Redraws the beam along the plugged in cable, from wherever the rig is now
/obj/item/rig/proc/update_cable_beam()
	QDEL_NULL(cable_beam)
	if(!charging_source)
		return
	var/atom/cable_end = get_cable_end()
	if(!cable_end)
		return
	cable_beam = cable_end.beam(charging_source, "wire", maxdistance = cable_length + 1)

/**
 * Charges the cell through the plugged in cable, and unplugs it when the rig got too far
 *
 * Arguments:
 * * delta_time - seconds since the last process
 */
/obj/item/rig/proc/process_cable(delta_time)
	if(!charging_source)
		return
	var/atom/cable_end = get_cable_end()
	if(!cable_end || cable_end.z != charging_source.z || get_dist(cable_end, charging_source) > cable_length)
		var/atom/movable/yanker = cable_end || src
		yanker.visible_message(SPAN_WARNING("The charging cable of [src] is yanked out of [charging_source]!"))
		disconnect_cable()
		return
	if(QDELETED(cable_beam) || cable_beam.origin != cable_end)
		update_cable_beam()
	if(!cell || cell.charge >= cell.maxcharge)
		return
	give_power(charging_source.supply_rig_charge(min(cable_charge_rate * delta_time, cell.maxcharge - cell.charge)))

#undef RIG_SMES_CHARGE_PER_CELL_CHARGE
