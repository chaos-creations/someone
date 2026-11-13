/datum/controller/configuration
	/// Folder loadmaplist() loads the map configs (JSON) of a map list from, with a trailing slash
	var/map_configs_directory = "maps/"
	/**
	 * The map lists loaded after the one of map_config/, in this order: the folder of the lists, like map_config/, to
	 * the folder their map configs (JSON) are in, with a trailing slash
	 *
	 * A universe keeps its maps in modular_chaos/universes/<universe>/: its lists in map_config/, the JSON of its maps
	 * in maps/. The secret maps are in the +secret submodule, which CI and public clones do not have. A folder without
	 * a list of that name is skipped.
	 */
	var/list/extra_map_sources = list(
		"modular_chaos/universes/bay12/map_config" = "modular_chaos/universes/bay12/maps/",
		"+secret/map_config" = "+secret/maps/",
	)

/**
 * Loads the map list of map_config/, then the lists of the same name in the folders of extra_map_sources
 *
 * "map foo" in a list from extra_map_sources loads foo.json from the folder paired with the list's, and that JSON
 * must have its folder as "map_root" for its map files (see /datum/map_config/var/map_root), as the JSON is copied to
 * data/ when the map is picked. All the lists are read with the same parser, so they take the same commands, and an
 * entry of a later list replaces an earlier one of the same map.
 *
 * Arguments:
 * * filename - name of the map list (CONFIG_GROUND_MAPS_FILE or CONFIG_SHIP_MAPS_FILE)
 * * maptype - GROUND_MAP or SHIP_MAP
 */
/datum/controller/configuration/loadmaplist(filename, maptype)
	CAN_BE_REDEFINED(TRUE)
	..()
	var/public_lists_directory = map_directory
	for(var/lists_directory in extra_map_sources)
		if(!fexists("[lists_directory]/[filename]"))
			continue
		map_directory = lists_directory
		map_configs_directory = extra_map_sources[lists_directory]
		..()
	map_directory = public_lists_directory
	map_configs_directory = initial(map_configs_directory)
