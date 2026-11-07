/**
 * Grenade launcher module, a shoulder-mounted launcher loaded with ordinary grenades
 *
 * Grenades used on the rig go into it. Using it readies it, and the next click launches the first loaded grenade at
 * what was clicked, primed with a short fuse, like an underslung launcher does.
 */
/obj/item/rig_module/grenade_launcher
	name = "hardsuit grenade launcher"
	desc = "A shoulder-mounted micro-explosive dispenser. Load it by using grenades on the hardsuit."
	icon_state = "grenade"
	interface_name = "integrated grenade launcher"
	interface_desc = "Discharges loaded grenades at a target."
	targeted = TRUE
	use_power_cost = 50
	module_cooldown = 2 SECONDS
	suit_overlay_active = "grenade"
	suit_overlay_inactive = "grenade"
	/// How many grenades it holds
	var/max_grenades = 3
	/// How far, in tiles, it throws a grenade
	var/fire_range = 10
	/// The loaded grenades, launched first to last
	var/list/obj/item/explosive/grenade/loaded_grenades = list()

/obj/item/rig_module/grenade_launcher/Destroy()
	QDEL_LIST(loaded_grenades)
	return ..()

/obj/item/rig_module/grenade_launcher/get_examine_text(mob/user)
	. = ..()
	. += SPAN_NOTICE("It holds [length(loaded_grenades)] of [max_grenades] grenades.")

/obj/item/rig_module/grenade_launcher/get_status_name()
	return "[interface_name] ([length(loaded_grenades)]/[max_grenades])"

/obj/item/rig_module/grenade_launcher/accepts_item(obj/item/item, mob/user)
	if(!istype(item, /obj/item/explosive/grenade))
		return FALSE
	var/obj/item/explosive/grenade/grenade = item
	if(grenade.active)
		to_chat(user, SPAN_WARNING("[grenade] is already primed!"))
		return TRUE
	if(length(loaded_grenades) >= max_grenades)
		to_chat(user, SPAN_WARNING("[src] is full."))
		return TRUE
	if(!user.drop_inv_item_to_loc(grenade, src))
		return TRUE
	loaded_grenades += grenade
	to_chat(user, SPAN_NOTICE("You slot [grenade] into [src]. It holds [length(loaded_grenades)] of [max_grenades] now."))
	playsound(user, 'sound/weapons/grenade_insert.wav', 25, TRUE)
	return TRUE

/obj/item/rig_module/grenade_launcher/engage(atom/target)
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer || !target)
		return FALSE
	if(!length(loaded_grenades))
		to_chat(wearer, SPAN_WARNING("[src] is empty."))
		return FALSE
	var/obj/item/explosive/grenade/grenade = loaded_grenades[1]
	if(grenade.harmful && (!wearer.allow_gun_usage || MODE_HAS_MODIFIER(/datum/gamemode_modifier/ceasefire)))
		to_chat(wearer, SPAN_WARNING("You can't fire [grenade] now."))
		return FALSE
	if(!..())
		return FALSE
	loaded_grenades -= grenade
	wearer.visible_message(SPAN_DANGER("[wearer] launches \a [grenade]!"), SPAN_WARNING("You launch [grenade]!"), message_flags = CHAT_TYPE_WEAPON_USE)
	msg_admin_attack("[key_name_admin(wearer)] fired a grenade ([grenade.name]) from a hardsuit grenade launcher.")
	log_game("[key_name_admin(wearer)] fired a grenade ([grenade.name]) from a hardsuit grenade launcher.")
	playsound(wearer, 'sound/weapons/armbomb.ogg', 50, TRUE)
	grenade.det_time = min(10, grenade.det_time)
	grenade.activate(wearer, FALSE)
	grenade.forceMove(get_turf(wearer))
	grenade.throw_atom(target, fire_range, SPEED_VERY_FAST, wearer, null, NORMAL_LAUNCH, PASS_MOB_THRU|PASS_HIGH_OVER)
	return TRUE

/**
 * Flash module, a shoulder-mounted flash that blinds everyone around but the wearer
 */
/obj/item/rig_module/flash
	name = "hardsuit mounted flash"
	desc = "You are the law."
	icon_state = "flash"
	interface_name = "mounted flash"
	interface_desc = "Disorientates everyone around by blinding them with an intense light."
	usable = TRUE
	use_power_cost = 300
	module_cooldown = 10 SECONDS
	/// The flash it fires
	var/obj/item/device/flash/flash

/obj/item/rig_module/flash/Initialize(mapload, ...)
	. = ..()
	flash = new(src)
	flash.skilllock = SKILL_POLICE_DEFAULT

/obj/item/rig_module/flash/Destroy()
	QDEL_NULL(flash)
	return ..()

/obj/item/rig_module/flash/engage(atom/target)
	. = ..()
	if(!.)
		return
	// The suit powers it, so it never runs out or burns out
	flash.broken = FALSE
	flash.flashes_stored = flash.max_flashes_stored
	flash.last_used = 0
	flash.attack_self(holder.wearer)

/**
 * Held module, which deploys an item into the wearer's hand while it is on
 *
 * Let go of, the item goes back into the module and the module turns off.
 */
/obj/item/rig_module/held
	toggleable = TRUE
	/// Type of the item it deploys
	var/held_type
	/// The item it deploys
	var/obj/item/held_item
	/// How long deploying the item takes, standing still
	var/deploy_delay = 0

/obj/item/rig_module/held/Initialize(mapload, ...)
	. = ..()
	if(!held_type)
		return
	held_item = new held_type(src)
	RegisterSignal(held_item, COMSIG_ITEM_DROPPED, PROC_REF(on_held_item_dropped))

/obj/item/rig_module/held/Destroy()
	. = ..()
	QDEL_NULL(held_item)

/obj/item/rig_module/held/activate()
	var/mob/living/carbon/human/wearer = holder?.wearer
	if(!wearer || !held_item)
		return FALSE
	if(wearer.l_hand && wearer.r_hand)
		to_chat(wearer, SPAN_WARNING("Your hands are full."))
		return FALSE
	if(deploy_delay && !do_after(wearer, deploy_delay, INTERRUPT_ALL, BUSY_ICON_GENERIC))
		return FALSE
	. = ..()
	if(!.)
		return
	if(!wearer.put_in_hands(held_item))
		to_chat(wearer, SPAN_WARNING("Your hands are full."))
		deactivate()
		return FALSE
	on_deployed(wearer)
	wearer.visible_message(SPAN_WARNING("[wearer] deploys [held_item] from [wearer.p_their()] suit!"), SPAN_NOTICE("You deploy [held_item]."))

/obj/item/rig_module/held/deactivate()
	var/mob/living/carbon/human/wearer = holder?.wearer
	. = ..()
	if(!.)
		return
	retract_held_item()
	if(wearer)
		to_chat(wearer, SPAN_NOTICE("[held_item] retracts into your suit."))

/// Takes the item back from wherever it is
/obj/item/rig_module/held/proc/retract_held_item()
	if(QDELETED(held_item) || held_item.loc == src)
		return
	if(ismob(held_item.loc))
		var/mob/holder_mob = held_item.loc
		holder_mob.drop_inv_item_to_loc(held_item, src, force = TRUE)
	else
		held_item.forceMove(src)
	on_retracted()

/**
 * Called when the item is deployed into the wearer's hand
 *
 * Arguments:
 * * wearer - the wearer
 */
/obj/item/rig_module/held/proc/on_deployed(mob/living/carbon/human/wearer)
	return

/// Called when the item is back in the module
/obj/item/rig_module/held/proc/on_retracted()
	return

/obj/item/rig_module/held/proc/on_held_item_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	if(held_item.loc == src)
		return
	if(active)
		INVOKE_ASYNC(src, PROC_REF(deactivate))
	else
		INVOKE_ASYNC(src, PROC_REF(retract_held_item))

/obj/item/rig_module/held/shield
	name = "hardsuit shield module"
	desc = "A heavy deployable shield installable on a hardsuit."
	icon_state = ""
	interface_name = "deployable shield"
	interface_desc = "A reinforced ballistic shield, unfolded from the suit into the wearer's hand."
	active_power_cost = 1
	deploy_delay = 1.5 SECONDS
	held_type = /obj/item/weapon/shield/riot/rig

/obj/item/weapon/shield/riot/rig
	name = "hardsuit shield"
	desc = "A reinforced ballistic shield unfolded from a hardsuit. It folds back when let go of."
	flags_equip_slot = NO_FLAGS
	blocks_on_back = FALSE

/obj/item/rig_module/held/energy_blade
	name = "hardsuit energy blade projector"
	desc = "A powerful cutting beam projector."
	icon_state = "eblade"
	interface_name = "energy blade"
	interface_desc = "A lethal energy projector that shapes a blade from the hand of the wearer."
	use_power_cost = 300
	active_power_cost = 5
	held_type = /obj/item/weapon/energy/rig_blade

/obj/item/rig_module/held/energy_blade/on_deployed(mob/living/carbon/human/wearer)
	playsound(wearer, 'sound/weapons/saberon.ogg', 25, TRUE)

/obj/item/rig_module/held/energy_blade/on_retracted()
	playsound(src, 'sound/weapons/saberoff.ogg', 25, TRUE)

/obj/item/weapon/energy/rig_blade
	name = "energy blade"
	desc = "A blade of concentrated energy, projected from a hardsuit gauntlet."
	icon_state = "swordblue"
	active = TRUE
	force = 30
	throwforce = 0
	w_class = SIZE_LARGE
	flags_item = UNBLOCKABLE|NOBLUDGEON
	heat_source = 3500
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = TRUE

/**
 * Gun module, which deploys an energy gun that fires from the rig's cell
 */
/obj/item/rig_module/held/gun
	name = "hardsuit mounted gun"
	desc = "Some sort of mounted gun."
	icon_state = "egun"
	interface_name = "mounted gun"
	interface_desc = "A gun that fires from the suit's cell."
	held_type = /obj/item/weapon/gun/energy/rig

/obj/item/rig_module/held/gun/on_deployed(mob/living/carbon/human/wearer)
	var/obj/item/weapon/gun/energy/rig/gun = held_item
	gun.cell = holder.cell
	gun.update_icon()

/obj/item/rig_module/held/gun/on_retracted()
	var/obj/item/weapon/gun/energy/rig/gun = held_item
	gun.cell = null

/**
 * Energy gun of a gun module, firing from the cell of the rig while it is deployed
 */
/obj/item/weapon/gun/energy/rig
	name = "mounted energy gun"
	desc = "An energy gun mounted on a hardsuit. It draws its power from the suit."
	flags_equip_slot = NO_FLAGS
	works_in_recharger = FALSE
	/// The gun module it belongs to
	var/obj/item/rig_module/held/gun/module

/obj/item/weapon/gun/energy/rig/Initialize(mapload, spawn_empty)
	. = ..()
	// It fires from the rig's cell, set while it is deployed
	QDEL_NULL(cell)
	module = loc
	if(!istype(module))
		module = null

/obj/item/weapon/gun/energy/rig/Destroy()
	cell = null
	module = null
	return ..()

/obj/item/weapon/gun/energy/rig/able_to_fire(mob/user, is_point_blank = FALSE)
	if(!module?.holder?.online)
		to_chat(user, SPAN_WARNING("[src] has no power: the suit is not online."))
		return FALSE
	return ..()
