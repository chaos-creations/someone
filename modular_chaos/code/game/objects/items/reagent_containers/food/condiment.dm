// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/reagent_container/food/condiment/juice
	static_container_icon = TRUE
	icon = 'modular_chaos/icons/obj/items/food.dmi'
	name = "Juice Packet"
	desc = "A small packet of dehydrated fruit-juice powder. Mix with water for a 'tasty' beverage. This one appears to be missing the label indicating what flavor it is however."
	w_class = SIZE_TINY
	icon_state = "bjpowder"
	amount_per_transfer_from_this = 1
	volume = 6

/obj/item/reagent_container/food/condiment/juice/egg
	icon = 'modular_chaos/icons/obj/items/food.dmi'
	name = "Powdered Egg Packet"
	desc = "A small packet of dehydrated egg-whites and egg-yolk powder. Mix with water for a passable alternative to the real deal."
	icon_state = "eggpowder"
	volume = 12
	w_class = SIZE_SMALL

/obj/item/reagent_container/food/condiment/juice/egg/Initialize()
	. = ..()
	reagents.add_reagent("dehydrated_egg_powder", 12)

/obj/item/reagent_container/food/condiment/juice/milk
	icon = 'modular_chaos/icons/obj/items/food.dmi'
	name = "Dehydrated Milk Packet"
	desc = "A small packet of dehydrated milk powder. Mix with water for a passable alternative to actual milk."
	icon_state = "milkpowder"
	amount_per_transfer_from_this = 1
	volume = 12
	w_class = SIZE_SMALL

/obj/item/reagent_container/food/condiment/juice/milk/Initialize()
	. = ..()
	reagents.add_reagent("dehydrated_milk_powder", 12)
