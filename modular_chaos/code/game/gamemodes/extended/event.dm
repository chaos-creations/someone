/**
 * Template for event launches: Extended with a hand-picked list of roles.
 *
 * Only the roles in [/datum/game_mode/extended/event/var/event_roles] show up in Setup Character, take part in roundstart
 * assignment and can be late joined. For a launch, make a subtype with its own `name`, `config_tag` and `event_roles`:
 * the name keys the role list in `GLOB.gamemode_roles`, so every subtype needs a unique one. Admins then pick it
 * through "Change Game Mode".
 *
 * Players cannot become xenomorphs (see [/datum/game_mode/var/xeno_join_allowed]); admins can VV it on SSticker.mode mid-round.
 *
 * Roles are only offered, not spawned: the ship and ground maps must have spawn landmarks for every listed role.
 */
/datum/game_mode/extended/event
	name = GAMEMODE_EVENT
	config_tag = GAMEMODE_EVENT
	votable = FALSE
	xeno_join_allowed = FALSE
	/// Titles (JOB_* defines) of the roles players can pick in this mode, in the order they are listed in the menus
	var/list/event_roles = list(
		JOB_CO,
		JOB_SO,
		JOB_SQUAD_LEADER,
		JOB_SQUAD_TEAM_LEADER,
		JOB_SQUAD_SMARTGUN,
		JOB_SQUAD_MEDIC,
		JOB_SQUAD_ENGI,
		JOB_SQUAD_MARINE,
	)

/datum/game_mode/extended/event/announce()
	to_world("<B>The current game mode is - [name]!</B>")

/datum/game_mode/extended/event/get_roles_list()
	return event_roles
