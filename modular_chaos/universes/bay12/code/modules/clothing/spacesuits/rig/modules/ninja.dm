/**
 * Teleporter module, a short-range phase projector
 *
 * Using it readies it, and the next click on a free spot in view puts the wearer there.
 */
/obj/item/rig_module/teleporter
	name = "hardsuit teleportation module"
	desc = "A complex, sleek-looking, hardsuit-integrated teleportation module."
	icon_state = "teleporter"
	interface_name = "VOID-shift phase projector"
	interface_desc = "An advanced teleportation system that puts the wearer on a free spot in view."
	targeted = TRUE
	use_power_cost = 1500
	module_cooldown = 6 SECONDS
	/// How far, in tiles, it teleports at most
	var/max_range = 7

/obj/item/rig_module/teleporter/engage(atom/target)
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer || !target)
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(!isturf(wearer.loc) || !target_turf)
		to_chat(wearer, SPAN_WARNING("You can't teleport from here."))
		return FALSE
	if(target_turf.z != wearer.z || get_dist(wearer, target_turf) > max_range || !(target_turf in view(max_range, wearer)))
		to_chat(wearer, SPAN_WARNING("That is too far away to teleport to."))
		return FALSE
	if(is_admin_level(target_turf.z) || target_turf.density)
		to_chat(wearer, SPAN_WARNING("You can't teleport there."))
		return FALSE
	for(var/atom/movable/thing as anything in target_turf)
		if(thing.density)
			to_chat(wearer, SPAN_WARNING("You can't teleport into [thing]."))
			return FALSE
	. = ..()
	if(!.)
		return
	var/turf/origin_turf = get_turf(wearer)
	make_sparks(origin_turf)
	playsound(origin_turf, 'sound/effects/phasein.ogg', 25, TRUE)
	wearer.forceMove(target_turf)
	make_sparks(target_turf)
	playsound(target_turf, 'sound/effects/phasein.ogg', 25, TRUE)
	wearer.visible_message(SPAN_WARNING("[wearer] appears out of thin air!"), SPAN_NOTICE("You phase through space."))

/**
 * Makes a puff of sparks
 *
 * Arguments:
 * * location - the turf
 */
/obj/item/rig_module/teleporter/proc/make_sparks(turf/location)
	var/datum/effect_system/spark_spread/sparks = new()
	sparks.set_up(5, FALSE, location)
	sparks.start()
	QDEL_IN(sparks, 2 SECONDS)

/**
 * Power sink module, which drains power from an APC, a SMES or a generator through the gauntlets
 *
 * Using it readies it, and the next click on a machine next to the wearer starts draining it into the rig's cell,
 * much faster than the charging cable does, until the cell is full, the machine is empty or the wearer steps away.
 * Using it again while it drains stops it.
 */
/obj/item/rig_module/power_sink
	name = "hardsuit power sink"
	desc = "A heavy-duty power sink."
	icon_state = "powersink"
	interface_name = "niling d-sink"
	interface_desc = "Colloquially known as a power siphon, this module drains power through the suit's hands into the suit's cell."
	targeted = TRUE
	/// Charge it drains a second at most
	var/drain_rate = 300
	/// The machine it drains
	var/obj/structure/machinery/power/drained_machine
	/// Charge it drained from the machine so far
	var/total_drained = 0

/obj/item/rig_module/power_sink/get_status_name()
	if(drained_machine)
		return "[interface_name] (draining)"
	return ..()

/obj/item/rig_module/power_sink/use_module()
	if(drained_machine)
		stop_draining()
		return RIG_MODULE_USE_DONE
	return ..()

/obj/item/rig_module/power_sink/engage(atom/target)
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer || drained_machine)
		return FALSE
	if(!istype(target, /obj/structure/machinery/power) || !wearer.Adjacent(target))
		to_chat(wearer, SPAN_WARNING("[capitalize(interface_name)] needs an APC, a SMES or a generator next to you."))
		return FALSE
	var/obj/structure/machinery/power/machine = target
	if(!machine.can_charge_rigs())
		to_chat(wearer, SPAN_WARNING("[machine] can't be drained."))
		return FALSE
	. = ..()
	if(!.)
		return
	drained_machine = machine
	total_drained = 0
	active = TRUE
	holder.update_icon()
	wearer.visible_message(SPAN_WARNING("[wearer] presses [wearer.p_their()] hand against [machine], sparks flying!"),
		SPAN_DANGER("You begin draining power from [machine]!"))
	playsound(wearer, 'sound/effects/sparks2.ogg', 50, TRUE)

/obj/item/rig_module/power_sink/deactivate()
	if(drained_machine)
		stop_draining()
	return ..()

/// Stops draining and tells the wearer how much it got
/obj/item/rig_module/power_sink/proc/stop_draining()
	if(holder?.wearer && drained_machine)
		to_chat(holder.wearer, SPAN_NOTICE("<b>Total power drained from [drained_machine]:</b> [floor(total_drained)]."))
	drained_machine = null
	total_drained = 0
	active = FALSE
	holder?.update_icon()

/obj/item/rig_module/power_sink/rig_process(delta_time)
	if(!drained_machine)
		return ..()
	var/mob/living/carbon/human/wearer = holder.wearer
	if(QDELETED(drained_machine) || !wearer.Adjacent(drained_machine))
		to_chat(wearer, SPAN_WARNING("Your power sink retracts into its casing."))
		stop_draining()
		return ..()
	if(!holder.cell || holder.cell.charge >= holder.cell.maxcharge)
		to_chat(wearer, SPAN_NOTICE("Your power sink flashes an amber light: your suit's cell is full."))
		stop_draining()
		return ..()
	var/drained = drained_machine.supply_rig_charge(min(drain_rate * delta_time, holder.cell.maxcharge - holder.cell.charge))
	if(drained <= 0)
		to_chat(wearer, SPAN_WARNING("Your power sink flashes a red light: there is no power left in [drained_machine]."))
		stop_draining()
		return ..()
	holder.give_power(drained)
	total_drained += drained
	if(prob(30))
		var/datum/effect_system/spark_spread/sparks = new()
		sparks.set_up(3, TRUE, get_turf(drained_machine))
		sparks.start()
		QDEL_IN(sparks, 2 SECONDS)
	return ..()

/**
 * Stealth field module, an active camouflage that makes the wearer barely visible
 *
 * It costs a lot of charge, and firing a gun breaks it.
 */
/obj/item/rig_module/stealth_field
	name = "hardsuit active camouflage module"
	desc = "A robust hardsuit-integrated stealth module."
	icon_state = "cloak"
	interface_name = "integrated stealth system"
	interface_desc = "An integrated active camouflage system. Firing a gun breaks it."
	toggleable = TRUE
	use_power_cost = 500
	active_power_cost = 15
	module_cooldown = 10 SECONDS
	suit_overlay_active = "stealth_active"
	suit_overlay_inactive = "stealth_inactive"
	/// Alpha of the wearer while it is on
	var/stealth_alpha = 25

/obj/item/rig_module/stealth_field/activate()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer = holder.wearer
	RegisterSignal(wearer, COMSIG_MOB_FIRED_GUN, PROC_REF(on_wearer_fired))
	animate(wearer, alpha = stealth_alpha, time = 1 SECONDS)
	playsound(wearer, 'sound/effects/pred_cloakon.ogg', 15, TRUE)
	wearer.visible_message(SPAN_WARNING("[wearer] melds into the shadows!"), SPAN_NOTICE("<b>You are now blending into your surroundings.</b>"))

/obj/item/rig_module/stealth_field/deactivate()
	var/mob/living/carbon/human/wearer = holder?.wearer
	. = ..()
	if(!. || !wearer)
		return
	UnregisterSignal(wearer, COMSIG_MOB_FIRED_GUN)
	animate(wearer, alpha = initial(wearer.alpha), time = 0.5 SECONDS)
	playsound(wearer, 'sound/effects/stealthoff.ogg', 25, TRUE)
	wearer.visible_message(SPAN_WARNING("[wearer] appears from thin air!"), SPAN_DANGER("You are now visible."))

/obj/item/rig_module/stealth_field/proc/on_wearer_fired(mob/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(deactivate))
