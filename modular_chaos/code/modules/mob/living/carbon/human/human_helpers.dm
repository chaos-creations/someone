/// Moves the human into the faction, with the faction group and ID card that friend-or-foe checks look at
/mob/living/carbon/human/proc/set_faction(new_faction)
	faction = new_faction
	faction_group = list(new_faction)

	var/obj/item/card/id/faction_tags = wear_id
	if(istype(faction_tags))
		faction_tags.faction = new_faction
		faction_tags.faction_group = faction_group

/// Deletes everything the human carries but its ID card
/mob/living/carbon/human/proc/strip_all()
	for(var/obj/item/current_item in src)
		if(istype(current_item, /obj/item/card/id))
			continue
		qdel(current_item)
	get_ai_brain()?.appraise_inventory(armor = TRUE)

/// Deletes the weapons, ammunition and explosives the human carries, anywhere in its gear. Zombie claws stay
/mob/living/carbon/human/proc/strip_weapons()
	for(var/obj/item/current_item in GetAllContents(3))
		if(current_item == src)
			continue
		if(istype(current_item, /obj/item/weapon/zombie_claws))
			continue
		if(!istype(current_item, /obj/item/ammo_magazine) && !istype(current_item, /obj/item/weapon) && !istype(current_item, /obj/item/explosive))
			continue

		var/obj/item/storage/item_storage = current_item.loc
		qdel(current_item)
		if(istype(item_storage))
			item_storage.update_icon()
	get_ai_brain()?.appraise_inventory(armor = TRUE)
