//Tanks and dispensers of reagents of Baystation 12 (code/modules/reagents/reagent_dispenser.dm in the source)
// Bay beer kegs are CM's, which have the same sprite.

/**
 * A Bay water tank
 *
 * A CM water tank (filling and emptying containers as there, with CM's amount of water) with the sprite of the source,
 * which shows neither how full it is nor which way it transfers. As CM has no fluids, a wrench does not open its tap
 * to flood the floor.
 */
/obj/structure/reagent_dispensers/tank/water/bay
	desc = "A tank containing water."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/liquid_tanks.dmi'

/obj/structure/reagent_dispensers/tank/water/bay/update_icon()
	overlays.Cut()

/**
 * A Bay fuel tank
 *
 * A CM fuel tank (rigged, leaked, set off and blown up as there) with the sprite of the source, which shows the device
 * rigged to it as the source does.
 */
/obj/structure/reagent_dispensers/tank/fuel/bay
	desc = "A tank containing welding fuel."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/liquid_tanks.dmi'

/obj/structure/reagent_dispensers/tank/fuel/bay/update_icon(cut_overlays = TRUE)
	overlays.Cut()
	if(!rig)
		return
	var/mutable_appearance/rig_overlay = new(rig)
	rig_overlay.pixel_x = 6
	rig_overlay.pixel_y = 1
	rig_overlay.layer = FLOAT_LAYER
	rig_overlay.plane = FLOAT_PLANE
	overlays += rig_overlay

/// A Bay pepper spray refiller, a CM one with the sprite of the source
/obj/structure/reagent_dispensers/peppertank/bay
	desc = "Refills pepper spray canisters."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/chemical_dispensers.dmi'

/// A Bay dispenser of sulphuric acid on a wall, which CM has none like
/obj/structure/reagent_dispensers/bay_acid
	name = "sulphuric acid dispenser"
	desc = "A dispenser of acid for industrial processes."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/chemical_dispensers.dmi'
	icon_state = "acidtank"
	anchored = TRUE
	density = FALSE
	wrenchable = FALSE
	drag_delay = 3
	chemical = "sulphuric acid"

/**
 * A Bay water cooler
 *
 * A CM water cooler with the sprite of the source, which hands out paper cups as the source's does, and has no
 * Weyland-Yutani label.
 */
/obj/structure/reagent_dispensers/water_cooler/bay
	desc = "A machine that dispenses cool water to drink."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/vending.dmi'
	/// How many cups it has left
	var/cups = 12
	/// What it hands out
	var/cup_type = /obj/item/reagent_container/food/drinks/sillycup

/obj/structure/reagent_dispensers/water_cooler/bay/Initialize()
	. = ..()
	RemoveElement(/datum/element/corp_label/wy)

/obj/structure/reagent_dispensers/water_cooler/bay/attack_hand(mob/user)
	if(cups <= 0)
		to_chat(user, SPAN_WARNING("[src]'s cup dispenser is empty."))
		return
	var/obj/item/cup = new cup_type(loc)
	user.put_in_active_hand(cup)
	cups--
	user.visible_message(SPAN_NOTICE("[user] grabs a paper cup from [src]."), SPAN_NOTICE("You grab a paper cup from [src]'s cup compartment."))

/obj/structure/reagent_dispensers/water_cooler/bay/attackby(obj/item/hit_item, mob/living/user)
	if(istype(hit_item, /obj/item/reagent_container))
		flick("[icon_state]-vend", src)
	return ..()
