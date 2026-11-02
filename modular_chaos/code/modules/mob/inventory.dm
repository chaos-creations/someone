/mob/drop_inv_item_to_loc(obj/item/I, atom/newloc, nomoveupdate, force)
	CAN_BE_REDEFINED(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_DROP_ITEM, I)
	return ..()

/mob/drop_inv_item_on_ground(obj/item/I, nomoveupdate, force)
	CAN_BE_REDEFINED(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_DROP_ITEM, I)
	return ..()
