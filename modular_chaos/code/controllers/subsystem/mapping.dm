/**
 * Loads the Hunter Ship z-level if the LOAD_HUNTER_SHIP config flag is set.
 *
 * Called from loadWorld() in place of upstream's unconditional load. Without the Hunter Ship
 * there are no yautja spawn points, so predators cannot join the round.
 * * errorList - list that collects the names of map files that failed to load
 */
/datum/controller/subsystem/mapping/proc/load_hunter_ship(list/errorList)
	if(!CONFIG_GET(flag/load_hunter_ship))
		return
	var/datum/map_config/hunter_map = new
	hunter_map.LoadConfig("maps/huntership.json", TRUE)
	Loadship(errorList, hunter_map.map_name, hunter_map.map_path, hunter_map.map_file, hunter_map.traits, ZTRAITS_ADMIN, override_map_path = "maps/")

/datum/controller/subsystem/mapping/HACK_LoadMapConfig()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	var/datum/game_mode/colonialmarines/ai/lowpop = new
	lowpop.update_lobby_roles()
	qdel(lowpop)

/**
 * Returns the squad type of the ship map's platoon (see [/datum/map_config/var/platoon]), or null if the ship has none or the map configs are not loaded yet.
 */
/datum/controller/subsystem/mapping/proc/get_main_ship_platoon()
	var/datum/map_config/ship_config = configs?[SHIP_MAP]
	return ship_config?.platoon
