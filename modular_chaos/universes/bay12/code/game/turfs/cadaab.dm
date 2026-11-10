//Turfs of Cadaab (maps/away/cadaab/cadaab_turfs.dm in Proxi-BoS-Bay12) and the city turfs of Inax it shares with Castelnau

/// The ground of Cadaab: red stone, sand and roads
/turf/open/cadaab
	name = "stone"
	desc = "Guess you could call it a RED STONE."
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/floors.dmi'
	icon_state = "stone0"
	is_groundmap_turf = TRUE
	baseturfs = /turf/open/cadaab/sand
	minimap_color = MINIMAP_DIRT
	/// Prefix of the numbered icon states one is picked from at random on Initialize(), "[variant_prefix]0" to "[variant_prefix][variants - 1]"; null keeps icon_state
	var/variant_prefix
	/// How many numbered icon states variant_prefix has
	var/variants = 0

/turf/open/cadaab/Initialize(mapload, ...)
	. = ..()
	if(variant_prefix)
		icon_state = "[variant_prefix][rand(0, variants - 1)]"

/turf/open/cadaab/stone
	variant_prefix = "stone"
	variants = 2

/turf/open/cadaab/sand
	name = "sand"
	desc = "It's coarse and gets everywhere."
	icon_state = "sand0"
	variant_prefix = "sand"
	variants = 7

/turf/open/cadaab/road
	name = "scorched sand"
	icon_state = "road"

/turf/open/cadaab/road/stone
	name = "stone road"
	icon_state = "stone_road"

/turf/open/cadaab/wood
	name = "wooden floor"
	desc = "Polished wood planks."
	icon_state = "wooden0"
	variant_prefix = "wooden"
	variants = 4
	minimap_color = MINIMAP_AREA_COLONY

/// The city turfs of Inax: asphalt, concrete plates and roofs
/turf/open/inaks
	name = "asphalt"
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/floors.dmi'
	icon_state = "asphalt"
	baseturfs = /turf/open/cadaab/sand

/turf/open/inaks/asphalt

/turf/open/inaks/plate
	name = "plate"
	icon_state = "plate"

/turf/open/inaks/cubic_plate
	name = "cubic plate"
	icon_state = "cubic_plate"

/turf/open/inaks/dark_cafel
	name = "dark cafel"
	icon_state = "dark_cafel"

/turf/open/inaks/roof
	name = "dark roof"
	icon_state = "roof0"

/turf/open/inaks/roof/Initialize(mapload, ...)
	. = ..()
	icon_state = "roof[rand(0, 3)]"

/// The rock of Cadaab, which nothing gets through (/turf/unsimulated/cadaab/rock in the source)
/turf/closed/cadaab_rock
	name = "impassable rock"
	desc = "It's a particularly tough rock here."
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/floors.dmi'
	icon_state = "rock0"
	turf_flags = TURF_HULL
	minimap_color = MINIMAP_BLACK

/turf/closed/cadaab_rock/Initialize(mapload)
	. = ..()
	icon_state = "rock[rand(0, 1)]"

/// The edge of the known world on Cadaab, a wall of radio noise (/turf/unsimulated/wall/cadaab in the source)
/turf/closed/cadaab_noise
	name = "distant noise"
	desc = "In these days, electrical noise follows people everywhere. Not always intelligible, but always unstoppable. It is like radio interference. It seems to intensify as it approaches the boundary of known space. Sometimes you can make out words in the noise. A strange whisper that makes no sense."
	icon = 'modular_chaos/universes/bay12/icons/turf/floors/floors.dmi'
	icon_state = "noise1"
	turf_flags = TURF_HULL
	minimap_color = MINIMAP_BLACK

/turf/closed/cadaab_noise/Initialize(mapload)
	. = ..()
	icon_state = "noise[rand(1, 3)]"
