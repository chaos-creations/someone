/**
 * Returns the turf on another level that stepping off these stairs in `direction` takes a mob to, for AI pathfinding.
 *
 * Mirrors on_premove(). Returns null if the step in that direction is an ordinary one, and FALSE if it leads off
 * the stairs but there is no level to go to, so the step is cancelled.
 */
/obj/structure/stairs/multiz/proc/get_level_change_exit(direction)
	if(direction != get_level_change_direction())
		return null
	var/turf/target_turf = get_step(src, direction)
	var/turf/exit = (src.direction == UP) ? SSmapping.get_turf_above(target_turf) : SSmapping.get_turf_below(target_turf)
	return exit || FALSE

/// Returns the direction in which stepping off these stairs changes the level
/obj/structure/stairs/multiz/proc/get_level_change_direction()
	return (direction == UP) ? dir : REVERSE_DIR(dir)
