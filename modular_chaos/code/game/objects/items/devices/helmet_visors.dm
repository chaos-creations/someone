// Without a client there is no optics zoom to check, and the upstream check reads client.view, which runtimes for human AI
/obj/item/device/helmet_visor/night_vision/can_toggle(mob/living/carbon/human/user)
	CAN_BE_REDEFINED(TRUE)
	if(user.client)
		return ..()

	if(!power_cell.use(power_use))
		to_chat(user, SPAN_NOTICE("Your [src] is out of power! You'll need to recharge it."))
		return FALSE

	return TRUE
