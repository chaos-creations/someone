/// Four tile shutter of the dropship Cyclone and the Golden Arrow class elevators, ported from cmss13-pve under its own name
/obj/structure/machinery/door/poddoor/two_tile/four_tile/pivot
	icon = 'modular_chaos/icons/obj/structures/doors/1x4blast_hor.dmi'
	icon_state = "hatch1"
	base_icon_state = "hatch"

/obj/structure/machinery/door/poddoor/two_tile/four_tile/pivot/Initialize()
	. = ..()
	// Fillers keep the default numeric id, which a shuttle's door controller would read as a list index
	for(var/obj/structure/machinery/door/poddoor/filler_object/filler as anything in list(f1, f2, f3, f4))
		filler?.id = "[id]_filler"

/obj/structure/machinery/door/poddoor/two_tile/four_tile/pivot/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	// The filler on the shutter's own tile can stay behind when a shuttle template is moved to its dock, and gets deleted with the template's reserved space
	var/turf/filler_turf = loc
	for(var/obj/structure/machinery/door/poddoor/filler_object/filler as anything in list(f1, f2, f3, f4))
		if(filler && filler.loc != filler_turf)
			filler.forceMove(filler_turf)
		filler_turf = get_step(filler_turf, dir)
