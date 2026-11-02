// Human AI fires guns from timers, which may run after the gun has left its hands and lost its gun_user
/obj/item/weapon/gun/start_fire(datum/source, atom/object, turf/location, control, params, bypass_checks = FALSE)
	CAN_BE_REDEFINED(TRUE)
	if(!gun_user && !source)
		return FALSE
	return ..()

/// Getter for burst_delay
/obj/item/weapon/gun/proc/get_burst_fire_delay()
	return burst_delay

/// Getter for target
/obj/item/weapon/gun/proc/get_target()
	RETURN_TYPE(/atom)
	return target

/obj/item/weapon/gun/ai_can_use(mob/living/carbon/human/user, datum/human_ai_brain/ai_brain)
	if(!in_chamber && (current_mag?.current_rounds <= 0) && !ai_brain.weapon_ammo_search(src))
		return FALSE

	if((flags_gun_features & GUN_WY_RESTRICTED) && !wy_allowed_check(user))
		return FALSE

	return TRUE
