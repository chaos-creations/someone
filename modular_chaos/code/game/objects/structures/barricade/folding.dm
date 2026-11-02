/// A wired folding metal barricade, for the Human Defense Creator Panel
/obj/structure/barricade/plasteel/metal/wired

/obj/structure/barricade/plasteel/metal/wired/Initialize(mapload, mob/user)
	. = ..()
	can_wire = FALSE
	is_wired = TRUE
	climbable = FALSE
	update_icon()

/obj/structure/barricade/plasteel/metal/wired/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	flags_can_pass_front_temp &= ~PASS_FLAGS_UNWIRED
	flags_can_pass_behind_temp &= ~PASS_FLAGS_UNWIRED
