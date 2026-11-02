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

/client/add_admin_verbs()
	CAN_BE_REDEFINED(TRUE)
	..()
	if(CLIENT_HAS_RIGHTS(src, R_DEBUG))
		add_verb(src, GLOB.admin_verbs_human_ai)

/client/remove_admin_verbs()
	CAN_BE_REDEFINED(TRUE)
	..()
	remove_verb(src, GLOB.admin_verbs_human_ai)
