//Shuttle engines of Baystation 12 (code/modules/shuttles/shuttle_engines.dm in the source)
// Their platforms and routers are CM's, which have the same sprites.

/// A Bay engine heater, a CM one with the sprite of the source
/obj/structure/shuttle/engine/heater/bay
	icon = 'modular_chaos/universes/bay12/icons/turf/shuttle.dmi'
	climbable = TRUE

/// A Bay engine nozzle, a CM one with the sprite of the source
/obj/structure/shuttle/engine/propulsion/bay
	icon = 'modular_chaos/universes/bay12/icons/turf/shuttle.dmi'

/obj/structure/shuttle/engine/propulsion/bay/burst
	name = "burst"

/obj/structure/shuttle/engine/propulsion/bay/burst/left
	name = "left"
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/bay/burst/right
	name = "right"
	icon_state = "burst_r"
