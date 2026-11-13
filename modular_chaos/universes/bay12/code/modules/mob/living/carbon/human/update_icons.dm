/// The face icon upstream draws the eyes from, see /mob/living/carbon/human/proc/update_eyes() in code/modules/mob/living/carbon/human/update_icons.dm
#define UPSTREAM_EYE_ICON 'icons/mob/humans/onmob/human_face.dmi'

/mob/living/carbon/human/update_eyes()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	// A species can have its eyes in its own icon (/datum/species/var/eye_icon)
	var/image/eyes = overlays_standing[EYES_LAYER]
	if(!eyes || species.eye_icon == UPSTREAM_EYE_ICON)
		return .
	remove_overlay(EYES_LAYER)
	eyes.icon = species.eye_icon
	overlays_standing[EYES_LAYER] = eyes
	apply_overlay(EYES_LAYER)
	return .

#undef UPSTREAM_EYE_ICON
