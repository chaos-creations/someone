/**
 * M3-R recon armor of the FORECON platoon, from the cmss13-pve M3 armor system.
 *
 * Like the rest of that system it has no pockets: storage comes from an M3 webbing clipped on, and pauldrons,
 * vambraces, greaves, kneepads and paint go in their own accessory slots.
 */
/obj/item/clothing/suit/storage/marine/medium/rto/forecon
	name = "\improper M3-R pattern recon armor"
	desc = "A modified Colonial Marines M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. Issued mostly to recon units."
	icon = 'modular_chaos/icons/obj/items/clothing/suits/forecon.dmi'
	icon_state = "4"
	item_icons = list(
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/clothing/suits/forecon.dmi',
	)
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN|NO_NAME_OVERRIDE
	light_range = 5
	storage_slots = 0
	valid_accessory_slots = list(
		ACCESSORY_SLOT_MEDAL,
		ACCESSORY_SLOT_DECORARMOR,
		ACCESSORY_SLOT_DECORGROIN,
		ACCESSORY_SLOT_DECORSHIN,
		ACCESSORY_SLOT_DECORBRACER,
		ACCESSORY_SLOT_DECORNECK,
		ACCESSORY_SLOT_PAINT,
		ACCESSORY_SLOT_M3UTILITY,
		ACCESSORY_SLOT_PONCHO,
		ACCESSORY_SLOT_DECORKNEE,
	)
