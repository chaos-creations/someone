//Areas for Cadaab, the hot desert moon of Inax (maps/away/cadaab/ in Proxi-BoS-Bay12)

/// Every area of Cadaab: always powered for now, as nothing on the map makes power yet
/area/cadaab
	name = "Cadaab"
	icon = 'modular_chaos/universes/bay12/icons/turf/areas.dmi'
	icon_state = "where"
	can_build_special = TRUE
	powernet_name = "ground"
	requires_power = FALSE
	temperature = 313.15 //kelvin, 40c, 104f
	ambience_exterior = AMBIENCE_BIGRED
	minimap_color = MINIMAP_AREA_COLONY

/// The rock around the playable part of the map (/area/space in the source)
/area/cadaab/oob
	name = "Cadaab - Impassable Rock"
	ceiling = CEILING_MAX
	is_resin_allowed = FALSE
	flags_area = AREA_NOBURROW|AREA_UNWEEDABLE
	minimap_color = MINIMAP_AREA_CAVES_DEEP

/// The edge of the known world, where the radio noise turns into walls
/area/cadaab/noise
	name = "Cadaab - Noise"
	icon_state = "desert"
	ambience_exterior = 'modular_chaos/universes/bay12/sound/ambience/cadaab/noise.ogg'

/area/cadaab/desert
	name = "Cadaab - Desert"
	icon_state = "desert"
	minimap_color = MINIMAP_DIRT

/area/cadaab/oasis
	name = "Cadaab - Oasis"
	icon_state = "desert"
	ambience_exterior = AMBIENCE_JUNGLE
	minimap_color = MINIMAP_AREA_JUNGLE

/area/cadaab/oasis_farm
	name = "Cadaab - Lone Home"
	icon_state = "living"
	ceiling = CEILING_METAL
	ambience_exterior = AMBIENCE_JUNGLE

/area/cadaab/city_streets
	name = "Cadaab - Shahtinsk - City-like Streets"
	icon_state = "desert"
	ambience_exterior = 'modular_chaos/universes/bay12/sound/ambience/cadaab/clot1.ogg'

/area/cadaab/lab
	name = "Cadaab - Underground Lab"
	icon_state = "medbay_alt"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	ambience_exterior = AMBIENCE_ALMAYER
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

//OUTPOST//

/area/cadaab/outpost
	name = "Regulators Outpost"
	icon_state = "command"
	ceiling = CEILING_METAL
	ambience_exterior = AMBIENCE_ALMAYER
	minimap_color = MINIMAP_AREA_COMMAND

/area/cadaab/outpost/teleport
	name = "Outpost - Teleport"

/area/cadaab/outpost/eng
	name = "Outpost - Engineering"
	icon_state = "engineering_alt"
	minimap_color = MINIMAP_AREA_ENGI

/area/cadaab/outpost/med
	name = "Outpost - Medical Bay"
	icon_state = "medbay_alt"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/cadaab/outpost/sec
	name = "Outpost - Security"
	icon_state = "security_alt"
	minimap_color = MINIMAP_AREA_SEC

/area/cadaab/outpost/sec/armory
	name = "Outpost - Armory"

/area/cadaab/outpost/living
	name = "Outpost - Living Area"
	icon_state = "living"

/area/cadaab/outpost/landing
	name = "Outpost - Landing Zone"
	icon_state = "landing"
	ceiling = CEILING_NONE
	ambience_exterior = AMBIENCE_BIGRED
	minimap_color = MINIMAP_AREA_LZ

/area/cadaab/outpost/syndivault
	name = "Syndipass Vault"
	icon_state = "syndipass"

/// The SSS PrettyBoy, a landed shuttle that is a part of the map for now
/area/cadaab/outpost/syndishuttle
	name = "SSS PrettyBoy"
	icon_state = "syndipass"

//CAVES - NEAR THE OUTPOST//

/area/cadaab/caves
	name = "Cadaab - Caves"
	icon_state = "desert"
	ceiling = CEILING_UNDERGROUND_ALLOW_CAS
	sound_environment = SOUND_ENVIRONMENT_CAVE
	ambience_exterior = AMBIENCE_CAVE
	soundscape_playlist = list(
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave1.ogg',
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave2.ogg',
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave3.ogg',
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave4.ogg',
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave5.ogg',
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave6.ogg',
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave7.ogg',
		'modular_chaos/universes/bay12/sound/ambience/cadaab/cave8.ogg',
	)
	minimap_color = MINIMAP_AREA_CAVES

/area/cadaab/caves/bunker
	name = "Vault - Security Checkpoint"
	icon_state = "security_alt"
	ceiling = CEILING_UNDERGROUND_METAL_BLOCK_CAS
	sound_environment = SOUND_ENVIRONMENT_ROOM
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/cadaab/caves/bunker/living
	name = "Vault - Living Area"
	icon_state = "living"
	minimap_color = MINIMAP_AREA_CAVES_STRUCTURE

/area/cadaab/caves/bunker/living/can
	name = "Vault - Canteen"

/area/cadaab/caves/bunker/living/bunk
	name = "Vault - Bunks"

/area/cadaab/caves/bunker/medsci
	name = "Vault - MedScience"
	icon_state = "medbay_alt"
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE

/area/cadaab/caves/bunker/engi
	name = "Vault - Engineering"
	icon_state = "engineering_alt"
	minimap_color = MINIMAP_AREA_ENGI_CAVE

//SHAHTINSK//

/area/cadaab/shahtinsk
	name = "Cadaab - Shahtinsk - Near Outpost"
	icon_state = "desert"
	minimap_color = MINIMAP_AREA_MINING

/area/cadaab/shahtinsk/second
	name = "Cadaab - Shahtinsk - Near Tribe"

/area/cadaab/shahtinsk/city_like
	name = "Cadaab - Shahtinsk - City-like"

//SHAHTINSK - BOOKERISTI//

/area/cadaab/shahtinsk/booker
	name = "Shahtinsk - Occupied Complex"
	icon_state = "living"
	ceiling = CEILING_METAL

/area/cadaab/shahtinsk/booker/start
	name = "Shahtinsk - Occupied Complex Dorms"
