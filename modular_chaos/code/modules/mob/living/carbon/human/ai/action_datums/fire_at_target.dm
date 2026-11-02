/datum/human_ai_brain
	/// What the AI was ordered to fire at, an atom or a turf, until ordered_fire_until
	var/atom/ordered_fire_target
	/// world.time when the order to fire at ordered_fire_target runs out
	var/ordered_fire_until = 0

/// Has the AI fire at the target for a while instead of anything it sees, a turf is fired at too
/datum/human_ai_brain/proc/order_fire_at(atom/target, duration)
	clear_fire_order()
	ordered_fire_target = target
	ordered_fire_until = world.time + duration
	if(!isturf(target))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_fire_order))
	lose_target()
	enter_combat()

/datum/human_ai_brain/proc/clear_fire_order()
	SIGNAL_HANDLER
	if(ordered_fire_target && !isturf(ordered_fire_target))
		UnregisterSignal(ordered_fire_target, COMSIG_PARENT_QDELETING)
	ordered_fire_target = null

/// Returns what the AI is ordered to fire at, null once the order ran out or the target died
/datum/human_ai_brain/proc/get_ordered_fire_target()
	if(!ordered_fire_target)
		return

	var/mob/living/living_target = ordered_fire_target
	if((world.time > ordered_fire_until) || (istype(living_target) && (living_target.stat == DEAD)))
		clear_fire_order()
		return

	return ordered_fire_target

/// Returns the turf the AI shoots at: what it was ordered to fire at, or where its target is
/datum/human_ai_brain/proc/get_fire_turf()
	var/atom/ordered_target = get_ordered_fire_target()
	return ordered_target ? get_turf(ordered_target) : target_turf

/datum/ai_action/fire_at_target
	name = "Fire At Target"
	action_flags = ACTION_USING_HANDS
	var/rounds_burst_fired = 0
	var/currently_firing

/datum/ai_action/fire_at_target/get_weight(datum/human_ai_brain/brain)
	if(brain.tried_reload)
		return 0

	if(!brain.primary_weapon)
		return 0

	if(!COOLDOWN_FINISHED(brain, stop_fire_cooldown))
		return 0

	var/atom/ordered_target = brain.get_ordered_fire_target()
	if(ordered_target)
		var/turf/ordered_turf = get_turf(ordered_target)
		if((ordered_turf.z != brain.tied_human.z) || (get_dist(brain.tied_human, ordered_turf) > brain.gun_data.maximum_range))
			return 0
		if(!firing_line_check(brain, ordered_target, TRUE))
			return 0
		if(brain.should_reload())
			return 0
		return 10

	if(!brain.in_combat)
		return 0

	// Shots aimed at another z-level fly off somewhere on ours, unless we see the target through open space
	if(brain.target_turf && (brain.target_turf.z != brain.tied_human.z) && !brain.can_see_across_levels(brain.current_target))
		return 0

	var/should_fire_offscreen = (brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen) && (brain.gun_data.maximum_range > brain.view_distance))

	if(!brain.current_target && !should_fire_offscreen)
		return 0

	if((get_dist(brain.tied_human, brain.target_turf) > brain.view_distance) && !should_fire_offscreen)
		return 0

	if(!firing_line_check(brain, brain.target_turf))
		return 0

	if(brain.should_reload())
		return 0

	return 10

/datum/ai_action/fire_at_target/Destroy(force, ...)
	stop_firing(brain)
	return ..()

/datum/ai_action/fire_at_target/proc/stop_firing(datum/human_ai_brain/brain)
	currently_firing = FALSE
	rounds_burst_fired = 0

	// Gone already when the brain is being deleted
	if(brain.tied_human)
		UnregisterSignal(brain.tied_human, COMSIG_MOB_FIRED_GUN)
	brain.primary_weapon?.set_target(null)

/datum/ai_action/fire_at_target/trigger_action()
	. = ..()

	var/obj/item/weapon/gun/primary_weapon = brain.primary_weapon
	if(!primary_weapon || brain.active_grenade_found || !COOLDOWN_FINISHED(brain, stop_fire_cooldown))
		return ONGOING_ACTION_COMPLETED

	var/atom/ordered_target = brain.get_ordered_fire_target()
	var/should_fire_offscreen = (brain.target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
	if(!ordered_target && !brain.current_target && !should_fire_offscreen)
		return ONGOING_ACTION_COMPLETED

	if(currently_firing || !COOLDOWN_FINISHED(brain, fire_overload_cooldown))
		return ONGOING_ACTION_UNFINISHED

	var/mob/living/carbon/tied_human = brain.tied_human
	brain.unholster_primary()

	var/datum/firearm_appraisal/gun_data = brain.gun_data
	gun_data.before_fire(primary_weapon, tied_human, brain)
	if(brain.should_reload())
		if(gun_data?.disposable)
			tied_human.drop_held_item(primary_weapon)
			brain.set_primary_weapon(null)
		return ONGOING_ACTION_COMPLETED

	var/turf/target_turf = brain.get_fire_turf()
	// Shots aimed at another z-level fly off somewhere on ours, unless we see the target through open space
	if(!target_turf || ((target_turf.z != tied_human.z) && (ordered_target || !brain.can_see_across_levels(brain.current_target))))
		return ONGOING_ACTION_COMPLETED

	if((get_dist(tied_human, target_turf) > gun_data.maximum_range) && !should_fire_offscreen)
		return ONGOING_ACTION_COMPLETED

	tied_human.face_atom(target_turf)
	tied_human.a_intent_change(INTENT_HARM)

	RegisterSignal(tied_human, COMSIG_MOB_FIRED_GUN, PROC_REF(on_gun_fire), TRUE)

	// Adjacent targets are shot normally, do_click() only point-blanks for mobs with a client
	primary_weapon?.set_target(target_turf)
	primary_weapon?.start_fire(object = target_turf, bypass_checks = TRUE)
	return ONGOING_ACTION_UNFINISHED

/// TRUE if nothing stops the shot and no friendly is in the way or right behind the target. Ordered fire may hit the wall or object it was ordered at
/datum/ai_action/fire_at_target/proc/firing_line_check(datum/human_ai_brain/brain, atom/target, ordered = FALSE)
	var/mob/living/carbon/tied_human = brain.tied_human
	var/turf/target_turf = get_turf(target)
	var/list/turf_list = get_line(get_turf(tied_human), target_turf)
	for(var/turf/tile in turf_list)
		var/tile_dist = get_dist(tied_human, tile)
		if(tile_dist > brain.view_distance)
			continue

		var/ordered_tile = ordered && (tile == target_turf)
		if(tile.density && !ordered_tile)
			return FALSE

		for(var/obj/thing in tile)
			if(ordered_tile)
				break
			if(!thing.unacidable || !thing.density)
				continue

			if((tile_dist <= 3) && (thing.projectile_coverage >= PROJECTILE_COVERAGE_HIGH)) // short range we allow for higher projectile coverage to be shot over
				return FALSE
			else if((tile_dist > 3) && thing.projectile_coverage >= PROJECTILE_COVERAGE_MEDIUM)
				return FALSE

		for(var/mob/living/carbon/human/possible_friendly in tile)
			if(possible_friendly == tied_human)
				continue

			if(possible_friendly.body_position == LYING_DOWN)
				continue

			if(brain.faction_check(possible_friendly))
				return FALSE

	if(brain.ally_behind_target(get_turf(tied_human), target_turf))
		return FALSE

	// Rockets and flames hit everyone around where they land
	var/splash_radius = brain.gun_data?.splash_radius
	if(splash_radius)
		for(var/mob/living/carbon/human/possible_friendly in range(splash_radius, target_turf))
			if((possible_friendly.stat != DEAD) && brain.faction_check(possible_friendly))
				return FALSE

	return TRUE

/datum/ai_action/fire_at_target/proc/on_gun_fire(datum/source, obj/item/weapon/gun/fired)
	SIGNAL_HANDLER

	if(!brain)
		qdel(src)
		return

	var/atom/ordered_target = brain.get_ordered_fire_target()
	var/turf/target_turf = brain.get_fire_turf()

	var/mob/living/carbon/tied_human = brain.tied_human
	tied_human.a_intent_change(INTENT_HARM)

	brain.shot_at = get_turf(target_turf)
	tied_human.face_atom(target_turf)

	currently_firing = TRUE

	var/datum/firearm_appraisal/gun_data = brain.gun_data
	if(brain.should_reload()) // note that bullet removal comes after comsig is triggered
		if(gun_data?.disposable)
			tied_human.drop_held_item(brain.primary_weapon)
			brain.set_primary_weapon(null)
		stop_firing(brain)
		qdel(src)
		return

	var/should_fire_offscreen = (target_turf && !COOLDOWN_FINISHED(brain, fire_offscreen))
	var/atom/shoot_next = ordered_target || brain.current_target

	// Checked when the action is picked, the order runs until it times out
	if(ordered_target)
		shoot_next = ordered_target

	else if(QDELETED(brain.current_target))
		if(!should_fire_offscreen)
			stop_firing(brain)
			qdel(src)
			return
		shoot_next = target_turf

	else if(ismob(brain.current_target))
		var/mob/mob_target = brain.current_target
		if(mob_target.stat == DEAD)
			stop_firing(brain)
			brain.lose_target()
			qdel(src)
			return

		var/is_unconscious = (mob_target.stat == UNCONSCIOUS || (locate(/datum/effects/crit) in mob_target.effects_list))
		if(!brain.shoot_to_kill && is_unconscious)
			brain.lose_target()
			qdel(src)
			return

	if(rounds_burst_fired >= gun_data.burst_amount_max)
		var/short_action_delay = brain.short_action_delay
		COOLDOWN_START(brain, fire_overload_cooldown, max(short_action_delay, short_action_delay * brain.action_delay_mult))
		stop_firing(brain)
		return

	if((get_dist(tied_human, shoot_next) > gun_data.maximum_range) && !should_fire_offscreen)
		if(!ordered_target)
			brain.lose_target()
		stop_firing(brain)
		qdel(src)
		return

	// The target took the stairs or a ladder mid-burst, and shots at another level come out of its floor or ceiling
	var/turf/shoot_next_turf = get_turf(shoot_next)
	if(!shoot_next_turf || ((shoot_next_turf.z != tied_human.z) && (ordered_target || !brain.can_see_across_levels(shoot_next))))
		stop_firing(brain)
		return

	if(!firing_line_check(brain, shoot_next, !!ordered_target))
		stop_firing(brain)
		return

	if(istype(brain.primary_weapon, /obj/item/weapon/gun/shotgun/pump))
		currently_firing = FALSE
		var/obj/item/weapon/gun/shotgun/pump/shotgun = brain.primary_weapon
		addtimer(CALLBACK(shotgun, TYPE_PROC_REF(/obj/item/weapon/gun/shotgun/pump, pump_shotgun), tied_human), shotgun.pump_delay)
		//addtimer(CALLBACK(shotgun, TYPE_PROC_REF(/obj/item/weapon/gun/shotgun/pump, start_fire), null, brain.current_target, null, null, null, TRUE), max(shotgun.pump_delay, shotgun.get_fire_delay()) + 1) // max with fire delay
		COOLDOWN_START(brain, stop_fire_cooldown, max(shotgun.pump_delay, shotgun.get_fire_delay()) + 1)
		stop_firing(brain)
		qdel(src)
		return

	else if(istype(brain.primary_weapon, /obj/item/weapon/gun/boltaction))
		var/obj/item/weapon/gun/boltaction/bolt = brain.primary_weapon
		currently_firing = FALSE
		addtimer(CALLBACK(bolt, TYPE_PROC_REF(/obj/item/weapon/gun/boltaction, unique_action), tied_human), 1)
		addtimer(CALLBACK(bolt, TYPE_PROC_REF(/obj/item/weapon/gun/boltaction, unique_action), tied_human), bolt.bolt_delay + 1)
		//addtimer(CALLBACK(bolt, TYPE_PROC_REF(/obj/item/weapon/gun/boltaction, start_fire), null, brain.current_target, null, null, null, TRUE), (bolt.bolt_delay * 2) + 1)
		COOLDOWN_START(brain, stop_fire_cooldown, max(bolt.bolt_delay * 2, bolt.get_fire_delay()) + 1)
		stop_firing(brain)
		qdel(src)
		return

	else if(brain.primary_weapon.gun_firemode == GUN_FIREMODE_SEMIAUTO)
		currently_firing = FALSE
		addtimer(CALLBACK(src, PROC_REF(fire_again)), brain.primary_weapon.get_fire_delay())

	else if(brain.primary_weapon.gun_firemode == GUN_FIREMODE_AUTOMATIC)
		rounds_burst_fired++

	else if(brain.primary_weapon.gun_firemode == GUN_FIREMODE_BURSTFIRE)
		currently_firing = FALSE
		addtimer(CALLBACK(src, PROC_REF(fire_again)), brain.primary_weapon.get_burst_fire_delay())

	brain.primary_weapon?.set_target(shoot_next)

/// Fires the next semi-automatic shot or burst at what we're ordered to fire at or our target, unless it went where we can't shoot it from here in the meantime
/datum/ai_action/fire_at_target/proc/fire_again()
	var/obj/item/weapon/gun/primary_weapon = brain?.primary_weapon
	var/atom/ordered_target = brain?.get_ordered_fire_target()
	var/atom/target = ordered_target || brain?.current_target
	var/turf/target_turf = get_turf(target)
	if(!primary_weapon || !target_turf)
		return
	if((target_turf.z != brain.tied_human.z) && (ordered_target || !brain.can_see_across_levels(target)))
		return
	primary_weapon.start_fire(null, target, null, null, null, TRUE)
