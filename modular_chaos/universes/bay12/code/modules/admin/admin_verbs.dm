//Admin verbs for the content of Baystation 12

/// Tools for the Baystation 12 content of the round, given with R_ADMIN since every one of them checks it
GLOBAL_LIST_INIT(admin_verbs_bay12, list(
	/client/proc/change_bay_security_level,
))

/client/add_admin_verbs()
	CAN_BE_REDEFINED(TRUE)
	..()
	if(CLIENT_HAS_RIGHTS(src, R_ADMIN))
		add_verb(src, GLOB.admin_verbs_bay12)

/client/remove_admin_verbs()
	CAN_BE_REDEFINED(TRUE)
	..()
	remove_verb(src, GLOB.admin_verbs_bay12)

/**
 * Sets the alert level among the levels of the map, which can be any of them
 */
/client/proc/change_bay_security_level()
	set name = "Set Map Alert Level"
	set category = "Admin.Events"
	if(!check_rights(R_ADMIN))
		return
	var/datum/security_state/state = GLOB.bay_security_state
	if(!state)
		to_chat(usr, SPAN_WARNING("This map has no alert levels of its own; set the security level instead."))
		return
	var/list/options = list()
	for(var/datum/security_level/level as anything in state.all_security_levels - state.current_security_level)
		options[level.name] = level
	var/choice = tgui_input_list(usr, "It's currently [state.current_security_level.name].", "Select new alert level", options)
	if(!choice)
		return
	var/datum/security_level/new_level = options[choice]
	if(state.set_security_level(new_level, force_change = TRUE))
		log_admin("[key_name(usr)] changed the alert level to [new_level.name].")
