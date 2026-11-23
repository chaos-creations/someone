// Cockpit seats of the dropship Cyclone, ported from cmss13-pve

/obj/structure/bed/chair/vehicle/dropship_cockpit
	name = "cockpit seat"
	desc = "A sturdy metal chair with a brace that lowers over your body. Holds you in place during high altitude drops."
	icon_state = "vehicle_seat"
	can_rotate = FALSE

/obj/structure/bed/chair/vehicle/dropship_cockpit/afterbuckle(mob/M)
	. = ..()
	if(buckled_mob)
		ADD_TRAIT(buckled_mob, TRAIT_UNDENSE, BUCKLED_TRAIT)
	else
		REMOVE_TRAIT(M, TRAIT_UNDENSE, BUCKLED_TRAIT)

/obj/structure/bed/chair/vehicle/dropship_cockpit/pilot
	name = "pilot seat"

/obj/structure/bed/chair/vehicle/dropship_cockpit/pilot/handle_rotation()
	if(dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = BELOW_MOB_LAYER
	if(buckled_mob)
		buckled_mob.setDir(dir)

/obj/structure/bed/chair/vehicle/dropship_cockpit/copilot
	name = "co-pilot seat"
