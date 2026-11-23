// Floors of the Golden Arrow class ships (USS Rover), ported from cmss13-pve

/turf/open/floor/almayer/edge
	icon_state = "floor_edge"

/turf/open/floor/almayer/edge/smooth
	icon_state = "floor_edge_smooth"

/turf/open/floor/almayer/edge/smooth/corner
	icon_state = "floor_edge_smooth_corner"

/turf/open/floor/almayer/edge/smooth/endcap_right
	icon_state = "floor_edge_smooth2"

/turf/open/floor/almayer/edge/smooth/endcap_left
	icon_state = "floor_edge_smooth3"

/turf/open/floor/almayer/edge/smooth/corner/north
	dir = NORTH

/turf/open/floor/almayer/edge/smooth/corner/east
	dir = EAST

/turf/open/floor/almayer/edge/smooth/corner/west
	dir = WEST

/turf/open/floor/almayer/edge/smooth/southwest
	dir = SOUTHWEST

/turf/open/floor/almayer/edge/smooth/north
	dir = NORTH

/turf/open/floor/almayer/edge/smooth/east
	dir = EAST

/turf/open/floor/almayer/edge/smooth/northeast
	dir = NORTHEAST

/turf/open/floor/almayer/edge/smooth/southeast
	dir = SOUTHEAST

/turf/open/floor/almayer/edge/smooth/west
	dir = WEST

/turf/open/floor/almayer/edge/smooth/northwest
	dir = NORTHWEST

/turf/open/floor/almayer/edge/southwest
	dir = SOUTHWEST

/turf/open/floor/almayer/edge/north
	dir = NORTH

/turf/open/floor/almayer/edge/east
	dir = EAST

/turf/open/floor/almayer/edge/west
	dir = WEST

/turf/open/floor/almayer/edge/northwest
	dir = NORTHWEST

/turf/open/floor/almayer/uscm/north
	dir = NORTH

/turf/open/floor/almayer/uscm/directional/up_down
	icon_state = "logo_directional1"

/turf/open/floor/almayer/uscm/directional/up_down/southwest
	dir = SOUTHWEST

/turf/open/floor/almayer/uscm/directional/up_down/north
	dir = NORTH

/turf/open/floor/almayer/uscm/directional/up_down/east
	dir = EAST

/turf/open/floor/almayer/uscm/directional/up_down/northeast
	dir = NORTHEAST

/turf/open/floor/almayer/uscm/directional/up_down/southeast
	dir = SOUTHEAST

/turf/open/floor/almayer/uscm/directional/up_down/west
	dir = WEST

/turf/open/floor/almayer/uscm/directional/up_down/northwest
	dir = NORTHWEST

/// Shaft of the cargo elevator: whoever falls in lands in the elevator, wherever it is
/turf/open/floor/almayer/empty/golden_arrow
	desc = "You can see the elevator down there. It's a pretty long fall though..."
	/// Area of the elevator that fallers land in
	var/area_type = /area/golden_arrow/cargo_shuttle/elevator

/turf/open/floor/almayer/empty/golden_arrow/get_depths_turfs()
	var/list/depths_turfs = list()
	for(var/turf/area_turf as anything in get_area_turfs(area_type))
		if(!area_turf.density)
			depths_turfs += area_turf
	return depths_turfs
