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
