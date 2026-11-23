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

// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/reagent_container/hypospray/autoinjector/iron
	name = "iron autoinjector"
	chemname = "iron"
	desc = "An autoinjector loaded with 3 uses of iron, to restore blood volume."
	amount_per_transfer_from_this = REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD
	volume = (REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD) * INJECTOR_USES
	display_maptext = TRUE
	maptext_label = "Fe"

/obj/item/reagent_container/hypospray/autoinjector/adrenaline_concentrated
	name = "concentrated adrenaline autoinjector"
	chemname = "adrenaline_concentrated"
	desc = "An autoinjector loaded with 3 uses of Concentrated Adrenaline, a stimulant that prevents unconsciousness but causes serious cardiovascular strain. <B>WARNING: Do not inject an individual more than twice!</B>"
	amount_per_transfer_from_this = LOWM_REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD
	volume = (LOWM_REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD) * INJECTOR_USES
	display_maptext = TRUE
	maptext_label = "Ad"
