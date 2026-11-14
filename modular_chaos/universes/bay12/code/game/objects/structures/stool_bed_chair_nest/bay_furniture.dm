//Beds and chairs of Baystation 12 (code/game/objects/structures/stool_bed_chair_nest/ in the source)

/obj/structure/bed
	/// The Bay material of the frame, a material name until resolve_materials(), then the /material; null for CM beds and chairs
	var/material/material
	/// The Bay material it is padded with, a material name until resolve_materials(), then the /material; null for none
	var/material/padding_material
	/// The sprites a Bay bed or chair is drawn with from its materials in furniture.dmi; null for CM ones
	var/material_icon
	/// What its materials change of it: MATERIAL_ALTERATION_NAME, MATERIAL_ALTERATION_DESC and MATERIAL_ALTERATION_COLOR
	var/material_alteration = MATERIAL_ALTERATION_ALL

/// Turns the material names a Bay bed or chair is mapped with into the materials
/obj/structure/bed/proc/resolve_materials()
	if(istext(material))
		material = get_bay_material(material)
	if(istext(padding_material))
		padding_material = get_bay_material(padding_material)

/**
 * Draws a Bay bed or chair from its materials, and names it after them, as /obj/structure/bed/on_update_icon() does in
 * the source
 *
 * The frame takes the colour of its material and the padding that of its own.
 */
/obj/structure/bed/proc/update_material_icon()
	resolve_materials()
	icon_state = ""
	overlays.Cut()
	overlays += material_image(material_icon, material)
	if(padding_material)
		overlays += material_image("[material_icon]_padding", padding_material)
	if(material_alteration & MATERIAL_ALTERATION_NAME)
		name = "[padding_material ? padding_material.adjective_name : material.adjective_name] [initial(name)]"
	if(material_alteration & MATERIAL_ALTERATION_DESC)
		desc = "[initial(desc)] [padding_material ? "It's made of [material.use_name] and covered with [padding_material.use_name]." : "It's made of [material.use_name]."]"

/**
 * One layer of a Bay bed or chair, in the colour of a material if its materials colour it
 *
 * * state - the icon state of the layer
 * * colour_material - the material whose colour it takes
 * * layer - the layer to draw it on, that of the bed or chair unless given
 */
/obj/structure/bed/proc/material_image(state, material/colour_material, layer = FLOAT_LAYER)
	var/image/layer_image = image(icon, state, layer = layer)
	if(material_alteration & MATERIAL_ALTERATION_COLOR)
		layer_image.color = colour_material.icon_colour
	return layer_image

/**
 * A Bay bed
 *
 * A CM bed of a Bay material, padded with another, which give it its name and colours.
 */
/obj/structure/bed/bay
	desc = "This is used to lie in, sleep in or strap on."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/furniture.dmi'
	icon_state = "bed"
	material = DEFAULT_FURNITURE_MATERIAL
	material_icon = "bed"

/obj/structure/bed/bay/Initialize(mapload, ...)
	color = null
	. = ..()
	update_icon()

/obj/structure/bed/bay/update_icon()
	update_material_icon()

/// A Bay bed of aluminium padded with cloth
/obj/structure/bed/bay/padded
	padding_material = MATERIAL_CLOTH

/obj/structure/bed/bay/psych
	name = "psychiatrist's couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon_state = "psychbed"
	material = MATERIAL_WALNUT
	padding_material = MATERIAL_LEATHER_GENERIC
	material_icon = "psychbed"

/**
 * A Bay chair
 *
 * A CM chair of a Bay material, padded with another, which give it its name and colours; the back and armrests are
 * drawn over whoever sits in it, the armrests only then. It does not fold as CM chairs do.
 */
/obj/structure/bed/chair/bay
	desc = "You sit in this, either by will or force."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/furniture.dmi'
	icon_state = "chair_preview"
	color = "#666666"
	foldabletype = null
	material = DEFAULT_FURNITURE_MATERIAL
	material_icon = "chair"

/obj/structure/bed/chair/bay/Initialize(mapload, ...)
	color = null
	. = ..()
	update_icon()

/obj/structure/bed/chair/bay/update_icon()
	update_material_icon()
	overlays += material_image("[material_icon]_over", material, ABOVE_MOB_LAYER)
	if(padding_material)
		overlays += material_image("[material_icon]_padding_over", padding_material, ABOVE_MOB_LAYER)
	if(buckled_mob)
		overlays += material_image("[material_icon]_armrest", material, ABOVE_MOB_LAYER)
		if(padding_material)
			overlays += material_image("[material_icon]_padding_armrest", padding_material, ABOVE_MOB_LAYER)

/obj/structure/bed/chair/bay/afterbuckle(mob/buckled)
	. = ..()
	update_icon()

/obj/structure/bed/chair/bay/padded/red
	padding_material = MATERIAL_CARPET

/obj/structure/bed/chair/bay/padded/brown
	padding_material = MATERIAL_LEATHER_GENERIC

/obj/structure/bed/chair/bay/padded/teal
	padding_material = "teal"

/obj/structure/bed/chair/bay/padded/black
	padding_material = "black"

/obj/structure/bed/chair/bay/padded/green
	padding_material = "green"

/obj/structure/bed/chair/bay/padded/purple
	padding_material = "purple"

/obj/structure/bed/chair/bay/padded/blue
	padding_material = "blue"

/obj/structure/bed/chair/bay/padded/beige
	padding_material = "beige"

/obj/structure/bed/chair/bay/padded/lime
	padding_material = "lime"

/obj/structure/bed/chair/bay/padded/yellow
	padding_material = "yellow"

/obj/structure/bed/chair/bay/comfy
	name = "comfy chair"
	desc = "It's a chair. It looks comfy."
	icon_state = "comfychair_preview"
	material_icon = "comfychair"

/obj/structure/bed/chair/bay/comfy/brown
	padding_material = MATERIAL_LEATHER_GENERIC

/obj/structure/bed/chair/bay/comfy/red
	padding_material = MATERIAL_CARPET

/obj/structure/bed/chair/bay/comfy/teal
	padding_material = "teal"

/obj/structure/bed/chair/bay/comfy/black
	padding_material = "black"

/obj/structure/bed/chair/bay/comfy/green
	padding_material = "green"

/obj/structure/bed/chair/bay/comfy/purple
	padding_material = "purple"

/obj/structure/bed/chair/bay/comfy/blue
	padding_material = "blue"

/obj/structure/bed/chair/bay/comfy/beige
	padding_material = "beige"

/obj/structure/bed/chair/bay/comfy/lime
	padding_material = "lime"

/obj/structure/bed/chair/bay/comfy/yellow
	padding_material = "yellow"

/// A Bay captain chair, steel padded in blue, with its emblem over its back
/obj/structure/bed/chair/bay/comfy/captain
	name = "captain chair"
	desc = "It's a chair. Only for the highest ranked asses."
	icon_state = "capchair_preview"
	material = MATERIAL_STEEL
	padding_material = "blue"
	material_icon = "capchair"

/obj/structure/bed/chair/bay/comfy/captain/update_icon()
	..()
	overlays += image(icon, "[material_icon]_special", layer = ABOVE_MOB_LAYER)

/obj/structure/bed/chair/bay/armchair
	name = "armchair"
	desc = "It's an armchair. It looks comfy."
	icon_state = "armchair_preview"
	material_icon = "armchair"

/obj/structure/bed/chair/bay/armchair/brown
	padding_material = MATERIAL_LEATHER_GENERIC

/obj/structure/bed/chair/bay/armchair/red
	padding_material = MATERIAL_CARPET

/obj/structure/bed/chair/bay/armchair/teal
	padding_material = "teal"

/obj/structure/bed/chair/bay/armchair/black
	padding_material = "black"

/obj/structure/bed/chair/bay/armchair/green
	padding_material = "green"

/obj/structure/bed/chair/bay/armchair/purple
	padding_material = "purple"

/obj/structure/bed/chair/bay/armchair/blue
	padding_material = "blue"

/obj/structure/bed/chair/bay/armchair/beige
	padding_material = "beige"

/obj/structure/bed/chair/bay/armchair/lime
	padding_material = "lime"

/obj/structure/bed/chair/bay/armchair/yellow
	padding_material = "yellow"

/**
 * A Bay shuttle seat: a harness folds over whoever is strapped in, and it buckles with a clunk
 */
/obj/structure/bed/chair/bay/shuttle
	name = "shuttle seat"
	desc = "A comfortable, secure seat. It has a sturdy-looking buckling system for smoother flights."
	icon_state = "shuttle_chair_preview"
	material_icon = "shuttle_chair"
	buckling_sound = 'modular_chaos/universes/bay12/sound/effects/metal_close.ogg'

/obj/structure/bed/chair/bay/shuttle/update_icon()
	material_icon = buckled_mob ? "shuttle_chair-b" : "shuttle_chair"
	..()
	if(!buckled_mob)
		overlays += material_image("[material_icon]_special", material, ABOVE_MOB_LAYER)

/obj/structure/bed/chair/bay/shuttle/blue
	material = MATERIAL_STEEL
	padding_material = "blue"

/obj/structure/bed/chair/bay/shuttle/black
	material = MATERIAL_STEEL
	padding_material = "black"

/obj/structure/bed/chair/bay/shuttle/white
	material = MATERIAL_STEEL
	padding_material = MATERIAL_CLOTH

/**
 * A Bay wooden chair, which cannot be padded
 *
 * As in the source, it is tinted with its wood on top of its frame taking that colour, which darkens it.
 */
/obj/structure/bed/chair/bay/wood
	name = "classic chair"
	desc = "Old is never too old to not be in fashion."
	icon_state = "wooden_chair_preview"
	color = WOOD_COLOR_GENERIC
	material = BAY_MATERIAL_WOOD
	material_icon = "wooden_chair"

/obj/structure/bed/chair/bay/wood/Initialize(mapload, ...)
	. = ..()
	color = material.icon_colour

/obj/structure/bed/chair/bay/wood/mahogany
	color = WOOD_COLOR_RICH
	material = MATERIAL_MAHOGANY

/obj/structure/bed/chair/bay/wood/maple
	color = WOOD_COLOR_PALE
	material = MATERIAL_MAPLE

/obj/structure/bed/chair/bay/wood/ebony
	color = WOOD_COLOR_BLACK
	material = MATERIAL_EBONY

/obj/structure/bed/chair/bay/wood/walnut
	color = WOOD_COLOR_CHOCOLATE
	material = MATERIAL_WALNUT

/obj/structure/bed/chair/bay/wood/wings
	name = "winged chair"
	icon_state = "wooden_chair_wings_preview"
	material_icon = "wooden_chair_wings"

/obj/structure/bed/chair/bay/wood/wings/mahogany
	color = WOOD_COLOR_RICH
	material = MATERIAL_MAHOGANY

/obj/structure/bed/chair/bay/wood/wings/maple
	color = WOOD_COLOR_PALE
	material = MATERIAL_MAPLE

/obj/structure/bed/chair/bay/wood/wings/ebony
	color = WOOD_COLOR_BLACK
	material = MATERIAL_EBONY

/obj/structure/bed/chair/bay/wood/wings/walnut
	color = WOOD_COLOR_CHOCOLATE
	material = MATERIAL_WALNUT

/**
 * A Bay pew, a long bench that does not turn, tinted with its wood as wooden chairs are
 */
/obj/structure/bed/chair/bay/pew
	name = "pew"
	desc = "A long, simple bench with a backboard, commonly found in places of worship, courtrooms and so on. Not known for being particularly comfortable."
	icon_state = "pew"
	color = WOOD_COLOR_GENERIC
	material = BAY_MATERIAL_WOOD
	material_icon = "pew"
	can_rotate = FALSE

/obj/structure/bed/chair/bay/pew/Initialize(mapload, ...)
	. = ..()
	color = material.icon_colour

/obj/structure/bed/chair/bay/pew/left
	icon_state = "pew_left"
	material_icon = "pew_left"

/obj/structure/bed/chair/bay/pew/mahogany
	color = WOOD_COLOR_RICH
	material = MATERIAL_MAHOGANY

/obj/structure/bed/chair/bay/pew/left/mahogany
	color = WOOD_COLOR_RICH
	material = MATERIAL_MAHOGANY

/**
 * A Bay office chair: a CM one, which rolls and crashes as those do, of a Bay material padded with another
 */
/obj/structure/bed/chair/office/bay
	name = "office chair"
	desc = "You sit in this, either by will or force."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/furniture.dmi'
	icon_state = "officechair_preview"
	material = DEFAULT_FURNITURE_MATERIAL
	material_icon = "officechair"

/obj/structure/bed/chair/office/bay/Initialize(mapload, ...)
	color = null
	. = ..()
	update_icon()

/obj/structure/bed/chair/office/bay/update_icon()
	update_material_icon()
	overlays += material_image("[material_icon]_over", material, ABOVE_MOB_LAYER)
	if(padding_material)
		overlays += material_image("[material_icon]_padding_over", padding_material, ABOVE_MOB_LAYER)
	if(buckled_mob)
		overlays += material_image("[material_icon]_armrest", material, ABOVE_MOB_LAYER)
		if(padding_material)
			overlays += material_image("[material_icon]_padding_armrest", padding_material, ABOVE_MOB_LAYER)

/obj/structure/bed/chair/office/bay/afterbuckle(mob/buckled)
	. = ..()
	update_icon()

/obj/structure/bed/chair/office/bay/light
	padding_material = MATERIAL_CLOTH

/obj/structure/bed/chair/office/bay/dark
	padding_material = "black"

/obj/structure/bed/chair/office/bay/comfy
	name = "comfy office chair"
	desc = "It's an office chair. It looks comfy."
	icon_state = "comfyofficechair_preview"
	material_icon = "comfyofficechair"

/obj/structure/bed/chair/office/bay/comfy/brown
	padding_material = MATERIAL_LEATHER_GENERIC

/obj/structure/bed/chair/office/bay/comfy/red
	padding_material = MATERIAL_CARPET

/obj/structure/bed/chair/office/bay/comfy/teal
	padding_material = "teal"

/obj/structure/bed/chair/office/bay/comfy/black
	padding_material = "black"

/obj/structure/bed/chair/office/bay/comfy/green
	padding_material = "green"

/obj/structure/bed/chair/office/bay/comfy/purple
	padding_material = "purple"

/obj/structure/bed/chair/office/bay/comfy/blue
	padding_material = "blue"

/obj/structure/bed/chair/office/bay/comfy/beige
	padding_material = "beige"

/obj/structure/bed/chair/office/bay/comfy/lime
	padding_material = "lime"

/obj/structure/bed/chair/office/bay/comfy/yellow
	padding_material = "yellow"

/**
 * A Bay wheelchair: a CM one, driven and pushed as those are, with the sprite of the source and its wheels over whoever
 * sits in it
 */
/obj/structure/bed/chair/wheelchair/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/furniture.dmi'
	icon_state = "wheelchair"

// The CM one draws its wheels from its own file as it turns
/obj/structure/bed/chair/wheelchair/bay/handle_rotation()
	overlays.Cut()
	overlays += image(icon, "w_overlay", layer = ABOVE_MOB_LAYER, dir = dir)
	if(buckled_mob)
		buckled_mob.setDir(dir)
