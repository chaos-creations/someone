SUBSYSTEM_DEF(pathfinding)
	name = "Pathfinding"
	priority = SS_PRIORITY_PATHFINDING
	flags = SS_NO_INIT|SS_TICKER|SS_BACKGROUND
	wait = 1
	/// A list of mobs scheduled to process
	var/list/datum/xeno_pathinfo/current_processing = list()
	/// A list of paths to calculate
	var/list/datum/xeno_pathinfo/paths_to_calculate = list()

	var/list/hash_path = list()
	var/current_position = 1

/datum/controller/subsystem/pathfinding/stat_entry(msg)
	msg = "P:[length(paths_to_calculate)]"
	return ..()

/datum/controller/subsystem/pathfinding/fire(resumed = FALSE)
	if(!resumed)
		current_processing = paths_to_calculate.Copy()

	while(length(current_processing))
		// A* Pathfinding. Uses priority queue
		if(current_position < 1 || current_position > length(current_processing))
			current_position = length(current_processing)

		var/datum/xeno_pathinfo/current_run = current_processing[current_position]
		current_position++

		var/turf/target = current_run.finish

		// Only human AI uses pathfinding in the fork
		var/mob/living/carbon/human/agent_human = current_run.agent
		var/datum/human_ai_brain/brain = ishuman(agent_human) ? agent_human.get_ai_brain() : null
		if(!brain)
			QDEL_NULL(current_run)
			continue

		var/list/visited_nodes = current_run.visited_nodes
		var/list/distances = current_run.distances
		var/list/f_distances = current_run.f_distances
		var/list/prev = current_run.prev

		while(length(visited_nodes))
			current_run.current_node = visited_nodes[length(visited_nodes)]
			visited_nodes.len--
			if(current_run.current_node == target)
				break

			var/list/neighbors = get_neighbors(current_run.current_node)
			for(var/turf/neighbor as anything in neighbors)
				var/direction = neighbors[neighbor]
				var/distance_between = distances[current_run.current_node] * DISTANCE_PENALTY
				if(isnull(distances[neighbor]))
					if(get_dist(neighbor, current_run.agent) > current_run.path_range)
						continue
					distances[neighbor] = INFINITY
					f_distances[neighbor] = INFINITY

				if(direction != get_dir(prev[neighbor], neighbor))
					distance_between += DIRECTION_CHANGE_PENALTY

				var/list/L
				if(is_level_change(current_run.current_node, neighbor))
					// link_blocked_list() can't follow a move between levels, the stairs or ladder only need the way out free
					distance_between += direction ? STAIRS_PENALTY : LADDER_PENALTY
					L = neighbor.density ? list(neighbor) : list()
				else
					L = link_blocked_list(current_run.agent, current_run.current_node, neighbor, current_run.ignore)
				L += check_special_blockers(current_run.agent, neighbor)
				for(var/atom/A as anything in L)
					distance_between += A.human_ai_obstacle(current_run.agent, brain, direction, target)

				if(distance_between < distances[neighbor])
					distances[neighbor] = distance_between
					var/f_distance = distance_between + ASTAR_COST_FUNCTION(neighbor)
					f_distances[neighbor] = f_distance
					prev[neighbor] = current_run.current_node
					if(neighbor in visited_nodes)
						visited_nodes -= neighbor

					for(var/i in 0 to length(visited_nodes))
						var/index_to_check = length(visited_nodes) - i
						if(index_to_check == 0)
							visited_nodes.Insert(1, neighbor)
							break

						if(f_distance < f_distances[visited_nodes[index_to_check]])
							visited_nodes.Insert(index_to_check, neighbor)
							break

			if(MC_TICK_CHECK)
				return

		#ifdef TESTING
		for(var/i in distances)
			var/turf/T = i
			var/distance = distances[i]
			if(distance == INFINITY)
				T.color = "#000000"
				for(var/l in T)
					var/atom/A = l
					A.color = "#000000"
				continue

			var/red = num2hex(min(distance*10, 255), 2)
			var/green = num2hex(max(255-distance*10, 0), 2)

			for(var/l in T)
				var/atom/A = l
				A.color = "#[red][green]00"
			T.color = "#[red][green]00"
		#endif

		if(!prev[target])
			current_run.to_return.Invoke()
			QDEL_NULL(current_run)
			return

		var/list/path = list()
		var/turf/current_node = target
		while(current_node)
			if(current_node == current_run.start)
				break
			path += current_node
			current_node = prev[current_node]

		current_run.to_return.Invoke(path)
		QDEL_NULL(current_run)

/**
 * Returns the turfs a mob can get to from the node in one move, as list(turf = direction).
 *
 * Besides the cardinal steps, multi-z stairs on the node replace the step off them with the turf on the level they lead to,
 * and ladders on the node lead to the ladders they connect to, with a direction of 0.
 */
/datum/controller/subsystem/pathfinding/proc/get_neighbors(turf/node)
	var/list/neighbors = list()
	var/obj/structure/stairs/multiz/stairs = locate() in node
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = stairs?.get_level_change_exit(direction)
		if(neighbor == FALSE) // Leads nowhere, so the step is cancelled
			continue
		if(!neighbor)
			neighbor = get_step(node, direction)
		if(neighbor)
			neighbors[neighbor] = direction

	for(var/obj/structure/ladder/ladder in node)
		for(var/obj/structure/ladder/connected_ladder in list(ladder.up, ladder.down))
			var/turf/ladder_turf = get_turf(connected_ladder)
			if(ladder_turf)
				neighbors[ladder_turf] = 0

	return neighbors

/// Returns TRUE if going from one turf to the other is a move to another level or through a ladder, not an ordinary step
/datum/controller/subsystem/pathfinding/proc/is_level_change(turf/from_turf, turf/to_turf)
	return (from_turf.z != to_turf.z) || (get_dist(from_turf, to_turf) > 1)

/datum/controller/subsystem/pathfinding/proc/check_special_blockers(mob/agent, turf/checking_turf)
	var/list/pass_back = list()

	for(var/spec_blocker in AI_SPECIAL_BLOCKERS)
		pass_back += istype(checking_turf, spec_blocker) ? checking_turf : list()

		for(var/atom/checked_atom as anything in checking_turf)
			pass_back += istype(checked_atom, spec_blocker) ? checked_atom : list()

	return pass_back

/datum/controller/subsystem/pathfinding/proc/stop_calculating_path(mob/agent)
	var/datum/xeno_pathinfo/data = hash_path[agent]
	qdel(data)

/datum/controller/subsystem/pathfinding/proc/calculate_path(atom/start, atom/finish, path_range, mob/agent, datum/callback/CB, list/ignore)
	if(!get_turf(start) || !get_turf(finish))
		return

	var/datum/xeno_pathinfo/data = hash_path[agent]
	SSpathfinding.current_processing -= data


	if(!data)
		data = new()
		data.RegisterSignal(agent, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/xeno_pathinfo, qdel_wrapper))

		hash_path[agent] = data
		paths_to_calculate += data

	data.current_node = get_turf(start)
	data.start = data.current_node

	var/turf/target = get_turf(finish)

	data.finish = target
	data.agent = agent
	data.to_return = CB
	data.path_range = path_range
	data.ignore = ignore

	data.distances[data.current_node] = 0
	data.f_distances[data.current_node] = ASTAR_COST_FUNCTION(data.current_node)

	data.visited_nodes += data.current_node

/datum/xeno_pathinfo
	var/turf/start
	var/turf/finish
	var/mob/agent
	var/datum/callback/to_return
	var/path_range

	var/turf/current_node
	var/list/ignore
	var/list/visited_nodes
	var/list/distances
	var/list/f_distances
	var/list/prev

/datum/xeno_pathinfo/proc/qdel_wrapper()
	SIGNAL_HANDLER
	qdel(src)

/datum/xeno_pathinfo/New()
	. = ..()
	visited_nodes = list()
	distances = list()
	f_distances = list()
	prev = list()

/datum/xeno_pathinfo/Destroy(force)
	SSpathfinding.hash_path -= agent
	SSpathfinding.paths_to_calculate -= src
	SSpathfinding.current_processing -= src

	#ifdef TESTING
	addtimer(CALLBACK(src, PROC_REF(clear_colors), distances), 5 SECONDS)
	#endif

	start = null
	finish = null
	agent = null
	to_return = null
	visited_nodes = null
	distances = null
	f_distances = null
	prev = null
	return ..()

#ifdef TESTING
/datum/xeno_pathinfo/proc/clear_colors(list/L)
	for(var/i in L)
		var/turf/T = i
		for(var/l in T)
			var/atom/A = l
			A.color = null
		T.color = null
#endif
