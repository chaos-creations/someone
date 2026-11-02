/datum/equipment_preset/load_preset(mob/living/carbon/human/new_human, randomise = FALSE, count_participant = FALSE, client/mob_client, show_job_gear = TRUE)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	// Every AI with a preset should appraise inventory on spawn
	var/datum/human_ai_brain/ai_brain = new_human.get_ai_brain()
	if(ai_brain)
		ai_brain.appraise_inventory()

// The three rebel weapon procs below are re-implemented because upstream passes ammo_amount as spawn_weapon()'s sidearm argument,
// so rebel SMGs, shotguns and rifles spawn as sidearms. Drop them once upstream fixes that.

/datum/equipment_preset/spawn_rebel_smg(atom/M, ammo_amount = 12)
	CAN_BE_REDEFINED(TRUE)
	if(!M)
		return

	var/gunpath = pick(GLOB.rebel_smgs)
	var/ammopath = GLOB.rebel_smgs[gunpath]

	spawn_weapon(gunpath, ammopath, M, FALSE, ammo_amount)

	return 1

/datum/equipment_preset/spawn_rebel_shotgun(atom/M, ammo_amount = 12)
	CAN_BE_REDEFINED(TRUE)
	if(!M)
		return

	var/gunpath = pick(GLOB.rebel_shotguns)
	var/ammopath = GLOB.rebel_shotguns[gunpath]

	spawn_weapon(gunpath, ammopath, M, FALSE, ammo_amount)

	return 1

/datum/equipment_preset/spawn_rebel_rifle(atom/M, ammo_amount = 12)
	CAN_BE_REDEFINED(TRUE)
	if(!M)
		return

	var/gunpath = pick(GLOB.rebel_rifles)
	var/ammopath = GLOB.rebel_rifles[gunpath]

	spawn_weapon(gunpath, ammopath, M, FALSE, ammo_amount)

	return 1
