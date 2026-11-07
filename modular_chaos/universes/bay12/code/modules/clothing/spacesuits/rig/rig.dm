// Rigs, hardsuit control modules, from Baystation 12 (code/modules/clothing/spacesuits/rig/) with modules of Sojourn
// Station (code/modules/clothing/spacesuits/rig/modules/); see the README of the universe for the sources of the sprites.
//
// What changed from the source: no access lock, wires, AI control, EMP damage or nanoUI. A rig is put on and taken
// off like any back item, its suit is deployed and sealed in one action, its modules are picked from a radial menu
// and used with keybindings (code/datums/keybinding/human.dm), and its cell is charged by a cable plugged into an APC,
// a SMES or a generator (rig_cable.dm).

/**
 * Hardsuit control module, a rig
 *
 * Worn on the back, it deploys its pieces (helmet, chestpiece, gauntlets and boots) onto the body and seals them into
 * a powered suit. While sealed and powered it is online: the suit is light to move in and its modules work, at the
 * cost of the charge of its cell. Without power the sealed suit is a heavy shell.
 *
 * Its maintenance panel is opened with a screwdriver. With it open, modules, a cell and an air tank go in, and a
 * wrench takes them out. A storage module makes the rig a backpack: a click on the worn rig opens it.
 */
/obj/item/rig
	name = "hardsuit control module"
	desc = "A back-mounted hardsuit deployment and control mechanism. This one is a light suit for extra-vehicular activity."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/rig_modules.dmi'
	icon_state = "eva_rig"
	item_icons = list(
		WEAR_BACK = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/back/rigs.dmi',
	)
	flags_equip_slot = SLOT_BACK
	flags_atom = FPRINT|CONDUCT
	w_class = SIZE_HUGE
	time_to_equip = 2 SECONDS
	time_to_unequip = 2 SECONDS
	force = 10

	/// Name of the suit in the names of its pieces ("[suit_type] helmet")
	var/suit_type = "hardsuit"
	/// Icon state of the pieces and of the worn rig, "[suit_state]_sealed" for the sealed pieces; null for icon_state
	var/suit_state
	/**
	 * Whether every piece has states of its own, "[suit_state]_helmet" and so on (see get_piece_state()), kept with
	 * their worn states in one icon (/obj/item/var/contained_sprite); otherwise all of them are suit_state, each in
	 * the icons of its kind of clothing
	 */
	var/separate_piece_states = FALSE
	/**
	 * Icon state in its icon drawn over the worn helmet, for what sticks up from the worn rig above the head (the
	 * worn helmet is drawn over the back), or null for none
	 */
	var/helmet_overlay_state
	/// Type of the helmet, or null if the suit has none
	var/helm_type = /obj/item/clothing/head/helmet/space/rig
	/// Type of the chestpiece, or null if the suit has none
	var/chest_type = /obj/item/clothing/suit/space/rig
	/// Type of the gauntlets, or null if the suit has none
	var/glove_type = /obj/item/clothing/gloves/rig
	/// Type of the boots, or null if the suit has none
	var/boot_type = /obj/item/clothing/shoes/rig
	/// Type of the cell it starts with, or null for none
	var/cell_type = /obj/item/cell/high
	/// Type of the air tank it starts with, or null for none
	var/air_type = /obj/item/tank/oxygen
	/// Types of the modules it starts with
	var/list/initial_modules = list(/obj/item/rig_module/storage)
	/// Items the chestpiece holds in the suit storage slot
	var/list/allowed_in_suit_storage = list(/obj/item/device/flashlight, /obj/item/tank)

	// Armor of every piece, see /obj/item/clothing/var/armor_melee and the rest
	var/armor_melee = CLOTHING_ARMOR_MEDIUM
	var/armor_bullet = CLOTHING_ARMOR_LOW
	var/armor_laser = CLOTHING_ARMOR_LOW
	var/armor_energy = CLOTHING_ARMOR_VERYLOW
	var/armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	var/armor_bio = CLOTHING_ARMOR_ULTRAHIGH
	var/armor_rad = CLOTHING_ARMOR_LOW
	var/armor_internaldamage = CLOTHING_ARMOR_MEDIUM

	/// Slowdown of the sealed suit while it is online
	var/online_slowdown = SLOWDOWN_ARMOR_HEAVY
	/// Slowdown of the deployed suit while it is not: unsealed, or sealed without power
	var/offline_slowdown = 3
	/// How much the helmet blocks the view while the suit is not online, a VISION_IMPAIR_* value
	var/offline_vision_impair = VISION_IMPAIR_HIGH
	/// How long sealing or unsealing each piece takes
	var/seal_delay = 1 SECONDS

	/// The helmet, while it exists
	var/obj/item/clothing/head/helmet/space/rig/helmet
	/// The chestpiece, while it exists
	var/obj/item/clothing/suit/space/rig/chest
	/// The gauntlets, while they exist
	var/obj/item/clothing/gloves/rig/gloves
	/// The boots, while they exist
	var/obj/item/clothing/shoes/rig/boots
	/// The power cell, if one is installed
	var/obj/item/cell/cell
	/// The air tank, if one is installed
	var/obj/item/tank/air_supply
	/// The installed modules
	var/list/obj/item/rig_module/installed_modules = list()
	/// The module the use keybinding uses
	var/obj/item/rig_module/selected_module
	/// The module that waits for the wearer to click a target, see set_aiming()
	var/obj/item/rig_module/aiming_module
	/// The installed storage module, if any; the rig opens as its storage
	var/obj/item/rig_module/storage/storage
	/// The installed vision module, if any
	var/obj/item/rig_module/vision/visor

	/// The human wearing it on the back
	var/mob/living/carbon/human/wearer
	/// Whether the suit is sealed around the wearer
	var/sealed = FALSE
	/// The pieces that are sealed, while the suit seals, unseals or is sealed
	var/list/obj/item/clothing/sealed_pieces = list()
	/// The wearer's own gloves and shoes the gauntlets and boots are deployed over, by piece; they wait inside the piece
	var/list/obj/item/clothing/covered_items = list()
	/// Whether the suit is sealing or unsealing right now
	var/sealing = FALSE
	/// Whether the suit is sealed, worn and powered; set by update_online() only
	var/online = FALSE
	/// Whether the maintenance panel is open
	var/panel_open = FALSE

	/// The charging cable, while it isn't plugged in
	var/obj/item/rig_cable/cable
	/// What the charging cable is plugged into
	var/obj/structure/machinery/power/charging_source
	/// The beam drawn along the plugged in cable
	var/datum/beam/cable_beam
	/// How far, in tiles, the plugged in cable reaches
	var/cable_length = 2
	/// Charge the cable brings in a second at most
	var/cable_charge_rate = 50

/obj/item/rig/Initialize(mapload, ...)
	. = ..()
	if(!suit_state)
		suit_state = icon_state
	LAZYSET(item_state_slots, WEAR_BACK, suit_state)
	if(cell_type)
		cell = new cell_type(src)
	if(air_type)
		air_supply = new air_type(src)
	cable = new(src)
	if(helm_type)
		helmet = new helm_type(src)
	if(chest_type)
		chest = new chest_type(src)
		chest.allowed = allowed_in_suit_storage.Copy()
	if(glove_type)
		gloves = new glove_type(src)
	if(boot_type)
		boots = new boot_type(src)
	for(var/obj/item/clothing/piece as anything in get_pieces())
		setup_piece(piece)

	for(var/module_type in initial_modules)
		install_module(new module_type(src))

	new /datum/action/item_action/rig/interface(src, src)
	new /datum/action/item_action/rig/toggle_suit(src, src)
	if(helmet)
		new /datum/action/item_action/rig/toggle_helmet(helmet, src)
	if(air_supply)
		new /datum/action/item_action/rig/toggle_air(air_supply, src)
	new /datum/action/item_action/rig/cable(cable, src)
	START_PROCESSING(SSobj, src)

/obj/item/rig/Destroy()
	STOP_PROCESSING(SSobj, src)
	disconnect_cable()
	set_aiming(null)
	if(wearer)
		clear_wearer()
	for(var/obj/item/rig_module/module as anything in installed_modules)
		module.removed()
	QDEL_LIST(installed_modules)
	selected_module = null
	storage = null
	visor = null
	for(var/obj/item/clothing/piece as anything in covered_items)
		var/obj/item/covered_item = covered_items[piece]
		covered_item.forceMove(get_turf(src))
	covered_items.Cut()
	QDEL_NULL(helmet)
	QDEL_NULL(chest)
	QDEL_NULL(gloves)
	QDEL_NULL(boots)
	QDEL_NULL(cell)
	QDEL_NULL(air_supply)
	QDEL_NULL(cable)
	sealed_pieces.Cut()
	return ..()

/**
 * Makes a newly created piece part of this suit: its name, sprite and armor come from the rig, and it can't be taken
 * off but by retracting it
 *
 * Arguments:
 * * piece - the helmet, chestpiece, gauntlets or boots
 */
/obj/item/rig/proc/setup_piece(obj/item/clothing/piece)
	piece.name = "[suit_type] [initial(piece.name)]"
	piece.desc = "It seems to be part of \a [src]."
	piece.icon_state = get_piece_state(piece, sealed = FALSE)
	piece.flags_item |= NODROP
	piece.armor_melee = armor_melee
	piece.armor_bullet = armor_bullet
	piece.armor_laser = armor_laser
	piece.armor_energy = armor_energy
	piece.armor_bomb = armor_bomb
	piece.armor_bio = armor_bio
	piece.armor_rad = armor_rad
	piece.armor_internaldamage = armor_internaldamage
	if(piece == chest)
		chest.slowdown = offline_slowdown
	if(piece == helmet)
		helmet.vision_impair = offline_vision_impair
		helmet.rig = src

/// Returns the pieces of the suit that exist
/obj/item/rig/proc/get_pieces()
	var/list/pieces = list()
	for(var/obj/item/clothing/piece in list(helmet, chest, gloves, boots))
		pieces += piece
	return pieces

/**
 * Returns the slot a piece of this suit is worn in
 *
 * Arguments:
 * * piece - one of the pieces
 */
/obj/item/rig/proc/get_piece_slot(obj/item/clothing/piece)
	if(piece == helmet)
		return WEAR_HEAD
	if(piece == chest)
		return WEAR_JACKET
	if(piece == gloves)
		return WEAR_HANDS
	if(piece == boots)
		return WEAR_FEET
	return null

/**
 * Returns the icon state of a piece of this suit, see separate_piece_states
 *
 * Arguments:
 * * piece - one of the pieces
 * * sealed - whether the state is the sealed one
 */
/obj/item/rig/proc/get_piece_state(obj/item/clothing/piece, sealed)
	var/state = suit_state
	if(separate_piece_states)
		switch(get_piece_slot(piece))
			if(WEAR_HEAD)
				state += "_helmet"
			if(WEAR_JACKET)
				state += "_chest"
			if(WEAR_HANDS)
				state += "_gloves"
			if(WEAR_FEET)
				state += "_boots"
	return sealed ? "[state]_sealed" : state

/obj/item/rig/get_examine_text(mob/user)
	. = ..()
	if(wearer)
		var/list/deployed = list()
		for(var/obj/item/clothing/piece as anything in get_pieces())
			if(piece.loc == wearer)
				deployed += piece.name
		if(length(deployed))
			. += SPAN_NOTICE("Deployed: [english_list(deployed)].")
	if(user != wearer && loc != user && get_dist(user, src) > 1)
		return
	. += SPAN_NOTICE("The suit is [sealed ? "sealed" : "unsealed"] and its systems are [online ? "<b>online</b>" : "offline"].")
	if(cell)
		. += SPAN_NOTICE("Its cell is at [floor(cell.percent())]% charge.")
	else
		. += SPAN_WARNING("It has no cell.")
	if(air_supply)
		. += SPAN_NOTICE("It has \a [air_supply] installed.")
	if(charging_source)
		. += SPAN_NOTICE("Its charging cable is plugged into \the [charging_source].")
	if(length(installed_modules))
		var/list/module_names = list()
		for(var/obj/item/rig_module/module as anything in installed_modules)
			module_names += module.get_status_name()
		. += SPAN_NOTICE("Modules: [english_list(module_names)].")
	. += SPAN_NOTICE("The maintenance panel is [panel_open ? "open" : "closed"]. A screwdriver [panel_open ? "closes" : "opens"] it.")

/obj/item/rig/item_action_slot_check(mob/user, slot)
	return slot == WEAR_BACK

/obj/item/rig/equipped(mob/user, slot, silent)
	. = ..()
	if(slot == WEAR_BACK && ishuman(user))
		set_wearer(user)
	else if(wearer)
		clear_wearer()

/obj/item/rig/unequipped(mob/user, slot)
	. = ..()
	if(slot == WEAR_BACK && wearer == user)
		clear_wearer()

/**
 * Starts working for a human who put it on the back
 *
 * Arguments:
 * * new_wearer - the human
 */
/obj/item/rig/proc/set_wearer(mob/living/carbon/human/new_wearer)
	if(wearer == new_wearer)
		return
	if(wearer)
		clear_wearer()
	wearer = new_wearer
	RegisterSignal(wearer, COMSIG_PARENT_QDELETING, PROC_REF(on_wearer_deleted))
	for(var/obj/item/rig_module/module as anything in installed_modules)
		module.on_wearer_set()
	update_cable_beam()
	update_icon()

/**
 * Stops working for the wearer: retracts and unseals the suit, turns off the modules and stops aiming
 */
/obj/item/rig/proc/clear_wearer()
	if(!wearer)
		return
	set_aiming(null)
	for(var/obj/item/rig_module/module as anything in installed_modules)
		module.deactivate()
		module.on_wearer_cleared()
	if(cable.loc != src)
		retract_cable()
	for(var/obj/item/clothing/piece as anything in get_pieces())
		retract_piece(piece, silent = TRUE)
	sealed = FALSE
	sealing = FALSE
	flags_item &= ~NODROP
	if(wearer.internal == air_supply)
		wearer.internal = null
	UnregisterSignal(wearer, COMSIG_PARENT_QDELETING)
	wearer = null
	update_online()
	update_cable_beam()
	update_icon()

/obj/item/rig/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	clear_wearer()

/obj/item/rig/update_icon()
	. = ..()
	wearer?.update_inv_back()

/obj/item/rig/get_mob_overlay(mob/user_mob, slot, default_bodytype = "Default")
	var/image/overlay = ..()
	if(slot != WEAR_BACK || !overlay)
		return overlay
	for(var/obj/item/rig_module/module as anything in installed_modules)
		var/module_overlay = module.get_suit_overlay()
		if(module_overlay)
			overlay.overlays += image(module.suit_overlay_icon, module_overlay)
	return overlay

// Sealing

/**
 * Deploys and seals the suit if it isn't sealed, unseals and retracts it if it is
 *
 * Arguments:
 * * user - who asked for it
 */
/obj/item/rig/proc/toggle_suit(mob/user)
	if(sealing)
		to_chat(user, SPAN_WARNING("The suit is already adjusting its seals."))
		return
	if(!wearer || wearer.back != src)
		to_chat(user, SPAN_WARNING("[src] has to be worn on the back."))
		return
	if(sealed)
		unseal_suit()
	else
		seal_suit()

/**
 * Deploys every piece onto the wearer and seals them one by one, which the wearer has to stand still for
 *
 * Returns TRUE once the suit is sealed.
 */
/obj/item/rig/proc/seal_suit()
	if(!cell || cell.charge <= 0)
		to_chat(wearer, SPAN_WARNING("[src] has no power to seal the suit."))
		return FALSE
	var/mob/living/carbon/human/sealing_wearer = wearer
	for(var/obj/item/clothing/piece as anything in get_pieces())
		if(!deploy_piece(piece))
			playsound(src, 'modular_chaos/universes/bay12/sound/machines/rigerror.ogg', 25, FALSE)
			for(var/obj/item/clothing/deployed_piece as anything in get_pieces())
				retract_piece(deployed_piece, silent = TRUE)
			return FALSE
	sealing = TRUE
	flags_item |= NODROP
	playsound(src, 'modular_chaos/universes/bay12/sound/machines/rigstarted.ogg', 25, FALSE)
	sealing_wearer.visible_message(SPAN_NOTICE("[sealing_wearer]'s suit emits a quiet hum as it begins to adjust its seals."),
		SPAN_NOTICE("With a quiet hum, the suit begins running checks and adjusting components."))
	for(var/obj/item/clothing/piece as anything in get_pieces())
		if((seal_delay && !do_after(sealing_wearer, seal_delay, INTERRUPT_ALL, BUSY_ICON_GENERIC)) || wearer != sealing_wearer || piece.loc != wearer)
			to_chat(sealing_wearer, SPAN_WARNING("You have to stand still while the suit adjusts its components."))
			playsound(src, 'modular_chaos/universes/bay12/sound/machines/rigerror.ogg', 25, FALSE)
			for(var/obj/item/clothing/sealed_piece as anything in sealed_pieces.Copy())
				set_piece_sealed(sealed_piece, FALSE)
			sealing = FALSE
			flags_item &= ~NODROP
			update_online()
			return FALSE
		set_piece_sealed(piece, TRUE)
		to_chat(sealing_wearer, SPAN_NOTICE("[piece] [piece.gender == PLURAL ? "seal" : "seals"] around you."))
		playsound(src, 'modular_chaos/universes/bay12/sound/machines/suitstorage_lockdoor.ogg', 15, FALSE)
	sealing = FALSE
	sealed = TRUE
	to_chat(sealing_wearer, SPAN_NOTICE("<b>Your entire suit tightens around you as the components lock into place.</b>"))
	update_online()
	return TRUE

/**
 * Unseals the pieces one by one, which the wearer has to stand still for, and retracts them
 *
 * Returns TRUE once the suit is retracted.
 */
/obj/item/rig/proc/unseal_suit()
	var/mob/living/carbon/human/sealing_wearer = wearer
	sealing = TRUE
	for(var/obj/item/rig_module/module as anything in installed_modules)
		module.deactivate()
	set_aiming(null)
	update_online()
	sealing_wearer.visible_message(SPAN_NOTICE("[sealing_wearer]'s suit hisses as it begins to release its seals."),
		SPAN_NOTICE("The suit begins to release its seals."))
	for(var/obj/item/clothing/piece as anything in reverselist(get_pieces()))
		if(!(piece in sealed_pieces))
			continue
		if((seal_delay && !do_after(sealing_wearer, seal_delay, INTERRUPT_ALL, BUSY_ICON_GENERIC)) || wearer != sealing_wearer)
			to_chat(sealing_wearer, SPAN_WARNING("You have to stand still while the suit adjusts its components."))
			sealing = FALSE
			update_online()
			return FALSE
		set_piece_sealed(piece, FALSE)
		playsound(src, 'modular_chaos/universes/bay12/sound/machines/suitstorage_lockdoor.ogg', 15, FALSE)
	sealing = FALSE
	sealed = FALSE
	flags_item &= ~NODROP
	for(var/obj/item/clothing/piece as anything in get_pieces())
		retract_piece(piece, silent = TRUE)
	to_chat(sealing_wearer, SPAN_NOTICE("<b>Your suit loosens and retracts into [src].</b>"))
	update_online()
	return TRUE

/**
 * Marks a piece as sealed or not, which changes its sprite
 *
 * Arguments:
 * * piece - one of the pieces
 * * new_sealed - whether it is now sealed
 */
/obj/item/rig/proc/set_piece_sealed(obj/item/clothing/piece, new_sealed)
	if(new_sealed)
		sealed_pieces |= piece
	else
		sealed_pieces -= piece
	piece.icon_state = get_piece_state(piece, new_sealed)
	if(piece.loc != wearer)
		return
	switch(get_piece_slot(piece))
		if(WEAR_HEAD)
			wearer.update_inv_head()
		if(WEAR_JACKET)
			wearer.update_inv_wear_suit()
		if(WEAR_HANDS)
			wearer.update_inv_gloves()
		if(WEAR_FEET)
			wearer.update_inv_shoes()

/**
 * Puts a piece on the wearer, unless the slot is taken or it doesn't fit
 *
 * Arguments:
 * * piece - one of the pieces
 *
 * Returns TRUE if the piece is on the wearer.
 */
/obj/item/rig/proc/deploy_piece(obj/item/clothing/piece)
	if(piece.loc == wearer)
		return TRUE
	var/slot = get_piece_slot(piece)
	var/obj/item/in_the_way = wearer.get_item_by_slot(slot)
	if(in_the_way && (piece == gloves || piece == boots) && !(in_the_way.flags_item & NODROP))
		// The gauntlets and boots go over the wearer's own gloves and shoes
		if(!wearer.drop_inv_item_to_loc(in_the_way, piece))
			return FALSE
		covered_items[piece] = in_the_way
		in_the_way = null
	if(in_the_way)
		to_chat(wearer, SPAN_WARNING("[src] can't deploy [piece]: [in_the_way] [in_the_way.gender == PLURAL ? "are" : "is"] in the way."))
		return FALSE
	if(!wearer.equip_to_slot_if_possible(piece, slot, disable_warning = TRUE))
		to_chat(wearer, SPAN_WARNING("[src] can't deploy [piece] onto your body."))
		return_covered_item(piece, wearer)
		return FALSE
	if(piece == helmet)
		playsound(wearer, 'modular_chaos/universes/bay12/sound/items/helmet_close.ogg', 20, FALSE)
	to_chat(wearer, SPAN_NOTICE("Your [piece.name] [piece.gender == PLURAL ? "deploy" : "deploys"] swiftly."))
	return TRUE

/**
 * Takes a piece off the wearer and back into the rig, unsealed
 *
 * Arguments:
 * * piece - one of the pieces
 * * silent - whether to tell the wearer
 */
/obj/item/rig/proc/retract_piece(obj/item/clothing/piece, silent = FALSE)
	if(piece in sealed_pieces)
		set_piece_sealed(piece, FALSE)
	if(piece == helmet && wearer?.internal == air_supply)
		wearer.internal = null
	if(piece.loc == src)
		return
	var/mob/living/carbon/human/holder = wearer
	if(ismob(piece.loc))
		holder = piece.loc
		holder.drop_inv_item_to_loc(piece, src, force = TRUE)
		if(piece == helmet && !silent)
			playsound(holder, 'modular_chaos/universes/bay12/sound/items/helmet_open.ogg', 20, FALSE)
	else
		piece.forceMove(src)
	return_covered_item(piece, holder)
	if(!silent && wearer)
		to_chat(wearer, SPAN_NOTICE("Your [piece.name] [piece.gender == PLURAL ? "retract" : "retracts"] swiftly."))

/**
 * Puts the wearer's own gloves or shoes a piece was deployed over back on them, or on the floor if they can't wear them
 *
 * Arguments:
 * * piece - the gauntlets or boots
 * * owner - who wore them, or null if nobody does now
 */
/obj/item/rig/proc/return_covered_item(obj/item/clothing/piece, mob/living/carbon/human/owner)
	var/obj/item/covered_item = covered_items[piece]
	if(!covered_item)
		return
	covered_items -= piece
	if(owner && owner.equip_to_slot_if_possible(covered_item, get_piece_slot(piece), disable_warning = TRUE))
		return
	covered_item.forceMove(get_turf(owner || src))

/**
 * Deploys or retracts the helmet alone, so the wearer can show the face while the suit stays sealed
 *
 * Arguments:
 * * user - who asked for it
 */
/obj/item/rig/proc/toggle_helmet(mob/user)
	if(!helmet || sealing || !wearer || wearer.back != src)
		return
	if(helmet.loc == wearer)
		visor?.deactivate()
		if(wearer.internal == air_supply)
			to_chat(wearer, SPAN_NOTICE("[src] closes the air supply."))
		retract_piece(helmet)
		return
	if(deploy_piece(helmet) && sealed)
		set_piece_sealed(helmet, TRUE)
	update_vision()

/**
 * Connects the air tank to the sealed helmet as internals, or disconnects it
 *
 * Arguments:
 * * user - who asked for it
 */
/obj/item/rig/proc/toggle_air_supply(mob/user)
	if(!wearer || !air_supply)
		return
	if(wearer.internal == air_supply)
		wearer.internal = null
		to_chat(wearer, SPAN_NOTICE("You close the air supply of [src]."))
		return
	if(!can_supply_air())
		to_chat(wearer, SPAN_WARNING("The air supply needs the helmet deployed and the suit sealed."))
		return
	wearer.internal = air_supply
	to_chat(wearer, SPAN_NOTICE("You open the air supply of [src], [air_supply] now feeds your helmet."))

/// Returns whether the wearer can breathe from the air tank: the suit is sealed and the helmet is on
/obj/item/rig/proc/can_supply_air()
	return wearer && air_supply && air_supply.loc == src && sealed && helmet?.loc == wearer && wearer.head == helmet

// Power

/**
 * Updates whether the suit is online, and with it the slowdown, the vision and the modules
 */
/obj/item/rig/proc/update_online()
	var/new_online = sealed && !sealing && wearer && wearer.back == src && cell && cell.charge > 0
	if(online == new_online)
		return
	online = new_online
	if(online)
		playsound(src, 'modular_chaos/universes/bay12/sound/machines/rigonline.ogg', 25, FALSE)
	else if(sealed && !sealing)
		playsound(src, 'modular_chaos/universes/bay12/sound/machines/rigdown.ogg', 25, FALSE)
	if(chest)
		chest.slowdown = online ? online_slowdown : offline_slowdown
	if(wearer)
		wearer.recalculate_move_delay = TRUE
	update_vision()
	if(online)
		return
	for(var/obj/item/rig_module/module as anything in installed_modules)
		module.deactivate()
	set_aiming(null)
	if(sealed && !sealing && wearer)
		to_chat(wearer, SPAN_DANGER("Your suit beeps stridently, and suddenly you're wearing a leaden mass of metal and plastic composites instead of a powered suit."))

/// Updates how much the helmet blocks the view
/obj/item/rig/proc/update_vision()
	if(!helmet)
		return
	helmet.vision_impair = online ? VISION_IMPAIR_NONE : offline_vision_impair
	if(wearer && wearer.head == helmet)
		wearer.update_tint()

/**
 * Takes charge from the cell
 *
 * Arguments:
 * * amount - the charge
 *
 * Returns TRUE if the cell had it.
 */
/obj/item/rig/proc/use_power(amount)
	if(!cell || cell.charge < amount)
		return FALSE
	cell.use(amount)
	return TRUE

/**
 * Puts charge into the cell
 *
 * Arguments:
 * * amount - the charge
 *
 * Returns how much went in.
 */
/obj/item/rig/proc/give_power(amount)
	if(!cell)
		return 0
	var/given = min(amount, cell.maxcharge - cell.charge)
	if(given <= 0)
		return 0
	cell.charge += given
	cell.update_icon()
	return given

/obj/item/rig/process(delta_time)
	// Pieces that got away somehow go back
	for(var/obj/item/clothing/piece as anything in get_pieces())
		if(piece.loc != src && !(wearer && piece.loc == wearer))
			retract_piece(piece, silent = TRUE)

	process_cable(delta_time)
	update_online()
	if(!online)
		return

	var/power_per_second = RIG_BASE_POWER_USE
	for(var/obj/item/rig_module/module as anything in installed_modules)
		power_per_second += module.rig_process(delta_time)
	var/power_used = power_per_second * delta_time
	if(cell.charge < power_used)
		cell.charge = 0
		cell.update_icon()
		update_online()
		return
	cell.use(power_used)

// Modules

/**
 * Puts a module into the rig
 *
 * Arguments:
 * * module - the module, already moved into the rig or about to be
 */
/obj/item/rig/proc/install_module(obj/item/rig_module/module)
	if(module.loc != src)
		module.forceMove(src)
	installed_modules += module
	module.installed(src)
	update_icon()

/**
 * Takes a module out of the rig
 *
 * Arguments:
 * * module - the module
 * * user - who takes it out, it goes into their hands if they can hold it
 */
/obj/item/rig/proc/uninstall_module(obj/item/rig_module/module, mob/user)
	module.deactivate()
	if(selected_module == module)
		selected_module = null
	if(aiming_module == module)
		set_aiming(null)
	installed_modules -= module
	module.removed()
	module.forceMove(get_turf(src))
	user?.put_in_hands(module)
	update_icon()

/**
 * Returns why a module can't go into the rig, or null if it can
 *
 * Arguments:
 * * module - the module
 */
/obj/item/rig/proc/get_install_problem(obj/item/rig_module/module)
	for(var/obj/item/rig_module/installed_module as anything in installed_modules)
		if(is_type_in_list(installed_module, module.banned_modules) || is_type_in_list(module, installed_module.banned_modules))
			return "[installed_module] is incompatible with [module]."
		if(!module.redundant && installed_module.type == module.type)
			return "[src] already has a module of that kind."
	return module.get_install_problem(src)

/**
 * Selects the module the use keybinding uses
 *
 * Arguments:
 * * module - the module, or null for none
 */
/obj/item/rig/proc/select_module(obj/item/rig_module/module)
	if(aiming_module && aiming_module != module)
		set_aiming(null)
	selected_module = module
	if(wearer && module)
		to_chat(wearer, SPAN_NOTICE("Primary system is now: <b>[module.interface_name]</b>."))

/**
 * Makes the next click of the wearer go to a module that needs a target, or stops it
 *
 * The click is taken before anything else handles it; modified clicks (examine, pulling) and clicks on the HUD still
 * work as usual.
 *
 * Arguments:
 * * module - the module, or null to stop aiming
 */
/obj/item/rig/proc/set_aiming(obj/item/rig_module/module)
	if(aiming_module == module)
		return
	if(aiming_module && wearer)
		UnregisterSignal(wearer, COMSIG_MOB_PRE_CLICK)
		if(!module)
			to_chat(wearer, SPAN_NOTICE("You lower [aiming_module.interface_name]."))
	aiming_module = module
	if(!module || !wearer)
		return
	RegisterSignal(wearer, COMSIG_MOB_PRE_CLICK, PROC_REF(on_wearer_click))
	to_chat(wearer, SPAN_NOTICE("[capitalize(module.interface_name)] is ready: click a target, or use it again to lower it."))

/obj/item/rig/proc/on_wearer_click(mob/source, atom/target, list/mods)
	SIGNAL_HANDLER
	if(mods[SHIFT_CLICK] || mods[ALT_CLICK] || mods[CTRL_CLICK] || mods[MIDDLE_CLICK] || istype(target, /atom/movable/screen))
		return NONE
	var/obj/item/rig_module/module = aiming_module
	set_aiming(null)
	INVOKE_ASYNC(module, TYPE_PROC_REF(/obj/item/rig_module, engage), target)
	return COMPONENT_INTERRUPT_CLICK

// Interaction

/obj/item/rig/attack_hand(mob/user, mods)
	if(loc == user && storage)
		if(storage.container.handle_attack_hand(user, mods))
			return ..()
		return
	return ..()

/obj/item/rig/MouseDrop(obj/over_object)
	if(!storage || storage.container.handle_mousedrop(usr, over_object))
		return ..()

/obj/item/rig/clicked(mob/user, list/mods)
	if(mods[ALT_CLICK] && !mods[SHIFT_CLICK] && !mods[CTRL_CLICK] && Adjacent(user))
		pull_cable(user)
		return TRUE
	return ..()

/obj/item/rig/attackby(obj/item/attacking_item, mob/user)
	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_SCREWDRIVER))
		if(sealed || sealing)
			to_chat(user, SPAN_WARNING("The maintenance panel is locked while the suit is sealed."))
			return TRUE
		panel_open = !panel_open
		playsound(src, 'sound/items/Screwdriver.ogg', 25, TRUE)
		to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the maintenance panel of [src]."))
		return TRUE

	if(panel_open && maintenance_attackby(attacking_item, user))
		return TRUE

	for(var/obj/item/rig_module/module as anything in installed_modules)
		if(module.accepts_item(attacking_item, user))
			return TRUE

	if(storage && loc == user)
		return storage.container.attackby(attacking_item, user)
	return ..()

/**
 * Handles the items used on the rig while its maintenance panel is open
 *
 * Arguments:
 * * attacking_item - the item
 * * user - who uses it
 *
 * Returns TRUE if the item was handled.
 */
/obj/item/rig/proc/maintenance_attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/rig_module))
		var/obj/item/rig_module/module = attacking_item
		if(wearer)
			to_chat(user, SPAN_WARNING("You can't install a module while [src] is being worn."))
			return TRUE
		var/problem = get_install_problem(module)
		if(problem)
			to_chat(user, SPAN_WARNING(problem))
			return TRUE
		to_chat(user, SPAN_NOTICE("You begin installing [module] into [src]."))
		if(!do_after(user, 2 SECONDS, INTERRUPT_ALL, BUSY_ICON_BUILD, src) || !panel_open || wearer || module.loc != user || get_install_problem(module))
			return TRUE
		if(!user.drop_inv_item_to_loc(module, src))
			return TRUE
		install_module(module)
		to_chat(user, SPAN_NOTICE("You install [module] into [src]."))
		return TRUE

	if(istype(attacking_item, /obj/item/cell))
		if(cell)
			to_chat(user, SPAN_WARNING("[src] already has a cell."))
			return TRUE
		if(!user.drop_inv_item_to_loc(attacking_item, src))
			return TRUE
		cell = attacking_item
		to_chat(user, SPAN_NOTICE("You jack [cell] into the battery mount of [src]."))
		return TRUE

	if(istype(attacking_item, /obj/item/tank))
		if(air_supply)
			to_chat(user, SPAN_WARNING("[src] already has a tank."))
			return TRUE
		if(!user.drop_inv_item_to_loc(attacking_item, src))
			return TRUE
		set_air_supply(attacking_item)
		to_chat(user, SPAN_NOTICE("You slot [air_supply] into [src] and tighten the connecting valve."))
		return TRUE

	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		remove_part(user)
		return TRUE
	return FALSE

/**
 * Asks the user what to take out of the rig, the cell, the tank or a module, and gives it to them
 *
 * Arguments:
 * * user - who takes it out
 */
/obj/item/rig/proc/remove_part(mob/user)
	var/list/parts = list()
	if(cell)
		parts += "cell"
	if(air_supply)
		parts += "air tank"
	for(var/obj/item/rig_module/module as anything in installed_modules)
		if(!module.permanent)
			parts[module.name] = module
	if(!length(parts))
		to_chat(user, SPAN_WARNING("There is nothing to take out of [src]."))
		return
	var/choice = tgui_input_list(user, "What do you want to take out?", "[src]", parts)
	if(!choice || !panel_open || !user.Adjacent(src) || user.is_mob_incapacitated())
		return
	switch(choice)
		if("cell")
			if(!cell)
				return
			var/obj/item/cell/removed_cell = cell
			cell = null
			update_online()
			removed_cell.forceMove(get_turf(src))
			user.put_in_hands(removed_cell)
			to_chat(user, SPAN_NOTICE("You detach [removed_cell] from the battery mount of [src]."))
		if("air tank")
			if(!air_supply)
				return
			var/obj/item/tank/removed_tank = air_supply
			set_air_supply(null)
			removed_tank.forceMove(get_turf(src))
			user.put_in_hands(removed_tank)
			to_chat(user, SPAN_NOTICE("You detach [removed_tank] from [src]."))
		else
			var/obj/item/rig_module/module = parts[choice]
			if(!(module in installed_modules))
				return
			if(wearer)
				to_chat(user, SPAN_WARNING("You can't remove a module while [src] is being worn."))
				return
			uninstall_module(module, user)
			to_chat(user, SPAN_NOTICE("You detach [module] from [src]."))
	playsound(src, 'sound/items/Ratchet.ogg', 25, TRUE)

/**
 * Sets the air tank, and the action that opens it
 *
 * Arguments:
 * * new_tank - the tank, or null for none
 */
/obj/item/rig/proc/set_air_supply(obj/item/tank/new_tank)
	if(air_supply && wearer?.internal == air_supply)
		wearer.internal = null
	for(var/datum/action/item_action/rig/toggle_air/air_action in actions)
		qdel(air_action)
	air_supply = new_tank
	if(!air_supply)
		return
	var/datum/action/item_action/rig/toggle_air/air_action = new(air_supply, src)
	if(wearer)
		air_action.give_to(wearer)
