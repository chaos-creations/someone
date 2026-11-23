// Lockers of the Golden Arrow class ships (USS Rover), ported from cmss13-pve.
// Unlike vehicle lockers, anyone with a job can open them: role_restriction is set to every job title.

/obj/structure/vehicle_locker/cabinet
	name = "cabinet"
	desc = "A cabinet securely fastened to the wall, capable of storing a variety of smaller items."
	icon = 'modular_chaos/icons/obj/structures/props/almayer_props.dmi'
	icon_state = "cabinet"
	layer = ABOVE_MOB_LAYER

/obj/structure/vehicle_locker/cabinet/Initialize()
	. = ..()
	role_restriction = GLOB.RoleAuthority.roles_by_name
	container.storage_slots = 12
	container.max_w_class = SIZE_TINY
	container.bypass_w_limit = list(
		/obj/item/reagent_container/glass,
		/obj/item/reagent_container/food,
		/obj/item/tool/kitchen,
	)

/obj/structure/vehicle_locker/cabinet/flip
	icon_state = "cabinet2"

/obj/structure/vehicle_locker/cabinet/cups
	name = "cups cabinet"

/obj/structure/vehicle_locker/cabinet/cups/Initialize()
	. = ..()
	for(var/i in 1 to 12)
		new /obj/item/reagent_container/food/drinks/cup(container)

/obj/structure/vehicle_locker/cabinet/cups/flip
	icon_state = "cabinet2"

/obj/structure/vehicle_locker/cabinet/utensils
	name = "utensils cabinet"

/obj/structure/vehicle_locker/cabinet/utensils/Initialize()
	. = ..()
	for(var/i in 1 to 12)
		new /obj/item/tool/kitchen/utensil/fork(container)

/obj/structure/vehicle_locker/cabinet/utensils/flip
	icon_state = "cabinet2"
