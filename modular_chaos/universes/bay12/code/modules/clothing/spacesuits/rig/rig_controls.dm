// How the wearer controls a rig: the action buttons it gives while worn on the back, and the procs of the
// keybindings that pick and use its modules (code/datums/keybinding/human.dm).

/datum/action/item_action/rig
	/// The rig the action belongs to
	var/obj/item/rig/rig

/datum/action/item_action/rig/New(Target, obj/item/holder)
	. = ..()
	rig = holder_item

/datum/action/item_action/rig/Destroy()
	rig = null
	return ..()

/datum/action/item_action/rig/toggle_suit
	name = "Toggle Hardsuit"

/datum/action/item_action/rig/toggle_suit/New(Target, obj/item/holder)
	. = ..()
	name = "Toggle Hardsuit"
	button.name = name

/datum/action/item_action/rig/toggle_suit/action_activate()
	. = ..()
	INVOKE_ASYNC(rig, TYPE_PROC_REF(/obj/item/rig, toggle_suit), owner)

/datum/action/item_action/rig/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/rig/toggle_helmet/New(Target, obj/item/holder)
	. = ..()
	name = "Toggle Helmet"
	button.name = name

/datum/action/item_action/rig/toggle_helmet/action_activate()
	. = ..()
	rig.toggle_helmet(owner)

/datum/action/item_action/rig/toggle_air
	name = "Toggle Air Supply"

/datum/action/item_action/rig/toggle_air/New(Target, obj/item/holder)
	. = ..()
	name = "Toggle Air Supply"
	button.name = name

/datum/action/item_action/rig/toggle_air/action_activate()
	. = ..()
	rig.toggle_air_supply(owner)

/datum/action/item_action/rig/cable
	name = "Charging Cable"

/datum/action/item_action/rig/cable/New(Target, obj/item/holder)
	. = ..()
	name = "Charging Cable"
	button.name = name

/datum/action/item_action/rig/cable/action_activate()
	. = ..()
	rig.pull_cable(owner)

/**
 * Returns the rig the human wears on the back, or null if they don't wear one
 */
/mob/living/carbon/human/proc/get_worn_rig()
	var/obj/item/rig/rig = back
	if(istype(rig) && rig.wearer == src)
		return rig
	return null

/**
 * Shows the modules of the worn rig in a radial menu around the human, and selects the picked one
 */
/mob/living/carbon/human/proc/rig_select_module()
	var/obj/item/rig/rig = get_worn_rig()
	if(!rig)
		to_chat(src, SPAN_WARNING("You aren't wearing a hardsuit."))
		return
	var/list/choices = list()
	var/list/modules_by_choice = list()
	for(var/obj/item/rig_module/module as anything in rig.installed_modules)
		if(!module.is_selectable())
			continue
		var/choice_name = module.get_radial_name()
		while(choice_name in choices)
			choice_name += " "
		choices[choice_name] = image(module.icon, module.icon_state)
		modules_by_choice[choice_name] = module
	if(!length(choices))
		to_chat(src, SPAN_WARNING("[rig] has no modules to select."))
		return
	var/choice = show_radial_menu(src, src, choices, uniqueid = "rig_modules_[REF(src)]")
	if(!choice || get_worn_rig() != rig)
		return
	var/obj/item/rig_module/module = modules_by_choice[choice]
	if(module.holder != rig)
		return
	rig.select_module(module)

/**
 * Uses the selected module of the worn rig, see /obj/item/rig_module/proc/use_module()
 */
/mob/living/carbon/human/proc/rig_use_module()
	var/obj/item/rig/rig = get_worn_rig()
	if(!rig)
		to_chat(src, SPAN_WARNING("You aren't wearing a hardsuit."))
		return
	if(!rig.selected_module)
		to_chat(src, SPAN_WARNING("No module of [rig] is selected."))
		return
	rig.selected_module.use_module()

/mob/living/carbon/human/get_status_tab_items()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	var/obj/item/rig/rig = get_worn_rig()
	if(!rig)
		return .
	. += ""
	. += "Hardsuit: [rig.sealing ? "adjusting seals" : (rig.online ? "online" : "offline")]"
	. += "Hardsuit charge: [rig.cell ? "[floor(rig.cell.percent())]%" : "no cell"]"
	if(rig.selected_module)
		. += "Hardsuit module: [rig.selected_module.get_status_name()]"
	return .

/datum/action/item_action/rig/interface
	name = "Hardsuit Interface"

/datum/action/item_action/rig/interface/New(Target, obj/item/holder)
	. = ..()
	name = "Hardsuit Interface"
	button.name = name

/datum/action/item_action/rig/interface/action_activate()
	. = ..()
	rig.tgui_interact(owner)

// The hardsuit interface (tgui/packages/tgui/interfaces/chaos/Hardsuit.tsx): the state of the suit, its cell, air
// supply and modules, and buttons for what the action buttons and keybindings do

/obj/item/rig/attack_self(mob/user)
	. = ..()
	tgui_interact(user)

/obj/item/rig/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/Hardsuit", name)
		ui.open()

/obj/item/rig/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/rig/ui_data(mob/user)
	var/list/data = list()
	data["name"] = name
	data["worn"] = wearer == user
	data["sealed"] = sealed
	data["sealing"] = sealing
	data["online"] = online
	data["charge"] = cell ? cell.charge : 0
	data["max_charge"] = cell ? cell.maxcharge : 0
	data["has_cell"] = !!cell
	data["charging_source"] = charging_source ? "[charging_source]" : null
	data["cable_out"] = cable && cable.loc != src

	var/list/pieces = list()
	for(var/obj/item/clothing/piece as anything in get_pieces())
		pieces += list(list(
			"name" = piece.name,
			"deployed" = wearer && piece.loc == wearer,
			"sealed" = (piece in sealed_pieces),
		))
	data["pieces"] = pieces
	data["has_helmet"] = !!helmet

	data["has_tank"] = !!air_supply
	data["tank_name"] = air_supply ? air_supply.name : null
	data["tank_pressure"] = air_supply ? round(air_supply.pressure) : 0
	data["air_open"] = wearer && air_supply && wearer.internal == air_supply

	var/list/modules = list()
	for(var/obj/item/rig_module/module as anything in installed_modules)
		modules += list(list(
			"ref" = REF(module),
			"name" = module.get_status_name(),
			"desc" = module.interface_desc,
			"selectable" = module.is_selectable(),
			"selected" = selected_module == module,
			"active" = module.active,
			"aiming" = aiming_module == module,
			"use_cost" = module.use_power_cost,
			"active_cost" = module.active_power_cost,
		))
	data["modules"] = modules
	return data

/obj/item/rig/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	if(user != wearer)
		return
	switch(action)
		if("toggle_suit")
			INVOKE_ASYNC(src, PROC_REF(toggle_suit), user)
			return TRUE
		if("toggle_helmet")
			toggle_helmet(user)
			return TRUE
		if("toggle_air")
			toggle_air_supply(user)
			return TRUE
		if("cable")
			pull_cable(user)
			return TRUE
		if("select_module", "use_module")
			var/obj/item/rig_module/module = locate(params["ref"]) in installed_modules
			if(!module || !module.is_selectable())
				return
			if(selected_module != module)
				select_module(module)
			if(action == "use_module")
				INVOKE_ASYNC(module, TYPE_PROC_REF(/obj/item/rig_module, use_module))
			return TRUE
