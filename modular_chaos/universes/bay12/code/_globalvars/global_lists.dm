// Here and not in modular_chaos/code/_globalvars/ because the lists name the races and origins of Baystation 12

/// Races players can pick in the character setup (ids in GLOB.playable_races), in the order the race picker lists them; BAY12_DEFAULT_RACE is one of them
GLOBAL_LIST_INIT(bay12_player_races, list(RACE_HUMAN, RACE_VOX))

/**
 * Origins players can pick in the character setup (names in GLOB.origins, in place of upstream's GLOB.player_origins);
 * BAY12_DEFAULT_ORIGIN is one of them
 *
 * The origin picker puts the planets of each star system on orbits around its star in this order, the first one closest,
 * and the moons (/datum/origin/var/moon_of) around their planets in this order too.
 */
GLOBAL_LIST_INIT(bay12_player_origins, list(
	ORIGIN_EARTH, ORIGIN_LUNA, ORIGIN_MARS,
	ORIGIN_VOX_STARLIGHT_HERALD, ORIGIN_VOX_STALWART_GUARDIAN, ORIGIN_VOX_CURIOUS_ACOLYTE, ORIGIN_VOX_DUTIFUL_BLADE, ORIGIN_VOX_VIGILANT_PROPHET,
))
