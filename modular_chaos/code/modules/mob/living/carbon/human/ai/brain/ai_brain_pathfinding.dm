/datum/human_ai_brain
	/// Delay timer for when the AI can next move, based on the tied_human's move delay
	var/ai_move_delay = 0
	/// The list of turfs that the AI is trying to move through
	var/list/current_path
	/// The next turf in current_path that the AI is moving to
	var/turf/current_path_target
	/// How long to wait if the AI can't find a path
	var/path_update_period = (0.5 SECONDS)
	/// If TRUE, pathfinding has failed to find a path and a cooldown will soon begin.
	var/no_path_found = FALSE
	/// The farthest that the AI will try to pathfind
	var/max_travel_distance = HUMAN_AI_MAX_PATHFINDING_RANGE
	/// Time storage for the next time a pathfinding path can try to be generated
	var/next_path_generation = 0
	/// Amount of times no path found has occured
	var/no_path_found_amount = 0
	///
	var/ai_timeout_time = 0

	/// The time interval between calculating new paths if we cannot find a path
	var/no_path_found_period = (2.5 SECONDS)

	/// Cooldown declaration for delaying finding a new path if no path was found
	COOLDOWN_DECLARE(no_path_found_cooldown)

/datum/human_ai_brain/proc/can_move_and_apply_move_delay()
	// Unable to move, try next time.
	if(ai_move_delay > world.time || !(tied_human.mobility_flags & MOBILITY_MOVE) || tied_human.is_mob_incapacitated(TRUE) || (tied_human.body_position != STANDING_UP && !tied_human.can_crawl) || tied_human.anchored)
		return FALSE

	ai_move_delay = world.time + tied_human.move_delay
	if(tied_human.recalculate_move_delay)
		ai_move_delay = world.time + tied_human.movement_delay()
	if(tied_human.next_move_slowdown)
		ai_move_delay += tied_human.next_move_slowdown
		tied_human.next_move_slowdown = 0
	return TRUE

/datum/human_ai_brain/proc/move_to_next_turf(turf/T, max_range = max_travel_distance)
	if(!T)
		return FALSE

	if(no_path_found)
		if(no_path_found_amount > 0)
			COOLDOWN_START(src, no_path_found_cooldown, no_path_found_period)
		no_path_found = FALSE
		no_path_found_amount++
		return FALSE

	no_path_found_amount = 0

	if((!current_path || (next_path_generation < world.time && current_path_target != T)) && COOLDOWN_FINISHED(src, no_path_found_cooldown))
		if(!CALCULATING_PATH(tied_human) || current_path_target != T)
			SSpathfinding.calculate_path(tied_human, T, max_range, tied_human, CALLBACK(src, PROC_REF(set_path)), list(tied_human, current_target))
			current_path_target = T
		next_path_generation = world.time + path_update_period

	if(CALCULATING_PATH(tied_human))
		return TRUE

	// No possible path to target.
	if(!current_path && get_dist_multiz(T, tied_human) > 0)
		return FALSE

	// Stairs and ladders put us onto the next turf without Move()
	if(length(current_path) && (current_path[length(current_path)] == tied_human.loc))
		current_path.len--

	// We've reached our destination
	if(!length(current_path) || get_dist_multiz(T, tied_human) <= 0)
		current_path = null
		return TRUE

	var/turf/next_turf = current_path[length(current_path)]
	var/level_change = SSpathfinding.is_level_change(tied_human.loc, next_turf)
	// We've somehow deviated from our current path. Generate next path whenever possible.
	if(!level_change && (get_dist(next_turf, tied_human) > 1))
		current_path = null
		return TRUE

	// Unable to move, try next time.
	if(!can_move_and_apply_move_delay())
		return TRUE

	if(level_change)
		if(!change_level_to(next_turf))
			current_path = null
		return TRUE

	var/list/L = link_blocked_list(tied_human, tied_human.loc, next_turf, list(tied_human))
	L += SSpathfinding.check_special_blockers(tied_human, next_turf)
	// Everything is checked before acting on anything, or we could start climbing a railing into the open space behind it
	var/direction = get_dir(tied_human.loc, next_turf)
	for(var/atom/A as anything in L)
		// Same target as the path was made for, so only a change since then blocks us, like a door bolted or a fire started
		if(A.human_ai_obstacle(tied_human, src, direction, current_path_target) == INFINITY)
			// The path was made through it, a new one goes around it, or we stop if there's none
			current_path = null
			return FALSE
	for(var/atom/A as anything in L)
		INVOKE_ASYNC(A, TYPE_PROC_REF(/atom, human_ai_act), tied_human, src)
	var/successful_move = tied_human.Move(next_turf, get_dir(tied_human, next_turf))
	if(successful_move)
		ai_timeout_time = world.time
		current_path.len--

	return TRUE

/**
 * Takes the stairs or ladder on our turf that lead to the turf, which is on another level or across a ladder.
 *
 * Returns FALSE if nothing here leads there, so the path is stale.
 */
/datum/human_ai_brain/proc/change_level_to(turf/next_turf)
	var/turf/current_turf = tied_human.loc
	var/obj/structure/stairs/multiz/stairs = locate() in current_turf
	if(stairs)
		var/direction = stairs.get_level_change_direction()
		if(stairs.get_level_change_exit(direction) == next_turf)
			// The stairs cancel the step and move us to the other level
			tied_human.Move(get_step(current_turf, direction), direction)
			return TRUE

	for(var/obj/structure/ladder/ladder in current_turf)
		for(var/obj/structure/ladder/connected_ladder in list(ladder.up, ladder.down))
			if(get_turf(connected_ladder) != next_turf)
				continue
			if(!tied_human.action_busy)
				INVOKE_ASYNC(ladder, TYPE_PROC_REF(/obj/structure/ladder, ai_climb), tied_human, connected_ladder)
			return TRUE

	return FALSE

/datum/human_ai_brain/proc/set_path(list/path)
	current_path = path
	if(!path)
		no_path_found = TRUE
