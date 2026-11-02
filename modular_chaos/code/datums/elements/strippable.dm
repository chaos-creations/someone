/// How long opening someone's storage through the strip menu takes
#define STRIP_STORAGE_OPEN_DELAY (3 SECONDS)
/// How long opening the storage of someone incapacitated through the strip menu takes
#define STRIP_STORAGE_OPEN_DELAY_INCAPACITATED (1 SECONDS)

/// Returns the storage of the item in this slot that the strip menu can open, or null if there is none
/datum/strippable_item/proc/get_storage(atom/source)
	var/obj/item/storage/storage = get_item(source)
	if(istype(storage))
		return storage
	return null

/// Returns the storage action of this slot as a key of STORAGE_ACTIONS in StripMenu.tsx, or null if it has no storage to open
/datum/strippable_item/proc/get_storage_action(atom/source, mob/user)
	if(!ishuman(source) || !get_storage(source))
		return null
	return "open_storage"

/**
 * Opens the storage of this slot to user after a delay, so they can take things out of it and put things in. Sleeps
 *
 * Returns TRUE if the storage was opened.
 */
/datum/strippable_item/proc/storage_action(atom/source, mob/user)
	if(!ishuman(source))
		return FALSE
	var/mob/living/carbon/human/sourcehuman = source
	var/obj/item/storage/storage = get_storage(sourcehuman)
	if(!storage || !can_open_storage(sourcehuman, user))
		return FALSE

	sourcehuman.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had their [storage.name] opened by [key_name(user)]</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to open [key_name(sourcehuman)]'s [storage.name]</font>")
	user.visible_message(SPAN_WARNING("[user] tries to open [sourcehuman]'s [storage.name]."), SPAN_NOTICE("You try to open [sourcehuman]'s [storage.name]."))

	var/open_delay = sourcehuman.is_mob_incapacitated() ? STRIP_STORAGE_OPEN_DELAY_INCAPACITATED : STRIP_STORAGE_OPEN_DELAY
	if(!do_after(user, open_delay, INTERRUPT_ALL, BUSY_ICON_GENERIC, sourcehuman, INTERRUPT_MOVED, BUSY_ICON_GENERIC))
		return FALSE
	// The storage could have been taken off or swapped in the meantime
	if(get_storage(sourcehuman) != storage || !can_open_storage(sourcehuman, user))
		return FALSE
	storage.open(user)
	return TRUE

/// Whether user can open storage worn by source right now, telling them why not. Follows the strip restrictions of [/datum/strippable_item/proc/try_unequip]
/datum/strippable_item/proc/can_open_storage(mob/living/carbon/human/source, mob/user)
	if(user.action_busy || user.is_mob_incapacitated() || !source.Adjacent(user))
		to_chat(user, SPAN_WARNING("You can't do this right now."))
		return FALSE
	if(MODE_HAS_MODIFIER(/datum/gamemode_modifier/disable_stripdrag_enemy) && (source.stat == DEAD || source.health < source.health_threshold_crit) && !source.get_target_lock(user.faction_group))
		to_chat(user, SPAN_WARNING("You can't search a crit or dead member of another faction!"))
		return FALSE
	if(HAS_TRAIT(source, TRAIT_UNSTRIPPABLE) && !source.is_mob_incapacitated())
		to_chat(user, SPAN_DANGER("[source] has an unbreakable grip on their equipment!"))
		return FALSE
	return TRUE

/datum/strip_menu/ui_data(mob/user)
	CAN_BE_REDEFINED(TRUE)
	var/list/data = ..()
	var/list/items = data["items"]
	for(var/strippable_key in items)
		var/list/result = items[strippable_key]
		// Only items the user can see have a name
		if(!result?["name"])
			continue
		var/datum/strippable_item/item_data = strippable.items[strippable_key]
		result["storage"] = item_data.get_storage_action(owner, user)
	return data

/datum/strip_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	// Upstream's ui_act reports every action as handled, so whether the UI can still be used is checked again here
	if(action != "storage" || !ui || ui.status != UI_INTERACTIVE)
		return .

	var/mob/user = ui.user
	var/key = params["key"]
	var/datum/strippable_item/strippable_item = strippable.items[key]
	if(isnull(strippable_item))
		return TRUE
	if(!strippable_item.should_show(owner, user))
		return TRUE
	if(strippable_item.get_obscuring(owner) == STRIPPABLE_OBSCURING_COMPLETELY)
		return TRUE
	if(isnull(strippable_item.get_storage_action(owner, user)))
		return TRUE

	LAZYORASSOCLIST(interactions, user, key)
	// Yielding call
	strippable_item.storage_action(owner, user)
	if(!QDELETED(src))
		LAZYREMOVEASSOC(interactions, user, key)
	return TRUE

#undef STRIP_STORAGE_OPEN_DELAY
#undef STRIP_STORAGE_OPEN_DELAY_INCAPACITATED
