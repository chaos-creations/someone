/obj/item
	/// flags for human AI to determine what this item does
	var/flags_human_ai = NO_FLAGS

/**
 * Called by human AI to use this item, from the AI's own process.
 *
 * May sleep. Subtypes that human AI can use override it together with ai_can_use().
 *
 * * user - the AI human using the item
 * * ai_brain - the brain of `user`
 */
/obj/item/proc/ai_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	return

/**
 * Returns TRUE if human AI can use this item right now through ai_use().
 *
 * * user - the AI human that would use the item
 * * ai_brain - the brain of `user`
 */
/obj/item/proc/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	return FALSE

/// Returns TRUE if the item is used up and a human AI should throw it away
/obj/item/proc/ai_is_spent()
	return FALSE
