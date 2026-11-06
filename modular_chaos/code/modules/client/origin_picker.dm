/**
 * Picker of the character's origin, accent and chat glyph, opened from the Origin link under Fluff Information in the character setup
 *
 * Shared by all players like /datum/loadout_doll; the values are kept in the user's /datum/preferences.
 * Religion is changed here too, through upstream's input in /datum/preferences/proc/process_link().
 */
/datum/origin_picker

/datum/origin_picker/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/OriginPicker", "Origin")
		ui.open()
		ui.set_autoupdate(FALSE)

	winset(user, ui.window.id, "focus=true")

/datum/origin_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/origin_picker/ui_static_data(mob/user)
	. = ..()
	// Only the origins the character's race allows, so the race picker updates this when the race changes
	var/datum/playable_race/character_race = GLOB.playable_races[user.client?.prefs?.race]
	var/datum/universe/universe = CURRENT_UNIVERSE
	var/list/allowed_origins = list()
	for(var/origin_name in universe.origins)
		if(!character_race || character_race.can_have_origin(origin_name))
			allowed_origins += origin_name

	var/list/origins = list()
	for(var/origin_name in allowed_origins)
		var/datum/origin/origin = GLOB.origins[origin_name]
		if(!origin)
			continue
		var/list/origin_accents = list()
		for(var/accent_name in GLOB.accents)
			if(origin.can_have_accent(accent_name))
				origin_accents += accent_name
		origins += list(list(
			"name" = origin.name,
			"desc" = origin.desc,
			"planet_type" = origin.planet_type,
			"planet_seed" = origin.planet_seed,
			"planet_size" = origin.planet_size,
			"planet_colors" = origin.planet_colors,
			"planet_random_colors" = origin.planet_random_colors,
			"planet_spin" = origin.planet_spin,
			"planet_tilt" = origin.planet_tilt,
			"moon_of" = origin.moon_of,
			"accents" = origin_accents,
		))
	.["origins"] = origins
	// Systems with origins on their orbits, the closest first, and the moons
	var/list/systems = list()
	for(var/system_name in GLOB.star_systems)
		var/datum/star_system/star_system = GLOB.star_systems[system_name]
		var/list/system_origins = list()
		for(var/origin_name in allowed_origins)
			var/datum/origin/origin = GLOB.origins[origin_name]
			if(origin?.star_system == system_name)
				system_origins += origin_name
		if(!length(system_origins))
			continue
		systems += list(list(
			"name" = star_system.name,
			"origins" = system_origins,
			"star_seed" = star_system.star_seed,
			"star_size" = star_system.star_size,
			"star_colors" = star_system.star_colors,
			"star_spin" = star_system.star_spin,
			"background_seed" = star_system.background_seed,
			"background_colorscheme" = star_system.background_colorscheme,
			"background_darken" = star_system.background_darken,
			"background_planets" = star_system.background_planets,
		))
	.["systems"] = systems

	var/list/accents = list()
	for(var/accent_name in GLOB.accents)
		var/datum/accent/accent = GLOB.accents[accent_name]
		accents += list(list(
			"name" = accent.name,
			"desc" = accent.desc,
			"color" = accent.glyph_color,
		))
	.["accents"] = accents
	.["glyphs"] = GLOB.accent_glyphs

/datum/origin_picker/ui_data(mob/user)
	. = ..()
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	.["origin"] = prefs.origin
	.["accent"] = prefs.accent
	.["glyph"] = prefs.accent_glyph
	.["religion"] = prefs.religion
	.["character_name"] = prefs.real_name

/datum/origin_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	switch(action)
		if("origin")
			var/origin_name = params["name"]
			var/datum/playable_race/character_race = GLOB.playable_races[prefs.race]
			if(!character_race.can_have_origin(origin_name))
				return
			prefs.origin = origin_name
			prefs.sanitize_origin()

		if("accent")
			var/datum/origin/character_origin = GLOB.origins[prefs.origin]
			var/accent_name = params["name"]
			if(!character_origin?.can_have_accent(accent_name))
				return
			prefs.accent = accent_name

		if("glyph")
			var/glyph = params["glyph"]
			if(glyph && !(glyph in GLOB.accent_glyphs))
				return
			prefs.accent_glyph = glyph || ""

		if("religion")
			// Shows the setup window itself
			prefs.process_link(user, list("preference" = "religion", "task" = "input"))
			return TRUE

		else
			return

	prefs.ShowChoices(user)
	return TRUE
