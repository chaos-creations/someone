// Vox space gear: vacuum suits and helmets that fit only the bone structure of a Vox.
// See modular_chaos/universes/bay12/code/modules/clothing/under/vox.dm for how their armor is ported.

/obj/item/clothing/suit/space/vox
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/suits_bos.dmi'
	icon_state = "vox-pressure"
	w_class = SIZE_MEDIUM
	species_restricted = list(SPECIES_VOX)
	allowed = list(/obj/item/weapon/gun, /obj/item/ammo_magazine, /obj/item/weapon/baton, /obj/item/restraint, /obj/item/tank, /obj/item/device/flashlight)
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_VERYLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_LOW
	armor_rad = CLOTHING_ARMOR_VERYLOW
	siemens_coefficient = 0.6
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_FEET|BODY_FLAG_ARMS|BODY_FLAG_HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROT
	flags_inv_hide = HIDEJUMPSUIT
	slowdown = SLOWDOWN_ARMOR_MEDIUM

/obj/item/clothing/head/helmet/space/vox
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/hats_bos.dmi'
	icon_state = "vox-pressure"
	species_restricted = list(SPECIES_VOX)
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_VERYLOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_LOW
	armor_rad = CLOTHING_ARMOR_VERYLOW
	siemens_coefficient = 0.6
	// The Vox wear their breathing mask under it
	flags_inventory = COVEREYES|NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = NO_FLAGS

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	desc = "A huge, armoured, pressurized helmet. Looks like an ancient human diving suit."
	icon_state = "vox-pressure"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."
	icon_state = "vox-pressure"

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	desc = "A glowing visor. The light slowly pulses, and seems to follow you."
	icon_state = "vox-carapace"

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	icon_state = "vox-carapace"

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	desc = "A smoothly contoured, matte-black alien helmet."
	icon_state = "vox-stealth"

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."
	icon_state = "vox-stealth"

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	desc = "An alien helmet with enormous goggled lenses."
	icon_state = "vox-medic"

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	desc = "An almost organic looking nonhuman pressure suit."
	icon_state = "vox-medic"

/obj/item/clothing/head/helmet/space/vox/raider
	name = "advanced alien helmet"
	desc = "A tight-fitting, beaked mask with three menacing eyeslits."
	icon_state = "vox-raider"
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_MEDIUM

/obj/item/clothing/suit/space/vox/raider
	name = "advanced alien armour"
	desc = "A sleek, greyish suit of armor over a tight bodysuit. Lighter than it looks."
	icon_state = "vox-raider"
	allowed = list(/obj/item/weapon/gun, /obj/item/ammo_magazine, /obj/item/weapon/baton, /obj/item/restraint, /obj/item/tank, /obj/item/device/flashlight, /obj/item/storage/toolbox)
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_energy = CLOTHING_ARMOR_MEDIUM
	flags_inv_hide = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	slowdown = SLOWDOWN_ARMOR_LIGHT
