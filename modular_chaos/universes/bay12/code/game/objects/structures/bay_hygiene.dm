//Toilets, showers, sinks, drains and faucets of Baystation 12 (code/game/objects/structures/watercloset.dm and drain.dm in the source)
// As CM has no fluids, nothing here clogs, floods or drains water: drains and faucets keep only what they do by hand.

/**
 * A Bay toilet
 *
 * A CM toilet (its cistern, crowbar and grabs as there) that works as the source's: a click lifts or drops the lid
 * instead of flushing, and nobody sits on it.
 */
/obj/structure/toilet/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/toilets.dmi'
	can_buckle = FALSE

// The source draws its cistern into the toilet itself, so there is no overlay of it
/obj/structure/toilet/bay/Initialize()
	. = ..()
	vis_contents -= cistern_overlay
	QDEL_NULL(cistern_overlay)

/obj/structure/toilet/bay/update_icon()
	icon_state = "toilet[open][cistern]"

/obj/structure/toilet/bay/attack_hand(mob/living/user)
	if(swirlie)
		user.visible_message(SPAN_DANGER("[user] slams the toilet seat onto [swirlie.name]'s head!"), SPAN_NOTICE("You slam the toilet seat onto [swirlie.name]'s head!"), "You hear reverberating porcelain.")
		swirlie.apply_damage(8, BRUTE)
		return
	if(cistern && !open)
		if(!length(contents))
			to_chat(user, SPAN_NOTICE("The cistern is empty."))
			return
		var/obj/item/found = pick(contents)
		if(ishuman(user))
			user.put_in_hands(found)
		else
			found.forceMove(get_turf(src))
		to_chat(user, SPAN_NOTICE("You find \an [found] in the cistern."))
		w_items -= found.w_class
		return
	open = !open
	update_icon()

/// The sound of a running Bay shower
/datum/looping_sound/bay_shower
	mid_sounds = 'modular_chaos/universes/bay12/sound/machines/shower.ogg'
	mid_length = 5 SECONDS
	volume = 20

/**
 * A Bay shower
 *
 * A CM shower (washing, mist and the heat of its water as there) with the sprite and the sound of the source, whose
 * temperature valve a wrench sets to the temperature picked rather than to the next one.
 */
/obj/structure/machinery/shower/bay
	desc = "The HS-451. Installed in the 2200s by the Hygiene Division."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/showers.dmi'
	/// The sound it makes while on
	var/datum/looping_sound/bay_shower/soundloop

/obj/structure/machinery/shower/bay/Initialize()
	. = ..()
	soundloop = new(src)

/obj/structure/machinery/shower/bay/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/structure/machinery/shower/bay/attack_hand(mob/user)
	. = ..()
	if(on)
		soundloop.start()
	else
		soundloop.stop()

/obj/structure/machinery/shower/bay/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		return ..()
	var/setting = tgui_input_list(user, "What setting would you like to set the temperature valve to?", "[name] Water Temperature Valve", list("normal", "boiling", "freezing"))
	if(!setting || !user.Adjacent(src))
		return
	playsound(src, 'sound/items/Ratchet.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] starts adjusting [src]'s temperature with [attacking_item]."), SPAN_NOTICE("You start adjusting [src]'s temperature with [attacking_item]."))
	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		return
	watertemp = setting
	playsound(src, 'sound/items/Ratchet.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] adjusts [src]'s temperature with [attacking_item]."), SPAN_NOTICE("You set [src]'s temperature to [watertemp] with [attacking_item]."))
	add_fingerprint(user)

/**
 * A Bay sink
 *
 * A CM sink (filling containers, alt-click to fill one up, extinguishers as there) that works as the source's: it has
 * no animations, washes with the sound of running water, wets mops and takes what is tipped into it.
 */
/obj/structure/sink/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/sinks.dmi'
	icon_state = "sink"

// CM sinks pick one of their animations, which the source has none of
/obj/structure/sink/bay/Initialize()
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/sink/bay/attack_hand(mob/user)
	if(isRemoteControlling(user) || !Adjacent(user))
		return
	if(busy)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return
	to_chat(user, SPAN_NOTICE("You start washing your hands."))
	playsound(loc, 'modular_chaos/universes/bay12/sound/effects/sink_long.ogg', 25, TRUE)
	busy = TRUE
	var/washed = do_after(user, 4 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC, src)
	busy = FALSE
	if(!washed)
		return
	user.clean_blood()
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.update_inv_gloves()
	user.visible_message(SPAN_NOTICE("[user] washes their hands using [src]."), SPAN_NOTICE("You wash your hands using [src]."))

/obj/structure/sink/bay/attackby(obj/item/attacking_item, mob/living/user, list/mods)
	if(istype(attacking_item, /obj/item/tool/extinguisher) || istype(attacking_item, /obj/item/attachable/attached_gun/extinguisher))
		return
	if(busy)
		to_chat(user, SPAN_WARNING("Someone's already washing here."))
		return

	if(istype(attacking_item, /obj/item/reagent_container))
		var/obj/item/reagent_container/container = attacking_item
		if(!container.reagents)
			return
		if(!container.is_open_container())
			to_chat(user, SPAN_WARNING("[container] needs to be open before you can fill it with [src]."))
			return
		playsound(src, 'modular_chaos/universes/bay12/sound/effects/sink.ogg', 25, TRUE)
		container.reagents.add_reagent("water", min(container.volume - container.reagents.total_volume, container.amount_per_transfer_from_this))
		user.visible_message(SPAN_NOTICE("[user] fills [container] with some water from [src]."), SPAN_NOTICE("You fill [container] with some water from [src]."), SPAN_NOTICE("You hear running water."))
		return

	if(istype(attacking_item, /obj/item/tool/mop))
		var/obj/item/tool/mop/mop = attacking_item
		mop.reagents.add_reagent("water", 5)
		mop.update_icon()
		playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] wets [mop] with [src]."), SPAN_NOTICE("You wet [mop] with [src]."), SPAN_NOTICE("You hear running water."))
		return

	playsound(src, 'modular_chaos/universes/bay12/sound/effects/sink_long.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] starts washing \a [attacking_item] in [src]."), SPAN_NOTICE("You start washing [attacking_item] in [src]."), SPAN_NOTICE("You hear running water."))
	busy = TRUE
	var/washed = do_after(user, 4 SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC, src)
	busy = FALSE
	if(!washed || QDELETED(attacking_item) || user.get_active_hand() != attacking_item)
		return
	attacking_item.clean_blood()
	user.visible_message(SPAN_NOTICE("[user] washes \a [attacking_item] in [src]."), SPAN_NOTICE("You wash [attacking_item] in [src]."))

/// Tips out a container dragged onto it
/obj/structure/sink/bay/MouseDrop_T(atom/dropping, mob/user)
	var/obj/item/container = dropping
	if(!istype(container) || !container.is_open_container() || !user.Adjacent(src) || !user.Adjacent(container))
		return ..()
	if(!container.reagents?.total_volume)
		to_chat(user, SPAN_WARNING("[container] is empty."))
		return
	visible_message(SPAN_NOTICE("[user] tips the contents of [container] into [src]."))
	container.reagents.clear_reagents()
	container.update_icon()

/obj/structure/sink/bay/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"

/**
 * A Bay drain, which a welder seals and a wrench takes up
 *
 * In the source it drains the water on its tile.
 */
/obj/structure/bay_drain
	name = "gutter"
	desc = "You probably can't get sucked down the plughole."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/drain.dmi'
	icon_state = "drain"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_TURF_LAYER
	/// Whether it is welded shut
	var/welded = FALSE
	/// The item it becomes when taken up
	var/item_type = /obj/item/bay_drain

/obj/structure/bay_drain/update_icon()
	icon_state = "[initial(icon_state)][welded ? "-welded" : ""]"

/obj/structure/bay_drain/get_examine_text(mob/user)
	. = ..()
	if(welded)
		. += "It is welded shut."

/obj/structure/bay_drain/attackby(obj/item/attacking_item, mob/user)
	if(iswelder(attacking_item))
		var/obj/item/tool/weldingtool/welder = attacking_item
		if(!welder.remove_fuel(1, user))
			return
		welded = !welded
		playsound(loc, 'sound/items/Welder2.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] [welded ? "welds" : "unwelds"] [src] with [welder]."), SPAN_NOTICE("You [welded ? "weld" : "unweld"] [src] with [welder]."))
		update_icon()
		return
	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		var/obj/item/bay_drain/drain_item = new item_type(loc)
		transfer_fingerprints_to(drain_item)
		playsound(src, 'sound/items/Ratchet.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] unwrenches [src] from the floor with [attacking_item]."), SPAN_NOTICE("You unwrench [src] from the floor with [attacking_item]."))
		qdel(src)
		return
	return ..()

/// A Bay drain of a bath, which a click opens and closes
/obj/structure/bay_drain/bath
	name = "sealable drain"
	desc = "You probably can't get sucked down the plughole. Specially not when it's closed!"
	icon_state = "drain_bath"
	item_type = /obj/item/bay_drain/bath
	/// Whether it is closed
	var/closed = FALSE

/obj/structure/bay_drain/bath/update_icon()
	if(welded)
		icon_state = "[initial(icon_state)]-welded"
	else
		icon_state = "[initial(icon_state)][closed ? "-closed" : ""]"

/obj/structure/bay_drain/bath/get_examine_text(mob/user)
	. = ..()
	. += "It is [closed ? "closed" : "open"]."

/obj/structure/bay_drain/bath/attack_hand(mob/user)
	. = ..()
	if(welded)
		return
	closed = !closed
	user.visible_message(SPAN_NOTICE("[user] has [closed ? "closed" : "opened"] the drain."))
	update_icon()

/// A Bay drain taken up, which a wrench secures to the floor again
/obj/item/bay_drain
	name = "gutter"
	desc = "You probably can't get sucked down the plughole."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/drain.dmi'
	icon_state = "drain"
	/// The drain it becomes when secured
	var/constructed_type = /obj/structure/bay_drain

/obj/item/bay_drain/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		return ..()
	if(!isturf(loc))
		to_chat(user, SPAN_WARNING("[src] needs to be placed on the floor before you can secure it."))
		return
	new constructed_type(loc)
	playsound(loc, 'sound/items/Ratchet.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] wrenches [src] down."), SPAN_NOTICE("You wrench [src] down."))
	qdel(src)

/obj/item/bay_drain/bath
	name = "sealable drain"
	desc = "You probably can't get sucked down the plughole. Specially not when it's closed!"
	icon_state = "drain_bath"
	constructed_type = /obj/structure/bay_drain/bath

/**
 * A Bay faucet of a pool, which a click opens and closes and a wrench takes up
 *
 * In the source it fills its tile with water while open.
 */
/obj/structure/bay_faucet
	name = "faucet"
	desc = "An outlet for liquids. Water you waiting for?"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/faucets.dmi'
	icon_state = "faucet"
	anchored = TRUE
	density = FALSE
	/// Whether it is open
	var/open = FALSE

/obj/structure/bay_faucet/update_icon()
	icon_state = "[initial(icon_state)][open ? "-on" : ""]"

/obj/structure/bay_faucet/get_examine_text(mob/user)
	. = ..()
	. += "It is turned [open ? "on" : "off"]."

/obj/structure/bay_faucet/attack_hand(mob/user)
	. = ..()
	open = !open
	playsound(loc, open ? 'modular_chaos/universes/bay12/sound/effects/closet_open.ogg' : 'modular_chaos/universes/bay12/sound/effects/closet_close.ogg', 10, TRUE)
	user.visible_message(SPAN_NOTICE("[user] has [open ? "opened" : "closed"] [src]."), SPAN_NOTICE("You [open ? "open" : "close"] [src]."))
	update_icon()

/obj/structure/bay_faucet/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		return ..()
	playsound(src, 'sound/items/Ratchet.ogg', 25, TRUE)
	var/obj/item/bay_faucet/faucet = new(loc)
	faucet.setDir(dir)
	transfer_fingerprints_to(faucet)
	user.visible_message(SPAN_NOTICE("[user] detaches [src] from the floor with [attacking_item]."), SPAN_NOTICE("You detach [src] from the floor with [attacking_item]."))
	qdel(src)

/// A Bay faucet taken up, which a wrench secures to the floor of a pool again
/obj/item/bay_faucet
	name = "faucet"
	desc = "An outlet for liquids. Water you waiting for?"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/faucets.dmi'
	icon_state = "faucet-item"

/obj/item/bay_faucet/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		return ..()
	if(!istype(loc, /turf/open/floor/bay/pool))
		to_chat(user, SPAN_WARNING("[src] can only be secured to pool tiles!"))
		return
	var/obj/structure/bay_faucet/faucet = new(loc)
	faucet.setDir(dir)
	playsound(loc, 'sound/items/Ratchet.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] wrenches [src] down."), SPAN_NOTICE("You wrench [src] down."))
	qdel(src)
