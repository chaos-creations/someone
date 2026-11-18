/**
 * Invisible wall removed when the cutscene with its cutscene_id finishes
 *
 * Use it to keep players from running ahead before a cutscene has played,
 * or with [CUTSCENE_WALL_DURING] to keep them from leaving while it plays.
 */
/obj/structure/blocker/invisible_wall/cutscene
	name = "cutscene wall"
	icon = 'modular_chaos/icons/landmarks.dmi'
	icon_state = "cutscene_wall"
	/// ID of the cutscene whose end removes the wall
	var/cutscene_id
	/// When the wall blocks the way, one of the CUTSCENE_WALL_* defines
	var/wall_mode = CUTSCENE_WALL_UNTIL_END

/obj/structure/blocker/invisible_wall/cutscene/Initialize(mapload, ...)
	. = ..()
	// Unit tests create every type without its mapped vars, only a mapped one without them is an error
	if(!cutscene_id)
		if(mapload)
			stack_trace("Cutscene wall at [AREACOORD(src)] has no cutscene_id.")
		return INITIALIZE_HINT_QDEL
	LAZYADDASSOCLIST(GLOB.cutscene_walls, cutscene_id, src)
	if(wall_mode == CUTSCENE_WALL_DURING)
		density = FALSE

/obj/structure/blocker/invisible_wall/cutscene/Destroy()
	LAZYREMOVEASSOC(GLOB.cutscene_walls, cutscene_id, src)
	return ..()

/// Called by the cutscene when it starts
/obj/structure/blocker/invisible_wall/cutscene/proc/on_cutscene_start()
	if(wall_mode == CUTSCENE_WALL_DURING)
		density = TRUE
