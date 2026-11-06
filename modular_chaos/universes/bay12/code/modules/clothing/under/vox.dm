// Vox clothing, from Baystation 12 (code/modules/clothing/spacesuits/alien.dm) and its BoS layer (code/bos/modules/clothing/vox/).
// Their armor is half of Baystation 12's, rounded to the nearest CLOTHING_ARMOR_*: armor there is weighed against
// armor penetration, so its values run about twice as high as upstream's.

/obj/item/clothing/under/vox
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/uniforms_bos.dmi'
	has_sensor = UNIFORM_NO_SENSORS
	species_restricted = list(SPECIES_VOX)
	armor_melee = CLOTHING_ARMOR_VERYLOW
	armor_bullet = CLOTHING_ARMOR_VERYLOW
	armor_laser = CLOTHING_ARMOR_VERYLOW

/obj/item/clothing/under/vox/vox_casual
	name = "alien medical clothing"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/uniforms/uniforms.dmi'
	icon_state = "vox-casual-1"
	item_state = "vox-casual-1"
	item_state_slots = list(WEAR_BODY = "vox-casual-1_s")
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_laser = CLOTHING_ARMOR_NONE
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH

/obj/item/clothing/under/vox/vox_robes
	name = "alien combat robe"
	desc = "Weird and flowing!"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/uniforms/uniforms.dmi'
	icon_state = "vox-casual-2"
	item_state = "vox-casual-2"
	item_state_slots = list(WEAR_BODY = "vox-casual-2_s")

/obj/item/clothing/under/vox/eng
	name = "alien uniform"
	desc = "Strange and very soft clothes...is it moving?"
	icon_state = "vox-uniform"
	item_state = "vox-uniform"
	item_state_slots = list(WEAR_BODY = "vox-uniform_s")
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_NONE

/obj/item/clothing/under/vox/lead
	name = "alien uniform"
	desc = "Strange and very soft clothes...is it moving?"
	icon_state = "vox-armorplate"
	item_state = "vox-armorplate"
	item_state_slots = list(WEAR_BODY = "vox-armorplate_s")
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
