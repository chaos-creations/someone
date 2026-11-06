/datum/map_config
	/**
	 * Folder the map's files (map_path) are in, with a trailing slash: "map_root" of the JSON, "maps/" when it has none
	 *
	 * Lets a map live outside maps/, like the maps of the secret map lists in +secret/maps/ (see
	 * /datum/controller/configuration/loadmaplist()). It is set in the JSON instead of taken from the folder the JSON is
	 * in, as the JSON of the next map is copied to data/next_map.json (MakeNextMap()). Not used by override maps, which
	 * are in data/.
	 */
	var/map_root = "maps/"

/**
 * Sets map_root from the map's JSON and returns it, the folder LoadConfig() looks for the map files in
 *
 * Arguments:
 * * json - the decoded JSON of the map config
 */
/datum/map_config/proc/load_map_root(list/json)
	map_root = istext(json["map_root"]) ? json["map_root"] : initial(map_root)
	return map_root

/datum/map_config/GetFullMapPaths()
	CAN_BE_REDEFINED(TRUE)
	// Re-implements the upstream proc, which reads the map files from maps/ only
	var/dirpath = "[map_root][map_path]"
	if(override_map)
		dirpath = "data/[map_path]"
	if(istext(map_file))
		return list("[dirpath]/[map_file]")
	var/list/full_paths = list()
	for(var/file in map_file)
		full_paths += "[dirpath]/[file]"
	return full_paths
