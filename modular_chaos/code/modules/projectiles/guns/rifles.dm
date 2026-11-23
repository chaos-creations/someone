// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/weapon/gun/rifle/lmg/recon
	icon = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_obj.dmi'
	icon_state = "m41ae2"
	item_state = "m41ae2"
	item_icons = list(
		WEAR_BACK = 'icons/obj/items/weapons/guns/guns_by_map/jungle/back.dmi',
		WEAR_J_STORE = 'icons/obj/items/weapons/guns/guns_by_map/jungle/suit_slot.dmi',
		WEAR_L_HAND = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_lefthand.dmi',
		WEAR_R_HAND = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_righthand.dmi',
	)
	map_specific_decoration = FALSE // always the jungle camo of FORECON
	current_mag = /obj/item/ammo_magazine/rifle/lmg/recon
	desc = "Heavy barreled higher capacity variant of the M41A. Greater sustained firepower and total ammunition carried, offset by removal of the grenade launcher and worsened handling. This one is painted in a fresh coat of the newer Humbrol 76 camouflage and is used by Force Reconnaissance units, while sporting a vertical grip in place of an integrated bipod."
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/bipod/m41ae2/recon,
		/obj/item/attachable/stock/rifle/collapsible/m41ae2,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/pve,
		/obj/item/attachable/sling,
	)
	starting_attachment_types = list(
		/obj/item/attachable/stock/rifle/collapsible/m41ae2,
		/obj/item/attachable/verticalgrip,
	)

/// The M4RA-A6: a PvE M4RA upgrade that chambers A19 depleted uranium rounds
/obj/item/weapon/gun/rifle/m4ra/pve
	name = "\improper M4RA-A6 battle rifle"
	desc = "The M4RA-A6 is a souped-up M4RA, the result of an ARMAT upgrade program that didn't pan out in huge numbers. Its main attraction is the ability to chamber and fire devastating <b>A19 depleted uranium rounds,</b> infamous for their overpenetration abilities and toxic effects on anyone unfortunate enough to survive a hit. The thicker barrel, of course, also has no issue with standard & regular HV ammo."
	desc_lore = "The USCMC was not terribly enthusiastic about unproven hand-held plasma weaponry. Before the XM99A was eventually adopted into use, the USCMC instead sought out a traditional squad-portable, precision, armor-piercing weapon, and contracted ARMAT to upgrade their M4RA platform to be capable of firing advanced AP rounds. They succeeded- sort of. <BR> <BR>  The A6 was rejected for several reasons. It's a killer, but also a piece of junk. It kicks hard enough that precision sights simply don't stay zeroed, and its oversized muzzle-device extends an already long barrel-length. Additionally, A19 ammo, already expensive, was driven to absurd highs by the ammunition's specs. Depleted uranium is expensive...and cutting the service life of the M4RA's barrel in half is even more expensive. <BR> <BR> Those that were made, however, are still service-ready and were issued where the XM99A was unavailable due to its production only just starting."
	icon = 'modular_chaos/icons/obj/items/weapons/guns/guns_by_faction/USCM/marksman_rifles.dmi'
	item_icons = list(
		WEAR_BACK = 'icons/obj/items/weapons/guns/guns_by_map/urban/back.dmi',
		WEAR_J_STORE = 'icons/obj/items/weapons/guns/guns_by_map/urban/suit_slot.dmi',
		WEAR_L_HAND = 'icons/obj/items/weapons/guns/guns_by_map/urban/guns_lefthand.dmi',
		WEAR_R_HAND = 'icons/obj/items/weapons/guns/guns_by_map/urban/guns_righthand.dmi',
	)
	map_specific_decoration = FALSE // always the grey finish, the urban camo of the M4RA
	starting_attachment_types = list()
	caliber = list("10x24mm", "A19")
	current_mag = /obj/item/ammo_magazine/rifle/m4ra/custom/pve
	accepted_ammo = list(
		/obj/item/ammo_magazine/rifle/m4ra,
		/obj/item/ammo_magazine/rifle/m4ra/ap,
		/obj/item/ammo_magazine/rifle/m4ra/extended,
		/obj/item/ammo_magazine/rifle/m4ra/rubber,
		/obj/item/ammo_magazine/rifle/m4ra/incendiary,
		/obj/item/ammo_magazine/rifle/m4ra/heap,
		/obj/item/ammo_magazine/rifle/m4ra/penetrating,
		/obj/item/ammo_magazine/rifle/m4ra/custom,
		/obj/item/ammo_magazine/rifle/m4ra/custom/incendiary,
		/obj/item/ammo_magazine/rifle/m4ra/custom/impact,
		/obj/item/ammo_magazine/rifle/m4ra/custom/pve,
	)

/obj/item/weapon/gun/rifle/m4ra/pve/Initialize()
	attachable_allowed = attachable_allowed.Copy()
	attachable_allowed += list(
		/obj/item/attachable/scope/mini/army,
		/obj/item/attachable/scope/pve,
		/obj/item/attachable/scope/mini_iff,
		/obj/item/attachable/sling,
	)
	return ..()

/obj/item/weapon/gun/rifle/m4ra/pve/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_4)
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_1 //Chunky barrel for better muzzle velocity, but not as good as the custom one
	recoil_unwielded = RECOIL_AMOUNT_TIER_1
	recoil = RECOIL_AMOUNT_TIER_3

// Upstream PR #13424 ports the same rifle; drop this copy once it is merged (see the fork's notes on #13424)
/obj/item/weapon/gun/rifle/m41aMK1/forecon
	desc = "Pulse action 10x24mm caseless assault rifle of the USCMC, personal friend of any Marine. This one is painted in a fresh coat of the newer Humbrol 76 camouflage and is used by Force Reconnaissance & MARSOC units."
	icon = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_obj.dmi'
	icon_state = "m41a"
	item_state = "m41a"
	item_icons = list(
		WEAR_BACK = 'icons/obj/items/weapons/guns/guns_by_map/jungle/back.dmi',
		WEAR_J_STORE = 'icons/obj/items/weapons/guns/guns_by_map/jungle/suit_slot.dmi',
		WEAR_L_HAND = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_lefthand.dmi',
		WEAR_R_HAND = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_righthand.dmi',
	)
	map_specific_decoration = FALSE // always the jungle camo of FORECON
	current_mag = /obj/item/ammo_magazine/rifle/m41aMK1/recon
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade/mk1/recon, /obj/item/attachable/stock/rifle/collapsible)

/obj/item/weapon/gun/rifle/m41aMK1/forecon/Initialize()
	attachable_allowed = attachable_allowed.Copy()
	attachable_allowed += /obj/item/attachable/attached_gun/grenade/mk1/recon
	return ..()

/obj/item/weapon/gun/rifle/m41aMK1/forecon/unloaded
	current_mag = null
