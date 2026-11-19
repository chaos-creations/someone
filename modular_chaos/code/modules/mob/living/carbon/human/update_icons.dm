// Re-implemented with the fix of upstream PR #13419: upstream adds the emissive eyes of TRAIT_INTENT_EYES species
// (Working Joes, first gen synthetics) to the image of the eyes in `.`, a type mismatch that runtimes on every limb
// when a mob turns into one of them. The emissive goes on the eyes' overlays instead. Drop this once that PR is merged.
/mob/living/carbon/human/update_eyes()
	CAN_BE_REDEFINED(TRUE)
	remove_overlay(EYES_LAYER)

	var/obj/limb/head/head = get_limb("head")

	if(!head || (head.status & LIMB_DESTROYED))
		return

	if(!(species.flags & HAS_EYELIDS) || eyelids_status == EYELID_OPEN || eyelids_status == EYELID_FLAYED)
		var/image/eyes = image('icons/mob/humans/onmob/human_face.dmi', species.eyes, layer = -EYES_LAYER)
		eyes.color = list(null, null, null, null, rgb(r_eyes, g_eyes, b_eyes))

		if(HAS_TRAIT(src, TRAIT_INTENT_EYES))
			eyes.overlays += emissive_appearance(icon = 'icons/mob/humans/onmob/human_face.dmi', icon_state = species.eyes)

		overlays_standing[EYES_LAYER] = eyes
		apply_overlay(EYES_LAYER)
