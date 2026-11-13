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
	.["upp_join_enabled"] = has_upp_late_join_roles()
	return .

/mob/new_player/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	CAN_BE_REDEFINED(TRUE)
	// Upstream opens the UPP late join menu only in CM vs UPP, but an event mode can have UPP roles too
	if(action != "late_join_upp" || GLOB.master_mode == /datum/game_mode/extended/faction_clash/cm_vs_upp::name || !has_upp_late_join_roles())
		return ..()
	// Runs upstream's checks for the regular late join menu, then switches the opened menu to the UPP roles
	. = ..("late_join", params, ui, state)
	if(!.)
		return .
	late_join_ui.faction = FACTION_UPP
	late_join_ui.tgui_interact(src)
	return .

/**
 * Whether the round has roles that only the UPP late join menu lists (/datum/job/var/faction_menu is FACTION_UPP)
 *
 * Always FALSE before the round starts, as roles_for_mode is not final until then.
 */
/mob/new_player/proc/has_upp_late_join_roles()
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return FALSE
	for(var/role_title in GLOB.RoleAuthority.roles_for_mode)
		var/datum/job/mode_job = GLOB.RoleAuthority.roles_for_mode[role_title]
		if(mode_job.faction_menu == FACTION_UPP)
			return TRUE
	return FALSE
