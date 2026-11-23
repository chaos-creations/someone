/**
 * Distress Signal for a small crew, ported from cmss13-pve without its xeno AI.
 *
 * On a ship with a platoon (the "platoon" key of its map json, see [/datum/map_config/var/platoon]) the platoon's squad
 * is the only one marines join, and only its jobs ([/datum/squad/var/platoon_jobs]) can be picked. On any other ship the
 * usual Distress Signal roles are offered.
 *
 * Xenos cannot evolve or take strains, there are no bioscans, resin can be placed near the LZs from the start and the
 * round never ends on its own: staff end it.
 */
/datum/game_mode/colonialmarines/ai
	name = GAMEMODE_LOWPOP
	config_tag = GAMEMODE_LOWPOP
	required_players = 0
	flags_round_type = MODE_INFESTATION|MODE_NEW_SPAWN|MODE_NO_XENO_EVOLVE
	static_comms_amount = 0
	round_time_resin = 0

/datum/game_mode/colonialmarines/ai/pre_setup()
	var/datum/squad/platoon = get_platoon()
	if(platoon)
		platoon.make_platoon()
		role_mappings = platoon.platoon_jobs
	return ..()

/datum/game_mode/colonialmarines/ai/get_roles_list()
	var/datum/squad/platoon = get_platoon()
	if(!platoon)
		return ..()
	var/list/roles = list()
	for(var/datum/job/platoon_job as anything in platoon.platoon_jobs)
		roles += initial(platoon_job.title)
	return roles

/**
 * Returns the squad of the ship's platoon, or null if the ship has none or the maps and squads are not set up yet.
 */
/datum/game_mode/colonialmarines/ai/proc/get_platoon()
	var/platoon_type = SSmapping.get_main_ship_platoon()
	if(!platoon_type || !GLOB.RoleAuthority)
		return null
	return GLOB.RoleAuthority.squads_by_type[platoon_type]

/**
 * Updates the roles the lobby offers for this mode once the ship map is known.
 *
 * The lists are filled when the config loads, before the maps, so without this the lobby would offer the roles of a ship without a platoon.
 */
/datum/game_mode/colonialmarines/ai/proc/update_lobby_roles()
	GLOB.gamemode_roles[name] = get_roles_list()
	var/datum/squad/platoon = get_platoon()
	GLOB.gamemode_role_mappings[name] = platoon?.platoon_jobs

/datum/game_mode/colonialmarines/ai/announce_bioscans()
	return

/datum/game_mode/colonialmarines/ai/check_win()
	return

/datum/game_mode/colonialmarines/ai/check_queen_status(hivenumber, immediately = FALSE)
	return
