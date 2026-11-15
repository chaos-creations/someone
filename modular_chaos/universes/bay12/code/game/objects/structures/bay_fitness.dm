//Gym equipment of Baystation 12 (code/game/objects/structures/fitness.dm in the source)

/// The nutrition a hit on a Bay punching bag costs, 5 * DEFAULT_HUNGER_FACTOR in the source
#define BAY_PUNCHINGBAG_NUTRITION (5 * HUNGER_FACTOR)
/// The time between hits on a Bay punching bag, DEFAULT_ATTACK_COOLDOWN in the source
#define BAY_PUNCHINGBAG_COOLDOWN (0.8 SECONDS)

/**
 * Bay gym equipment, which CM has none like
 *
 * Working out costs nutrition as in the source; the thirst and personal goals of the source are not ported.
 */
/obj/structure/bay_fitness
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/gym_equipment.dmi'
	anchored = TRUE
	/// Whether someone is working out on it
	var/being_used = FALSE

/// A Bay punching bag, hit on harm intent
/obj/structure/bay_fitness/punchingbag
	name = "punching bag"
	desc = "A punching bag."
	icon_state = "punchingbag"
	density = TRUE
	/// Verbs the hits are told with
	var/list/hit_message = list("hit", "punch", "kick", "robust")

/obj/structure/bay_fitness/punchingbag/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return ..()
	var/synth = issynth(user)
	if(!synth && user.nutrition < 20)
		to_chat(user, SPAN_WARNING("You need more energy to use the punching bag. Go eat something."))
		return
	if(user.a_intent != INTENT_HARM)
		return
	user.next_move = world.time + BAY_PUNCHINGBAG_COOLDOWN
	flick("[icon_state]_hit", src)
	playsound(loc, 'modular_chaos/universes/bay12/sound/effects/woodhit.ogg', 25, TRUE, -1)
	user.animation_attack_on(src)
	if(!synth)
		user.nutrition = max(user.nutrition - BAY_PUNCHINGBAG_NUTRITION, 0)
	to_chat(user, SPAN_WARNING("You [pick(hit_message)] [src]."))

/**
 * A Bay weightlifting machine
 *
 * Lifted by someone on its tile; a wrench sets its weight from 1 to 5. Lifting more than one's endurance can take
 * fails, and far more can hurt; the source weighs it against hauling, a skill CM has none like.
 */
/obj/structure/bay_fitness/weightlifter
	name = "weightlifting machine"
	desc = "A machine used to lift weights."
	icon_state = "weightlifter"
	/// The weight it is set to, 1 to max_weight
	var/weight = 1
	/// The heaviest weight it is set to
	var/max_weight = 5
	/// How a successful lift goes, from the hardest to the easiest
	var/list/success_message = list(" with great effort", ", straining hard", " without any trouble", " with ease")
	/// How a failed lift goes, from the closest to the furthest
	var/list/fail_message = list(", lifting them part of the way and then letting them drop", ", unable to even budge them")

/obj/structure/bay_fitness/weightlifter/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		return ..()
	playsound(src, 'sound/items/Ratchet.ogg', 25, TRUE)
	weight = (weight % max_weight) + 1
	user.visible_message(SPAN_NOTICE("[user] adjusts [src]'s weight level with \a [attacking_item]."), SPAN_NOTICE("You set [src]'s weight level to [weight] with [attacking_item]."))

/obj/structure/bay_fitness/weightlifter/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/synth = issynth(user)
	if(user.loc != loc)
		to_chat(user, SPAN_WARNING("You must be on the weight machine to use it."))
		return
	if(!synth && user.nutrition < 50)
		to_chat(user, SPAN_WARNING("You need more energy to lift weights. Go eat something."))
		return
	if(being_used)
		to_chat(user, SPAN_WARNING("The weight machine is already in use by somebody else."))
		return
	being_used = TRUE
	playsound(loc, 'modular_chaos/universes/bay12/sound/effects/weightlifter.ogg', 25, TRUE)
	user.setDir(SOUTH)
	flick("[icon_state]_[weight]", src)
	if(!do_after(user, (2 + weight) SECONDS, INTERRUPT_ALL, BUSY_ICON_GENERIC, src))
		being_used = FALSE
		return
	being_used = FALSE
	playsound(loc, 'modular_chaos/universes/bay12/sound/effects/weightdrop.ogg', 25, TRUE)
	var/skill = max_weight * (user.skills ? user.skills.get_skill_level(SKILL_ENDURANCE) : 0) / SKILL_ENDURANCE_MAX
	var/message
	if(skill < weight)
		if(weight - skill > max_weight * 0.5)
			if(prob(50))
				message = ", getting hurt in the process"
				user.apply_damage(5, BRUTE)
			else
				message = "; this does not look safe"
		else
			message = fail_message[min(1 + floor(weight - skill), length(fail_message))]
		user.visible_message(SPAN_NOTICE("[user] fails to lift the weights[message]."), SPAN_NOTICE("You fail to lift the weights[message]."))
		return
	if(!synth)
		user.nutrition = max(user.nutrition - weight * 5 * HUNGER_FACTOR, 0)
	message = success_message[min(1 + floor(skill - weight), length(success_message))]
	user.visible_message(SPAN_NOTICE("[user] lifts the weights[message]."), SPAN_NOTICE("You lift the weights[message]."))

#undef BAY_PUNCHINGBAG_NUTRITION
#undef BAY_PUNCHINGBAG_COOLDOWN
