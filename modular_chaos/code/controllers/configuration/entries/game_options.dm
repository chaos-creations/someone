/// Loads the Hunter Ship z-level at round start. Off by default: without it predators cannot join.
/datum/config_entry/flag/load_hunter_ship

/// Id of the universe the server runs in (UNIVERSE_*), see CURRENT_UNIVERSE. Characters follow it, so it changes only with a restart.
/datum/config_entry/string/universe
	config_entry_value = CHAOS_DEFAULT_UNIVERSE
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/universe/ValidateAndSet(str_val)
	if(!(trim(str_val) in GLOB.universes))
		return FALSE
	return ..()
