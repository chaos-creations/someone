/// The face icon upstream draws the eyes from, see /obj/limb/head/get_limb_icon() in code/modules/organs/limbs.dm
#define UPSTREAM_EYE_ICON 'icons/mob/humans/onmob/human_face.dmi'

/obj/limb/head/get_limb_icon()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	// A species can have its eyes in its own icon (/datum/species/var/eye_icon)
	if(species.eye_icon == UPSTREAM_EYE_ICON)
		return .
	for(var/image/overlay in .)
		if(overlay.icon == UPSTREAM_EYE_ICON && overlay.icon_state == species.eyes)
			overlay.icon = species.eye_icon
	return .

#undef UPSTREAM_EYE_ICON
