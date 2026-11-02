/obj/item/reagent_container/hypospray/autoinjector/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(uses_left <= 0)
		return FALSE
	return ..()

/obj/item/reagent_container/hypospray/autoinjector/ai_is_spent()
	return uses_left <= 0

// Saved for when the AI is about to go down, so doubling up on what is already working is fine as long as nothing overdoses
/obj/item/reagent_container/hypospray/autoinjector/emergency/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if((uses_left <= 0) || !reagents?.total_volume || !target?.can_inject(user, FALSE, "chest"))
		return FALSE
	return ai_brain.is_safe_dose(target, reagents, amount_per_transfer_from_this, stack_doses = TRUE)
