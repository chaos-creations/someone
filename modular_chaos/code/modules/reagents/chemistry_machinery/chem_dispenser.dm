/obj/structure/machinery/chem_dispenser/canteen
	name = "NestleCo AutoDrink"
	desc = "A NestleCo AutoDrink dispenser, capable of making a variety of drinks to consume from a mixture of water and instant flavoring juice and caffeine additives."
	icon = 'modular_chaos/icons/obj/structures/machinery/vending_32x64.dmi'
	icon_state = "drink"
	ui_title = "NestleCo AutoDrink Dispenser W-A3"
	req_skill = null
	req_skill_level = null
	accept_beaker_only = FALSE
	wrenchable = FALSE
	network = "Misc"
	dispensable_reagents = list(
		"water",
		"coffee",
		"cream",
		"tea",
		"milk",
		"soymilk",
		"orangejuice",
		"limejuice",
		"watermelonjuice",
		"tomatojuice",
		"carrotjuice",
		"berryjuice",
		"grapejuice",
		"lemonjuice",
	)

/obj/structure/machinery/chem_dispenser/canteen/update_icon()
	overlays.Cut()
	if(!beaker)
		return
	overlays += "+beaker"
	if(inoperable())
		return
	overlays += "+onlight"
