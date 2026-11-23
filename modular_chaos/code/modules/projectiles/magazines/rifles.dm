// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/ammo_magazine/rifle/m41aMK1/recon
	icon = 'modular_chaos/icons/obj/items/weapons/guns/ammo_by_faction/USCM/assault_rifles.dmi'
	icon_state = "m41a_mk1_recon"
	current_rounds = 95

/// M41AE2 ammo box always in the jungle camo (the unprefixed upstream sprite) of FORECON, whatever the camouflage of the map
/obj/item/ammo_magazine/rifle/lmg/recon
	flags_atom = FPRINT|CONDUCT

/obj/item/ammo_magazine/rifle/lmg/recon/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	return FALSE
