/obj/item/stack/medical
	flags_human_ai = HEALING_ITEM

/// Returns TRUE if the limb has burns that no ointment was put on yet
/obj/item/stack/medical/proc/limb_has_unsalved_burns(obj/limb/limb)
	for(var/datum/wound/wound as anything in limb.wounds)
		if(wound.internal || wound.damage_type != BURN)
			continue

		if(!(wound.salved & WOUND_BANDAGED))
			return TRUE
	return FALSE

/obj/item/stack/medical/bruise_pack/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target || issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			return TRUE
	return FALSE

/obj/item/stack/medical/bruise_pack/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
			user.zone_selected = limb.name
			attack(target, user)
			if(!ai_brain.ai_sleep(ai_brain.short_action_delay))
				return

/obj/item/stack/medical/ointment/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target || issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		if(limb_has_unsalved_burns(limb))
			return TRUE
	return FALSE

/obj/item/stack/medical/ointment/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		if(limb_has_unsalved_burns(limb))
			user.zone_selected = limb.name
			attack(target, user)
			if(!ai_brain.ai_sleep(ai_brain.short_action_delay))
				return

/obj/item/stack/medical/advanced/bruise_pack/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target || issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		if(limb_needs_trauma_kit(limb))
			return TRUE
	return FALSE

/obj/item/stack/medical/advanced/bruise_pack/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		// One application treats every wound on the limb
		if(limb_needs_trauma_kit(limb))
			user.zone_selected = limb.name
			attack(target, user)
			if(!ai_brain.ai_sleep(ai_brain.short_action_delay))
				return

/// Returns TRUE if the limb bleeds or has brute wounds that are not bandaged yet
/obj/item/stack/medical/advanced/bruise_pack/proc/limb_needs_trauma_kit(obj/limb/limb)
	if(locate(/datum/effects/bleeding/external) in limb.bleeding_effects_list)
		return TRUE

	for(var/datum/wound/wound as anything in limb.wounds)
		if(wound.internal || wound.damage_type == BURN)
			continue

		if(!(wound.bandaged & WOUND_BANDAGED))
			return TRUE
	return FALSE

/obj/item/stack/medical/advanced/ointment/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target || issynth(target))
		return FALSE

	for(var/obj/limb/limb as anything in target.limbs)
		if(limb_has_unsalved_burns(limb))
			return TRUE
	return FALSE

/obj/item/stack/medical/advanced/ointment/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		// One application treats every burn on the limb
		if(limb_has_unsalved_burns(limb))
			user.zone_selected = limb.name
			attack(target, user)
			if(!ai_brain.ai_sleep(ai_brain.short_action_delay))
				return

/obj/item/stack/medical/splint/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target)
		return FALSE
	return ai_brain.has_unsplinted_fracture(target)

/obj/item/stack/medical/splint/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	for(var/obj/limb/limb as anything in target.limbs)
		if(QDELETED(src))
			return

		if(!(limb.status & LIMB_BROKEN) || (limb.status & (LIMB_SPLINTED|LIMB_DESTROYED|LIMB_ROBOT|LIMB_SYNTHSKIN)))
			continue

		user.zone_selected = limb.name
		// Nobody can splint the arm holding the splint, so the other hand holds it for a moment
		var/splinting_held_arm = (user == target) && (limb.name in (user.hand ? list("l_arm", "l_hand") : list("r_arm", "r_hand")))
		if(splinting_held_arm)
			user.hand = !user.hand
		attack(target, user)
		if(splinting_held_arm)
			user.hand = !user.hand
		if(!ai_brain.ai_sleep(ai_brain.short_action_delay))
			return
