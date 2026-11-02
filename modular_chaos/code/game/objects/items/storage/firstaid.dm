/obj/item/storage/pill_bottle
	flags_human_ai = HEALING_ITEM

/obj/item/storage/pill_bottle/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	if(!target || issynth(target))
		return FALSE

	if(skilllock && !skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC))
		return FALSE

	var/obj/item/reagent_container/pill/pill = locate() in src
	if(!pill)
		return FALSE

	return ai_brain.is_safe_dose(target, pill.reagents)

/obj/item/storage/pill_bottle/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain, mob/living/carbon/human/target)
	var/obj/item/reagent_container/pill/pill = locate() in src
	if(!pill?.reagents)
		return

	var/list/pill_reagents = list()
	for(var/datum/reagent/reagent as anything in pill.reagents.reagent_list)
		pill_reagents[reagent.id] = reagent.volume

	remove_from_storage(pill, user)
	pill.attack(target, user)
	if(QDELETED(pill))
		ai_brain.add_pending_reagents(target, pill_reagents)
		if(!ai_brain.ai_sleep(ai_brain.medium_action_delay * ai_brain.action_delay_mult))
			return
	// Packets don't take pills back
	else if((pill.loc == user) && !attempt_item_insertion(pill, TRUE, user))
		pill.forceMove(get_turf(user))

/obj/item/storage/pill_bottle/ai_is_spent()
	return !(locate(/obj/item/reagent_container/pill) in src)
