/mob/living/carbon/human/u_equip(obj/item/I, atom/newloc, nomoveupdate, force)
	CAN_BE_REDEFINED(TRUE)
	// The slot is looked up before the item leaves it
	var/slot = get_worn_slot_bitflag(I)
	. = ..()
	if(!. || !I)
		return FALSE

	SEND_SIGNAL(src, COMSIG_HUMAN_UNEQUIPPED_ITEM, I, slot)

/**
 * Returns the SLOT_* bitflag of the slot `item` is worn in, for COMSIG_HUMAN_UNEQUIPPED_ITEM.
 *
 * Returns null if the item is not worn (held items included).
 */
/mob/living/carbon/human/proc/get_worn_slot_bitflag(obj/item/item)
	if(!item)
		return null
	if(item == back)
		return SLOT_BACK
	if(item == wear_mask)
		return SLOT_FACE
	if(item == wear_suit)
		return SLOT_OCLOTHING
	if(item == w_uniform)
		return SLOT_ICLOTHING
	if(item == head)
		return SLOT_HEAD
	if(item == gloves)
		return SLOT_HANDS
	if(item == glasses)
		return SLOT_EYES
	if(item == wear_l_ear || item == wear_r_ear)
		return SLOT_EAR
	if(item == shoes)
		return SLOT_FEET
	if(item == belt)
		return SLOT_WAIST
	if(item == wear_id)
		return SLOT_ID
	if(item == r_store || item == l_store)
		return SLOT_STORE
	if(item == s_store)
		return SLOT_SUIT_STORE
	return null
