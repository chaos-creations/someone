/// Ckeys the entry whitelist lets in, one per line; `#` starts a comment line. Read on every check, so edits apply without a restart.
#define ENTRY_WHITELIST_FILE "config/entry_whitelist.txt"

/**
 * Adds the entry whitelist to upstream's connection checks.
 *
 * With the ENTRY_WHITELIST flag on, turns away anyone not listed in [ENTRY_WHITELIST_FILE] who is not staff.
 * Telemetry checks (alt accounts of a connecting player) are left to the real bans, and a guest key waiting for
 * external auth is let through here and checked again under its real ckey once it logs in.
 */
/world/IsBanned(
		key,
		address,
		computer_id,
		type,
		real_bans_only = FALSE,
		is_telemetry = FALSE,
		guest_bypass_with_ext_auth = TRUE,
		byond_user = TRUE
	)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(.)
		return .
	if(!CONFIG_GET(flag/entry_whitelist) || type == "world" || is_telemetry)
		return .

	var/ckey = ckey(key)
	if(GLOB.directory[ckey])
		return . // Already connected, as upstream skips it.
	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		return .
	if(guest_bypass_with_ext_auth && IsGuestKey(key) && length(CONFIG_GET(keyed_list/auth_urls)))
		return .
	if(is_entry_whitelisted(ckey))
		return .

	log_access("Failed Login: [key] - Not on the entry whitelist")
	return list("reason" = "whitelist", "desc" = "\nReason: [CONFIG_GET(string/entry_whitelist_message)]")

/**
 * Whether a ckey is listed in [ENTRY_WHITELIST_FILE]. A missing file lists nobody.
 *
 * * ckey - ckey to look for
 */
/world/proc/is_entry_whitelisted(ckey)
	for(var/line in file2list(ENTRY_WHITELIST_FILE))
		if(!length(line) || copytext(line, 1, 2) == "#")
			continue
		if(ckey(line) == ckey)
			return TRUE
	return FALSE

#undef ENTRY_WHITELIST_FILE
