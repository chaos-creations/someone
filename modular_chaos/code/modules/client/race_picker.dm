/**
 * Picker of the character's race and the race's options, opened from the Race link under the name in the character setup
 *
 * Shared by all players like /datum/origin_picker; the values are kept in the user's /datum/preferences.
 * Shows the character preview of the setup window, which shows the race (see /datum/preferences/copy_appearance_to()).
 */
/datum/race_picker

/datum/race_picker/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/RacePicker", "Race")
		ui.open()
		ui.set_autoupdate(FALSE)

	winset(user, ui.window.id, "focus=true")

/datum/race_picker/ui_state(mob/user)
	return GLOB.always_state

/datum/race_picker/ui_static_data(mob/user)
	. = ..()
	var/list/races = list()
	for(var/race_id in GLOB.chaos_player_races)
		var/datum/playable_race/playable_race = GLOB.playable_races[race_id]
		races += list(playable_race.get_ui_data())
	.["races"] = races

/datum/race_picker/ui_data(mob/user)
	. = ..()
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	var/datum/playable_race/character_race = GLOB.playable_races[prefs.race]
	.["race"] = prefs.race
	.["values"] = character_race.sanitize_values(prefs.race_options[prefs.race])
	.["species"] = prefs.species
	.["origin"] = prefs.origin
	.["character_name"] = prefs.real_name
	.["preview"] = get_preview(prefs)

/**
 * Returns the character preview of the setup window, facing south, as a base64 PNG
 *
 * Returns null before the setup window has made the preview.
 */
/datum/race_picker/proc/get_preview(datum/preferences/prefs)
	if(!prefs.preview_dummy)
		return null
	return icon2base64(getFlatIcon(prefs.preview_dummy, SOUTH, no_anim = TRUE))

/datum/race_picker/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	switch(action)
		if("race")
			var/race_id = params["id"]
			if(!(race_id in GLOB.chaos_player_races))
				return
			prefs.race = race_id
			prefs.sanitize_race()
			prefs.sanitize_origin()
			// The race can allow other origins
			prefs.origin_picker.update_static_data(user)

		if("option", "ask_option")
			var/datum/playable_race/character_race = GLOB.playable_races[prefs.race]
			var/datum/race_option/option = character_race.options[params["key"]]
			if(!option)
				return
			var/list/values = character_race.sanitize_values(prefs.race_options[prefs.race])
			var/new_value = params["value"]
			if(action == "ask_option")
				new_value = option.ask(user, values[option.key])
				// The race could have been changed during the input
				if(isnull(new_value) || character_race != GLOB.playable_races[prefs.race])
					return
			values[option.key] = option.sanitize(new_value)
			prefs.race_options[prefs.race] = values
			// An option can pick the species
			prefs.sanitize_race()

		if("origin_picker")
			prefs.origin_picker.tgui_interact(user)
			return TRUE

		else
			return

	// Shows the setup window with the new preview, which ui_data() then sends
	prefs.ShowChoices(user)
	return TRUE
