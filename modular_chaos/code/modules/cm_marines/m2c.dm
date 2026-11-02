/obj/structure/machinery/m56d_hmg/auto
	ammo_box_type = /obj/item/ammo_magazine/m2c

// A copy of the upstream proc that only moves the view of a gunner with a client, human AI gunners have none.
// Keep it in sync with upstream on merges that change it.
/obj/structure/machinery/m56d_hmg/auto/update_pixels(mob/user, mounting = TRUE)
	CAN_BE_REDEFINED(TRUE)
	if(mounting)
		var/diff_x = 0
		var/diff_y = 0
		var/tilesize = 32
		var/viewoffset = tilesize * 1

		user.reset_view(src)
		var/view_x = 0
		var/view_y = 0
		switch(dir)
			if(EAST)
				diff_x = -16 + user_old_x
				view_x = viewoffset
			if(WEST)
				diff_x = 16 + user_old_x
				view_x = -viewoffset
			if(NORTH)
				diff_y = -16 + user_old_y
				view_y = viewoffset
			if(SOUTH)
				diff_y = 16 + user_old_y
				view_y = -viewoffset

		if(user.client)
			user.client.set_pixel_x(view_x)
			user.client.set_pixel_y(view_y)

		animate(user, pixel_x=diff_x, pixel_y=diff_y, 0.4 SECONDS)
	else
		if(user.client)
			user.client.change_view(GLOB.world_view_size)
			user.client.set_pixel_x(0)
			user.client.set_pixel_y(0)

		animate(user, pixel_x=user_old_x, pixel_y=user_old_y, 4, 1)

/// Returns TRUE if rotate_to() would be able to turn the gun towards the atom
/obj/structure/machinery/m56d_hmg/auto/proc/can_rotate_to(atom/A)
	var/turf/gun_turf = get_turf(src)
	var/turf/target_turf = get_turf(A)
	if(!gun_turf || !target_turf || (gun_turf == target_turf))
		return FALSE

	var/dx = target_turf.x - gun_turf.x
	var/dy = target_turf.y - gun_turf.y
	var/direction
	if(abs(dx) < abs(dy))
		direction = dy > 0 ? NORTH : SOUTH
	else
		direction = dx > 0 ? EAST : WEST

	var/turf/rotate_check = get_step(gun_turf, turn(direction, 180))
	return !rotate_check?.density

/obj/structure/machinery/m56d_hmg/auto/can_aim_at(atom/target)
	return in_firing_arc(target) || can_rotate_to(target)
