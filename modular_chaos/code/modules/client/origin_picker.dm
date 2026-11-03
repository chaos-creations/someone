/**
 * Picker of the character's origin, accent and chat glyph, opened from the Origin tab of the character setup
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

/datum/origin_picker/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/origin_planets))

/datum/origin_picker/ui_static_data(mob/user)
	. = ..()
	var/list/origins = list()
	for(var/origin_name in GLOB.chaos_player_origins)
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
			"planet" = origin.get_planet_asset_name(),
			"accents" = origin_accents,
		))
	.["origins"] = origins

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
			if(!(origin_name in GLOB.chaos_player_origins))
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
