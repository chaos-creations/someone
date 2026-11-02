/datum/strippable_item/mob_item_slot/jumpsuit/get_storage(atom/source)
	var/obj/item/clothing/under/uniform = get_item(source)
	if(!istype(uniform))
		return null
	var/obj/item/clothing/accessory/storage/storage_accessory = locate() in uniform.accessories
	return storage_accessory?.hold

/datum/strippable_item/mob_item_slot/suit/get_storage(atom/source)
	var/obj/item/clothing/suit/suit = get_item(source)
	if(!istype(suit))
		return null
	if(istype(suit, /obj/item/clothing/suit/storage))
		var/obj/item/clothing/suit/storage/storage_suit = suit
		return storage_suit.pockets
	var/obj/item/clothing/accessory/storage/storage_accessory = locate() in suit.accessories
	return storage_accessory?.hold
