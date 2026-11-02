// The guns we fired keep their fire delay group cooldown in fire_delay_next_fire, which only firing again prunes.
// A deleted gun held there and its deleted user then keep each other from being garbage collected.
/mob/Destroy()
	CAN_BE_REDEFINED(TRUE)
	fire_delay_next_fire = null
	return ..()
