/obj/structure/bed/chair/Initialize()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	// A chair shifted on the map (two seats on one tile and the like) seats its mob where it is drawn, as vehicle seats do
	buckling_x += pixel_x
	buckling_y += pixel_y

/// Passenger seat that starts folded up
/obj/structure/bed/chair/dropship/passenger/folded

/obj/structure/bed/chair/dropship/passenger/folded/Initialize()
	. = ..()
	fold_down()
