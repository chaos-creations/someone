// Vox armor and coats, see modular_chaos/universes/bay12/code/modules/clothing/under/vox.dm for how their armor is ported

/obj/item/clothing/suit/armor/vox
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/suits_bos.dmi'
	species_restricted = list(SPECIES_VOX)
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_ARMS
	flags_inv_hide = NO_FLAGS
	allowed = list(/obj/item/weapon/gun, /obj/item/ammo_magazine, /obj/item/tank, /obj/item/restraint, /obj/item/weapon/baton, /obj/item/device/flashlight)

/obj/item/clothing/suit/armor/vox/bombsuit
	name = "vox bombsuit"
	desc = "A massive chitinous exoskeleton, in the vox society, is used by engineers to work with radiation and explosion protection."
	icon_state = "vox-bombsuit"
	w_class = SIZE_HUGE
	gas_transfer_coefficient = 0.01
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_VERYLOW
	armor_bomb = CLOTHING_ARMOR_VERYLOW
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
	armor_rad = CLOTHING_ARMOR_ULTRAHIGH
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_ARMS|BODY_FLAG_HEAD
	flags_heat_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROT
	siemens_coefficient = 0.2
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/armor/vox/quill_armor
	name = "quill mantle"
	desc = "A blue mantle made of extremely durable material, complemented by fragments of armor made of heavy-duty chitin. Such armor is worn only by high-ranking Quills that bring death to the opponents of their empire."
	icon_state = "vox-mantle"
	armor_melee = CLOTHING_ARMOR_LOW
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	siemens_coefficient = 0
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/armor/vox/quill_armor/inq
	name = "inquisitor mantle"
	desc = "Chitinous durable armor, able to protect against many types of damage. Such armor is worn mainly by high ranks in the cult of worship of Auralis."
	icon_state = "vox-inq"

/obj/item/clothing/suit/armor/vox/guard
	name = "guard shell"
	desc = "A heavy shell that perfectly protects against the adversities of any nature, be it a hail of bullets, lasers or even bombs. Wearing such chitinous armor, members of the honor guard become mobile fortresses that withstand the onslaught alone."
	icon_state = "vox-guard"
	armor_melee = CLOTHING_ARMOR_MEDIUMLOW
	armor_bullet = CLOTHING_ARMOR_VERYHIGH
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	w_class = SIZE_HUGE
	gas_transfer_coefficient = 0.9
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_GROIN|BODY_FLAG_LEGS|BODY_FLAG_FEET|BODY_FLAG_ARMS|BODY_FLAG_HANDS
	siemens_coefficient = 0.2
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/armor/vox_scrap
	name = "rusted metal armor"
	desc = "A hodgepodge of various pieces of metal scrapped together into a rudimentary vox-shaped piece of armor."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/suits.dmi'
	icon_state = "vox-scrap"
	// The old Vox sheet, the BoS one doesn't have it
	sprite_sheets = list(SPECIES_VOX = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/suit.dmi')
	species_restricted = list(SPECIES_VOX)
	allowed = list(/obj/item/weapon/gun, /obj/item/tank)
	armor_melee = CLOTHING_ARMOR_HIGHPLUS
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	armor_laser = CLOTHING_ARMOR_VERYLOW
	armor_energy = CLOTHING_ARMOR_NONE
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_ARMS|BODY_FLAG_GROIN|BODY_FLAG_LEGS
	flags_inv_hide = NO_FLAGS
	siemens_coefficient = 1
	slowdown = SLOWDOWN_ARMOR_MEDIUM

/obj/item/clothing/suit/storage/vox
	name = "vox cloak"
	desc = "A whitish raincoat used in everyday life just like human labcoats. They are worn and appreciated by many vox for their comfort, however, most often such robes are ranked among the bio-techniques of vox fleets."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/suits_bos.dmi'
	icon_state = "vox-labcoat"
	// Baystation 12 lets anyone wear it, but only the Vox sheet has it
	species_restricted = list(SPECIES_VOX)
	flags_armor_protection = BODY_FLAG_CHEST|BODY_FLAG_ARMS
	allowed = list(/obj/item/device/healthanalyzer, /obj/item/stack/medical, /obj/item/reagent_container/syringe, /obj/item/reagent_container/hypospray, /obj/item/device/flashlight, /obj/item/reagent_container/glass/bottle, /obj/item/reagent_container/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper)
	armor_bio = CLOTHING_ARMOR_MEDIUMHIGH
