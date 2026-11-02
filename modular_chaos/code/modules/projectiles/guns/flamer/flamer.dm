// Human AI counts its shots through COMSIG_MOB_FIRED_GUN, which the flamer's own Fire() does not send
/obj/item/weapon/gun/flamer/Fire(atom/target, mob/living/user, params, reflex)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(. == AUTOFIRE_CONTINUE)
		SEND_SIGNAL(user, COMSIG_MOB_FIRED_GUN, src)
