/// Human AI tools, given with R_DEBUG since every one of them checks it
GLOBAL_LIST_INIT(admin_verbs_human_ai, list(
	/datum/admins/proc/toggle_human_ai,
	/client/proc/open_human_ai_management_panel,
	/client/proc/open_human_faction_management_panel,
	/client/proc/open_human_defense_creator_panel,
	/client/proc/create_human_ai,
	/client/proc/make_human_ai,
	/client/proc/place_plastic_explosives,
	/client/proc/open_human_ai_spawner_panel,
))

/// Game master tools, given with R_ADMIN since every one of them checks it
GLOBAL_LIST_INIT(admin_verbs_game_master, list(
	/client/proc/toggle_admin_only_observe,
	/client/proc/toggle_nightmare_menu,
))

/client/add_admin_verbs()
	CAN_BE_REDEFINED(TRUE)
	..()
	if(CLIENT_HAS_RIGHTS(src, R_DEBUG))
		add_verb(src, GLOB.admin_verbs_human_ai)
	if(CLIENT_HAS_RIGHTS(src, R_ADMIN))
		add_verb(src, GLOB.admin_verbs_game_master)

/client/remove_admin_verbs()
	CAN_BE_REDEFINED(TRUE)
	..()
	remove_verb(src, GLOB.admin_verbs_human_ai)
	remove_verb(src, GLOB.admin_verbs_game_master)

/// Closes or opens observing to players, see GLOB.admin_only_observe
/client/proc/toggle_admin_only_observe()
	set name = "Toggle Admin Only Observe"
	set category = "Game Master.Flags"

	if(!check_rights(R_ADMIN))
		return

	GLOB.admin_only_observe = !GLOB.admin_only_observe
	message_admins("[key_name_admin(usr)] toggled admin-only observe [GLOB.admin_only_observe ? "ON" : "OFF"].")
	log_admin("[key_name(usr)] toggled admin-only observe [GLOB.admin_only_observe ? "ON" : "OFF"].")
