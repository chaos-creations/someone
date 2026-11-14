//Curtains of Baystation 12 (code/game/objects/structures/curtains.dm in the source)

/**
 * A Bay curtain
 *
 * A CM curtain (drawn by hand, torn down by bullets and xenos, as there) with the sprites of the source, which a
 * colour tints.
 */
/obj/structure/curtain/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/props/curtain.dmi'
	icon_state = "closed"

/obj/structure/curtain/bay/toggle()
	open = !open
	set_opacity(!open)
	if(open)
		icon_state = "open"
		layer = OBJ_LAYER
	else
		icon_state = "closed"
		layer = ABOVE_MOB_LAYER

/obj/structure/curtain/bay/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/bay/medical
	name = "plastic curtain"
	color = "#b8f5e3"
	alpha = 200

/// A Bay curtain that starts drawn back
/obj/structure/curtain/bay/open
	icon_state = "open"
	layer = OBJ_LAYER
	opacity = FALSE
	open = TRUE

/obj/structure/curtain/bay/open/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/bay/open/privacy
	name = "privacy curtain"
	color = "#b8f5e3"

/obj/structure/curtain/bay/open/shower
	name = "shower curtain"
	color = "#acd1e9"
	alpha = 200

/obj/structure/curtain/bay/open/shower/engineering
	color = "#ffa500"

/obj/structure/curtain/bay/open/shower/security
	color = "#aa0000"
