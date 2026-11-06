/// Folder of the secret map lists, the counterpart of map_config/ in the +secret submodule
#define SECRET_MAP_LISTS_DIRECTORY "+secret/map_config"
/// Folder the map configs of the secret map lists are in, with a trailing slash
#define SECRET_MAP_CONFIGS_DIRECTORY "+secret/maps/"

/datum/controller/configuration
	/// Folder loadmaplist() loads the map configs (JSON) of a map list from, with a trailing slash
	var/map_configs_directory = "maps/"

/**
 * Loads the map list of map_config/, then the map list of the same name in +secret/map_config/ if there is one
 *
 * The maps of a secret list are in +secret/maps/: "map foo" loads +secret/maps/foo.json, which must have
 * "map_root": "+secret/maps/" for its map files (see /datum/map_config/var/map_root). The secret lists are read with
 * the same parser as the public ones, so they take the same commands. Without the submodule (CI, public clones) there
 * are no secret lists and nothing changes.
 *
 * Arguments:
 * * filename - name of the map list (CONFIG_GROUND_MAPS_FILE or CONFIG_SHIP_MAPS_FILE)
 * * maptype - GROUND_MAP or SHIP_MAP
 */
/datum/controller/configuration/loadmaplist(filename, maptype)
	CAN_BE_REDEFINED(TRUE)
	..()
	if(!fexists("[SECRET_MAP_LISTS_DIRECTORY]/[filename]"))
		return
	var/public_lists_directory = map_directory
	map_directory = SECRET_MAP_LISTS_DIRECTORY
	map_configs_directory = SECRET_MAP_CONFIGS_DIRECTORY
	..()
	map_directory = public_lists_directory
	map_configs_directory = initial(map_configs_directory)

#undef SECRET_MAP_LISTS_DIRECTORY
#undef SECRET_MAP_CONFIGS_DIRECTORY
