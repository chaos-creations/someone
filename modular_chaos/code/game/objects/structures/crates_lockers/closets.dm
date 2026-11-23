/obj/structure/closet/dump_contents()
	CAN_BE_REDEFINED(TRUE)
	var/list/obj/dumped_objects = list()
	for(var/obj/dumped_object in src)
		dumped_objects += dumped_object
	. = ..()
	// What falls out of a closet shifted on the map lands where the closet is drawn, as in cmss13-pve
	for(var/obj/dumped_object as anything in dumped_objects)
		if(dumped_object.loc != loc)
			continue
		dumped_object.pixel_x = pixel_x
		dumped_object.pixel_y = pixel_y
