// Vox rigs, from Baystation 12 (code/modules/clothing/spacesuits/rig/suits/vox.dm) and its BoS layer
// (code/bos/modules/clothing/vox/vox_rig.dm). Their pieces fit only the Vox, who see them on their bodies through the
// Vox sprite sheets every clothing has (/obj/item/clothing/proc/get_default_species_sprite_sheets()). Their armor is
// half of the source's, see modular_chaos/universes/bay12/code/modules/clothing/under/vox.dm. The maneuvering jets and
// the cooling unit of the source aren't ported: there is no zero gravity or overheating to use them against.

/obj/item/rig/vox
	name = "alien rig control module"
	desc = "A strange rig. Parts of it writhe and squirm as if alive. The visor looks more like a thick membrane."
	icon_state = "vox_rig"
	suit_type = "alien rig"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_HIGH
	armor_laser = CLOTHING_ARMOR_MEDIUM
	armor_energy = CLOTHING_ARMOR_MEDIUM
	armor_bomb = CLOTHING_ARMOR_MEDIUMLOW
	armor_bio = CLOTHING_ARMOR_ULTRAHIGH
	armor_rad = CLOTHING_ARMOR_ULTRAHIGH
	online_slowdown = SLOWDOWN_ARMOR_LOWHEAVY
	helm_type = /obj/item/clothing/head/helmet/space/rig/vox
	chest_type = /obj/item/clothing/suit/space/rig/vox
	glove_type = /obj/item/clothing/gloves/rig/vox
	boot_type = /obj/item/clothing/shoes/rig/vox
	air_type = /obj/item/tank/nitrogen
	allowed_in_suit_storage = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/ammo_magazine,
		/obj/item/restraint,
		/obj/item/device/radio,
		/obj/item/weapon/baton,
		/obj/item/weapon/gun,
		/obj/item/tool/pickaxe,
	)
	initial_modules = list(
		/obj/item/rig_module/storage,
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/held/gun/plasmacutter,
		/obj/item/rig_module/power_sink,
	)

/obj/item/clothing/head/helmet/space/rig/vox
	icon_state = "vox_rig"
	species_restricted = list(SPECIES_VOX)
	// The Vox wear their breathing mask under it
	flags_inventory = COVEREYES|NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEALLHAIR

/obj/item/clothing/suit/space/rig/vox
	icon_state = "vox_rig"
	species_restricted = list(SPECIES_VOX)

/obj/item/clothing/gloves/rig/vox
	icon_state = "vox_rig"
	species_restricted = list(SPECIES_VOX)
	siemens_coefficient = 0

/obj/item/clothing/shoes/rig/vox
	icon_state = "vox_rig"
	species_restricted = list(SPECIES_VOX)

/obj/item/rig/vox/inq
	name = "inquisitor rig control module"
	desc = "A strange purple thing, as if from the nightmares of a psychopath with schizophrenia. A thousand legs are moving, making it clear that it is alive and extremely unfriendly. These rigs envelop the bodies of the Inquisition of the New Empire, so that they instill the fire of their faith into the hearts of their brethren and animal fear into their enemies. If you look closely, you can see \"Kighakiki\" scratched on the chitin."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/rigs_bos.dmi'
	icon_state = "vox_rig_inq"
	item_icons = list(
		WEAR_BACK = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/rig_back_bos.dmi',
	)
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	online_slowdown = SLOWDOWN_ARMOR_MEDIUM
	helm_type = /obj/item/clothing/head/helmet/space/rig/vox/inq
	chest_type = /obj/item/clothing/suit/space/rig/vox/inq
	glove_type = /obj/item/clothing/gloves/rig/vox/inq
	boot_type = /obj/item/clothing/shoes/rig/vox/inq
	initial_modules = list(
		/obj/item/rig_module/storage,
		/obj/item/rig_module/vision/darkmatter,
		/obj/item/rig_module/held/gun/plasmacutter/darkmatter,
		/obj/item/rig_module/teleporter,
		/obj/item/rig_module/power_sink,
	)

/obj/item/clothing/head/helmet/space/rig/vox/inq
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/hats_bos.dmi'
	icon_state = "vox_rig_inq"
	// It shows the breathing mask of the Vox
	flags_inv_hide = HIDEEARS|HIDEALLHAIR

/obj/item/clothing/suit/space/rig/vox/inq
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/suits_bos.dmi'
	icon_state = "vox_rig_inq"

/obj/item/clothing/gloves/rig/vox/inq
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/gloves_bos.dmi'
	icon_state = "vox_rig_inq"

/obj/item/clothing/shoes/rig/vox/inq
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/shoes_bos.dmi'
	icon_state = "vox_rig_inq"

/obj/item/rig/vox/breacher
	name = "breacher control module"
	desc = "A strange purple thing, as if from the nightmares of a psychopath with schizophrenia. A thousand legs are moving, making it clear that it is alive and extremely unfriendly. These rigs envelop the bodies of the Inquisition of the New Empire, so that they instill the fire of their faith into the hearts of their brethren and animal fear into their enemies. If you look closely, you can see \"Ciharica\" scratched on the chitin."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/rigs_bos.dmi'
	icon_state = "vox_rig_breacher"
	item_icons = list(
		WEAR_BACK = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/rig_back_bos.dmi',
	)
	armor_bullet = CLOTHING_ARMOR_MEDIUMHIGH
	online_slowdown = SLOWDOWN_ARMOR_MEDIUM
	helm_type = /obj/item/clothing/head/helmet/space/rig/vox/breacher
	chest_type = /obj/item/clothing/suit/space/rig/vox/breacher
	glove_type = /obj/item/clothing/gloves/rig/vox/breacher
	boot_type = /obj/item/clothing/shoes/rig/vox/breacher
	initial_modules = list(
		/obj/item/rig_module/storage,
		/obj/item/rig_module/vision/darkmatter,
		/obj/item/rig_module/held/gun/plasmacutter/darkmatter,
		/obj/item/rig_module/teleporter,
		/obj/item/rig_module/power_sink,
	)

/obj/item/clothing/head/helmet/space/rig/vox/breacher
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/hats_bos.dmi'
	icon_state = "vox_rig_breacher"
	// It shows the breathing mask of the Vox
	flags_inv_hide = HIDEEARS|HIDEALLHAIR

/obj/item/clothing/suit/space/rig/vox/breacher
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/suits_bos.dmi'
	icon_state = "vox_rig_breacher"

/obj/item/clothing/gloves/rig/vox/breacher
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/gloves_bos.dmi'
	icon_state = "vox_rig_breacher"

/obj/item/clothing/shoes/rig/vox/breacher
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/shoes_bos.dmi'
	icon_state = "vox_rig_breacher"
