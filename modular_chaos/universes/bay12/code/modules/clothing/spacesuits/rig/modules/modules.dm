/**
 * Rig module, an upgrade installed into a rig
 *
 * A module works only while its rig is online. The rig's wearer picks one in a radial menu and uses it with a
 * keybinding (/mob/living/carbon/human/proc/rig_use_module()); what using it does depends on what kind it is:
 * a targeted module waits for a click on a target and engages it, a toggleable one turns on and off, a usable one
 * engages once. Modules can also run all the time without being used, like the storage module.
 */
/obj/item/rig_module
	name = "hardsuit upgrade"
	desc = "It looks pretty sciency."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/rig_modules_sojourn.dmi'
	icon_state = ""
	w_class = SIZE_MEDIUM
	flags_atom = FPRINT|CONDUCT

	/// The rig it is installed into
	var/obj/item/rig/holder
	/// Short name in the radial menu and in messages
	var/interface_name = "hardsuit upgrade"
	/// What it does, shown on examine
	var/interface_desc = "A generic hardsuit upgrade."

	/// Whether using it waits for a click and engages the clicked atom
	var/targeted = FALSE
	/// Whether using it turns it on and off
	var/toggleable = FALSE
	/// Whether using it engages it once
	var/usable = FALSE
	/// Whether it is on
	var/active = FALSE

	/// Charge taken each time it engages
	var/use_power_cost = 0
	/// Charge taken every second while it is on
	var/active_power_cost = 0
	/// Charge taken every second while it is off, as long as the rig is online
	var/passive_power_cost = 0
	/// How long after engaging it can engage again
	var/module_cooldown = 1 SECONDS
	COOLDOWN_DECLARE(module_use)

	/// Whether a rig can have more than one of this kind
	var/redundant = FALSE
	/// Whether it can't be taken out of the rig
	var/permanent = FALSE
	/// Types of modules it can't be installed together with
	var/list/banned_modules = list()

	/// Icon of the overlays it draws on the worn rig
	var/suit_overlay_icon = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/back/rig_modules_sojourn.dmi'
	/// Overlay drawn on the worn rig while it is on, if any
	var/suit_overlay_active
	/// Overlay drawn on the worn rig while it is off, if any
	var/suit_overlay_inactive

/obj/item/rig_module/Destroy()
	if(holder)
		holder.installed_modules -= src
		removed()
	return ..()

/obj/item/rig_module/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE(interface_desc)
	var/list/costs = list()
	if(use_power_cost)
		costs += "[use_power_cost] charge a use"
	if(active_power_cost)
		costs += "[active_power_cost] charge a second while on"
	if(passive_power_cost)
		costs += "[passive_power_cost] charge a second while off"
	if(length(costs))
		. += SPAN_NOTICE("It takes [english_list(costs)].")

/// Returns its name in the list of modules on the rig's examine
/obj/item/rig_module/proc/get_status_name()
	if(toggleable)
		return "[interface_name] ([active ? "on" : "off"])"
	return interface_name

/**
 * Returns why it can't go into a rig, or null if it can
 *
 * Arguments:
 * * rig - the rig
 */
/obj/item/rig_module/proc/get_install_problem(obj/item/rig/rig)
	return null

/**
 * Called when it is installed into a rig
 *
 * Arguments:
 * * new_holder - the rig
 */
/obj/item/rig_module/proc/installed(obj/item/rig/new_holder)
	SHOULD_CALL_PARENT(TRUE)
	holder = new_holder

/// Called when it is taken out of its rig, or its rig is destroyed
/obj/item/rig_module/proc/removed()
	SHOULD_CALL_PARENT(TRUE)
	deactivate()
	holder = null

/// Called when someone puts its rig on
/obj/item/rig_module/proc/on_wearer_set()
	return

/// Called when its rig's wearer takes it off, after the module was deactivated
/obj/item/rig_module/proc/on_wearer_cleared()
	return

/// Returns whether it shows in the radial menu of modules
/obj/item/rig_module/proc/is_selectable()
	return targeted || toggleable || usable

/// Returns the icon state of the overlay it draws on the worn rig now, or null for none
/obj/item/rig_module/proc/get_suit_overlay()
	return active ? suit_overlay_active : suit_overlay_inactive

/// Returns its name in the radial menu of modules
/obj/item/rig_module/proc/get_radial_name()
	if(toggleable && active)
		return "[interface_name] (on)"
	return interface_name

/**
 * Called by the use keybinding while it is the selected module
 *
 * Returns a RIG_MODULE_USE_* value.
 */
/obj/item/rig_module/proc/use_module()
	if(targeted)
		if(holder.aiming_module == src)
			holder.set_aiming(null)
			return RIG_MODULE_USE_DONE
		if(!check(0))
			return RIG_MODULE_USE_FAILED
		holder.set_aiming(src)
		return RIG_MODULE_USE_AIMING
	if(toggleable)
		if(active)
			return deactivate() ? RIG_MODULE_USE_DONE : RIG_MODULE_USE_FAILED
		return activate() ? RIG_MODULE_USE_DONE : RIG_MODULE_USE_FAILED
	if(usable)
		return engage() ? RIG_MODULE_USE_DONE : RIG_MODULE_USE_FAILED
	return RIG_MODULE_USE_FAILED

/**
 * Checks that it can work now and takes the charge for it
 *
 * Tells the wearer why it can't.
 *
 * Arguments:
 * * cost - the charge to take
 *
 * Returns TRUE if it can work.
 */
/obj/item/rig_module/proc/check(cost = use_power_cost)
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer)
		return FALSE
	if(!holder.online)
		to_chat(wearer, SPAN_WARNING("The suit is not online."))
		return FALSE
	if(wearer.is_mob_incapacitated())
		to_chat(wearer, SPAN_WARNING("You can't use the suit in this state."))
		return FALSE
	if(!COOLDOWN_FINISHED(src, module_use))
		to_chat(wearer, SPAN_WARNING("You can't use [interface_name] again so soon."))
		return FALSE
	if(cost && !holder.use_power(cost))
		to_chat(wearer, SPAN_WARNING("Not enough stored power for [interface_name]."))
		return FALSE
	return TRUE

/**
 * Does what it does once: on the clicked target for a targeted module
 *
 * Arguments:
 * * target - what the wearer clicked, or null for a module that isn't targeted
 *
 * Returns TRUE if it engaged.
 */
/obj/item/rig_module/proc/engage(atom/target)
	if(!check())
		return FALSE
	COOLDOWN_START(src, module_use, module_cooldown)
	return TRUE

/**
 * Turns it on
 *
 * Returns TRUE if it turned on.
 */
/obj/item/rig_module/proc/activate()
	if(active || !engage())
		return FALSE
	active = TRUE
	holder.update_icon()
	return TRUE

/**
 * Turns it off; safe to call while it is off or out of a rig
 *
 * Returns TRUE if it turned off.
 */
/obj/item/rig_module/proc/deactivate()
	if(!active)
		return FALSE
	active = FALSE
	holder?.update_icon()
	return TRUE

/**
 * Called every process of its online rig
 *
 * Arguments:
 * * delta_time - seconds since the last process
 *
 * Returns the charge it takes a second now.
 */
/obj/item/rig_module/proc/rig_process(delta_time)
	return active ? active_power_cost : passive_power_cost

/**
 * Called for an item used on its rig while the maintenance panel is closed
 *
 * Arguments:
 * * item - the item
 * * user - who uses it
 *
 * Returns TRUE if it took the item, and nothing else should.
 */
/obj/item/rig_module/proc/accepts_item(obj/item/item, mob/user)
	return FALSE
