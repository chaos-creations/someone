// Vox masks, the only ones that fit a beak (see /obj/item/clothing/mask/var/species_restricted)

/// The mask a Vox breathes nitrogen through, given to every Vox (/datum/species/vox/proc/equip_survival_gear())
/obj/item/clothing/mask/gas/vox
	name = "vox breathing mask"
	desc = "A small filter mask for use by Vox, which keeps the oxygen out of their lungs."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/masks/masks.dmi'
	icon_state = "respirator"
	item_state = "respirator"
	species_restricted = list(SPECIES_VOX)
	flags_inventory = ALLOWINTERNALS|BLOCKGASEFFECT
	flags_inv_hide = NO_FLAGS
	flags_armor_protection = NO_FLAGS

/obj/item/clothing/mask/gas/swat/vox
	name = "alien mask"
	desc = "Clearly not designed for a human face."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/masks/masks.dmi'
	icon_state = "voxswat"
	item_state = "voxswat"
	species_restricted = list(SPECIES_VOX)
	flags_armor_protection = BODY_FLAG_EYES
