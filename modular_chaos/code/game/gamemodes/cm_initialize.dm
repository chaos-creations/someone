/datum/game_mode
	/// Whether players can become xenomorphs: join as one, take over a xeno, or be drafted from the larva pool. Admins can still put players into xenos
	var/xeno_join_allowed = TRUE

/datum/game_mode/check_xeno_late_join(mob/xeno_candidate)
	CAN_BE_REDEFINED(TRUE)
	if(!xeno_join_allowed)
		to_chat(xeno_candidate, SPAN_WARNING("Joining as a xenomorph is disabled in [name]."))
		return FALSE
	return ..()
