/mob/new_player/attempt_observe()
	CAN_BE_REDEFINED(TRUE)
	if(src != usr || is_observing_blocked())
		return
	return ..()

/**
 * Opens the fork's trimmed lobby menu (chaos/LobbyMenu) instead of upstream's LobbyMenu.
 *
 * Re-implements the upstream proc without calling it, as it hardcodes the interface name; keep in sync with
 * code/modules/mob/new_player/login.dm.
 */
/mob/new_player/tgui_interact(mob/user, datum/tgui/ui)
	CAN_BE_REDEFINED(TRUE)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "chaos/LobbyMenu", window = lobby_window)
		ui.closeable = FALSE
		ui.open(preinitialized = TRUE)

/mob/new_player/ui_data(mob/user)
	CAN_BE_REDEFINED(TRUE)
	. = ..()

	// Roles with their own faction menu (UPP) are hidden from the regular late join menu, so they need a button of their own
	var/upp_join_enabled = FALSE
	if(SSticker.current_state == GAME_STATE_PLAYING)
		for(var/role_title in GLOB.RoleAuthority.roles_for_mode)
			var/datum/job/mode_job = GLOB.RoleAuthority.roles_for_mode[role_title]
			if(mode_job.faction_menu == FACTION_UPP)
				upp_join_enabled = TRUE
				break
	.["upp_join_enabled"] = upp_join_enabled
	return .
