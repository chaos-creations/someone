/datum/human_ai_brain
	/// How often a medic looks around for wounded allies
	var/patient_search_delay = 2 SECONDS
	/// How long a medic leaves an ally alone after treating them or giving up on them
	var/patient_rest_delay = 15 SECONDS
	/// Assoc list of ally ref = world.time from which a medic may treat them again
	var/list/patient_rest_times = list()
	/// Assoc list of ally ref = brain of the medic treating them, so that several medics don't overdose one patient
	var/static/list/patient_medics = list()
	/// How far from a patient seen by hostiles a medic looks for a spot out of their sight to drag the patient to
	var/patient_drag_range = 6
	/// How long a medic takes between two pieces of treatment of an ally, like two bandages
	var/ally_treatment_delay = 4 SECONDS
	COOLDOWN_DECLARE(patient_search_cooldown)
	COOLDOWN_DECLARE(ally_treatment_cooldown)

/// Returns TRUE if we are a medic, who treats the wounded first and keeps out of the push: someone with the skill of one and a health analyzer
/datum/human_ai_brain/proc/is_medic()
	return skillcheck(tied_human, SKILL_MEDICAL, SKILL_MEDICAL_MEDIC) && !!get_medical_scanner()

/// Returns the health analyzer we look patients over with, if we carry one
/datum/human_ai_brain/proc/get_medical_scanner()
	RETURN_TYPE(/obj/item/device/healthanalyzer)
	for(var/obj/item/device/healthanalyzer/scanner in list(tied_human.belt, tied_human.back, tied_human.s_store, tied_human.l_hand, tied_human.r_hand))
		return scanner
	return get_item_from_equipment_map_path(/obj/item/device/healthanalyzer, HUMAN_AI_TOOLS)

/// Returns TRUE if the ally is in sight, hurt, and something we carry helps them
/datum/human_ai_brain/proc/can_treat_patient(mob/living/carbon/human/patient)
	if(QDELETED(patient) || (patient == tied_human) || (patient.stat == DEAD) || patient.on_fire)
		return FALSE

	if((patient.z != tied_human.z) || (get_dist(tied_human, patient) > view_distance))
		return FALSE

	if(patient_rest_times[REF(patient)] > world.time)
		return FALSE

	var/datum/human_ai_brain/other_medic = patient_medics[REF(patient)]
	if(other_medic && (other_medic != src) && !QDELETED(other_medic) && (other_medic.found_injured_ally == patient))
		return FALSE

	if(!faction_check(patient) || !healing_start_check(patient))
		return FALSE

	return !!find_treatment(patient)

/// Returns the most hurt ally in sight that we can treat, looking around again only every patient_search_delay
/datum/human_ai_brain/proc/find_patient()
	RETURN_TYPE(/mob/living/carbon/human)
	if(found_injured_ally)
		if(can_treat_patient(found_injured_ally))
			return found_injured_ally
		lose_injured_ally()

	if(!COOLDOWN_FINISHED(src, patient_search_cooldown))
		return

	COOLDOWN_START(src, patient_search_cooldown, patient_search_delay)
	var/mob/living/carbon/human/patient = get_injured_ally()
	set_injured_ally(patient)
	if(patient)
		patient_medics[REF(patient)] = src
	return patient

/// Leaves the patient alone for a while
/datum/human_ai_brain/proc/rest_patient(mob/living/carbon/human/patient)
	if(patient)
		patient_rest_times[REF(patient)] = world.time + patient_rest_delay
	if(patient == found_injured_ally)
		lose_injured_ally()

/**
 * Returns the turfs the hostiles around the patient see, as an assoc list of turf = TRUE, or an empty list if none of them sees the patient.
 *
 * The hostiles are the conscious ones the patient sees, and our target where it was last seen.
 */
/datum/human_ai_brain/proc/get_turfs_seen_by_hostiles(mob/living/carbon/human/patient)
	var/list/turf/hostile_turfs = list()
	for(var/mob/living/carbon/hostile in view(view_distance, patient))
		if((hostile.stat == CONSCIOUS) && !faction_check(hostile))
			hostile_turfs |= get_turf(hostile)
	if(target_turf?.z == patient.z)
		hostile_turfs |= target_turf

	var/list/seen_turfs = list()
	for(var/turf/hostile_turf as anything in hostile_turfs)
		for(var/turf/seen_turf in view(view_distance, hostile_turf))
			seen_turfs[seen_turf] = TRUE

	if(!seen_turfs[get_turf(patient)])
		return list()
	return seen_turfs

/// Returns TRUE if a patient can be dragged onto the turf and left there
/datum/human_ai_brain/proc/is_drag_spot(turf/spot)
	if(!istype(spot, /turf/open) || istype(spot, /turf/open/space) || is_blocked_turf(spot))
		return FALSE

	return !(locate(/obj/flamer_fire) in spot)

/**
 * Returns the turf closest to the patient that the hostiles don't see and that we can drag the patient onto, null if there's none within patient_drag_range.
 *
 * A dragged patient follows onto the turf we leave, so the spot also needs a turf beside it out of sight, see get_step_off_drag_spot().
 *
 * * patient - who we drag
 * * seen_turfs - the turfs the hostiles see, from get_turfs_seen_by_hostiles()
 */
/datum/human_ai_brain/proc/find_drag_spot(mob/living/carbon/human/patient, list/seen_turfs)
	var/turf/patient_turf = get_turf(patient)
	var/turf/closest_spot
	var/smallest_distance = INFINITY
	for(var/turf/spot in range(patient_drag_range, patient_turf))
		if(seen_turfs[spot])
			continue

		var/distance = get_dist(patient_turf, spot)
		if(distance >= smallest_distance)
			continue

		if(!is_drag_spot(spot) || !get_step_off_drag_spot(spot, seen_turfs, patient_turf))
			continue

		closest_spot = spot
		smallest_distance = distance

	return closest_spot

/**
 * Returns a turf beside the drag spot that the hostiles don't see, for us to step onto so that the patient we drag follows onto the spot. Null if there's none.
 *
 * * spot - the drag spot
 * * seen_turfs - the turfs the hostiles see
 * * excluded_turf - a turf not to step onto, where the patient is
 */
/datum/human_ai_brain/proc/get_step_off_drag_spot(turf/spot, list/seen_turfs, turf/excluded_turf)
	for(var/direction in GLOB.cardinals)
		var/turf/beside = get_step(spot, direction)
		if(!beside || (beside == excluded_turf) || seen_turfs[beside] || !is_drag_spot(beside))
			continue

		if(length(link_blocked_list(tied_human, spot, beside, list(tied_human))))
			continue

		return beside

/datum/ai_action/treat_ally
	name = "Treat Ally"
	action_flags = ACTION_USING_HANDS | ACTION_USING_LEGS
	// A medic keeps the wounded alive first and shoots back after
	preempts_actions = TRUE
	/// If TRUE, the patient was looked over with the health analyzer
	var/scanned = FALSE
	/// When we give up on a patient that keeps walking away or can't be treated
	var/give_up_time
	/// The turfs the hostiles see as turf = TRUE, made when we reach the patient, empty if they don't see the patient
	var/list/seen_turfs
	/// The turf out of the hostiles' sight we drag the patient to before treating them, null if we treat them where they are
	var/turf/drag_spot
	/// The patient we hold to drag
	var/mob/living/carbon/human/dragged_patient
	/// If TRUE, the brain was applying something to the patient when we last looked
	var/applying_treatment = FALSE
	/// If TRUE, we applied anything to the patient at all
	var/treated = FALSE

/datum/ai_action/treat_ally/get_weight(datum/human_ai_brain/brain)
	if(iszombie(brain.tied_human))
		return 0

	if(brain.healing_someone || brain.hold_position)
		return 0

	if(!length(brain.equipment_map[HUMAN_AI_HEALTHITEMS]) || !brain.is_medic())
		return 0

	// Patch ourselves up first
	if(brain.healing_start_check(brain.tied_human) && COOLDOWN_FINISHED(brain, treatment_search_cooldown) && brain.find_treatment(brain.tied_human))
		return 0

	if(!brain.find_patient())
		return 0

	// Over fire_at_target
	return 12

/datum/ai_action/treat_ally/Added()
	give_up_time = world.time + 30 SECONDS

/datum/ai_action/treat_ally/Destroy(force, ...)
	stop_dragging()
	return ..()

/datum/ai_action/treat_ally/trigger_action()
	. = ..()

	// Finish what we started first, the item is already in our hand
	if(brain.healing_someone)
		applying_treatment = TRUE
		return ONGOING_ACTION_UNFINISHED

	// Bandaging someone takes a medic a moment, and rushing it would patch up a squad in seconds
	if(applying_treatment)
		applying_treatment = FALSE
		COOLDOWN_START(brain, ally_treatment_cooldown, brain.ally_treatment_delay)

	var/mob/living/carbon/human/patient = brain.found_injured_ally
	if(!brain.can_treat_patient(patient) || (world.time > give_up_time))
		// Nothing more we can do for them, which the patient should hear
		if(treated && !QDELETED(patient) && (patient.stat != DEAD))
			brain.say_treat_ally_done_line()
		brain.rest_patient(patient)
		return ONGOING_ACTION_COMPLETED

	if(drag_spot)
		drag_patient(patient)
		return ONGOING_ACTION_UNFINISHED

	var/mob/living/carbon/human/medic = brain.tied_human
	if(get_dist(medic, patient) > 1)
		if(!brain.move_to_next_turf(get_turf(patient)))
			brain.rest_patient(patient)
			return ONGOING_ACTION_COMPLETED
		return ONGOING_ACTION_UNFINISHED

	// Treating someone under fire gets us both shot, so we first drag them out of sight if we can
	if(isnull(seen_turfs))
		seen_turfs = brain.get_turfs_seen_by_hostiles(patient)
		// Whoever still walks gets out of sight on their own and would only break free
		if(length(seen_turfs) && ((patient.body_position == LYING_DOWN) || patient.is_mob_incapacitated()))
			drag_spot = brain.find_drag_spot(patient, seen_turfs)
			if(drag_spot)
				give_up_time = world.time + 30 SECONDS
				drag_patient(patient)
				return ONGOING_ACTION_UNFINISHED

	medic.face_atom(patient)
	if(!scanned)
		scanned = TRUE
		brain.say_treat_ally_line()
		brain.get_medical_scanner()?.ai_use(medic, brain, patient)
		return ONGOING_ACTION_UNFINISHED

	if(!COOLDOWN_FINISHED(brain, ally_treatment_cooldown))
		return ONGOING_ACTION_UNFINISHED

	if(treated)
		brain.say_treat_ally_fumble_line()
	treated = TRUE
	// Every piece of treatment gives us time for the next one
	give_up_time = world.time + 30 SECONDS
	brain.apply_treatment(patient, brain.find_treatment(patient))
	return ONGOING_ACTION_UNFINISHED

/// Grabs the patient and drags them towards the drag spot, until they are out of the hostiles' sight
/datum/ai_action/treat_ally/proc/drag_patient(mob/living/carbon/human/patient)
	var/mob/living/carbon/human/medic = brain.tied_human
	if(!seen_turfs[get_turf(patient)])
		stop_dragging()
		return

	if(medic.pulling != patient)
		// They broke free or got up, so they don't want to be dragged
		if(dragged_patient)
			stop_dragging()
			return

		if(get_dist(medic, patient) > 1)
			if(!brain.move_to_next_turf(get_turf(patient)))
				stop_dragging()
			return

		// The grab goes into a free hand
		brain.holster_primary()
		// start_pulling() won't do anything without a usr, which there is none of while the AI thinks.
		// It only sleeps for xenos pulling, so a human gets hold of the patient before it returns
		usr = medic
		INVOKE_ASYNC(medic, TYPE_PROC_REF(/mob, start_pulling), patient)
		if(medic.pulling != patient)
			stop_dragging()
			return

		dragged_patient = patient
		return

	var/turf/destination = drag_spot
	if(get_turf(medic) == drag_spot)
		destination = brain.get_step_off_drag_spot(drag_spot, seen_turfs, get_turf(patient))
	if(!destination || !brain.move_to_next_turf(destination))
		stop_dragging()

/// Lets go of the patient we drag, to treat them where they are
/datum/ai_action/treat_ally/proc/stop_dragging()
	drag_spot = null
	var/mob/living/carbon/human/medic = brain?.tied_human
	if(dragged_patient && (medic?.pulling == dragged_patient))
		medic.stop_pulling()
	dragged_patient = null
