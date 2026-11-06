/**
 * A universe the server runs in: the setting of a launch, with the races and origins players can pick in it
 *
 * The server runs in one universe at a time, the one the UNIVERSE config entry sets (CURRENT_UNIVERSE), and changes
 * it only with a restart. The races and origins themselves are shared by every universe; a universe lists which of them
 * players get, and the character setup resets a saved race or origin the universe doesn't have to its default.
 * Subtypes are the universes, in GLOB.universes.
 */
/datum/universe
	/// Key of the universe in GLOB.universes and the value of the UNIVERSE config entry (UNIVERSE_*)
	var/id
	var/name
	/// Ids of the races players can pick (in GLOB.playable_races), in the order the race picker lists them
	var/list/races = list()
	/// Race of new characters, and of characters whose race players can't pick in this universe; one of races
	var/default_race
	/**
	 * Names of the origins players can pick (in GLOB.origins)
	 *
	 * The origin picker puts the planets of each star system on orbits around its star in this order, the first one closest,
	 * and the moons (/datum/origin/var/moon_of) around their planets in this order too.
	 */
	var/list/origins = list()
	/// Origin of characters whose race has no default origin of its own in this universe; one of origins
	var/default_origin
	/**
	 * Loadout gear players can have in this universe: a list of /datum/gear types (subtypes not included), or null for
	 * every gear. Checked when the gear is picked on the loadout doll and when it is equipped at spawn (see has_gear());
	 * upstream's role loadout picker still lists every gear.
	 */
	var/list/gear_types

/// Returns whether players can have the loadout gear in this universe
/datum/universe/proc/has_gear(datum/gear/gear)
	return !gear_types || (gear.type in gear_types)
