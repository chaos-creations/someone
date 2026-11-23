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

/datum/equipment_preset/load_vanity(mob/living/carbon/human/new_human, client/mob_client)
	CAN_BE_REDEFINED(TRUE)
	var/obj/structure/closet/secure_closet/marine_personal/locker = claim_personal_locker(new_human)
	if(!locker)
		return ..()
	load_vanity_into_locker(new_human, locker)

/**
 * Gives the first free personal locker of the marine's job to them.
 *
 * A locker fits if its job is the marine's job title or the squad role that job stands in for in this round.
 * Returns the claimed locker, or null if the marine is not spawning for a job or no locker fits.
 * Dummies (preference previews and other abstract mobs dressed with a preset) never claim one.
 * * new_human - marine spawning with this preset
 */
/datum/equipment_preset/proc/claim_personal_locker(mob/living/carbon/human/new_human)
	if(!new_human.job || !length(GLOB.personal_closets) || istype(new_human, /mob/living/carbon/human/dummy))
		return null
	var/default_role = GET_DEFAULT_ROLE(new_human.job)
	var/obj/structure/closet/secure_closet/marine_personal/fallback
	for(var/obj/structure/closet/secure_closet/marine_personal/locker as anything in GLOB.personal_closets)
		if(locker.owner)
			continue
		if(locker.job == new_human.job)
			fallback = locker
			break
		if(!fallback && locker.job == default_role)
			fallback = locker
	if(!fallback)
		return null
	fallback.owner = new_human.real_name
	fallback.name = "[fallback.owner]'s personal locker"
	return fallback

/**
 * Puts what [/datum/equipment_preset/proc/load_vanity] would equip into the marine's personal locker instead.
 *
 * The marine spawns without a uniform, so loadout items, rank pins, the service medal and prescription glasses wait in the locker.
 * * new_human - owner of the locker
 * * locker - personal locker claimed for them
 */
/datum/equipment_preset/proc/load_vanity_into_locker(mob/living/carbon/human/new_human, obj/structure/closet/secure_closet/marine_personal/locker)
	var/datum/preferences/prefs = new_human.client?.prefs
	if(!prefs)
		return

	for(var/gear_type in prefs.gear)
		var/datum/gear/current_gear = GLOB.gear_datums_by_type[gear_type]
		if(current_gear.allowed_roles && !(new_human.job in current_gear.allowed_roles))
			to_chat(new_human, SPAN_WARNING("Gear [current_gear.display_name] cannot be equipped: Invalid Role."))
			continue
		if(current_gear.allowed_origins && !(new_human.origin in current_gear.allowed_origins))
			to_chat(new_human, SPAN_WARNING("Gear [current_gear.display_name] cannot be equipped: Invalid Origin."))
			continue
		new current_gear.path(locker)

	SEND_SIGNAL(new_human, COMSIG_POST_VANITY_UPDATE)

	var/current_rank = paygrades[1]
	var/obj/item/card/id/id_card = new_human.get_idcard()
	if(id_card)
		current_rank = id_card.paygrade
	if(current_rank)
		var/rankpath = get_rank_pins(current_rank)
		if(rankpath)
			new rankpath(locker)

	if((flags & EQUIPMENT_PRESET_MARINE) && prefs.playtime_perks)
		var/medal_type
		switch(get_job_playtime(new_human.client, job_title))
			if(JOB_PLAYTIME_TIER_1 to JOB_PLAYTIME_TIER_2)
				medal_type = /obj/item/clothing/accessory/medal/bronze/service
			if(JOB_PLAYTIME_TIER_2 to JOB_PLAYTIME_TIER_3)
				medal_type = /obj/item/clothing/accessory/medal/silver/service
			if(JOB_PLAYTIME_TIER_3 to JOB_PLAYTIME_TIER_4)
				medal_type = /obj/item/clothing/accessory/medal/gold/service
			if(JOB_PLAYTIME_TIER_4 to INFINITY)
				medal_type = /obj/item/clothing/accessory/medal/platinum/service
		if(medal_type)
			var/obj/item/clothing/accessory/medal/medal = new medal_type(locker)
			medal.recipient_name = new_human.real_name
			medal.recipient_rank = assignment

	if(new_human.disabilities & NEARSIGHTED)
		new /obj/item/clothing/glasses/regular(locker)
