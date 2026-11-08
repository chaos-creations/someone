// The infantry hardsuit of the Torch's marines, from Baystation 12 (maps/torch/infantry/hardsuit.dm). All its sprites,
// worn ones too, are in one icon; the source gives the control module no sprite of its own, so it has the chief
// engineer's one recolored to the suit's grey, see the README of the universe. Its armor is half of the source's, see modular_chaos/universes/bay12/code/modules/clothing/under/vox.dm.

/obj/item/rig/infantry
	name = "infantry fighting hardsuit control module"
	desc = "The Modular Advanced Extra Vehicular Armor, or MAEVA, suit used by Sol marines. It is built from a heavy plasteel-titanium alloy. While it lacks equal protection from energy based weaponry, it has the ability to increase the wearer's strength tenfold."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/rigs_infantry.dmi'
	icon_state = "infantry_rig"
	item_icons = null
	contained_sprite = TRUE
	separate_piece_states = TRUE
	suit_type = "combat hardsuit"
	armor_melee = CLOTHING_ARMOR_MEDIUMHIGH
	armor_bullet = CLOTHING_ARMOR_HIGHPLUS
	armor_laser = CLOTHING_ARMOR_MEDIUMHIGH
	armor_energy = CLOTHING_ARMOR_LOW
	armor_bomb = CLOTHING_ARMOR_HIGH
	armor_bio = CLOTHING_ARMOR_ULTRAHIGH
	armor_rad = CLOTHING_ARMOR_ULTRAHIGH
	online_slowdown = SLOWDOWN_ARMOR_HEAVY
	offline_slowdown = 3
	helm_type = /obj/item/clothing/head/helmet/space/rig/infantry
	chest_type = /obj/item/clothing/suit/space/rig/infantry
	glove_type = /obj/item/clothing/gloves/rig/infantry
	boot_type = /obj/item/clothing/shoes/rig/infantry
	allowed_in_suit_storage = list(
		/obj/item/device/flashlight,
		/obj/item/tank,
		/obj/item/ammo_magazine,
		/obj/item/restraint,
		/obj/item/device/radio,
		/obj/item/weapon/baton,
		/obj/item/weapon/gun,
		/obj/item/storage/firstaid,
		/obj/item/reagent_container/hypospray,
		/obj/item/tool,
		/obj/item/device/multitool,
	)

/obj/item/clothing/head/helmet/space/rig/infantry
	icon = 'modular_chaos/universes/bay12/icons/obj/items/rigs_infantry.dmi'
	icon_state = "infantry_rig_helmet"
	item_icons = null
	contained_sprite = TRUE
	species_restricted = list("exclude", SPECIES_VOX)

/obj/item/clothing/suit/space/rig/infantry
	icon = 'modular_chaos/universes/bay12/icons/obj/items/rigs_infantry.dmi'
	icon_state = "infantry_rig_chest"
	item_icons = null
	contained_sprite = TRUE
	species_restricted = list("exclude", SPECIES_VOX)

/obj/item/clothing/gloves/rig/infantry
	icon = 'modular_chaos/universes/bay12/icons/obj/items/rigs_infantry.dmi'
	icon_state = "infantry_rig_gloves"
	item_icons = null
	contained_sprite = TRUE

/obj/item/clothing/shoes/rig/infantry
	icon = 'modular_chaos/universes/bay12/icons/obj/items/rigs_infantry.dmi'
	icon_state = "infantry_rig_boots"
	item_icons = null
	contained_sprite = TRUE

/obj/item/rig/infantry/sl
	name = "squad leader fighting hardsuit control module"
	desc = "The Modular Advanced Extra Vehicular Armor, or MAEVA, suit used by Sol marines. It is built from a heavy plasteel-titanium alloy. While it lacks equal protection from energy based weaponry, it has the ability to increase the wearer's strength tenfold. This particular suit has the markings of a squad leader."
	icon_state = "sl_infantry_rig"
	// Its antennas stick up above the helmet when seen from behind
	helmet_overlay_state = "sl_infantry_rig_antennas"

// The rigs the Lordanian marines are issued (/datum/equipment_preset/lordania/marine): the rig takes the place of a
// backpack, so they get a storage system as big as one, and the modules of their role

/obj/item/rig/infantry/equipped
	initial_modules = list(/obj/item/rig_module/storage/large)

/obj/item/rig/infantry/equipped/medic
	helm_type = /obj/item/clothing/head/helmet/space/rig/infantry/medic
	initial_modules = list(/obj/item/rig_module/storage/large, /obj/item/rig_module/health_scanner)

/// The helmet of the combat medic's rig, with a medical HUD built in
/obj/item/clothing/head/helmet/space/rig/infantry/medic
	hud_type = MOB_HUD_MEDICAL_ADVANCED

/obj/item/rig/infantry/equipped/technician
	initial_modules = list(/obj/item/rig_module/storage/large, /obj/item/rig_module/vision/meson)

/obj/item/rig/infantry/sl/equipped
	initial_modules = list(/obj/item/rig_module/storage/large)
