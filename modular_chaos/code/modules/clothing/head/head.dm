// Ported from cmss13-pve for the USS Rover and its FORECON platoon

// Caps and hats of one fixed camouflage for the FORECON vendors, on the upstream sprites of that camouflage:
// the upstream types take the camouflage of the ground map instead.

/obj/item/clothing/head/cmcap/jungle
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon_state = "cap"

/obj/item/clothing/head/cmcap/snow
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon = 'icons/obj/items/clothing/hats/hats_by_map/snow.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_map/snow.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_righthand.dmi',
	)
	name = "\improper coldweather utility cap"
	desc = "A utility cap worn in cold weather environments."
	icon_state = "cap"

/obj/item/clothing/head/cmcap/desert
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon = 'icons/obj/items/clothing/hats/hats_by_map/desert.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_map/desert.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/desert_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/desert_righthand.dmi',
	)
	name = "\improper desert utility cap"
	desc = "A desert BDU utility cap."
	icon_state = "cap"

/obj/item/clothing/head/cmcap/khaki
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon = 'modular_chaos/icons/obj/items/clothing/cm_hats.dmi'
	item_icons = list(
		WEAR_HEAD = 'modular_chaos/icons/mob/humans/onmob/head_1.dmi',
	)
	name = "\improper khaki utility cap"
	desc = "A khaki utility cap"
	icon_state = "cap_khaki"

/obj/item/clothing/head/cmcap/boonie/jungle
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon_state = "booniehat"

/obj/item/clothing/head/cmcap/boonie/snow
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon = 'icons/obj/items/clothing/hats/hats_by_map/snow.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_map/snow.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_righthand.dmi',
	)
	icon_state = "booniehat"

/obj/item/clothing/head/cmcap/flap/jungle
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon_state = "flapcap"

/obj/item/clothing/head/cmcap/flap/desert
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon = 'icons/obj/items/clothing/hats/hats_by_map/desert.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_map/desert.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/desert_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/desert_righthand.dmi',
	)
	name = "\improper desert expedition cap"
	icon_state = "flapcap"

/obj/item/clothing/head/cmcap/flap/snow
	flags_atom = parent_type::flags_atom|NO_GAMEMODE_SKIN
	icon = 'icons/obj/items/clothing/hats/hats_by_map/snow.dmi'
	item_icons = list(
		WEAR_HEAD = 'icons/mob/humans/onmob/clothing/head/hats_by_map/snow.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/items_by_map/snow_righthand.dmi',
	)
	name = "\improper snow expedition cap"
	desc = "A casual cap issued as part of the non-combat uniform. While it only protects from the wind and snow, it's much more comfortable than a helmet. This one comes with flaps to keep your neck and ears warm."
	icon_state = "flapcap"
