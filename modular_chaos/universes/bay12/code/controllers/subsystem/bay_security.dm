//Sets up the Baystation 12 alert levels of the map (the security_state of /datum/map in the source)

/**
 * Sets up the alert levels of the round from the maps
 *
 * The ship map, else the ground map, names the type of its levels as "security_state" in its JSON; GLOB.bay_security_state
 * holds them, and stays null when neither does.
 */
SUBSYSTEM_DEF(bay_security)
	name = "Bay Security"
	init_order = SS_INIT_MAPPING - 1
	flags = SS_NO_FIRE

/datum/controller/subsystem/bay_security/Initialize()
	var/state_type
	for(var/map_type in list(SHIP_MAP, GROUND_MAP))
		var/datum/map_config/config = SSmapping.configs?[map_type]
		if(!config?.config_filename || !fexists(config.config_filename))
			continue
		var/list/json = json_decode(file2text(config.config_filename))
		if(istext(json?["security_state"]))
			state_type = text2path(json["security_state"])
			if(!ispath(state_type, /datum/security_state))
				log_world("[config.config_filename]: [json["security_state"]] is not a type of alert levels")
				state_type = null
				continue
			break
	if(!state_type)
		return SS_INIT_NO_NEED
	GLOB.bay_security_state = new state_type()
	GLOB.bay_security_state.start()
	return SS_INIT_SUCCESS
