/obj/item/weapon/sword
	flags_human_ai = MELEE_WEAPON_ITEM

// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/weapon/knife/marine
	icon = 'modular_chaos/icons/obj/items/weapons/weapons.dmi'
	item_icons = list(
		WEAR_L_HAND = 'modular_chaos/icons/mob/humans/onmob/items_lefthand_0.dmi',
		WEAR_R_HAND = 'modular_chaos/icons/mob/humans/onmob/items_righthand_0.dmi',
	)
	name = "\improper M13 fighting knife"
	icon_state = "knife_gerber"
	item_state = "knife_gerber"
	desc = "A standard issue USCMC fighting knife developed by the Kershaw-Gerber company, a subsidiary of Armat Battlefield Systems. Neatly fits into boot-mounted holsters, and can - in emergencies - be utilized to dig out shrapnel."
	flags_atom = FPRINT|QUICK_DRAWABLE|CONDUCT
	flags_equip_slot = SLOT_WAIST|SLOT_FACE
	flags_armor_protection = SLOT_FACE
	flags_item = CAN_DIG_SHRAPNEL
	w_class = SIZE_SMALL
	edge = 1
	sharp = IS_SHARP_ITEM_ACCURATE
	force = MELEE_FORCE_NORMAL
	throwforce = MELEE_FORCE_NORMAL
	throw_speed = SPEED_VERY_FAST
	throw_range = 6
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	attack_speed = 9
