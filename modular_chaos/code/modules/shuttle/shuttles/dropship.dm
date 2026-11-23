// Dropship Cyclone of the USS Rover: a copy of the Normandy (same hull and size) under its own name, id and channels.

/obj/docking_port/mobile/marine_dropship/cyclone
	name = "Cyclone"
	id = DROPSHIP_CYCLONE

/obj/docking_port/mobile/marine_dropship/cyclone/get_transit_path_type()
	return /turf/open/space/transit/dropship/cyclone

/obj/docking_port/stationary/marine_dropship/golden_arrow_hangar
	name = "Hangar Bay"
	id = GOLDEN_ARROW_LZ
	auto_open = TRUE
	roundstart_template = /datum/map_template/shuttle/cyclone

/datum/map_template/shuttle/cyclone
	name = "Cyclone"
	prefix = "modular_chaos/maps/shuttles/"
	shuttle_id = DROPSHIP_CYCLONE
