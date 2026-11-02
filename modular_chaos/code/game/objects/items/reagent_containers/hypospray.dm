/obj/item/reagent_container/hypospray
	flags_human_ai = HEALING_ITEM

/obj/item/reagent_container/hypospray/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target || (magfed && !mag) || !reagents?.total_volume)
		return FALSE

	// Untrained users still inject after fumbling, but locked hyposprays refuse outright
	if((skilllock != SKILL_MEDICAL_TRAINED) && !skillcheck(user, SKILL_MEDICAL, skilllock))
		return FALSE

	if(!target.can_inject(user, FALSE, "chest"))
		return FALSE

	return ai_brain.is_safe_dose(target, reagents, amount_per_transfer_from_this)

/obj/item/reagent_container/hypospray/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	user.zone_selected = "chest"
	attack(target, user)
