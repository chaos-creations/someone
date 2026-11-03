/datum/origin
	/// Picture of the homeworld shown in the character setup, or null for none. Sent as an asset named after the file, so file names must be unique.
	var/planet_image
	/// Accent a character of this origin gets unless they pick another one
	var/default_accent = ACCENT_TEMPLATE
	/// Accents a character of this origin can pick, or null for any accent
	var/list/allowed_accents

/// Returns whether a character of this origin can have the accent (a name in GLOB.accents)
/datum/origin/proc/can_have_accent(accent_name)
	if(!accent_name || !GLOB.accents[accent_name])
		return FALSE
	return !allowed_accents || (accent_name in allowed_accents)

/// Returns the asset name of planet_image (its file name), or null if the origin has none
/datum/origin/proc/get_planet_asset_name()
	if(!planet_image)
		return null
	var/image_path = "[planet_image]"
	return copytext(image_path, findlasttext(image_path, "/") + 1)

/datum/origin/chaos_template
	name = ORIGIN_CHAOS_TEMPLATE
	desc = "You were born on a world far from the core systems. Its name means little to anyone but you."
	planet_image = 'modular_chaos/icons/origins/template_planet.gif'
