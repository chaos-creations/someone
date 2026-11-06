/datum/species
	/// Icon file of the eyes state (eyes) drawn on the head, for species whose eyes aren't in upstream's face icon
	var/eye_icon = 'icons/mob/humans/onmob/human_face.dmi'
	/// Gases (GAS_TYPE_*) the species can breathe, or null for any; breathing another one suffocates it
	var/list/breathable_gases
	/// Gases (GAS_TYPE_*) that poison the species when it breathes them
	var/list/poisonous_gases
	/// Languages (LANGUAGE_*) the species always speaks, added after the equipment preset sets the languages of the job
	var/list/innate_languages
	/// Whether an item without a state of its own in the species' sprite sheet is drawn with the human sprite instead of not at all (see /obj/item/use_spritesheet())
	var/sprite_sheet_fallback = FALSE

/**
 * Gives a member of the species what it needs to survive, once its equipment preset is loaded
 *
 * Arguments:
 * * human - the member of the species
 */
/datum/species/proc/equip_survival_gear(mob/living/carbon/human/human)
	return
