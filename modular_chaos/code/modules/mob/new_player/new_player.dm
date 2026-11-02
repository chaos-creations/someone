/mob/new_player/attempt_observe()
	CAN_BE_REDEFINED(TRUE)
	if(src != usr || is_observing_blocked())
		return
	return ..()
