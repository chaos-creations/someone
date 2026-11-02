/obj/item/stack/cable_coil
	flags_human_ai = HEALING_ITEM

// Medical purposes for synths
/obj/item/stack/cable_coil/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BRUTE))
				continue

			return TRUE

	return FALSE

/obj/item/stack/cable_coil/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	user.a_intent_change(INTENT_HELP)

	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal || (wound.damage_type == BRUTE))
				continue

			if(QDELETED(src))
				return

			user.zone_selected = limb.name
			attack(target, user)
			if(!ai_brain.ai_sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult))
				return
