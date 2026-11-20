// Hub listing. Upstream's HUB flag lives in code/controllers/configuration/entries/general.dm; the fork makes it set world.visibility in /world/proc/update_status().

/// Image URL shown at the top of the hub entry. Counts towards BYOND's 254 character hub status limit together with the rest of the entry.
/datum/config_entry/string/hub_banner_url

/// Extra HTML appended to the end of the hub entry, after the map, mode and round time.
/datum/config_entry/string/hub_body

// Entry whitelist

/// Only lets in players whose ckey is listed in config/entry_whitelist.txt, plus admins, mentors and deadmined staff. Off by default.
/datum/config_entry/flag/entry_whitelist

/// Reason shown to a player the entry whitelist turns away.
/datum/config_entry/string/entry_whitelist_message
	config_entry_value = "This server is whitelist-only."
