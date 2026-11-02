// world.view is the "15x15" string, and callers (like IFF fire prevention) do math with the result, which runtimes for human AI without a client
/mob/get_maximum_view_range()
	CAN_BE_REDEFINED(TRUE)
	if(!client)
		return GLOB.world_view_size
	return ..()
