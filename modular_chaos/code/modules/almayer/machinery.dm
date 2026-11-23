// Props of the Golden Arrow class ships (USS Rover), ported from cmss13-pve

/obj/structure/machinery/prop/almayer/computer/PC/large
	icon = 'modular_chaos/icons/obj/structures/machinery/computer.dmi'
	icon_state = "largecomp"

/obj/structure/machinery/prop/almayer/computer/PC/large/dark
	icon_state = "largecomp_dark"

/// Map table big enough to put things on
/obj/structure/machinery/prop/almayer/CICmap/table
	name = "map table"
	desc = "A large flat map table used for planning operations. It's large enough it can even be used as a proper table."
	icon = 'modular_chaos/icons/obj/structures/props/maptable.dmi'
	icon_state = "v_maptable1"
	layer = TABLE_LAYER
	light_system = STATIC_LIGHT
	light_color = "#DAE2FF"
	light_power = 1
	light_range = 2.5

/obj/structure/machinery/prop/almayer/CICmap/table/attackby(obj/item/attacking_item, mob/user, click_data)
	if(!user.drop_inv_item_to_loc(attacking_item, loc))
		return

	auto_align(attacking_item, click_data)
	user.next_move = world.time + 2
	return TRUE

/**
 * Puts an item where it was clicked on the table, like tables do.
 * * new_item - item put on the table
 * * click_data - click params of the click that put it
 */
/obj/structure/machinery/prop/almayer/CICmap/table/proc/auto_align(obj/item/new_item, click_data)
	if(!new_item.center_of_mass) // Clothing, material stacks, generally items with large sprites where exact placement would be unhandy.
		new_item.pixel_x = rand(-new_item.randpixel, new_item.randpixel)
		new_item.pixel_y = rand(-new_item.randpixel, new_item.randpixel)
		new_item.pixel_z = 0
		return

	if(!click_data)
		return

	if(!click_data[ICON_X] || !click_data[ICON_Y])
		return

	// Calculation to apply new pixelshift.
	var/mouse_x = text2num(click_data[ICON_X])-1 // Ranging from 0 to 31
	var/mouse_y = text2num(click_data[ICON_Y])-1

	var/cell_x = clamp(floor(mouse_x/CELLSIZE), 0, CELLS-1) // Ranging from 0 to CELLS-1
	var/cell_y = clamp(floor(mouse_y/CELLSIZE), 0, CELLS-1)

	var/list/center = cached_key_number_decode(new_item.center_of_mass)

	new_item.pixel_x = (CELLSIZE * (cell_x + 0.5)) - center["x"]
	new_item.pixel_y = (CELLSIZE * (cell_y + 0.5)) - center["y"]
	new_item.pixel_z = 0

/obj/structure/machinery/prop/almayer/CICmap/table/update_icon()
	..()
	overlays.Cut()
	if(stat & NOPOWER)
		return
	overlays += emissive_appearance(icon, "[icon_state]_e")
	overlays += mutable_appearance(icon, "[icon_state]_e")

/// One tile of a map table built from several
/obj/structure/machinery/prop/almayer/CICmap/table/segment
	icon_state = "v_maptable1"

/obj/structure/machinery/prop/almayer/CICmap/table/segment/one
	icon_state = "v_maptable1"

/obj/structure/machinery/prop/almayer/CICmap/table/segment/two
	icon_state = "v_maptable2"

/obj/structure/machinery/prop/almayer/CICmap/table/segment/three
	icon_state = "v_maptable3"

/obj/structure/machinery/prop/almayer/CICmap/table/segment/four
	icon_state = "v_maptable4"

/obj/structure/machinery/prop/almayer/CICmap/table/segment/five
	icon_state = "v_maptable5"

/obj/structure/machinery/prop/almayer/CICmap/table/segment/six
	icon_state = "v_maptable6"

/obj/structure/prop/almayer/sadar_decoration
	name = "\improper Spent M83A2 SADAR"
	desc = "A spent M83A2 tube. It's been kept as a trophy after a lucky tank kill nearly a thousand meters out. Someone has engraved a single tally-mark on the side to begin recording a kill-count."
	icon = 'modular_chaos/icons/obj/structures/props/almayer_props.dmi'
	icon_state = "sadar_decoration"
	density = FALSE

/obj/structure/prop/almayer/whiteboard
	name = "\improper whiteboard"
	desc = "A blank white surface where thoughts turn to plans. It's blank, all of the markers having dried out from the constant inappropriate drawings."
	icon = 'modular_chaos/icons/obj/structures/props/almayer_props64.dmi'
	icon_state = "whiteboard"
	bound_width = 64
