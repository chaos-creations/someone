// Elevators of the Golden Arrow class ships (USS Rover), ported from cmss13-pve

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator
	name = "Vehicle Elevator One"
	height = 5
	width = 7
	preferred_direction = NORTH
	port_direction = SOUTH

	id = MOBILE_SHUTTLE_SHIPMAP_ELEVATOR_ONE

	callTime = 5 SECONDS
	ignitionTime = 1 SECONDS

	ignition_sound = 'sound/machines/asrs_raising.ogg'
	landing_sound = null
	var/list/railings = list()
	var/list/gears = list()
	area_type = /area/golden_arrow/vehicle_shuttle

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator/get_transit_path_type()
	return /turf/closed/wall/almayer/outer

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator/Initialize(mapload, ...)
	. = ..()
	// The fillers of a multi-tile shutter open and close with it; a controller of their own would only keep references to them
	for(var/door_id in door_control.door_controllers.Copy())
		if(findtext(door_id, "_filler", -length("_filler")))
			qdel(door_control.door_controllers[door_id])
			door_control.door_controllers -= door_id

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator/register()
	. = ..()
	for(var/obj/structure/machinery/gear/G in GLOB.machines)
		if(G.id == id)
			gears += G
	for(var/obj/structure/machinery/door/poddoor/railing/R in GLOB.machines)
		if(R.id == id)
			railings += R

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator/on_ignition()
	for(var/i in gears)
		var/obj/structure/machinery/gear/G = i
		G.start_moving()
	var/obj/docking_port/stationary/dropzone = destination
	playsound(dropzone.return_center_turf(), ignition_sound, 60, 0)
	playsound(return_center_turf(), ignition_sound, 60, 0)

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator/on_prearrival()
	..()
	for(var/i in gears)
		var/obj/structure/machinery/gear/G = i
		G.stop_moving()

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator/two
	name = "Vehicle Elevator Two"
	id = MOBILE_SHUTTLE_SHIPMAP_ELEVATOR_TWO
	area_type = /area/golden_arrow/vehicle_shuttle/two

/obj/docking_port/mobile/trijent_elevator/shipmap_elevator/cargo
	name = "Cargo Elevator"
	height = 6
	width = 8
	id = MOBILE_SHUTTLE_SHIPMAP_ELEVATOR_CARGO
	area_type = /area/golden_arrow/cargo_shuttle/elevator

/obj/docking_port/stationary/shipmap_elevator/visible_message()
	return

/obj/docking_port/stationary/shipmap_elevator
	dir = NORTH
	height = 5
	width = 7

/obj/docking_port/stationary/trijent_elevator/shipmap_elevator/one
	name = "Vehicle Elevator One"

/obj/docking_port/stationary/trijent_elevator/shipmap_elevator/two
	name = "Vehicle Elevator Two"

/obj/docking_port/stationary/trijent_elevator/shipmap_elevator/cargo
	name = "Cargo Elevator"
	height = 6
	width = 8
