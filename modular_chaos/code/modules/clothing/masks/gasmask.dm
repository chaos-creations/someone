// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/clothing/mask/gas/military
	icon = 'modular_chaos/icons/obj/items/clothing/masks.dmi'
	item_icons = list(
		WEAR_FACE = 'modular_chaos/icons/mob/humans/onmob/mask.dmi',
	)
	name = "\improper M5 gasmask"
	desc = "The standard service gas mask of the USCM as part of a modernization program meant to replace the need for MOPP gear."
	icon_state = "m5"
	item_state = "m5"
	flags_obj = OBJ_NO_HELMET_BAND|OBJ_IS_HELMET_GARB
	flags_inv_hide = HIDEEARS|HIDEFACE|HIDEALLHAIR

/obj/item/clothing/mask/gas/military/on_enter_storage(obj/item/storage/internal/helmet_internal_inventory)
	..()
	if(!istype(helmet_internal_inventory))
		return
	var/obj/item/clothing/head/helmet/helmet_item = helmet_internal_inventory.master_object

	if(!istype(helmet_item))
		return

	helmet_item.flags_inventory |= BLOCKGASEFFECT
	helmet_item.flags_inv_hide |= HIDEFACE

/obj/item/clothing/mask/gas/military/on_exit_storage(obj/item/storage/internal/helmet_internal_inventory)
	..()
	if(!istype(helmet_internal_inventory))
		return
	var/obj/item/clothing/head/helmet/helmet_item = helmet_internal_inventory.master_object

	if(!istype(helmet_item))
		return

	helmet_item.flags_inventory &= ~(BLOCKGASEFFECT)
	helmet_item.flags_inv_hide &= ~(HIDEFACE)
