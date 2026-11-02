/obj/item/ammo_magazine
	flags_human_ai = AMMUNITION_ITEM

/obj/item/ammo_magazine/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	if(current_rounds <= 0)
		return FALSE

	return TRUE

// Only the handfuls of guns that human AI reloads from handfuls are ammunition for it
/obj/item/ammo_magazine/handful
	flags_human_ai = NONE
