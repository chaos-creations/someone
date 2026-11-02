/datum/ai_action/keep_distance
	name = "Keep Distance"
	action_flags = ACTION_USING_LEGS

/datum/ai_action/keep_distance/get_weight(datum/human_ai_brain/brain)
	var/atom/movable/current_target = brain.current_target
	if(!current_target)
		return 0

	if(!brain.primary_weapon || brain.tried_reload || brain.hold_position)
		return 0

	var/distance = get_dist(brain.tied_human, current_target)
	var/datum/firearm_appraisal/gun_data = brain.gun_data

	// Medics shoot back from where they are and only ever back off
	if(brain.is_medic())
		return (distance < gun_data.optimal_range) ? 10 : 0

	if(ismob(current_target) && current_target?:is_mob_incapacitated())
		if(distance != gun_data.minimum_range)
			return 10

	else if(brain.in_cover)
		// Out of reach from cover, like a shotgun at range, means we have to get closer
		if((distance < gun_data.minimum_range) || (distance > gun_data.maximum_range))
			return 10

	else if(distance != gun_data.optimal_range)
		return 10

	return 0

/datum/ai_action/keep_distance/trigger_action()
	. = ..()

	if(!brain.current_target)
		return ONGOING_ACTION_COMPLETED

	if(!brain.primary_weapon)
		return ONGOING_ACTION_COMPLETED

	if(brain.active_grenade_found)
		return ONGOING_ACTION_COMPLETED

	if(brain.current_cover && !brain.in_cover)
		return ONGOING_ACTION_COMPLETED

	return approach() || back_up() || ONGOING_ACTION_COMPLETED

/datum/ai_action/keep_distance/proc/approach()
	if(brain.is_medic())
		return

	var/range
	if(ismob(brain.current_target))
		var/mob/current_mob_target = brain.current_target
		if(current_mob_target.is_mob_incapacitated())
			range = brain.gun_data.minimum_range
		else
			range = brain.gun_data.optimal_range
	else
		range = brain.gun_data.optimal_range

	var/distance = get_dist(brain.tied_human, brain.current_target)
	if(distance <= range)
		return

	if(brain.in_cover)
		if(distance <= brain.gun_data.maximum_range)
			return ONGOING_ACTION_UNFINISHED
		// We can't shoot them from here, so the cover is no use
		brain.end_cover()

	if(!brain.move_to_next_turf(get_turf(brain.current_target)))
		return ONGOING_ACTION_COMPLETED

	return ONGOING_ACTION_UNFINISHED

/datum/ai_action/keep_distance/proc/back_up()
	var/mob/living/carbon/human/tied_human = brain.tied_human
	var/range
	var/is_incap = FALSE
	if(ismob(brain.current_target))
		var/mob/current_mob_target = brain.current_target
		is_incap = current_mob_target.is_mob_incapacitated()

	if(brain.in_cover || is_incap)
		range = brain.gun_data.minimum_range
	else
		range = brain.gun_data.optimal_range

	if(get_dist(brain.tied_human, brain.current_target) >= range)
		return

	var/moved = FALSE
	var/relative_dir = Get_Compass_Dir(brain.current_target, tied_human)
	for(var/direction in list(relative_dir, turn(relative_dir, 90), turn(relative_dir, -90)))
		var/turf/destination = get_step(tied_human, direction)
		if(brain.move_to_next_turf(destination))
			moved = TRUE
			break

	if(!moved)
		return ONGOING_ACTION_COMPLETED

	return ONGOING_ACTION_UNFINISHED
