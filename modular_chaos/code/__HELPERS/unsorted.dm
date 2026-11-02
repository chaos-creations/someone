/// Makes a given dir cardinal. If the dir is non-cardinal, it will return both cardinal directions that make up the direction. Else, it will be a single-entry list returned.
/proc/make_dir_cardinal(direction)
	switch(direction)
		if(NORTH)
			return list(NORTH)

		if(EAST)
			return list(EAST)

		if(SOUTH)
			return list(SOUTH)

		if(WEST)
			return list(WEST)

		if(NORTHEAST)
			return list(NORTH, EAST)

		if(SOUTHEAST)
			return list(EAST, SOUTH)

		if(SOUTHWEST)
			return list(SOUTH, WEST)

		if(NORTHWEST)
			return list(NORTH, WEST)

//straight directions get priority over diagonal directions in edge cases
/proc/angle2dir4ai(angle)
	if(isnull(angle))
		return null
	switch(angle) // 80/10 degrees diagonals/cardinals respectively
		if (40 to 50)
			return NORTHEAST
		if (130 to 140)
			return SOUTHEAST
		if (220 to 230)
			return SOUTHWEST
		if (310 to 320)
			return NORTHWEST
		if (0 to 40)
			return NORTH
		if (50 to 130)
			return EAST
		if (140 to 220)
			return SOUTH
		if (230 to 310)
			return WEST
		else
			return NORTH

/// Returns TRUE if the two z-levels are the same or levels of one stack, connected by ZTRAIT_UP and ZTRAIT_DOWN
/proc/are_z_levels_connected(first_z, second_z)
	if(first_z == second_z)
		return TRUE
	if(!first_z || !second_z)
		return FALSE

	var/trait = (second_z > first_z) ? ZTRAIT_UP : ZTRAIT_DOWN
	var/current_z = first_z
	while(current_z != second_z)
		var/offset = SSmapping.level_trait(current_z, trait)
		if(!offset)
			return FALSE
		current_z += offset
		// Stacks go one way, so overshooting means the levels aren't in one
		if((trait == ZTRAIT_UP) ? (current_z > second_z) : (current_z < second_z))
			return FALSE
	return TRUE

/**
 * get_dist() that counts levels, as BYOND's get_dist() ignores z and puts a turf right above at a distance of 0.
 *
 * Each level of difference adds MULTIZ_LEVEL_DISTANCE tiles. Returns INFINITY for atoms on levels that are not one stack, or not on a turf.
 */
/proc/get_dist_multiz(atom/first, atom/second)
	var/turf/first_turf = get_turf(first)
	var/turf/second_turf = get_turf(second)
	if(!first_turf || !second_turf)
		return INFINITY
	if(first_turf.z == second_turf.z)
		return get_dist(first_turf, second_turf)
	if(!are_z_levels_connected(first_turf.z, second_turf.z))
		return INFINITY
	return get_dist(first_turf, second_turf) + abs(first_turf.z - second_turf.z) * MULTIZ_LEVEL_DISTANCE

/**
 * A copy of /proc/LinkBlocked() that returns every atom blocking the link instead of the first one.
 *
 * Used by AI pathfinding to add up the cost of all obstacles between two turfs.
 * Keep it in sync with LinkBlocked() on upstream merges that change it.
 *
 * Returns a list of blocking atoms (turfs included), empty if nothing blocks the link, or null if there is no mover or the turfs are the same.
 */
/proc/link_blocked_list(atom/movable/mover, turf/start_turf, turf/target_turf, list/atom/forget)
	if (!mover)
		return null

	/// the actual dir between the start and target turf
	var/fdir = get_dir(start_turf, target_turf)
	if (!fdir)
		return null

	var/fd1 = fdir & (fdir-1)
	var/fd2 = fdir - fd1
	var/list/list_to_return = list()

	/// The direction that mover's path is being blocked by
	var/blocking_dir = 0

	var/obstacle
	var/turf/T
	var/atom/A

	blocking_dir |= start_turf.BlockedExitDirs(mover, fdir)
	for (obstacle in start_turf) //First, check objects to block exit
		if (mover == obstacle || (obstacle in forget))
			continue
		if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.BlockedExitDirs(mover, fdir)
		if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			list_to_return += A

	// Check for atoms in adjacent turf EAST/WEST
	if (fd1 && fd1 != fdir)
		T = get_step(start_turf, fd1)
		if (T.BlockedExitDirs(mover, fd2) || T.BlockedPassDirs(mover, fd1))
			blocking_dir |= fd1
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				list_to_return += T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
				continue
			A = obstacle
			if (A.BlockedExitDirs(mover, fd2) || A.BlockedPassDirs(mover, fd1))
				blocking_dir |= fd1
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					list_to_return += A
				break

	// Check for atoms in adjacent turf NORTH/SOUTH
	if (fd2 && fd2 != fdir)
		T = get_step(start_turf, fd2)
		if (T.BlockedExitDirs(mover, fd1) || T.BlockedPassDirs(mover, fd2))
			blocking_dir |= fd2
			if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
				list_to_return += T
		for (obstacle in T)
			if(obstacle in forget)
				continue
			if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
				continue
			A = obstacle
			if (A.BlockedExitDirs(mover, fd1) || A.BlockedPassDirs(mover, fd2))
				blocking_dir |= fd2
				if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
					list_to_return += A
				break

	// Check the turf itself
	blocking_dir |= target_turf.BlockedPassDirs(mover, fdir)
	if ((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
		list_to_return += target_turf
	for (obstacle in target_turf) // Finally, check atoms in the target turf
		if(obstacle in forget)
			continue
		if (!isStructure(obstacle) && !ismob(obstacle) && !isVehicle(obstacle))
			continue
		A = obstacle
		blocking_dir |= A.BlockedPassDirs(mover, fdir)
		if((!fd1 || blocking_dir & fd1) && (!fd2 || blocking_dir & fd2))
			list_to_return += A

	return list_to_return
