//Security states and alert levels of Baystation 12 (code/datums/security_state.dm and maps/torch/torch_security_state.dm in the source)

/**
 * The alert levels of a map, /singleton/security_state of the source
 *
 * A map names its type as "security_state" in its JSON. The levels run from the lowest up; the crew can switch between
 * the standard ones only, and not at all once a higher one is in effect.
 *
 * CM keeps its own alert level (GLOB.security_level), which marines, consoles and the self-destruct follow. Each level
 * here sets the CM level it stands for (cm_level), and a change of the CM level by CM code switches these levels to the
 * one that stands for it (cm_equivalent), without the announcements, which CM made.
 */
/datum/security_state
	/// The level from which extreme measures are allowed, the last one unless set; a type until New()
	var/datum/security_level/severe_security_level
	/// The level from which high alert measures hold, the second to last unless set; a type until New()
	var/datum/security_level/high_security_level
	/// The highest level the crew can switch to, the second to last unless set; FALSE for no limit; a type until New()
	var/datum/security_level/highest_standard_security_level
	/// The level in effect, the first one unless set; a type until New()
	var/datum/security_level/current_security_level
	/// The levels from the lowest up: types until New(), then their instances
	var/list/datum/security_level/all_security_levels
	/// The levels the crew can normally switch to
	var/list/datum/security_level/standard_security_levels
	/// The levels the communications console can switch to: the standard ones but the highest
	var/list/datum/security_level/comm_console_security_levels
	/// Whether it is setting the CM level itself, so the change of the CM level does not switch it back
	var/syncing = FALSE

/datum/security_state/New()
	. = ..()
	var/list/level_types = all_security_levels
	all_security_levels = list()
	var/list/instances = list()
	for(var/level_type in level_types)
		var/datum/security_level/level = new level_type()
		all_security_levels += level
		instances[level_type] = level

	severe_security_level = instances[severe_security_level] || all_security_levels[length(all_security_levels)]
	high_security_level = instances[high_security_level] || all_security_levels[length(all_security_levels) - 1]
	if(highest_standard_security_level || isnull(highest_standard_security_level))
		highest_standard_security_level = instances[highest_standard_security_level] || all_security_levels[length(all_security_levels) - 1]
	else
		highest_standard_security_level = null
	current_security_level = instances[current_security_level] || all_security_levels[1]

	standard_security_levels = list()
	for(var/datum/security_level/level as anything in all_security_levels)
		standard_security_levels += level
		if(level == highest_standard_security_level)
			break
	comm_console_security_levels = list()
	for(var/datum/security_level/level as anything in all_security_levels)
		if(level == highest_standard_security_level)
			break
		comm_console_security_levels += level

	// The high level is not above the severe one, though they may be the same
	if(all_security_levels.Find(high_security_level) > all_security_levels.Find(severe_security_level))
		high_security_level = severe_security_level

	RegisterSignal(SSdcs, COMSIG_GLOB_SECURITY_LEVEL_CHANGED, PROC_REF(on_cm_level_changed))

/datum/security_state/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_SECURITY_LEVEL_CHANGED)
	QDEL_LIST(all_security_levels)
	standard_security_levels = null
	comm_console_security_levels = null
	return ..()

/// Brings in the starting level when the round sets up, quietly, and sets the CM level for it
/datum/security_state/proc/start()
	current_security_level.switching_up_to(src, announce = FALSE)
	sync_cm_level()

/// Whether the crew can switch levels now
/datum/security_state/proc/can_change_security_level()
	return current_security_level in standard_security_levels

/**
 * Whether the crew can switch to a level now
 *
 * * given_security_level - the level
 */
/datum/security_state/proc/can_switch_to(datum/security_level/given_security_level)
	if(!can_change_security_level())
		return FALSE
	return given_security_level in standard_security_levels

/**
 * Whether the level in effect is lower than another
 *
 * * given_security_level - the other level
 */
/datum/security_state/proc/current_security_level_is_lower_than(datum/security_level/given_security_level)
	var/given_index = all_security_levels.Find(given_security_level)
	return given_index && all_security_levels.Find(current_security_level) < given_index

/**
 * Whether the level in effect is the same as another or higher
 *
 * * given_security_level - the other level
 */
/datum/security_state/proc/current_security_level_is_same_or_higher_than(datum/security_level/given_security_level)
	var/given_index = all_security_levels.Find(given_security_level)
	return given_index && all_security_levels.Find(current_security_level) >= given_index

/**
 * Whether the level in effect is higher than another
 *
 * * given_security_level - the other level
 */
/datum/security_state/proc/current_security_level_is_higher_than(datum/security_level/given_security_level)
	var/given_index = all_security_levels.Find(given_security_level)
	return given_index && all_security_levels.Find(current_security_level) > given_index

/**
 * Switches to a level
 *
 * Returns TRUE if it switched.
 * * new_security_level - the level
 * * force_change - whether to switch even where the crew could not
 * * announce - whether the level announces itself
 * * sync_cm - whether to set the CM level it stands for; not when following a change of the CM level
 */
/datum/security_state/proc/set_security_level(datum/security_level/new_security_level, force_change = FALSE, announce = TRUE, sync_cm = TRUE)
	if(new_security_level == current_security_level)
		return FALSE
	if(!(new_security_level in all_security_levels))
		return FALSE
	if(!force_change && !can_switch_to(new_security_level))
		return FALSE

	var/datum/security_level/previous_security_level = current_security_level
	current_security_level = new_security_level
	if(all_security_levels.Find(new_security_level) > all_security_levels.Find(previous_security_level))
		previous_security_level.switching_up_from(src)
		new_security_level.switching_up_to(src, announce)
	else
		previous_security_level.switching_down_from(src)
		new_security_level.switching_down_to(src, announce)
	if(sync_cm)
		sync_cm_level()
	message_admins("The alert level has changed from [previous_security_level.name] to [new_security_level.name].")
	return TRUE

/**
 * Switches one level down, if there is one below
 *
 * * force_change - whether to switch even where the crew could not
 */
/datum/security_state/proc/decrease_security_level(force_change = FALSE)
	var/current_index = all_security_levels.Find(current_security_level)
	if(current_index == 1)
		return FALSE
	return set_security_level(all_security_levels[current_index - 1], force_change)

/// Sets the CM level the level in effect stands for, without CM's announcement
/datum/security_state/proc/sync_cm_level()
	if(GLOB.security_level == current_security_level.cm_level)
		return
	syncing = TRUE
	// The global proc, which the proc of the same name here hides
	call(GLOBAL_PROC_REF(set_security_level))(current_security_level.cm_level, TRUE, FALSE)
	syncing = FALSE

/// Follows a change of the CM level by CM code, quietly, to the level that stands for it
/datum/security_state/proc/on_cm_level_changed(datum/source, new_cm_level)
	SIGNAL_HANDLER
	if(syncing)
		return
	for(var/datum/security_level/level as anything in all_security_levels)
		if(level.cm_equivalent == new_cm_level)
			INVOKE_ASYNC(src, PROC_REF(set_security_level), level, TRUE, FALSE, FALSE)
			return

/**
 * Something a level does when it comes into effect, on top of what the default levels do
 *
 * The Torch unbolts its saferooms on code red.
 */
/datum/security_state/proc/unbolt_saferooms()
	return

/**
 * An alert level, /singleton/security_level of the source
 *
 * The lights and overlays are what alarms and status displays show while it is in effect.
 */
/datum/security_level
	/// The file of its overlays
	var/icon = 'modular_chaos/universes/bay12/icons/misc/security_state.dmi'
	var/name
	/// Whether rotating alarms spin while it is in effect, "on" or "off"
	var/alarm_level = "off"
	/// The range of the light of alarms and displays
	var/light_range
	/// The power of the light of alarms and displays
	var/light_power
	/// The colour of the light of alarms
	var/light_color_alarm
	/// The colour of the light of status displays
	var/light_color_status_display
	/// The overlay of alarms
	var/overlay_alarm
	/// The overlay of status displays
	var/overlay_status_display
	/// The border it draws around the screen
	var/alert_border
	/// What it announces when switched up to
	var/up_description
	/// What it announces when switched down to
	var/down_description
	/// The CM alert level, SEC_LEVEL_*, that is set while it is in effect
	var/cm_level = SEC_LEVEL_GREEN
	/// The CM alert level, SEC_LEVEL_*, whose setting by CM code switches to it; null if none does
	var/cm_equivalent

/**
 * Called when switched to from a lower level
 *
 * * state - the levels it belongs to
 * * announce - whether it announces itself
 */
/datum/security_level/proc/switching_up_to(datum/security_state/state, announce = TRUE)
	return

/**
 * Called when switched to from a higher level
 *
 * * state - the levels it belongs to
 * * announce - whether it announces itself
 */
/datum/security_level/proc/switching_down_to(datum/security_state/state, announce = TRUE)
	return

/**
 * Called when switched from to a higher level
 *
 * * state - the levels it belongs to
 */
/datum/security_level/proc/switching_up_from(datum/security_state/state)
	return

/**
 * Called when switched from to a lower level
 *
 * * state - the levels it belongs to
 */
/datum/security_level/proc/switching_down_from(datum/security_state/state)
	return

/// The default alert levels: code green, blue, red and delta
/datum/security_state/default
	all_security_levels = list(
		/datum/security_level/default/code_green,
		/datum/security_level/default/code_blue,
		/datum/security_level/default/code_red,
		/datum/security_level/default/code_delta,
	)

/**
 * A default alert level
 *
 * It announces itself ship-wide, and has the alarms of the ship show it.
 */
/datum/security_level/default
	/// The sound it announces itself with
	var/announcement_sound = 'modular_chaos/universes/bay12/sound/misc/notice1.ogg'

/datum/security_level/default/switching_up_to(datum/security_state/state, announce = TRUE)
	if(announce && up_description)
		announce_level(up_description, "Attention! Alert level elevated to [name]!")
	notify_station()

/datum/security_level/default/switching_down_to(datum/security_state/state, announce = TRUE)
	if(announce && down_description)
		announce_level(down_description, "Attention! Alert level changed to [name]!")
	notify_station()

/**
 * Announces the level to everyone aboard, a priority security announcement of the source
 *
 * * message - the announcement
 * * title - its title
 * * sound - the sound it plays, announcement_sound unless given
 */
/datum/security_level/default/proc/announce_level(message, title, sound = announcement_sound)
	shipwide_ai_announcement(message, title, sound(sound), ares_logging = ARES_LOG_SECURITY)

/// Has the alarms of the ship show the level
/datum/security_level/default/proc/notify_station()
	for(var/obj/structure/machinery/firealarm/bay/alarm in GLOB.machines)
		if(is_mainship_level(alarm.z))
			alarm.update_icon()

/datum/security_level/default/code_green
	name = "code green"
	light_range = 2
	light_power = 1
	light_color_alarm = BAY_COLOR_GREEN
	light_color_status_display = BAY_COLOR_GREEN
	overlay_alarm = "alarm_green"
	overlay_status_display = "status_display_green"
	alert_border = "alert_border_green"
	down_description = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	cm_level = SEC_LEVEL_GREEN
	cm_equivalent = SEC_LEVEL_GREEN

/datum/security_level/default/code_blue
	name = "code blue"
	alarm_level = "on"
	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_BLUE
	light_color_status_display = COLOR_BLUE
	overlay_alarm = "alarm_blue"
	overlay_status_display = "status_display_blue"
	alert_border = "alert_border_blue"
	up_description = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	down_description = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	cm_level = SEC_LEVEL_BLUE
	cm_equivalent = SEC_LEVEL_BLUE

/datum/security_level/default/code_red
	name = "code red"
	alarm_level = "on"
	light_range = 4
	light_power = 2
	light_color_alarm = COLOR_RED
	light_color_status_display = COLOR_RED
	overlay_alarm = "alarm_red"
	overlay_status_display = "status_display_red"
	alert_border = "alert_border_red"
	up_description = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	down_description = "The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	cm_level = SEC_LEVEL_RED
	cm_equivalent = SEC_LEVEL_RED

/**
 * Code delta, when the self-destruct is engaged
 *
 * It keeps CM at red, so it does not start the CM self-destruct; the CM self-destruct, which sets delta, switches to it.
 */
/datum/security_level/default/code_delta
	name = "code delta"
	alarm_level = "on"
	light_range = 4
	light_power = 2
	light_color_alarm = COLOR_RED
	light_color_status_display = COLOR_NAVY_BLUE
	overlay_alarm = "alarm_delta"
	overlay_status_display = "status_display_delta"
	alert_border = "alert_border_delta"
	cm_level = SEC_LEVEL_RED
	cm_equivalent = SEC_LEVEL_DELTA
	/// The sound it announces itself with when it comes into effect
	var/delta_sound = 'modular_chaos/universes/bay12/sound/effects/siren.ogg'

/datum/security_level/default/code_delta/switching_up_to(datum/security_state/state, announce = TRUE)
	if(announce)
		announce_level("The self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill.", "Attention! Delta security level reached!", delta_sound)
	notify_station()

/**
 * The alert levels of the Torch: code green, violet, orange, blue, red and delta
 *
 * Violet and orange are medical and engineering emergencies, which CM sees as blue.
 */
/datum/security_state/default/torchdept
	all_security_levels = list(
		/datum/security_level/default/torchdept/code_green,
		/datum/security_level/default/torchdept/code_violet,
		/datum/security_level/default/torchdept/code_orange,
		/datum/security_level/default/torchdept/code_blue,
		/datum/security_level/default/torchdept/code_red,
		/datum/security_level/default/torchdept/code_delta,
	)
	/// The area whose subareas are the saferooms, unbolted on code red
	var/saferoom_area = /area/torch/crew_quarters/safe_room

/datum/security_state/default/torchdept/unbolt_saferooms()
	for(var/area_type in typesof(saferoom_area))
		var/area/saferoom = locate(area_type)
		if(!saferoom)
			continue
		for(var/obj/structure/machinery/door/airlock/bay/vault/bolted/door in saferoom)
			if(door.locked)
				door.unlock()

/datum/security_level/default/torchdept/code_green
	name = "code green"
	light_range = 2
	light_power = 1
	light_color_alarm = BAY_COLOR_GREEN
	light_color_status_display = BAY_COLOR_GREEN
	overlay_alarm = "alarm_green"
	overlay_status_display = "status_display_green"
	alert_border = "alert_border_green"
	announcement_sound = 'modular_chaos/universes/bay12/sound/misc/notice2.ogg'
	cm_level = SEC_LEVEL_GREEN
	cm_equivalent = SEC_LEVEL_GREEN

/datum/security_level/default/torchdept/code_green/switching_down_to(datum/security_state/state, announce = TRUE)
	if(announce)
		announce_level("The situation has been resolved, and all crew are to return to their regular duties.", "Attention! Alert level lowered to code green.")
	notify_station()

/datum/security_level/default/torchdept/code_violet
	name = "code violet"
	alarm_level = "on"
	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_VIOLET
	light_color_status_display = COLOR_VIOLET
	overlay_alarm = "alarm_violet"
	overlay_status_display = "status_display_violet"
	alert_border = "alert_border_violet"
	up_description = "A major medical emergency has developed. Medical personnel are required to report to their supervisor for orders, and non-medical personnel are required to obey all relevant instructions from medical staff."
	down_description = "Code violet procedures are now in effect; Medical personnel are required to report to their supervisor for orders, and non-medical personnel are required to obey relevant instructions from medical staff."
	cm_level = SEC_LEVEL_BLUE

/datum/security_level/default/torchdept/code_orange
	name = "code orange"
	alarm_level = "on"
	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_ORANGE
	light_color_status_display = COLOR_ORANGE
	overlay_alarm = "alarm_orange"
	overlay_status_display = "status_display_orange"
	alert_border = "alert_border_orange"
	up_description = "A major engineering emergency has developed. Engineering personnel are required to report to their supervisor for orders, and non-engineering personnel are required to evacuate any affected areas and obey relevant instructions from engineering staff."
	down_description = "Code orange procedures are now in effect; Engineering personnel are required to report to their supervisor for orders, and non-engineering personnel are required to evacuate any affected areas and obey relevant instructions from engineering staff."
	cm_level = SEC_LEVEL_BLUE

/datum/security_level/default/torchdept/code_blue
	name = "code blue"
	alarm_level = "on"
	light_range = 2
	light_power = 1
	light_color_alarm = COLOR_BLUE
	light_color_status_display = COLOR_BLUE
	overlay_alarm = "alarm_blue"
	overlay_status_display = "status_display_blue"
	alert_border = "alert_border_blue"
	up_description = "A major security emergency has developed. Security personnel are to report to their supervisor for orders, are permitted to search staff and facilities, and may have weapons visible on their person."
	down_description = "Code blue procedures are now in effect. Security personnel are to report to their supervisor for orders, are permitted to search staff and facilities, and may have weapons visible on their person."
	cm_level = SEC_LEVEL_BLUE
	cm_equivalent = SEC_LEVEL_BLUE

/datum/security_level/default/torchdept/code_red
	name = "code red"
	alarm_level = "on"
	light_range = 4
	light_power = 2
	light_color_alarm = COLOR_RED
	light_color_status_display = COLOR_RED
	overlay_alarm = "alarm_red"
	overlay_status_display = "status_display_red"
	alert_border = "alert_border_red"
	up_description = "A severe emergency has occurred. All staff are to report to their supervisor for orders. All crew should obey orders from relevant emergency personnel. Security personnel are permitted to search staff and facilities, and may have weapons unholstered at any time. Saferooms have been unbolted."
	announcement_sound = 'modular_chaos/universes/bay12/sound/misc/redalert1.ogg'
	cm_level = SEC_LEVEL_RED
	cm_equivalent = SEC_LEVEL_RED

/datum/security_level/default/torchdept/code_red/switching_up_to(datum/security_state/state, announce = TRUE)
	if(announce)
		announce_level(up_description, "Attention! Code red alert procedures now in effect!")
	notify_station()
	state.unbolt_saferooms()

/datum/security_level/default/torchdept/code_red/switching_down_to(datum/security_state/state, announce = TRUE)
	if(announce)
		announce_level("Code Delta has been disengaged. All staff are to report to their supervisor for orders. All crew should obey orders from relevant emergency personnel. Security personnel are permitted to search staff and facilities, and may have weapons unholstered at any time.", "Attention! Code red alert procedures now in effect!")
	notify_station()

/// Code delta of the Torch; as the default one, it keeps CM at red and is what the CM self-destruct switches to
/datum/security_level/default/torchdept/code_delta
	name = "code delta"
	alarm_level = "on"
	light_range = 4
	light_power = 2
	light_color_alarm = COLOR_RED
	light_color_status_display = COLOR_NAVY_BLUE
	overlay_alarm = "alarm_delta"
	overlay_status_display = "status_display_delta"
	alert_border = "alert_border_delta"
	cm_level = SEC_LEVEL_RED
	cm_equivalent = SEC_LEVEL_DELTA
	/// The sound it announces itself with when it comes into effect
	var/delta_sound = 'modular_chaos/universes/bay12/sound/effects/siren.ogg'

/datum/security_level/default/torchdept/code_delta/switching_up_to(datum/security_state/state, announce = TRUE)
	if(announce)
		announce_level("Code Delta procedures have been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill.", "Attention! Delta security level reached!", delta_sound)
	notify_station()
