/obj/item/use_spritesheet(bodytype, slot, icon_state)
	CAN_BE_REDEFINED(TRUE)
	// Upstream draws nothing for a state the sheet doesn't have (except on the head and the suit slot);
	// a species with sprite_sheet_fallback is drawn with the human sprite instead
	var/datum/species/species = GLOB.all_species[bodytype]
	if(species?.sprite_sheet_fallback && LAZYISIN(sprite_sheets, bodytype) && slot != WEAR_R_HAND && slot != WEAR_L_HAND)
		return (icon_state in icon_states(sprite_sheets[bodytype]))
	return ..()
