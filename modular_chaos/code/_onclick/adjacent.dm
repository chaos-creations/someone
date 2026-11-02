/obj/item/Adjacent(atom/neighbor, recurse = 1)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(.)
		return .
	// Storage can be opened on someone else through the strip menu, so what a human wears, carries in worn storage
	// or keeps in the pockets and webbing of worn clothing is as close as the human is
	if(ishuman(loc))
		return loc.Adjacent(neighbor)
	if(!isitem(loc))
		return FALSE
	if(ishuman(loc.loc))
		return loc.loc.Adjacent(neighbor)
	if(istype(loc, /obj/item/storage/internal) && isitem(loc.loc) && ishuman(loc.loc.loc))
		return loc.loc.loc.Adjacent(neighbor)
	return FALSE
