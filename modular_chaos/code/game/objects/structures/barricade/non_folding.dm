/// A wired plasteel barricade, for the Human Defense Creator Panel and Fortify Room
/obj/structure/barricade/metal/plasteel/wired

/obj/structure/barricade/metal/plasteel/wired/Initialize(mapload, mob/user)
	. = ..()
	maxhealth += 50
	update_health(-50)
	can_wire = FALSE
	is_wired = TRUE
	climbable = FALSE
	update_icon()

/obj/structure/barricade/metal/plasteel/wired/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	flags_can_pass_front_temp &= ~PASS_FLAGS_UNWIRED
	flags_can_pass_behind_temp &= ~PASS_FLAGS_UNWIRED
