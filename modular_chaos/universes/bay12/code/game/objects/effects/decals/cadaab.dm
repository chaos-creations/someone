//Decals of Cadaab and of the city of Inax; like every /obj/effect/decal they become overlays of their turf

/// Graffiti of Cadaab (/obj/effect/decal/cleanable/cadaab in the source)
/obj/effect/decal/cadaab_graffiti
	name = "graffiti"
	desc = "'BOOKER ZHIV'"
	icon = 'modular_chaos/universes/bay12/icons/effects/decals.dmi'
	icon_state = "alive"

/obj/effect/decal/cadaab_graffiti/booker
	desc = "Our mighty Lord"
	icon_state = "booker"

/obj/effect/decal/cadaab_graffiti/bio
	name = "biohazard graffiti"
	desc = "You probably shouldn't go here."
	icon_state = "bio"

/// Graffiti of the Torch map (/obj/effect/decal/cleanable/antar in the source)
/obj/effect/decal/antar_graffiti
	name = "graffiti"
	icon = 'modular_chaos/universes/bay12/icons/effects/decals.dmi'
	icon_state = "huy"

/obj/effect/decal/antar_graffiti/gaia
	icon_state = "gaia"

/obj/effect/decal/antar_graffiti/solgov
	icon_state = "solgov"

/obj/effect/decal/antar_graffiti/text3
	icon_state = "text3"

/obj/effect/decal/antar_graffiti/text5
	icon_state = "text5"

/obj/effect/decal/cadaab_hole
	name = "hole"
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/decals.dmi'
	icon_state = "holedecal"

/// A tuft of the red grass of Cadaab, of a random look (/obj/random/cadaab_grass in the source)
/obj/effect/decal/cadaab_grass
	name = "grass"
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/decals.dmi'
	icon_state = "grass0"

/obj/effect/decal/cadaab_grass/Initialize()
	icon_state = pick("grass0", "grass1", "grass3", "grass4", "grass5", "grass6", "grass7", "grass8", "grass9", "grass10", "grass11", "grass12", "grass13", "grass14", "grass15")
	return ..()

/// The sign painted on the landing zone of the outpost of the Regulators
/obj/effect/decal/outpost_sign
	name = "outpost"
	icon = 'modular_chaos/universes/bay12/icons/effects/decals_96x32.dmi'
	icon_state = "outpost"

/// The emblem of the Free Trade Union painted on the floor (/obj/effect/floor_decal/ftu in the source)
/obj/effect/decal/ftu_sign
	name = "ftu"
	icon = 'modular_chaos/universes/bay12/icons/effects/decals_38x52.dmi'
	icon_state = "ftu"

/// Road markings and wear of the city of Inax (/obj/effect/floor_decal/inaks in the source)
/obj/effect/decal/inaks
	name = "asphalt edge"
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/decals.dmi'
	icon_state = "asphalt_edge"

/obj/effect/decal/inaks/road_border
	name = "road border"
	icon_state = "road_border"

/obj/effect/decal/inaks/road_border_corner
	name = "road border"
	icon_state = "road_border_corner"

/obj/effect/decal/inaks/road_border_surrounded
	name = "road border"
	icon_state = "road_border_surrounded"

/obj/effect/decal/inaks/hatch
	name = "hatch"
	icon_state = "hatch"

/obj/effect/decal/inaks/sand_dust
	name = "sand dust"
	icon_state = "sand_dust"

/obj/effect/decal/inaks/cafel_hole
	name = "hole in cafel"
	icon_state = "cafel_hole"

/// A crack in asphalt: the map sets icon_state from "crack_1" to "crack_24", or leaves it to /random
/obj/effect/decal/inaks/asphalt_crack
	name = "crack in asphalt"
	icon_state = "crack_1"

/// A crack in asphalt of a random look (/obj/random/asphalt_crack in the source)
/obj/effect/decal/inaks/asphalt_crack/random

/obj/effect/decal/inaks/asphalt_crack/random/Initialize()
	icon_state = "crack_[rand(1, 24)]"
	return ..()
