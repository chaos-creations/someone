/obj/structure/magazine_box/update_icon()
	CAN_BE_REDEFINED(TRUE)
	// A deployed box looks like the box it was unfolded from, also when that one uses icons other than upstream's
	if(item_box)
		icon = item_box.icon
		text_markings_icon = item_box.text_markings_icon
		magazines_icon = item_box.magazines_icon
		handfuls_icon = item_box.handfuls_icon
		flames_icon = item_box.flames_icon
	return ..()
