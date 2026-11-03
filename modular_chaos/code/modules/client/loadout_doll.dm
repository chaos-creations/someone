/// Doll slot of gear that has no slot of its own on the doll, listed under the doll
#define LOADOUT_DOLL_OTHER "other"

/**
 * Paper doll editor of the fluff loadout (/datum/preferences/var/gear), opened from the Loadout tab of the character setup.
 *
 * Shows a body outline whose parts are the equipment slots. Gear goes to the doll slot of its
 * [/datum/gear/var/slot], one item per slot; gear without a doll slot is listed under the doll as other items.
 * Gear bought with role loadout points is still picked in upstream's /datum/loadout_picker.
 */
/datum/loadout_doll
	/**
	 * Slots shown on the doll: list(list("key", "name", "wear_slots"))
	 *
	 * wear_slots are the WEAR_* slots of gear that goes to this doll slot. The body part of each key is laid out in chaos/LoadoutDoll.tsx.
	 */
	var/static/list/doll_slots = list(
		list("key" = "head", "name" = "Head", "wear_slots" = list(WEAR_HEAD)),
		list("key" = "eyes", "name" = "Eyes", "wear_slots" = list(WEAR_EYES)),
		list("key" = "mask", "name" = "Mask", "wear_slots" = list(WEAR_FACE)),
		list("key" = "uniform", "name" = "Uniform", "wear_slots" = list(WEAR_BODY)),
		list("key" = "accessory", "name" = "Accessory", "wear_slots" = list(WEAR_IN_ACCESSORY, WEAR_ACCESSORY)),
		list("key" = "suit", "name" = "Suit", "wear_slots" = list(WEAR_JACKET)),
		list("key" = "gloves", "name" = "Gloves", "wear_slots" = list(WEAR_HANDS)),
		list("key" = "hand", "name" = "Hand", "wear_slots" = list(WEAR_R_HAND, WEAR_L_HAND)),
		list("key" = "belt", "name" = "Belt", "wear_slots" = list(WEAR_WAIST)),
		list("key" = "shoes", "name" = "Shoes", "wear_slots" = list(WEAR_FEET)),
	)
	/// WEAR_* slot to the key of its doll slot, built from doll_slots
	var/static/list/doll_slot_by_wear_slot

/datum/loadout_doll/New()
	. = ..()
	if(doll_slot_by_wear_slot)
		return
	doll_slot_by_wear_slot = list()
	for(var/list/doll_slot as anything in doll_slots)
		for(var/wear_slot in doll_slot["wear_slots"])
			doll_slot_by_wear_slot[wear_slot] = doll_slot["key"]

/// Returns the key of the doll slot the gear goes to, or LOADOUT_DOLL_OTHER if it has none
/datum/loadout_doll/proc/get_doll_slot(datum/gear/gear)
	return doll_slot_by_wear_slot[gear.slot] || LOADOUT_DOLL_OTHER

/**
 * Whether the gear can be picked on the doll by the given preferences
 *
 * Only fluff gear is, and only for the role on High if the gear is role-restricted.
 */
/datum/loadout_doll/proc/can_pick(datum/gear/gear, datum/preferences/prefs)
	if(!gear.fluff_cost || gear.loadout_cost)
		return FALSE
	var/job = prefs.get_high_priority_job()
	if(job && length(gear.allowed_roles) && !(job in gear.allowed_roles))
		return FALSE
	return TRUE

/// Returns the fluff points the gear in the preferences costs
/datum/loadout_doll/proc/get_used_points(datum/preferences/prefs)
	var/total_cost = 0
	for(var/gear_type in prefs.gear)
		var/datum/gear/gear = GLOB.gear_datums_by_type[gear_type]
		total_cost += gear?.fluff_cost
	return total_cost

/datum/loadout_doll/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/LoadoutDoll", "Loadout")
		ui.open()
		ui.set_autoupdate(FALSE)

	winset(user, ui.window.id, "focus=true")

/datum/loadout_doll/ui_state(mob/user)
	return GLOB.always_state

/datum/loadout_doll/ui_static_data(mob/user)
	. = ..()
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	.["max_points"] = MAX_GEAR_COST

	var/list/slots = list()
	for(var/list/doll_slot as anything in doll_slots)
		slots += list(list("key" = doll_slot["key"], "name" = doll_slot["name"]))
	.["slots"] = slots

	// list("slot key" = list(item, ...)) for the doll slots, list(list("name", "items")) by category for the rest
	var/list/slot_items = list()
	var/list/other_categories = list()
	for(var/category in GLOB.gear_datums_by_category)
		var/list/category_items = list()
		for(var/datum/gear/gear as anything in GLOB.gear_datums_by_category[category])
			if(!can_pick(gear, prefs))
				continue
			var/doll_slot = get_doll_slot(gear)
			if(doll_slot == LOADOUT_DOLL_OTHER)
				category_items += list(gear.get_list_representation())
				continue
			LAZYADD(slot_items[doll_slot], list(gear.get_list_representation()))
		if(length(category_items))
			other_categories += list(list("name" = category, "items" = category_items))
	.["slot_items"] = slot_items
	.["other_categories"] = other_categories

/datum/loadout_doll/ui_data(mob/user)
	. = ..()
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	// list("slot key" = item) of the first gear in each doll slot, list(item, ...) of the rest
	var/list/equipped = list()
	var/list/other = list()
	for(var/gear_type in prefs.gear)
		var/datum/gear/gear = GLOB.gear_datums_by_type[gear_type]
		if(!gear)
			continue
		var/doll_slot = get_doll_slot(gear)
		if(doll_slot == LOADOUT_DOLL_OTHER)
			other += list(gear.get_list_representation())
			continue
		if(!equipped[doll_slot])
			equipped[doll_slot] = gear.get_list_representation()
	.["equipped"] = equipped
	.["other"] = other
	.["points"] = get_used_points(prefs)

	var/job = prefs.get_high_priority_job()
	var/datum/job/high_job = job ? GLOB.RoleAuthority.roles_by_name[job] : null
	.["role_loadout"] = high_job?.loadout_points ? job : null

/datum/loadout_doll/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	switch(action)
		if("equip")
			var/datum/gear/gear = GLOB.gear_datums_by_type[text2path(params["type"])]
			if(!istype(gear) || !can_pick(gear, prefs))
				return
			var/doll_slot = get_doll_slot(gear)
			var/list/replaced = list()
			if(doll_slot == LOADOUT_DOLL_OTHER)
				if(gear.type in prefs.gear)
					return
			else
				for(var/gear_type in prefs.gear)
					var/datum/gear/worn_gear = GLOB.gear_datums_by_type[gear_type]
					if(worn_gear && get_doll_slot(worn_gear) == doll_slot)
						replaced += gear_type

			var/replaced_cost = 0
			for(var/gear_type in replaced)
				replaced_cost += GLOB.gear_datums_by_type[gear_type].fluff_cost
			if(get_used_points(prefs) - replaced_cost + gear.fluff_cost > MAX_GEAR_COST)
				to_chat(user, SPAN_WARNING("Not enough loadout points for [gear.display_name]."))
				return

			prefs.gear -= replaced
			prefs.gear += gear.type

		if("unequip")
			var/doll_slot = params["slot"]
			for(var/gear_type in prefs.gear.Copy())
				var/datum/gear/worn_gear = GLOB.gear_datums_by_type[gear_type]
				if(worn_gear && get_doll_slot(worn_gear) == doll_slot)
					prefs.gear -= gear_type

		if("remove")
			var/picked_type = text2path(params["type"])
			if(!picked_type)
				return
			prefs.gear -= picked_type

		if("role_loadout")
			prefs.loadout_picker.tgui_interact(user)
			return TRUE

		else
			return

	prefs.ShowChoices(user)
	return TRUE

#undef LOADOUT_DOLL_OTHER
