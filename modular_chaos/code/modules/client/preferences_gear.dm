/datum/gear/equip_to_user(mob/living/carbon/human/user, override_checks = FALSE, drop_instead_of_del = TRUE)
	CAN_BE_REDEFINED(TRUE)
	// Saved gear of another universe isn't given; the preview (override_checks) still shows it, like gear of another role
	if(!override_checks)
		var/datum/universe/universe = CURRENT_UNIVERSE
		if(!universe.has_gear(src))
			to_chat(user, SPAN_WARNING("Gear [display_name] cannot be equipped: Invalid Universe."))
			return
	return ..()
