// The pieces a rig deploys onto its wearer. They exist only inside their rig or on its wearer: the rig names them,
// gives them its armor and sprite (/obj/item/rig/proc/setup_piece()) and makes them NODROP, so they come off only
// when it retracts them.

/obj/item/clothing/head/helmet/space/rig
	name = "helmet"
	desc = "A hardsuit helmet."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/hats/hats.dmi'
	icon_state = "eva_rig"
	item_icons = list(
		WEAR_HEAD = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/head/hats.dmi',
	)
	/// The rig it belongs to
	var/obj/item/rig/rig
	/// HUD built into the helmet (MOB_HUD_*), which its wearer sees while it is deployed; null for none
	var/hud_type

/obj/item/clothing/head/helmet/space/rig/Destroy()
	rig = null
	return ..()

/obj/item/clothing/head/helmet/space/rig/equipped(mob/user, slot, silent)
	. = ..()
	if(hud_type && slot == WEAR_HEAD)
		var/datum/mob_hud/hud = GLOB.huds[hud_type]
		hud.add_hud_to(user, src)

/obj/item/clothing/head/helmet/space/rig/unequipped(mob/user, slot)
	. = ..()
	if(hud_type && slot == WEAR_HEAD)
		var/datum/mob_hud/hud = GLOB.huds[hud_type]
		hud.remove_hud_from(user, src)

/obj/item/clothing/head/helmet/space/rig/get_mob_overlay(mob/user_mob, slot, default_bodytype = "Default")
	var/image/overlay = ..()
	if(slot == WEAR_HEAD && overlay && rig?.helmet_overlay_state && rig.wearer && rig.wearer.back == rig)
		overlay.overlays += image(rig.icon, rig.helmet_overlay_state)
	return overlay

/obj/item/clothing/suit/space/rig
	name = "chestpiece"
	desc = "A hardsuit chestpiece."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/suits/suits.dmi'
	icon_state = "eva_rig"
	item_icons = list(
		WEAR_JACKET = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/suits/suits.dmi',
	)
	w_class = SIZE_HUGE
	// The suit is drawn over the uniform and the rig's own gauntlets and boots
	flags_inv_hide = HIDETAIL

/obj/item/clothing/gloves/rig
	name = "gauntlets"
	desc = "A pair of hardsuit gauntlets."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/gloves/gloves.dmi'
	icon_state = "eva_rig"
	item_icons = list(
		WEAR_HANDS = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/hands/gloves.dmi',
	)
	gender = PLURAL
	flags_armor_protection = BODY_FLAG_HANDS
	flags_cold_protection = BODY_FLAG_HANDS
	flags_heat_protection = BODY_FLAG_HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROT
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROT
	siemens_coefficient = 0.2

/obj/item/clothing/shoes/rig
	name = "boots"
	desc = "A pair of hardsuit boots."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/shoes/shoes.dmi'
	icon_state = "eva_rig"
	item_icons = list(
		WEAR_FEET = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/feet/shoes.dmi',
	)
	gender = PLURAL
	flags_armor_protection = BODY_FLAG_FEET
	flags_cold_protection = BODY_FLAG_FEET
	flags_heat_protection = BODY_FLAG_FEET
	flags_inventory = NOSLIPPING
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROT
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROT
