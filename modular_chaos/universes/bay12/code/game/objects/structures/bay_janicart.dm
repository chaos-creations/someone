//Janitorial carts of Baystation 12 (code/game/objects/structures/janicart.dm in the source)

/**
 * A Bay janitorial cart
 *
 * A CM janitorial cart (its bag, mop, spray, light replacer, signs and bucket of water as there) with the sprites of
 * the source, which draw the water into the cart itself rather than as a bucket on it.
 */
/obj/structure/janitorialcart/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/janitorial_cart.dmi'

/obj/structure/janitorialcart/bay/update_icon()
	overlays.Cut()
	if(mybag)
		overlays += "cart_garbage"
	if(mymop)
		overlays += "cart_mop"
	if(myspray)
		overlays += "cart_spray"
	if(myreplacer)
		overlays += "cart_replacer"
	if(signs)
		overlays += "cart_sign[signs]"
