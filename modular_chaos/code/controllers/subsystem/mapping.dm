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
