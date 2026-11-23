/mob/living/carbon/xenomorph/evolve_checks()
	CAN_BE_REDEFINED(TRUE)
	if(MODE_HAS_FLAG(MODE_NO_XENO_EVOLVE))
		to_chat(src, SPAN_WARNING("This mode disallows xeno evolution."))
		return FALSE
	return ..()
