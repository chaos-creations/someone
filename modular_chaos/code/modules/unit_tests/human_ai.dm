/// How long the two AI humans of /datum/unit_test/human_ai_combat get to fight
#define HUMAN_AI_COMBAT_TIME (10 SECONDS)

/// Two hostile armed human AI fight each other for a while; runtimes on the way fail check_runtimes
/datum/unit_test/human_ai_combat

/datum/unit_test/human_ai_combat/Run()
	var/mob/living/carbon/human/clf_human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/upp_human = allocate(/mob/living/carbon/human, run_loc_floor_top_right)

	for(var/mob/living/carbon/human/ai_human as anything in list(clf_human, upp_human))
		ai_human.AddComponent(/datum/component/human_ai)
		TEST_ASSERT(ai_human.get_ai_brain(), "[ai_human] has no AI brain after adding the human AI component")
		TEST_ASSERT(ai_human.is_ai_controlled(), "[ai_human] is not AI controlled after adding the human AI component")

	arm_equipment(clf_human, /datum/equipment_preset/clf/soldier, TRUE)
	arm_equipment(upp_human, /datum/equipment_preset/upp/soldier/dressed, TRUE)

	for(var/mob/living/carbon/human/ai_human as anything in list(clf_human, upp_human))
		var/datum/human_ai_brain/brain = ai_human.get_ai_brain()
		TEST_ASSERT(brain.primary_weapon, "[ai_human] found no primary weapon in its equipment")
		// The test room may be dark
		brain.has_nightvision = TRUE

	clf_human.face_atom(upp_human)
	upp_human.face_atom(clf_human)

	sleep(HUMAN_AI_COMBAT_TIME)

	var/clf_hurt = (clf_human.health < clf_human.maxHealth) || (clf_human.stat == DEAD)
	var/upp_hurt = (upp_human.health < upp_human.maxHealth) || (upp_human.stat == DEAD)
	TEST_ASSERT(clf_hurt || upp_hurt, "Neither AI human was hurt after [HUMAN_AI_COMBAT_TIME * 0.1] seconds of combat")

#undef HUMAN_AI_COMBAT_TIME

/// How long the AI human of /datum/unit_test/human_ai_short_range_cover gets to close in and shoot
#define HUMAN_AI_CLOSE_IN_TIME (10 SECONDS)

/// An AI human with a shotgun, in cover from a hostile out of shotgun reach, leaves the cover to close in and shoot instead of sitting there
/datum/unit_test/human_ai_short_range_cover

/datum/unit_test/human_ai_short_range_cover/Run()
	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/target_human = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	ai_human.AddComponent(/datum/component/human_ai)
	arm_equipment(ai_human, /datum/equipment_preset/other/freelancer/standard, TRUE)
	arm_equipment(target_human, /datum/equipment_preset/upp/soldier/dressed, TRUE)

	var/datum/human_ai_brain/brain = ai_human.get_ai_brain()
	brain.has_nightvision = TRUE
	qdel(brain.primary_weapon)
	var/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/shotgun = new(ai_human)
	ai_human.put_in_active_hand(shotgun)
	brain.appraise_inventory()
	brain.set_primary_weapon(shotgun)
	TEST_ASSERT(get_dist(ai_human, target_human) > brain.gun_data.maximum_range, "The test room is too small to put the target out of shotgun reach")

	ai_human.face_atom(target_human)
	brain.current_cover = get_turf(ai_human)
	brain.in_cover = TRUE

	var/give_up_time = world.time + HUMAN_AI_CLOSE_IN_TIME
	while((target_human.health >= target_human.maxHealth) && (world.time < give_up_time))
		sleep(1 SECONDS)
	TEST_ASSERT(target_human.health < target_human.maxHealth, "AI human with a shotgun in cover didn't close in on a target out of its reach and shoot it")

#undef HUMAN_AI_CLOSE_IN_TIME

/// Equipment presets of the factions human AI usually plays, which an AI human can put on, then draw and wield its weapon
/datum/unit_test/human_ai_presets
	/// The presets checked, every role of the CLF, PMC, Weyland-Yutani goon and UPP squads
	var/list/preset_paths = list(
		/datum/equipment_preset/clf/commander,
		/datum/equipment_preset/clf/engineer,
		/datum/equipment_preset/clf/leader,
		/datum/equipment_preset/clf/medic,
		/datum/equipment_preset/clf/soldier,
		/datum/equipment_preset/clf/specialist,
		/datum/equipment_preset/goon/engineer,
		/datum/equipment_preset/goon/lead,
		/datum/equipment_preset/goon/standard,
		/datum/equipment_preset/pmc/pmc_gunner,
		/datum/equipment_preset/pmc/pmc_leader,
		/datum/equipment_preset/pmc/pmc_medic,
		/datum/equipment_preset/pmc/pmc_standard,
		/datum/equipment_preset/upp/conscript,
		/datum/equipment_preset/upp/leader/dressed,
		/datum/equipment_preset/upp/machinegunner/dressed,
		/datum/equipment_preset/upp/medic/dressed,
		/datum/equipment_preset/upp/officer/dressed,
		/datum/equipment_preset/upp/soldier/dressed,
	)

/datum/unit_test/human_ai_presets/Run()
	for(var/equipment_path in preset_paths)
		var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human)
		ai_human.AddComponent(/datum/component/human_ai)
		arm_equipment(ai_human, equipment_path, TRUE)

		var/datum/human_ai_brain/brain = ai_human.get_ai_brain()
		TEST_ASSERT(brain, "[equipment_path] AI human has no AI brain")
		brain.unholster_primary()
		brain.wield_primary()
		brain.holster_primary()
		qdel(ai_human)

/// How long an AI human of /datum/unit_test/human_ai_multiz gets to reach a turf on another level
#define HUMAN_AI_LEVEL_CHANGE_TIME (20 SECONDS)

/**
 * An AI human ordered to a turf on another level takes multi-z stairs or a ladder there and back.
 *
 * Needs a ship map with multi-z stairs and ladders, like the Almayer. CI tests with an empty ship, so it skips there.
 */
/datum/unit_test/human_ai_multiz

/datum/unit_test/human_ai_multiz/Run()
	var/obj/structure/stairs/multiz/up/stairs = locate() in world
	if(stairs)
		var/turf/lower_turf = get_step(get_step(stairs, REVERSE_DIR(stairs.dir)), REVERSE_DIR(stairs.dir))
		var/turf/upper_turf = stairs.get_level_change_exit(stairs.dir)
		if(upper_turf)
			upper_turf = get_step(upper_turf, stairs.dir)
		check_level_change(lower_turf, upper_turf, "stairs at [COORD(stairs)]")
	else
		TEST_NOTICE(src, "No multi-z stairs on the map, skipping the stairs part")

	var/obj/structure/ladder/ladder
	for(var/obj/structure/ladder/multiz/multiz_ladder in world)
		if(multiz_ladder.up && !multiz_ladder.down)
			ladder = multiz_ladder
			break
	if(ladder)
		check_level_change(get_turf(ladder), get_turf(ladder.up), "ladder at [COORD(ladder)]")
	else
		TEST_NOTICE(src, "No multi-z ladders on the map, skipping the ladder part")

	check_sight_across_levels()

/// Sends a fresh AI human from start_turf to end_turf and back, failing if it doesn't get to either in time
/datum/unit_test/human_ai_multiz/proc/check_level_change(turf/start_turf, turf/end_turf, description)
	if(!start_turf || !end_turf || start_turf.density || end_turf.density)
		TEST_NOTICE(src, "No free turfs around the [description], skipping it")
		return

	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, start_turf)
	ai_human.AddComponent(/datum/component/human_ai)
	var/datum/human_ai_brain/brain = ai_human.get_ai_brain()

	for(var/turf/destination as anything in list(end_turf, start_turf))
		brain.quick_approach = destination
		var/give_up_time = world.time + HUMAN_AI_LEVEL_CHANGE_TIME
		while((get_turf(ai_human) != destination) && (world.time < give_up_time))
			sleep(1 SECONDS)
		TEST_ASSERT_EQUAL(get_turf(ai_human), destination, "AI human didn't get from [COORD(start_turf == destination ? end_turf : start_turf)] to [COORD(destination)] through the [description]")

	qdel(ai_human)

/// Hostile AI humans see each other through open space: from next to a hole down at whoever is under it and from under it up, and no AI steps into it
/datum/unit_test/human_ai_multiz/proc/check_sight_across_levels()
	var/turf/upper_turf
	var/turf/lower_turf
	var/turf/open_space/found_hole
	for(var/turf/open_space/hole in world)
		var/turf/below = SSmapping.get_turf_below(hole)
		if(!istype(below, /turf/open) || below.density || (locate(/obj/structure) in below))
			continue
		for(var/direction in GLOB.cardinals)
			var/turf/edge = get_step(hole, direction)
			if(istype(edge, /turf/open) && !edge.density && !(locate(/obj/structure) in edge))
				upper_turf = edge
				break
		if(upper_turf)
			lower_turf = below
			found_hole = hole
			break

	if(!upper_turf)
		TEST_NOTICE(src, "No open space with free floor below and next to it on the map, skipping the sight part")
		return

	var/mob/living/carbon/human/upper_human = allocate(/mob/living/carbon/human, upper_turf)
	var/mob/living/carbon/human/lower_human = allocate(/mob/living/carbon/human, lower_turf)
	for(var/mob/living/carbon/human/ai_human as anything in list(upper_human, lower_human))
		ai_human.AddComponent(/datum/component/human_ai)
	arm_equipment(upper_human, /datum/equipment_preset/clf/soldier, TRUE)
	arm_equipment(lower_human, /datum/equipment_preset/upp/soldier/dressed, TRUE)

	for(var/mob/living/carbon/human/ai_human as anything in list(upper_human, lower_human))
		var/datum/human_ai_brain/brain = ai_human.get_ai_brain()
		// Neither the lighting nor the facing of either level matters here
		brain.has_nightvision = TRUE
		brain.scope_vision = FALSE

	var/datum/human_ai_brain/upper_brain = upper_human.get_ai_brain()
	TEST_ASSERT_EQUAL(upper_brain.get_target(), lower_human, "AI human at [COORD(upper_human)] doesn't see the hostile below at [COORD(lower_human)] through the open space")
	var/datum/human_ai_brain/lower_brain = lower_human.get_ai_brain()
	TEST_ASSERT_EQUAL(lower_brain.get_target(), upper_human, "AI human at [COORD(lower_human)] doesn't see the hostile above at [COORD(upper_human)] through the open space")

	// Even ordered right onto it, the AI doesn't step into open space
	qdel(lower_human)
	upper_brain.quick_approach = found_hole
	sleep(3 SECONDS)
	TEST_ASSERT_EQUAL(upper_human.z, upper_turf.z, "AI human at [COORD(upper_human)] ordered onto the open space at [COORD(found_hole)] fell through it")
	qdel(upper_human)

#undef HUMAN_AI_LEVEL_CHANGE_TIME

/// The Create Human AI panel lists the equipment presets by category and spawns AI humans and squads from them
/datum/unit_test/human_ai_spawner

/datum/unit_test/human_ai_spawner/Run()
	var/datum/human_ai_spawner_menu/menu = new()
	TEST_ASSERT(length(menu.preset_categories), "The spawner lists no preset categories")
	var/preset_path = "[/datum/equipment_preset/clf/soldier]"
	TEST_ASSERT(menu.presets_by_path[preset_path], "The spawner doesn't list [preset_path]")

	var/mob/living/carbon/human/game_master = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/list/mob/living/carbon/human/spawned_humans = list()

	spawned_humans += menu.spawn_human(game_master, preset_path, run_loc_floor_bottom_left)
	TEST_ASSERT(spawned_humans[1].get_ai_brain(), "A human spawned by the spawner has no AI brain")

	var/list/old_squads = SShuman_ai.squads.Copy()
	menu.squad = list("[preset_path]" = 2)
	menu.spawn_squad(game_master, run_loc_floor_bottom_left)
	var/list/new_squads = SShuman_ai.squads - old_squads
	TEST_ASSERT_EQUAL(length(new_squads), 1, "Spawning a squad from the spawner didn't make one AI squad")
	var/datum/human_ai_squad/new_squad = new_squads[1]
	TEST_ASSERT_EQUAL(length(new_squad.ai_in_squad), 2, "The spawned AI squad doesn't hold its 2 members")
	TEST_ASSERT(new_squad.squad_leader, "The spawned AI squad has no leader")
	for(var/datum/human_ai_brain/brain as anything in new_squad.ai_in_squad)
		spawned_humans += brain.tied_human

	for(var/mob/living/carbon/human/spawned_human as anything in spawned_humans)
		qdel(spawned_human)
	qdel(new_squad)
	qdel(menu)

/// How long the AI gunner of /datum/unit_test/human_ai_mounted_gun gets to get on its gun
#define HUMAN_AI_MOUNT_TIME (10 SECONDS)

/// An MG nest from the Create Human AI panel gets an AI gunner that mans the gun and stays on it
/datum/unit_test/human_ai_mounted_gun

/datum/unit_test/human_ai_mounted_gun/Run()
	var/datum/human_ai_spawner_menu/menu = new()
	var/mob/living/carbon/human/game_master = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	menu.selected_preset = "[/datum/equipment_preset/clf/soldier]"
	menu.nest_gun = "M56D"
	menu.spawn_direction = "North"
	menu.nest_spare_ammo = 0

	var/turf/gun_turf = get_step(run_loc_floor_bottom_left, NORTH)
	menu.spawn_nest(game_master, gun_turf)
	var/obj/structure/machinery/m56d_hmg/gun = locate() in gun_turf
	TEST_ASSERT(gun, "The MG nest has no gun at [COORD(gun_turf)]")
	var/mob/living/carbon/human/gunner = locate() in run_loc_floor_bottom_left
	TEST_ASSERT(gunner?.get_ai_brain()?.mounted_gun == gun, "The MG nest has no AI gunner told to man its gun")

	var/give_up_time = world.time + HUMAN_AI_MOUNT_TIME
	while((gun.operator != gunner) && (world.time < give_up_time))
		sleep(1 SECONDS)
	TEST_ASSERT_EQUAL(gun.operator, gunner, "The AI gunner didn't get on its gun")

	// Without a client the gun checks every tick whether its gunner may stay on it
	sleep(2 SECONDS)
	TEST_ASSERT_EQUAL(gun.operator, gunner, "The AI gunner got thrown off its gun")

	qdel(gunner)
	qdel(gun)
	qdel(menu)

#undef HUMAN_AI_MOUNT_TIME

/// How long the AI human of /datum/unit_test/human_ai_airlock gets to pry open the airlock
#define HUMAN_AI_PRY_TIME (8 SECONDS)

/// An AI human treats an airlock it has no access to as a wall, drops a path made through one, and pries it open once it has a crowbar
/datum/unit_test/human_ai_airlock

/datum/unit_test/human_ai_airlock/Run()
	var/turf/door_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/end_turf = get_step(door_turf, EAST)
	var/mob/living/carbon/human/ai_human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	arm_equipment(ai_human, /datum/equipment_preset/upp/soldier/dressed, TRUE)
	ai_human.AddComponent(/datum/component/human_ai)
	var/datum/human_ai_brain/brain = ai_human.get_ai_brain()
	TEST_ASSERT_NULL(brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR), "The UPP soldier preset has a crowbar now, the test needs another one")
	var/obj/structure/machinery/door/airlock/almayer/generic/airlock = allocate(/obj/structure/machinery/door/airlock/almayer/generic, door_turf)
	airlock.gen_access()
	airlock.req_access = list(ACCESS_MARINE_BRIG)
	airlock.req_one_access = null
	TEST_ASSERT(airlock.arePowerSystemsOn(), "The test airlock has no power")

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_MARINE_BRIG)
	// The ID of the preset has no access to the airlock, a card in hand does
	TEST_ASSERT(ai_human.put_in_active_hand(card), "The active hand of the AI human is taken")
	TEST_ASSERT_EQUAL(airlock.human_ai_obstacle(ai_human, brain, EAST), DOOR_PENALTY, "AI human doesn't walk through an airlock it has access to")
	qdel(card)
	TEST_ASSERT_EQUAL(airlock.human_ai_obstacle(ai_human, brain, EAST), INFINITY, "AI human without a crowbar sees a way through an airlock it has no access to")

	// A path made before the airlock got in the way
	brain.current_path = list(end_turf, door_turf)
	brain.current_path_target = end_turf
	brain.next_path_generation = world.time + 1 MINUTES
	brain.ai_move_delay = 0
	TEST_ASSERT(!brain.move_to_next_turf(end_turf), "AI human moved on into an airlock it has no access to")
	TEST_ASSERT_NULL(brain.current_path, "AI human kept its path into an airlock it has no access to and would walk into it forever")

	// Only some of the UPP soldier loadouts have a backpack
	var/obj/item/tool/crowbar/crowbar = new(ai_human)
	var/obj/item/storage/container
	for(var/obj/item/storage/worn_storage in list(ai_human.back, ai_human.belt))
		if(worn_storage.can_be_inserted(crowbar, stop_messages = TRUE))
			container = worn_storage
			break
	if(!container)
		qdel(ai_human.back)
		container = new /obj/item/storage/backpack(ai_human)
		ai_human.equip_to_slot_or_del(container, WEAR_BACK)
	container.handle_item_insertion(crowbar, TRUE)
	TEST_ASSERT_EQUAL(crowbar.loc, container, "The crowbar didn't go into the [container] of the AI human")
	brain.appraise_inventory()
	TEST_ASSERT_EQUAL(brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR), crowbar, "AI human didn't find the crowbar in its [container]")
	TEST_ASSERT_EQUAL(airlock.human_ai_obstacle(ai_human, brain, EAST), LOCKED_DOOR_PENALTY, "AI human with a crowbar sees no way through an airlock it has no access to")

	INVOKE_ASYNC(airlock, TYPE_PROC_REF(/atom, human_ai_act), ai_human, brain)
	var/give_up_time = world.time + HUMAN_AI_PRY_TIME
	while(airlock.density && (world.time < give_up_time))
		sleep(1 SECONDS)
	TEST_ASSERT(!airlock.density, "AI human with a crowbar didn't pry open an airlock it has no access to")
	TEST_ASSERT_EQUAL(crowbar.loc, container, "AI human didn't put its crowbar back after prying the airlock")

#undef HUMAN_AI_PRY_TIME

/// How long the AI medic of /datum/unit_test/human_ai_treat_ally gets to treat its ally
#define HUMAN_AI_TREAT_ALLY_TIME (20 SECONDS)

/// An AI medic treats a wounded ally of its faction before shooting at the hostile it sees
/datum/unit_test/human_ai_treat_ally

/datum/unit_test/human_ai_treat_ally/Run()
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	arm_equipment(medic, /datum/equipment_preset/upp/medic/dressed, TRUE)
	arm_equipment(patient, /datum/equipment_preset/upp/soldier/dressed, TRUE)
	arm_equipment(hostile, /datum/equipment_preset/clf/soldier, TRUE)
	medic.AddComponent(/datum/component/human_ai)
	var/datum/human_ai_brain/brain = medic.get_ai_brain()
	TEST_ASSERT(length(brain.equipment_map[HUMAN_AI_HEALTHITEMS]), "The AI medic found no medicine in its equipment")
	TEST_ASSERT(brain.is_medic(), "The UPP medic doesn't count as a medic")

	patient.apply_damage(60, BRUTE, "chest")
	patient.updatehealth()
	var/wounded_health = patient.health
	var/give_up_time = world.time + HUMAN_AI_TREAT_ALLY_TIME
	while((patient.health <= wounded_health) && (world.time < give_up_time))
		sleep(1 SECONDS)
	TEST_ASSERT(patient.health > wounded_health, "AI medic didn't treat its wounded ally next to it, with a hostile at [COORD(hostile)] in sight")

#undef HUMAN_AI_TREAT_ALLY_TIME

/// How long the AI medic of /datum/unit_test/human_ai_drag_ally gets to drag its ally out of sight and treat them
#define HUMAN_AI_DRAG_ALLY_TIME (30 SECONDS)

/// An AI medic drags a wounded ally a hostile sees out of its sight, then treats them
/datum/unit_test/human_ai_drag_ally

/datum/unit_test/human_ai_drag_ally/Run()
	// Everyone sees only 2 turfs far, so the hostile sees the patient but not the medic, which would shoot it instead
	var/turf/patient_turf = get_step(run_loc_floor_bottom_left, EAST)
	var/turf/hostile_turf = locate(patient_turf.x + 2, patient_turf.y, patient_turf.z)
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, patient_turf)
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, hostile_turf)
	arm_equipment(medic, /datum/equipment_preset/upp/medic/dressed, TRUE)
	arm_equipment(patient, /datum/equipment_preset/upp/soldier/dressed, TRUE)
	arm_equipment(hostile, /datum/equipment_preset/clf/soldier, TRUE)
	medic.AddComponent(/datum/component/human_ai)
	var/datum/human_ai_brain/brain = medic.get_ai_brain()
	brain.view_distance = 2

	patient.apply_damage(60, BRUTE, "chest")
	patient.updatehealth()
	// Only those who can't walk away on their own get dragged
	patient.apply_effect(HUMAN_AI_DRAG_ALLY_TIME * 0.1, WEAKEN)
	var/wounded_health = patient.health
	var/give_up_time = world.time + HUMAN_AI_DRAG_ALLY_TIME
	while(((get_dist(patient, hostile) <= brain.view_distance) || (patient.health <= wounded_health)) && (world.time < give_up_time))
		sleep(1 SECONDS)
	TEST_ASSERT(get_dist(patient, hostile) > brain.view_distance, "AI medic didn't drag its wounded ally out of the sight of the hostile at [COORD(hostile)], the ally is at [COORD(patient)]")
	TEST_ASSERT(patient.health > wounded_health, "AI medic didn't treat its wounded ally after dragging them out of sight")
	TEST_ASSERT_NULL(medic.pulling, "AI medic still drags its ally after treating them")

#undef HUMAN_AI_DRAG_ALLY_TIME

/// An AI medic shoots back from where it is instead of closing in on its target or chasing one it lost
/datum/unit_test/human_ai_medic_stays_back

/datum/unit_test/human_ai_medic_stays_back/Run()
	var/mob/living/carbon/human/medic = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/hostile = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	arm_equipment(medic, /datum/equipment_preset/upp/medic/dressed, TRUE)
	arm_equipment(hostile, /datum/equipment_preset/clf/soldier, TRUE)
	medic.AddComponent(/datum/component/human_ai)
	var/datum/human_ai_brain/brain = medic.get_ai_brain()
	TEST_ASSERT(brain.gun_data, "The AI medic has no gun to shoot back with")
	// The test room is smaller than the reach of most guns, but not of a shotgun
	brain.gun_data = locate(/datum/firearm_appraisal/shotgun) in GLOB.firearm_appraisals
	brain.set_target(hostile)
	TEST_ASSERT(get_dist(medic, hostile) > brain.gun_data.optimal_range, "The test room is too small to put the hostile beyond the optimal range of a shotgun")

	var/datum/ai_action/keep_distance = GLOB.AI_actions[/datum/ai_action/keep_distance]
	TEST_ASSERT_EQUAL(keep_distance.get_weight(brain), 0, "AI medic wants to close in on its target")
	brain.lose_target()
	brain.target_turf = get_turf(hostile)
	var/datum/ai_action/chase_target = GLOB.AI_actions[/datum/ai_action/chase_target]
	TEST_ASSERT_EQUAL(chase_target.get_weight(brain), 0, "AI medic wants to chase a target it lost")
	brain.target_turf = null




