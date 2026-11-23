/mob/living/carbon/xenomorph/can_take_strain(reset = FALSE)
	CAN_BE_REDEFINED(TRUE)
	if(MODE_HAS_FLAG(MODE_NO_XENO_EVOLVE))
		to_chat(src, SPAN_WARNING("This mode disallows xeno strains."))
		return FALSE
	return ..()
