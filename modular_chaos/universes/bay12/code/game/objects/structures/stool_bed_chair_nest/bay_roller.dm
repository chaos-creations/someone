//Roller beds and their racks of Baystation 12 (code/game/objects/structures/roller_bed.dm and roller_rack.dm in the source)

/**
 * A Bay roller bed
 *
 * A CM roller bed (buckling, carrying body bags and folding up as there) with the sprites of the source. The IV bag
 * the source can hang on it comes with the IV bags of the source.
 */
/obj/structure/bed/roller/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/rollerbed.dmi'
	buckling_y = 6
	foldabletype = /obj/item/roller/bay

/// A Bay roller bed folded up
/obj/item/roller/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/rollerbed.dmi'
	rollertype = /obj/structure/bed/roller/bay

/**
 * A Bay rack of folded roller beds
 *
 * Holds up to four of them, taken out by hand and put back with the bed; a welder takes the empty rack apart into
 * metal. It is made of Bay plastic, whose colour and opacity it is drawn in.
 */
/obj/structure/bay_roller_rack
	name = "roller bed rack"
	desc = "A standing rack for holding collapsed roller beds."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/rollerbedrack.dmi'
	icon_state = "rack_base"
	anchored = TRUE
	density = FALSE
	wrenchable = TRUE
	/// The most beds it holds
	var/max_beds = 4
	/// How many beds it starts with
	var/initial_beds = 0
	/// The beds it holds, the last one taken out first
	var/list/obj/item/roller/bay/beds = list()
	/// The name of the Bay material it is made of
	var/material = MATERIAL_PLASTIC

/obj/structure/bay_roller_rack/Initialize(mapload, ...)
	. = ..()
	for(var/i in 1 to clamp(initial_beds, 0, max_beds))
		beds += new /obj/item/roller/bay(src)
	update_icon()

/obj/structure/bay_roller_rack/Destroy()
	QDEL_LIST(beds)
	return ..()

/obj/structure/bay_roller_rack/update_icon()
	icon_state = "blank"
	overlays.Cut()
	var/material/rack_material = get_bay_material(material)
	var/image/rack_base = image(icon, "rack_base")
	rack_base.color = rack_material.icon_colour
	rack_base.alpha = 255 * rack_material.opacity
	overlays += rack_base
	for(var/i in 1 to min(length(beds), max_beds))
		overlays += image(icon, "bed_[i]")
		var/image/rack = image(icon, "rack_[i]")
		rack.color = rack_material.icon_colour
		rack.alpha = 255 * rack_material.opacity
		overlays += rack

/obj/structure/bay_roller_rack/get_examine_text(mob/user)
	. = ..()
	. += "It holds [length(beds)] beds."

/obj/structure/bay_roller_rack/attack_hand(mob/user)
	if(!length(beds))
		to_chat(user, SPAN_NOTICE("The rack is empty."))
		return
	var/obj/item/roller/bay/bed = beds[length(beds)]
	beds -= bed
	user.put_in_hands(bed)
	to_chat(user, SPAN_NOTICE("You retrieve [bed] from the rack."))
	update_icon()

/obj/structure/bay_roller_rack/attackby(obj/item/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/roller/bay))
		if(length(beds) >= max_beds)
			to_chat(user, SPAN_NOTICE("The rack has no space for [attacking_item]."))
			return
		if(!user.drop_inv_item_to_loc(attacking_item, src))
			return
		beds += attacking_item
		to_chat(user, SPAN_NOTICE("You place [attacking_item] on the rack."))
		update_icon()
		return
	if(iswelder(attacking_item))
		if(length(beds))
			to_chat(user, SPAN_WARNING("[src] cannot be dismantled while it's holding beds."))
			return
		var/obj/item/tool/weldingtool/welder = attacking_item
		if(!welder.isOn())
			return
		user.visible_message(SPAN_NOTICE("[user] starts to dismantle [src] with \a [welder]."), SPAN_NOTICE("You start to dismantle [src] with [welder]."))
		if(!do_after(user, 2 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src) || length(beds))
			return
		if(!welder.remove_fuel(1, user))
			return
		playsound(loc, 'sound/items/Welder2.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] cleanly dismantles [src] with \a [welder]."), SPAN_NOTICE("You cleanly dismantle [src] with [welder]."))
		deconstruct(TRUE)
		return
	return ..()

// Metal of CM until the materials of the source have stacks
/obj/structure/bay_roller_rack/deconstruct(disassembled = TRUE)
	if(disassembled)
		new /obj/item/stack/sheet/metal(loc, 2)
	return ..()
