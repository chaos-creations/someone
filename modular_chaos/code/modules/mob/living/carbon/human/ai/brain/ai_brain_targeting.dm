#define EXTRA_CHECK_DISTANCE_MULTIPLIER 0.20

/datum/human_ai_brain
	/// At how far out the AI can see cloaked enemies
	var/cloak_visible_range = 3
	/// Ref to the currently focused (and shooting at) target
	var/atom/movable/current_target
	/// Last turf our target was seen at
	var/turf/target_turf
	/// Ref to the last turf that the AI shot at
	var/turf/shot_at
	/// If TRUE, the AI will throw grenades at enemies who enter cover
	var/grenading_allowed = TRUE
	/// If TRUE, we care about the target being in view after shooting at them. If not, then we only do a line check instead
	var/requires_vision = TRUE
	/// How often the AI looks around for enemies while it isn't fighting
	var/target_scan_delay = 0.4 SECONDS

	COOLDOWN_DECLARE(fire_offscreen)
	COOLDOWN_DECLARE(target_scan_cooldown)

/// Returns how long to wait before looking for a target again. Long sight lines cost more to check, so they're checked less often
/datum/human_ai_brain/proc/get_target_scan_delay()
	. = in_combat ? 0 : target_scan_delay
	if(view_distance > GLOB.world_view_size)
		. = max(., target_scan_delay) * 2

/// Returns TRUE if there is enough light next to the thing to make it out in the dark
/datum/human_ai_brain/proc/is_lit(atom/movable/thing)
	for(var/turf/open/nearby_turf in RANGE_TURFS(1, thing))
		if(nearby_turf.luminosity || (nearby_turf.dynamic_lumcount >= 1))
			return TRUE
	return FALSE

/// Locates a viable target within vision
/datum/human_ai_brain/proc/get_target()
	var/list/viable_targets = list()
	var/atom/movable/closest_target
	var/smallest_distance = INFINITY

	/// FOV dirs for if our target is out of base world.view range
	var/list/dir_cone = reverse_nearby_direction(reverse_direction(tied_human.dir))
	var/rear_view_penalty = scope_vision ? view_distance / 7 - 1 : 0

	var/list/rear_dirs = reverse_nearby_direction(tied_human.dir)
	// Cheapest checks first, can_target() traces a line to every candidate
	for(var/mob/living/carbon/potential_target in view(view_distance, tied_human) + get_mobs_seen_across_levels())
		if(potential_target == tied_human)
			continue

		var/distance = get_dist(tied_human, potential_target)
		if(scope_vision && (distance > 7) && !(get_dir(tied_human, potential_target) in dir_cone))
			continue

		var/rear_view_check = scope_vision && (get_dir(tied_human, potential_target) in rear_dirs)
		if(rear_view_check && (distance > view_distance - rear_view_penalty))
			continue

		if(!has_nightvision && (distance > 1) && !is_lit(potential_target))
			continue

		if(!can_engage_from_gun(potential_target))
			continue

		if(!can_target(potential_target))
			continue

		viable_targets += potential_target

		if(smallest_distance <= distance)
			continue

		closest_target = potential_target
		smallest_distance = distance

	for(var/obj/vehicle/multitile/potential_vehicle_target as anything in GLOB.all_multi_vehicles)
		if(tied_human.z != potential_vehicle_target.z) //todo: make this work
			continue

		var/distance = get_dist(tied_human, potential_vehicle_target)

		// Vehicles are big and lousy, no need to consider our rear view penalty
		if(distance > view_distance)
			continue

		if(scope_vision && (distance > 7) && !(get_dir(tied_human, potential_vehicle_target) in dir_cone))
			continue

		if(faction_check(potential_vehicle_target))
			continue

		// Zombies go after the people inside instead
		if(!iszombie(tied_human) && !potential_vehicle_target.ai_is_threat())
			continue

		if(!can_engage_from_gun(potential_vehicle_target))
			continue

		if(!(tied_human in viewers(view_distance, potential_vehicle_target)))
			continue

		if(iszombie(tied_human))
			var/list/valid_targets = list()
			for(var/mob/living/carbon/potential_target in potential_vehicle_target.interior.get_passengers())
				if(!can_target(potential_target))
					continue

				valid_targets += potential_target

			if(!length(valid_targets))
				continue

		viable_targets += potential_vehicle_target

		if(smallest_distance <= distance)
			continue

		closest_target = potential_vehicle_target
		smallest_distance = distance

	for(var/obj/structure/machinery/defenses/potential_defense_target as anything in GLOB.all_active_defenses)
		if(tied_human.z != potential_defense_target.z)
			continue

		if(tied_human.faction in potential_defense_target.faction_group)
			continue

		var/distance = get_dist(tied_human, potential_defense_target)

		// Let's just not rear check a loud ass CLANK CLANK CLANK servo sentry
		if(distance > view_distance)
			continue

		if(scope_vision && (distance > 7) && !(get_dir(tied_human, potential_defense_target) in dir_cone))
			continue

		if(!can_engage_from_gun(potential_defense_target))
			continue

		if(!(tied_human in viewers(view_distance, potential_defense_target)))
			continue

		viable_targets += potential_defense_target

		if(smallest_distance <= distance)
			continue

		closest_target = potential_defense_target
		smallest_distance = distance

	var/extra_check_distance = round(smallest_distance * EXTRA_CHECK_DISTANCE_MULTIPLIER)

	if(extra_check_distance < 1)
		return closest_target

	var/list/extra_checked = orange(extra_check_distance, closest_target)

	var/list/final_targets = extra_checked & viable_targets

	return length(final_targets) ? pick(final_targets) : closest_target


/**
 * Returns the topmost turf of an unbroken column of open space above lower_turf that reaches upper_z, or null if there is none.
 *
 * This is the hole through which the levels see each other, players look down through it like human AI does.
 */
/proc/get_level_window(turf/lower_turf, upper_z)
	var/turf/window = lower_turf
	while(window && (window.z != upper_z))
		window = SSmapping.get_turf_above(window)
		if(!window || !istransparentturf(window))
			return null
	return (window != lower_turf) ? window : null

/**
 * Returns the carbon mobs on other levels that we see through open space.
 *
 * Below: under a hole in our view, like players look down. Above: only through a hole right above us, from those who see that hole,
 * which are exactly those who can look down and shoot at us. Nobody gets to shoot down at the AI without it shooting back, and the AI
 * never shoots through a ceiling.
 */
/datum/human_ai_brain/proc/get_mobs_seen_across_levels()
	. = list()
	var/turf/our_turf = get_turf(tied_human)
	if(!our_turf)
		return

	// Looking down through open space we can see
	for(var/turf/hole in view(view_distance, tied_human))
		if(!istransparentturf(hole))
			continue
		var/turf/below = SSmapping.get_turf_below(hole)
		while(below)
			for(var/mob/living/carbon/below_mob in below)
				. += below_mob
			if(!istransparentturf(below))
				break
			below = SSmapping.get_turf_below(below)

	// Up through a hole right above us
	var/turf/above = SSmapping.get_turf_above(our_turf)
	while(above && istransparentturf(above))
		for(var/mob/living/carbon/above_mob in viewers(view_distance, above))
			if(above_mob.z == above.z)
				. |= above_mob
		above = SSmapping.get_turf_above(above)

/// Returns TRUE if the target on another level is in sight through open space, see get_mobs_seen_across_levels()
/datum/human_ai_brain/proc/can_see_across_levels(atom/target)
	var/turf/our_turf = get_turf(tied_human)
	var/turf/target_turf = get_turf(target)
	if(!our_turf || !target_turf || (our_turf.z == target_turf.z) || (get_dist(our_turf, target_turf) > view_distance))
		return FALSE

	// Whoever is above, the hole has to be over whoever is below and in sight of whoever is above
	if(target_turf.z < our_turf.z)
		var/turf/window = get_level_window(target_turf, our_turf.z)
		return window && (tied_human in viewers(view_distance, window))

	var/turf/window = get_level_window(our_turf, target_turf.z)
	return window && (target in viewers(view_distance, window))

/// Returns TRUE if a standing ally is a few tiles behind the target, where shots that miss it fly on to
/datum/human_ai_brain/proc/ally_behind_target(turf/start_turf, turf/target_turf, distance = 2)
	// Shots at another level drop through open space, the line past the target doesn't apply
	if(!start_turf || !target_turf || (start_turf == target_turf) || (start_turf.z != target_turf.z))
		return FALSE

	var/turf/past_turf = get_angle_target_turf(start_turf, Get_Angle(start_turf, target_turf), get_dist(start_turf, target_turf) + distance)
	for(var/turf/line_turf as anything in get_line(target_turf, past_turf, include_start_atom = FALSE))
		// Whatever got past the target stops here
		if(line_turf.density)
			return FALSE

		for(var/mob/living/carbon/human/possible_ally in line_turf)
			if((possible_ally.body_position == STANDING_UP) && faction_check(possible_ally))
				return TRUE

	return FALSE

/// Returns FALSE once a vehicle or defense we fight stops being worth the ammo
/datum/human_ai_brain/proc/is_object_target_valid(atom/target)
	if(istype(target, /obj/vehicle/multitile))
		// Zombies go after the people inside, which get_target() already checked
		if(iszombie(tied_human))
			return TRUE
		var/obj/vehicle/multitile/vehicle_target = target
		return vehicle_target.ai_is_threat()

	if(isdefenses(target))
		var/obj/structure/machinery/defenses/defense_target = target
		return defense_target.turned_on

	return TRUE

/datum/human_ai_brain/proc/can_target(mob/living/carbon/target)
	if(!istype(target))
		return FALSE

	if(target.stat == DEAD)
		return FALSE

	if(!shoot_to_kill && (target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in target.effects_list)))
		return FALSE

	if(faction_check(target))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_CLOAKED) && get_dist(tied_human, target) > cloak_visible_range)
		return FALSE

	if(!friendly_check(target) && !iszombie(tied_human))
		return FALSE

	return TRUE

/// Given a target, checks if there are any (not laying down) friendlies in a line between the AI and the target
/datum/human_ai_brain/proc/friendly_check(atom/target)
	var/list/turf_list = get_line(get_turf(tied_human), get_turf(target))
	turf_list.Cut(1, 2) // starting turf
	for(var/turf/tile in turf_list)
		if(istype(tile, /turf/closed))
			return TRUE

		for(var/mob/living/carbon/human/possible_friendly in tile)
			if(possible_friendly.body_position == LYING_DOWN)
				continue

			if(faction_check(possible_friendly))
				return FALSE
	return TRUE

#undef EXTRA_CHECK_DISTANCE_MULTIPLIER
