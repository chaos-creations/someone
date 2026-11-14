//Fire alarms of Baystation 12 (the fire alarm of code/game/machinery/alarm.dm in the source)

/**
 * A Bay fire alarm
 *
 * A CM fire alarm, which raises the fire alarm of its area and so shuts its firedoors, as the source's does, and is built
 * and taken apart the same way. It has the window of the source: the alarm and its reset, and a time lock that raises
 * the alarm once it runs out. Something that is not a tool of its own triggers it.
 *
 * Its light shows the alert level: that of the levels of the map (GLOB.bay_security_state), else the CM one as the
 * default levels of the source show it. The levels update it when they change; the CM level, through sec_changed().
 */
/obj/structure/machinery/firealarm/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/firealarm.dmi'
	icon_state = "casing"
	/// Whether the time lock is counting down
	var/timing = FALSE
	/// What is left of the time lock, in seconds
	var/time = 10
	/// The world.timeofday the time lock last counted down at
	var/last_process = 0

/obj/structure/machinery/firealarm/bay/update_icon()
	overlays.Cut()
	pixel_x = 0
	pixel_y = 0
	var/wall_dir = (dir & (NORTH|SOUTH)) ? REVERSE_DIR(dir) : dir
	var/turf/wall = get_step(get_turf(src), wall_dir)
	if(istype(wall) && wall.density)
		switch(dir)
			if(SOUTH)
				pixel_y = 21
			if(NORTH)
				pixel_y = -21
			if(EAST)
				pixel_x = 21
			if(WEST)
				pixel_x = -21
	icon_state = "casing"
	if(wiresexposed)
		overlays += image(icon, "b[buildstage]")
		set_light(0)
		return
	if(stat & BROKEN)
		overlays += image(icon, "broken")
		set_light(0)
		return
	if(stat & NOPOWER)
		overlays += image(icon, "unpowered")
		set_light(0)
		return
	if(!detecting)
		overlays += image(icon, "fire1")
		set_light(2, 0.25, COLOR_RED)
		return
	var/datum/security_level/level = GLOB.bay_security_state?.current_security_level
	if(level)
		overlays += image(level.icon, level.overlay_alarm)
		set_light(level.light_range, level.light_power, level.light_color_alarm)
		return
	// Without alert levels of the map, the CM one, as the default levels of the source show it
	var/cm_level = get_security_level()
	overlays += image('modular_chaos/universes/bay12/icons/misc/security_state.dmi', "alarm_[cm_level]")
	switch(cm_level)
		if("green")
			set_light(2, 1, BAY_COLOR_GREEN)
		if("blue")
			set_light(2, 1, COLOR_BLUE)
		else
			set_light(4, 2, COLOR_RED)

// The CM one sets its icon state for the level; this one draws it in update_icon()
// CM tells of a new level before it sets it, so the alarm draws it once it is set
/obj/structure/machinery/firealarm/bay/sec_changed(datum/source, new_sec)
	addtimer(CALLBACK(src, PROC_REF(update_icon)), 1)

/obj/structure/machinery/firealarm/bay/power_change()
	..()
	update_icon()

/obj/structure/machinery/firealarm/bay/get_examine_text(mob/user)
	. = ..()
	if(is_mainship_level(z))
		. += "The current alert level is [get_alert_level_name()]."

/// The name of the alert level in effect: that of the levels of the map, else the CM one
/obj/structure/machinery/firealarm/bay/proc/get_alert_level_name()
	return GLOB.bay_security_state?.current_security_level.name || "code [get_security_level()]"

/obj/structure/machinery/firealarm/bay/alarm()
	if(!working)
		return
	..()
	playsound(src, 'modular_chaos/universes/bay12/sound/machines/fire_alarm.ogg', 75, FALSE)

/obj/structure/machinery/firealarm/bay/attackby(obj/item/held_object, mob/user)
	add_fingerprint(user)
	var/static/list/tools = list(TRAIT_TOOL_SCREWDRIVER, TRAIT_TOOL_MULTITOOL, TRAIT_TOOL_WIRECUTTERS, TRAIT_TOOL_CROWBAR, TRAIT_TOOL_WRENCH)
	var/is_tool = istype(held_object, /obj/item/stack/cable_coil) || istype(held_object, /obj/item/circuitboard/firealarm)
	for(var/tool in tools)
		if(HAS_TRAIT(held_object, tool))
			is_tool = TRUE
	if(is_tool && (wiresexposed || HAS_TRAIT(held_object, TRAIT_TOOL_SCREWDRIVER)))
		return ..()
	to_chat(user, SPAN_WARNING("You fumble with \the [held_object] and trigger the alarm!"))
	alarm()

/obj/structure/machinery/firealarm/bay/attack_hand(mob/user)
	if(user.stat || inoperable() || buildstage != 2 || wiresexposed)
		return
	tgui_interact(user)

/obj/structure/machinery/firealarm/bay/process()
	if(inoperable() || !timing)
		return
	if(time > 0)
		time -= (world.timeofday - last_process) * 0.1
	else
		alarm()
		time = 0
		timing = FALSE
		stop_processing()
	last_process = world.timeofday

/obj/structure/machinery/firealarm/bay/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/BayFireAlarm", name)
		ui.open()

/obj/structure/machinery/firealarm/bay/ui_data(mob/user)
	var/area/alarm_area = get_area(src)
	return list(
		"fire" = !!(alarm_area.flags_alarm_state & ALARM_WARNING_FIRE),
		"alert_level" = get_alert_level_name(),
		"timing" = timing,
		"time" = round(time),
	)

/obj/structure/machinery/firealarm/bay/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(buildstage != 2)
		return
	switch(action)
		if("alarm")
			alarm()
			return TRUE
		if("reset")
			reset()
			return TRUE
		if("time_lock")
			timing = !!text2num(params["on"])
			last_process = world.timeofday
			if(timing)
				start_processing()
			return TRUE
		if("time_adjust")
			var/change = text2num(params["change"])
			if(!(abs(change) in list(1, 30)))
				return
			time = clamp(round(time + change), 0, 120)
			return TRUE
