/**
 * A setting of a playable race (/datum/playable_race/var/option_types), shown in the race picker under the race
 *
 * The preferences keep its value per race (/datum/preferences/var/race_options), so trying another race loses nothing.
 * The kind decides how chaos/RacePicker.tsx shows it. A value does something only through apply_to(), or through a
 * proc of the race that reads it (/datum/playable_race/proc/get_species()).
 */
/datum/race_option
	/// Key of the value in the saves, unique within the race; never change it once players have saved values
	var/key
	var/name
	/// Shown under the option, or null
	var/desc
	/// How the race picker shows the option (RACE_OPTION_*)
	var/kind
	/// Value of a character who hasn't set the option; must be one sanitize() keeps
	var/default

/// Returns the value if the option takes it, else the default
/datum/race_option/proc/sanitize(value)
	return default

/**
 * Asks the user for a new value, for kinds the race picker can't edit by itself (RACE_OPTION_COLOR, RACE_OPTION_TEXT)
 *
 * Sleeps. Returns the new value, not yet sanitized, or null if the user cancelled or the kind doesn't ask.
 *
 * Arguments:
 * * user - the mob of the player editing the option
 * * current_value - the value the character has
 */
/datum/race_option/proc/ask(mob/user, current_value)
	return null

/**
 * Applies the value to the character, when they spawn and in the preview of the character setup
 *
 * Runs after the race set the species. Does nothing unless the option overrides it.
 *
 * Arguments:
 * * character - the human
 * * value - the character's value of the option, sanitized
 */
/datum/race_option/proc/apply_to(mob/living/carbon/human/character, value)
	return

/// Returns the option's data for the race picker
/datum/race_option/proc/get_ui_data()
	return list(
		"key" = key,
		"name" = name,
		"desc" = desc,
		"kind" = kind,
	)

/// An option of one of a few values, picked with buttons
/datum/race_option/choice
	kind = RACE_OPTION_CHOICE
	/// Values to the names their buttons show, in the order of the buttons
	var/list/choices = list()
	/// Values to a line about them, shown under the buttons when picked; values without one show none
	var/list/choice_descs = list()

/datum/race_option/choice/sanitize(value)
	if(value in choices)
		return value
	return default

/datum/race_option/choice/get_ui_data()
	. = ..()
	var/list/choices_data = list()
	for(var/value in choices)
		choices_data += list(list(
			"value" = value,
			"name" = choices[value],
			"desc" = choice_descs[value],
		))
	.["choices"] = choices_data
	return .

/// An option that is on or off
/datum/race_option/toggle
	kind = RACE_OPTION_TOGGLE
	default = FALSE

/datum/race_option/toggle/sanitize(value)
	if(isnull(value))
		return default
	return value ? TRUE : FALSE

/// An option of a "#rrggbb" color
/datum/race_option/color
	kind = RACE_OPTION_COLOR
	default = "#ffffff"

/datum/race_option/color/sanitize(value)
	if(!istext(value) || length(value) != 7)
		return default
	return sanitize_hexcolor(value, default)

/datum/race_option/color/ask(mob/user, current_value)
	return tgui_color_picker(user, desc || "Choose the [lowertext(name)]:", name, current_value)

/**
 * An option of a line of text
 *
 * The value is kept as plain text, not HTML-encoded (sanitize() runs on every load, so it must not encode),
 * without line breaks, "<" and ">"; html_encode() it before putting it into chat or HTML.
 */
/datum/race_option/text
	kind = RACE_OPTION_TEXT
	default = ""
	/// Most characters the text can have
	var/max_length = MAX_NAME_LEN

/datum/race_option/text/sanitize(value)
	if(!istext(value))
		return default
	value = replacetext(replacetext(sanitize_simple(value), "<", ""), ">", "")
	return copytext_char(trim(value), 1, max_length + 1)

/datum/race_option/text/ask(mob/user, current_value)
	return tgui_input_text(user, desc || "Enter the [lowertext(name)]:", name, current_value, max_length, encode = FALSE)
