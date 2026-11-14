//Security cameras of Baystation 12 (code/game/machinery/camera/camera.dm and presets.dm, and maps/torch/torch_presets.dm in the source)

/**
 * A Bay security camera
 *
 * A CM camera on the networks of the source, with its sprites, set against the wall behind it as the source sets it.
 * The camera consoles that watch these networks come with the consoles of the Torch.
 */
/obj/structure/machinery/camera/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/cameras.dmi'
	icon_state = "camera"
	colony_camera_mapload = FALSE

/obj/structure/machinery/camera/bay/set_pixel_location()
	pixel_x = 0
	pixel_y = 0
	var/turf/wall = get_step(get_turf(src), REVERSE_DIR(dir))
	if(!istype(wall, /turf/closed/wall))
		return
	switch(dir)
		if(SOUTH)
			pixel_y = 21
		if(WEST)
			pixel_x = 10
		if(EAST)
			pixel_x = -10

/obj/structure/machinery/camera/bay/update_icon()
	if(!status || inoperable())
		icon_state = "[initial(icon_state)]1"
	else if(stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	else
		icon_state = initial(icon_state)

/obj/structure/machinery/camera/bay/network/engineering
	network = list(NETWORK_ENGINEERING)

/obj/structure/machinery/camera/bay/network/medbay
	network = list(NETWORK_MEDICAL)

/obj/structure/machinery/camera/bay/network/research
	network = list(NETWORK_RESEARCH)

/obj/structure/machinery/camera/bay/network/security
	network = list(NETWORK_SECURITY)

/obj/structure/machinery/camera/bay/network/aquila
	network = list(NETWORK_AQUILA)

/obj/structure/machinery/camera/bay/network/bridge
	network = list(NETWORK_BRIDGE)

/obj/structure/machinery/camera/bay/network/exploration_shuttle
	network = list(NETWORK_CHARON)

/obj/structure/machinery/camera/bay/network/first_deck
	network = list(NETWORK_FIRST_DECK)

/obj/structure/machinery/camera/bay/network/second_deck
	network = list(NETWORK_SECOND_DECK)

/obj/structure/machinery/camera/bay/network/third_deck
	network = list(NETWORK_THIRD_DECK)

/obj/structure/machinery/camera/bay/network/fourth_deck
	network = list(NETWORK_FOURTH_DECK)

/obj/structure/machinery/camera/bay/network/fifth_deck
	network = list(NETWORK_FIFTH_DECK)
