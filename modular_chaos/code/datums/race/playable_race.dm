/**
 * A race players can pick in the character setup, in the race picker (/datum/race_picker)
 *
 * The race sets the species (/datum/species) the character spawns as, whatever their job, and can limit the origins
 * they can have. Settings of its own are race options (/datum/race_option): the race picker shows them and the
 * preferences keep their values per race in /datum/preferences/var/race_options, so a new setting needs only a new
 * option type. Players pick from GLOB.bay12_player_races; the instances are in GLOB.playable_races by id.
 */
/datum/playable_race
	/// Key of the race in GLOB.playable_races and in the saves (RACE_*); never change it once players have picked the race
	var/id
	var/name
	/// Short line under the name in the race list
	var/tagline
	var/desc
	/// Font Awesome icon of the race in the race picker
	var/icon = "user"
	/// Color of the race in the race picker, "#rrggbb"
	var/color = "#ffd23f"
	/// Name of the species (in GLOB.all_species) a character of the race spawns as, unless get_species() picks another one
	var/species = SPECIES_HUMAN
	/// What the race does better than a human, one line each
	var/list/pros = list()
	/// What the race does worse than a human, one line each
	var/list/cons = list()
	/// Types of the race's options (/datum/race_option), in the order the race picker shows them
	var/list/option_types = list()
	/// The race's options by key, made from option_types
	var/list/datum/race_option/options = list()
	/// Origins (names in GLOB.origins) a character of the race can have, or null for every origin of GLOB.bay12_player_origins
	var/list/allowed_origins
	/// Origin a character of the race gets when theirs isn't allowed, or null for BAY12_DEFAULT_ORIGIN (see get_default_origin())
	var/default_origin

/datum/playable_race/New()
	. = ..()
	for(var/option_type in option_types)
		var/datum/race_option/option = new option_type
		options[option.key] = option

/**
 * Returns the name of the species (in GLOB.all_species) a character of the race spawns as
 *
 * Arguments:
 * * values - the character's option values of this race by key, from sanitize_values()
 */
/datum/playable_race/proc/get_species(list/values)
	return species

/// Returns whether a character of the race can have the origin (a name in GLOB.origins): one of GLOB.bay12_player_origins the race allows
/datum/playable_race/proc/can_have_origin(origin_name)
	if(!(origin_name in GLOB.bay12_player_origins))
		return FALSE
	return !allowed_origins || (origin_name in allowed_origins)

/**
 * Returns the origin a character of the race gets when theirs isn't allowed
 *
 * That is the race's own default_origin where the race can have it, else BAY12_DEFAULT_ORIGIN, which the race may not
 * allow (the races unit test checks that it does).
 */
/datum/playable_race/proc/get_default_origin()
	if(default_origin && can_have_origin(default_origin))
		return default_origin
	return BAY12_DEFAULT_ORIGIN

/**
 * Returns the option values of the race by key, with a value for every option of the race and only values the options take
 *
 * An option missing from the values, or with a value it doesn't take, gets its default; values of unknown keys are dropped.
 *
 * Arguments:
 * * values - option values by key as saved; null or not a list gives the defaults
 */
/datum/playable_race/proc/sanitize_values(list/values)
	var/list/sanitized_values = list()
	for(var/key in options)
		var/datum/race_option/option = options[key]
		sanitized_values[key] = option.sanitize(islist(values) ? values[key] : null)
	return sanitized_values

/**
 * Turns the character into the race: sets the species and applies the options
 *
 * Called after the appearance is copied from the preferences, as a species can change it (the hair color of first
 * generation synthetics), like the species an equipment preset sets in /datum/equipment_preset/proc/load_race().
 *
 * Arguments:
 * * character - the human, a new one spawning or the preview dummy of the character setup
 * * values - the character's option values of this race by key, from sanitize_values()
 */
/datum/playable_race/proc/apply_to(mob/living/carbon/human/character, list/values)
	character.set_species(get_species(values))
	for(var/key in options)
		var/datum/race_option/option = options[key]
		option.apply_to(character, values[key])

/// Returns the race's data for the race picker
/datum/playable_race/proc/get_ui_data()
	var/list/options_data = list()
	for(var/key in options)
		var/datum/race_option/option = options[key]
		options_data += list(option.get_ui_data())
	return list(
		"id" = id,
		"name" = name,
		"tagline" = tagline,
		"desc" = desc,
		"icon" = icon,
		"color" = color,
		"pros" = pros,
		"cons" = cons,
		"options" = options_data,
	)
