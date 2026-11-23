// Dropship Cyclone of the USS Rover, a copy of the Normandy: same settings as /area/shuttle/drop2/sulaco

/area/shuttle/cyclone
	name = "\improper Dropship Cyclone"
	icon_state = "shuttlered"
	base_muffle = MUFFLE_HIGH
	soundscape_interval = 30
	flags_area = AREA_NOBURROW
	is_landing_zone = TRUE
	ceiling = CEILING_REINFORCED_METAL
	base_lighting_alpha = 255
	is_resin_allowed = FALSE

/area/shuttle/cyclone/Enter(atom/movable/O, atom/oldloc)
	if(istype(O, /obj/structure/barricade))
		return FALSE
	return TRUE
