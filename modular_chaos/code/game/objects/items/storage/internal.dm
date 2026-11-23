/obj/item/storage/internal/handle_attack_hand(mob/living/user, mods)
	CAN_BE_REDEFINED(TRUE)
	// Pockets with no slots at all (the PvE M3 armor of the USS Rover) are never opened:
	// show_to() takes storage_slots = 0 for "no slot limit" and would put an uncreated screen object on the client.
	if(!isnull(storage_slots) && !storage_slots)
		return TRUE
	return ..()
