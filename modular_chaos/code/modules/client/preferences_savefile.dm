/datum/preferences/load_character(slot)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(!.)
		return .
	var/list/save_data = savefile.tree["character[default_slot]"]
	if(islist(save_data))
		accent = save_data["accent"]
		accent_glyph = save_data["accent_glyph"]
	sanitize_origin()
	return .

/datum/preferences/save_character(write = FALSE)
	CAN_BE_REDEFINED(TRUE)
	if(!path)
		return FALSE
	// Upstream's save_character() fills and writes the same list
	var/tree_key = "character[default_slot]"
	if(!(tree_key in savefile.tree))
		savefile.tree[tree_key] = list()
	var/list/save_data = savefile.tree[tree_key]
	save_data["accent"] = accent
	save_data["accent_glyph"] = accent_glyph
	return ..()
