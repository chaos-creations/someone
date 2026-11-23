// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/reagent_container/food/snacks/cheesewedge/mature/kraft
	icon = 'modular_chaos/icons/obj/items/food.dmi'
	name = "packaged cheese-product slice"
	desc = "A slice what legally has to be called 'cheese-product'. Not the nicest thing to eat, but can work in recipes in place of proper cheese. Ensure wrapper removal before consumption."
	icon_state = "kruft_single"
	bitesize = 2
	package = TRUE

/obj/item/reagent_container/food/snacks/cheesewedge/mature/kraft/Initialize()
	. = ..()
	reagents.add_reagent("cheese", 5)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("plasticide", 2)

/obj/item/reagent_container/food/snacks/cheesewedge/mature/kraft/attack_self(mob/user)
	..()

	if(package)
		playsound(src.loc,'sound/effects/pageturn2.ogg', 15, 1)
		to_chat(user, SPAN_NOTICE("You pull the wrapping off of the 'cheese' slice!"))
		reagents.remove_reagent("plasticide", 2)
		package = FALSE
		icon_state = "kruft_single-o"
