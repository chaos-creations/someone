/**
 * Combat gloves of the Lordanian Sovereign Systems, from Proxi-BoS-Bay12 (maps/castelnau/bos/items/clothing/mil/lss/lordania-hands.dm)
 *
 * Thick duty gloves there (/obj/item/clothing/gloves/thick/duty), with half their armor, see
 * modular_chaos/universes/bay12/code/modules/clothing/under/vox.dm.
 */
/obj/item/clothing/gloves/lordania
	name = "combat gloves"
	desc = "These black gloves are made from durable synthetic materials."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/gloves/gloves_by_faction/lordania.dmi'
	icon_state = "marcombat"
	item_icons = list(
		WEAR_HANDS = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/hands/hands_by_faction/lordania.dmi',
	)
	siemens_coefficient = 0.5
	flags_cold_protection = BODY_FLAG_HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROT
	flags_armor_protection = BODY_FLAG_HANDS
	armor_melee = CLOTHING_ARMOR_VERYLOW
	armor_bullet = CLOTHING_ARMOR_VERYLOW
	armor_laser = CLOTHING_ARMOR_VERYLOW
