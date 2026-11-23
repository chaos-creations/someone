// UD-4 Dropship Cyclone: the hull of the Normandy (dropship2.dmi) under the Cyclone's name. The map sets each part's icon_state.

/obj/structure/shuttle/part/cyclone
	name = "\improper Cyclone"
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "1"
	opacity = TRUE

/obj/structure/shuttle/part/cyclone/ex_act(severity, direction)
	return FALSE

/obj/structure/shuttle/part/cyclone/transparent
	opacity = FALSE
