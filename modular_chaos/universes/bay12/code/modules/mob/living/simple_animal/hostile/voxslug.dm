/**
 * A vicious little slug the Vox keep, which bites everyone but them and latches onto the chest of the wounded
 *
 * Latched on, it stays in the chest like shrapnel (until surgery takes it out) and keeps pumping cryptobiolin, which
 * confuses, into its host.
 */
/mob/living/simple_animal/hostile/voxslug
	name = "slug"
	desc = "A vicious little creature, it has a mouth of too many teeth and a penchant for blood."
	icon = 'modular_chaos/universes/bay12/icons/mob/simple_animal/animal.dmi'
	icon_state = "voxslug"
	icon_living = "voxslug"
	icon_dead = "voxslug_dead"
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "stamps on"
	health = 15
	maxHealth = 15
	melee_damage_lower = 3
	melee_damage_upper = 6
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	move_to_delay = 2
	destroy_surroundings = FALSE
	mob_size = MOB_SIZE_SMALL
	min_oxy = 0
	holder_type = /obj/item/holder/voxslug

/mob/living/simple_animal/hostile/voxslug/FindTarget()
	// Held or latched on, it has its prey already
	if(istype(loc, /obj/item/holder))
		return null
	return ..()

/mob/living/simple_animal/hostile/voxslug/evaluate_target(mob/living/target)
	if(isvox(target))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/voxslug/AttackingTarget()
	. = ..()
	var/mob/living/carbon/human/human = .
	// The worse the wounds, the likelier it finds a way in
	if(istype(human) && !isvox(human) && prob(human.getBruteLoss() * 0.5))
		attach(human)

/mob/living/simple_animal/hostile/voxslug/get_scooped(mob/living/carbon/grabber)
	if(!isvox(grabber))
		to_chat(grabber, SPAN_WARNING("[src] wriggles out of your hands before you can pick it up!"))
		return
	return ..()

/mob/living/simple_animal/hostile/voxslug/Life(delta_time)
	. = ..()
	if(stat != CONSCIOUS || !istype(loc, /obj/item/holder))
		return .
	var/mob/living/host = loc.loc
	if(!isliving(host))
		return .
	if(prob(1))
		to_chat(host, SPAN_WARNING("You feel strange as [src] pulses..."))
	host.reagents?.add_reagent("cryptobiolin", 0.5)
	return .

/**
 * Latches onto the chest of the human, inside a holder that is embedded there
 *
 * Arguments:
 * * human - who it latches onto
 */
/mob/living/simple_animal/hostile/voxslug/proc/attach(mob/living/carbon/human/human)
	var/obj/limb/chest = human.get_limb("chest")
	if(!chest)
		return
	var/obj/item/holder/voxslug/slug_holder = new(get_turf(src))
	forceMove(slug_holder)
	slug_holder.name = name
	human.visible_message(SPAN_DANGER("[src] latches itself onto [human]!"), SPAN_HIGHDANGER("[src] latches itself onto your chest!"))
	chest.embed(slug_holder, silent = TRUE)

/obj/item/holder/voxslug
	name = "slug"
	desc = "A vicious little creature, it has a mouth of too many teeth and a penchant for blood."
	icon = 'modular_chaos/universes/bay12/icons/mob/simple_animal/animal.dmi'
	icon_state = "voxslug"
	item_icons = list(
		WEAR_L_HAND = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/inhands/items/holders_lefthand.dmi',
		WEAR_R_HAND = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/inhands/items/holders_righthand.dmi',
	)
	w_class = SIZE_TINY
	flags_equip_slot = NO_FLAGS

/obj/item/holder/voxslug/attack(mob/living/target, mob/living/user)
	var/mob/living/simple_animal/hostile/voxslug/slug = locate() in src
	if(!slug || slug.stat || !ishuman(target) || isvox(target))
		return ..()
	if(!do_after(user, 3 SECONDS, INTERRUPT_ALL, BUSY_ICON_HOSTILE, target, INTERRUPT_MOVED, BUSY_ICON_HOSTILE))
		return
	slug.forceMove(get_turf(src))
	slug.attach(target)
	qdel(src)
