// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/// The PvE canteen food vendor: a tall autochef in place of the ColMarTech vendor, with the meals that exist here
/obj/structure/machinery/cm_vending/sorted/marine_food/autochef
	name = "\improper NestleCo AutoChef"
	desc = "An autochef food dispenser, capable of distributing food containing all the essential vitamins and nutrients anyone could ever need. Inedible-looking sludge is passed through a variety of heaters, re-shapers, and solidifiers before being artificially flavored to create something that looks and tastes mostly edible."
	icon = 'modular_chaos/icons/obj/structures/machinery/vending_32x64.dmi'
	icon_state = "food"
	hackable = FALSE

/obj/structure/machinery/cm_vending/sorted/marine_food/autochef/populate_product_list(scale)
	listed_products = list(
		list("MECHANICALLY PREPARED MEALS", -1, null, null),
		list("Menu 1: Chili & Cornbread", 15, /obj/item/reagent_container/food/snacks/mre_pack/meal1, VENDOR_ITEM_REGULAR),
		list("Menu 2: Ham & Potatoes", 15, /obj/item/reagent_container/food/snacks/mre_pack/meal2, VENDOR_ITEM_REGULAR),
		list("Menu 3: Spaghetti", 15, /obj/item/reagent_container/food/snacks/mre_pack/meal3, VENDOR_ITEM_REGULAR),
		list("Menu 4: Pizza", 15, /obj/item/reagent_container/food/snacks/mre_pack/meal4, VENDOR_ITEM_REGULAR),
		list("Menu 5: Chicken", 15, /obj/item/reagent_container/food/snacks/mre_pack/meal5, VENDOR_ITEM_REGULAR),
		list("Menu 6: Vegetarian Tofu", 15, /obj/item/reagent_container/food/snacks/mre_pack/meal6, VENDOR_ITEM_REGULAR),
		list("PREEMPTIVE ACTION BARS", -1, null, null),
		list("Protein Bar", 50, /obj/item/reagent_container/food/snacks/protein_pack, VENDOR_ITEM_REGULAR),
		list("CONTAINERS", -1, null, null),
		list("Canteen", 10, /obj/item/reagent_container/food/drinks/flask/canteen, VENDOR_ITEM_REGULAR),
		list("Metal Flask", 10, /obj/item/reagent_container/food/drinks/flask, VENDOR_ITEM_REGULAR),
		list("USCM Flask", 5, /obj/item/reagent_container/food/drinks/flask/marine, VENDOR_ITEM_REGULAR),
		list("W-Y Flask", 5, /obj/item/reagent_container/food/drinks/flask/weylandyutani, VENDOR_ITEM_REGULAR),
		list("Plastic Cup", 20, /obj/item/reagent_container/food/drinks/cup, VENDOR_ITEM_REGULAR),
	)
