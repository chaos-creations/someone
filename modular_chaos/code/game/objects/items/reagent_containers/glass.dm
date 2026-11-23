// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/reagent_container/glass/beaker/vial/kilodermlipo
	name = "vial (temperature stablization)"
	desc = "Contains leporazine - used to stabilize body temperature, kelotane and dermaline - used to rapidly heal burns. Filled in a 1:2:3 ratio."

/obj/item/reagent_container/glass/beaker/vial/kilodermlipo/Initialize()
	. = ..()
	reagents.add_reagent("leporazine", 5)
	reagents.add_reagent("kelotane", 10)
	reagents.add_reagent("dermaline", 15)
	update_icon()
