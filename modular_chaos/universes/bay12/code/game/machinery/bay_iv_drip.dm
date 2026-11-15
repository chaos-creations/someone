//IV drips of Baystation 12 (code/game/objects/structures/iv_drip.dm in the source)

/**
 * A Bay IV drip
 *
 * A CM IV drip (hooked up, switched between giving and taking blood, and fed from a beaker or blood pack, as there)
 * with the sprites of the source: the light that shows how full its bag is glows in the dark. It takes CM's containers
 * until the IV bags of the source are ported.
 */
/obj/structure/machinery/iv_drip/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/iv_drip.dmi'
	icon_state = "unhooked"
	base_pixel_x = 0
	base_pixel_y = 0

/obj/structure/machinery/iv_drip/bay/update_icon()
	icon_state = attached ? "hooked" : "unhooked"
	overlays.Cut()
	if(!beaker)
		return
	var/datum/reagents/reagents = beaker.reagents
	var/percent = beaker.volume ? floor(reagents.total_volume / beaker.volume * 100) : 0
	var/reagent_state
	var/light_state
	switch(percent)
		if(-INFINITY to 9)
			reagent_state = "reagent0"
			light_state = "light_low"
		if(10 to 24)
			reagent_state = "reagent10"
			light_state = "light_low"
		if(25 to 49)
			reagent_state = "reagent25"
			light_state = "light_mid"
		if(50 to 74)
			reagent_state = "reagent50"
			light_state = "light_mid"
		if(75 to 79)
			reagent_state = "reagent75"
			light_state = "light_full"
		if(80 to 90)
			reagent_state = "reagent80"
			light_state = "light_full"
		else
			reagent_state = "reagent100"
			light_state = "light_full"
	var/image/filling = image(icon, reagent_state)
	if(reagents.total_volume)
		filling.color = mix_color_from_reagents(reagents.reagent_list)
	overlays += filling
	overlays += image(icon, light_state)
	overlays += emissive_appearance(icon, light_state)
