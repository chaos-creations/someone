// Vox helmets, see modular_chaos/universes/bay12/code/modules/clothing/under/vox.dm for how their armor is ported

/obj/item/clothing/head/helmet/vox
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/hats_bos.dmi'
	icon_state = "vox-guard"
	species_restricted = list(SPECIES_VOX)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = NO_FLAGS

/obj/item/clothing/head/helmet/vox/quill_crown
	name = "quill crown"
	icon_state = "vox-crown"
	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW

/obj/item/clothing/head/helmet/vox/guard
	name = "guard helmet"
	icon_state = "vox-guard"
	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW

/obj/item/clothing/head/helmet/vox/jaw
	name = "chitin jaw"
	icon_state = "vox-jaws"
	armor_melee = CLOTHING_ARMOR_VERYLOW
	armor_bullet = CLOTHING_ARMOR_NONE
	armor_laser = CLOTHING_ARMOR_NONE
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
