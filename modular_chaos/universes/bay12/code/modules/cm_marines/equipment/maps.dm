/datum/controller/global_vars/InitGlobalmapless_maps()
	CAN_BE_REDEFINED(TRUE)
	..()
	// The maps of the universe have no paper map (a wiki page with the map image) yet
	mapless_maps += list(MAP_CADAAB)
