// Uniforms of the Lordanian Sovereign Systems, from Proxi-BoS-Bay12 (maps/castelnau/bos/items/clothing/mil/lss/lordania-under.dm).
// Their armor is half of the source's, see modular_chaos/universes/bay12/code/modules/clothing/under/vox.dm. The
// department insignia the source pins on them aren't ported: they have no sprites for the inventory.

/obj/item/clothing/under/lordania
	name = "lordania uniform parent object"
	desc = "You shouldn't be seeing this."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/uniforms/uniforms_by_faction/lordania.dmi'
	item_icons = list(
		WEAR_BODY = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/uniforms/uniforms_by_faction/lordania.dmi',
	)
	siemens_coefficient = 0.8

/obj/item/clothing/under/lordania/utility
	name = "marine urban utility uniform"
	desc = "The utility uniform of the LSS Marine Corps, made from durable material."
	icon_state = "greyutility"
	worn_state = "greyutility_s"
	armor_melee = CLOTHING_ARMOR_VERYLOW
	armor_energy = CLOTHING_ARMOR_VERYLOW

/obj/item/clothing/under/lordania/utility/green
	name = "marine utility uniform"
	desc = "A green version of the LSS Marine utility uniform, made from durable material."
	icon_state = "greenutility"
	worn_state = "greenutility_s"
