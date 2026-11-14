//Fire axe cabinets of Baystation 12 (code/game/objects/structures/fireaxe_cabinet.dm in the source)

/// The least damage a hit does to the glass of a Bay fire axe cabinet, health_min_damage in the source
#define BAY_FIREAXE_CABINET_MIN_DAMAGE 15

/**
 * A Bay fire axe cabinet
 *
 * Works as the source's, not as a CM one: its maglock keeps it shut until a multitool unlocks it, a click then opens
 * and closes it, and the axe is taken by dragging the cabinet onto oneself. Hits strong enough break its glass, which
 * unlocks and opens it for good until reinforced glass repairs it. It holds a CM fire axe until the axes of the source
 * are ported.
 */
/obj/structure/bay_fireaxe_cabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/fireaxe_cabinet.dmi'
	icon_state = "fireaxe"
	anchored = TRUE
	density = FALSE
	health = 30
	/// Whether its glass door is open
	var/open = FALSE
	/// Whether its maglock is off
	var/unlocked = FALSE
	/// Whether its glass is broken
	var/smashed = FALSE
	/// The axe in it, if any
	var/obj/item/weapon/twohanded/fireaxe/fireaxe

/obj/structure/bay_fireaxe_cabinet/Initialize(mapload, ...)
	. = ..()
	fireaxe = new(src)
	update_icon()

/obj/structure/bay_fireaxe_cabinet/Destroy()
	if(fireaxe)
		fireaxe.forceMove(loc)
		fireaxe = null
	return ..()

/obj/structure/bay_fireaxe_cabinet/update_icon()
	overlays.Cut()
	if(fireaxe)
		overlays += image(icon, "fireaxe_item")
	if(smashed)
		overlays += image(icon, "fireaxe_window_broken")
	else if(!open)
		overlays += image(icon, "fireaxe_window")

/obj/structure/bay_fireaxe_cabinet/attack_hand(mob/user)
	if(!unlocked)
		to_chat(user, SPAN_WARNING("[src] is locked."))
		return
	toggle_open(user)

/obj/structure/bay_fireaxe_cabinet/MouseDrop(over_object, src_location, over_location)
	var/mob/living/user = usr
	if(over_object != user || !istype(user) || !user.Adjacent(src) || user.is_mob_incapacitated())
		return
	if(!open)
		to_chat(user, SPAN_WARNING("[src] is closed."))
		return
	if(!fireaxe)
		to_chat(user, SPAN_WARNING("[src] is empty."))
		return
	user.put_in_hands(fireaxe)
	fireaxe = null
	update_icon()

/obj/structure/bay_fireaxe_cabinet/attackby(obj/item/attacking_item, mob/living/user)
	if(istype(attacking_item, /obj/item/weapon/twohanded/fireaxe))
		if(!open)
			to_chat(user, SPAN_WARNING("[src] is closed."))
			return
		if(fireaxe)
			to_chat(user, SPAN_WARNING("[src] already has \a [fireaxe] inside."))
			return
		if(attacking_item.flags_item & WIELDED)
			to_chat(user, SPAN_WARNING("Unwield [attacking_item] first."))
			return
		if(!user.drop_inv_item_to_loc(attacking_item, src))
			return
		fireaxe = attacking_item
		update_icon()
		user.visible_message(SPAN_NOTICE("[user] places \a [attacking_item] into [src]."), SPAN_NOTICE("You place [attacking_item] into [src]."))
		return

	if(istype(attacking_item, /obj/item/stack/sheet/glass))
		if(health >= initial(health) && !smashed)
			to_chat(user, SPAN_WARNING("[src] doesn't need repair."))
			return
		if(!istype(attacking_item, /obj/item/stack/sheet/glass/reinforced))
			to_chat(user, SPAN_WARNING("[src] can only be repaired with reinforced glass."))
			return
		var/obj/item/stack/sheet/glass/reinforced/glass = attacking_item
		if(!glass.use(1))
			return
		user.visible_message(SPAN_NOTICE("[user] repairs [src]'s damage with [glass]."), SPAN_NOTICE("You repair [src]'s damage with [glass]."))
		health = initial(health)
		smashed = FALSE
		update_icon()
		return

	if(HAS_TRAIT(attacking_item, TRAIT_TOOL_MULTITOOL))
		if(open)
			to_chat(user, SPAN_WARNING("[src] must be closed before you can lock it."))
			return
		if(smashed)
			to_chat(user, SPAN_WARNING("[src] is shattered and the lock doesn't function."))
			return
		user.visible_message(SPAN_NOTICE("[user] begins toggling [src]'s maglock with \a [attacking_item]."), SPAN_NOTICE("You begin [unlocked ? "locking" : "unlocking"] [src]'s maglock with [attacking_item]."))
		if(!do_after(user, 2 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || open || smashed)
			return
		playsound(src, 'sound/machines/lockreset.ogg', 25, TRUE)
		unlocked = !unlocked
		user.visible_message(SPAN_NOTICE("[user] [unlocked ? "unlocks" : "locks"] [src]'s maglock with \a [attacking_item]."), SPAN_NOTICE("You [unlocked ? "unlock" : "lock"] [src]'s maglock with [attacking_item]."))
		return

	if(!smashed && attacking_item.force && !(attacking_item.flags_item & NOBLUDGEON))
		user.animation_attack_on(src)
		take_glass_damage(attacking_item.force, user)
		return ATTACKBY_HINT_UPDATE_NEXT_MOVE
	return ..()

/**
 * Damages its glass, which breaks once its health runs out
 *
 * * damage - the force of the hit, which does nothing below BAY_FIREAXE_CABINET_MIN_DAMAGE
 * * user - who hit it, if anyone
 */
/obj/structure/bay_fireaxe_cabinet/proc/take_glass_damage(damage, mob/user)
	if(damage < BAY_FIREAXE_CABINET_MIN_DAMAGE)
		playsound(src, 'modular_chaos/universes/bay12/sound/effects/Glasshit.ogg', 25, TRUE)
		if(user)
			to_chat(user, SPAN_NOTICE("The cabinet's protective glass glances off the hit."))
		return
	health -= damage
	if(health > 0)
		playsound(src, 'modular_chaos/universes/bay12/sound/effects/Glasshit.ogg', 25, TRUE)
		return
	playsound(src, 'sound/effects/Glassbr3.ogg', 50, TRUE)
	smashed = TRUE
	open = TRUE
	unlocked = TRUE
	update_icon()

/**
 * Opens or closes its door; a broken one stays open
 *
 * * user - who opens it
 */
/obj/structure/bay_fireaxe_cabinet/proc/toggle_open(mob/user)
	if(smashed)
		open = TRUE
		unlocked = TRUE
	else
		open = !open
		to_chat(user, SPAN_NOTICE("You [open ? "open" : "close"] [src]."))
	update_icon()

/obj/structure/bay_fireaxe_cabinet/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(smashed)
		return XENO_NO_DELAY_ACTION
	xeno.animation_attack_on(src)
	xeno.visible_message(SPAN_DANGER("[xeno] slashes [src]!"), SPAN_DANGER("We slash [src]!"), null, 5, CHAT_TYPE_XENO_COMBAT)
	take_glass_damage(xeno.melee_damage_upper)
	return XENO_ATTACK_ACTION

/obj/structure/bay_fireaxe_cabinet/bullet_act(obj/projectile/bullet)
	if(!smashed)
		take_glass_damage(bullet.damage)
	return TRUE

/obj/structure/bay_fireaxe_cabinet/ex_act(severity)
	if(!smashed)
		take_glass_damage(severity)

#undef BAY_FIREAXE_CABINET_MIN_DAMAGE
