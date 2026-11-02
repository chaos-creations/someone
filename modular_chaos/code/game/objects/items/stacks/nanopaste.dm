/obj/item/stack/nanopaste
	flags_human_ai = HEALING_ITEM

/obj/item/stack/nanopaste/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!issynth(target))
		return FALSE

	// attack() forbids synths without allow_gun_usage from repairing themselves
	if(isspeciessynth(target) && (target == user) && !target.allow_gun_usage)
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal)
				continue

			return TRUE

	return FALSE

/obj/item/stack/nanopaste/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		for(var/datum/wound/wound in limb.wounds)
			if(wound.internal)
				continue

			if(QDELETED(src))
				return

			user.zone_selected = limb.name
			attack(target, user)
			if(!ai_brain.ai_sleep(ai_brain.short_action_delay * ai_brain.action_delay_mult))
				return
