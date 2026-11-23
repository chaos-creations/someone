// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/clothing/accessory/storage/smallpouch
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "small pouch"
	desc = "A small pouch to carry a few items, typically the contents of an IFAK."
	icon_state = "pouch"
	hold = /obj/item/storage/internal/accessory/smallpouch

/obj/item/storage/internal/accessory/smallpouch
	w_class = SIZE_LARGE
	max_w_class = SIZE_SMALL
	storage_flags = NONE
	storage_slots = 4

/obj/item/clothing/accessory/pads
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3 Pauldrons"
	desc = "Attachable supplementary armor for the M3 armor system. Protects from glancing hits and covers the arm opening in the cuirass against shrapnel."
	icon_state = "pads"
	item_state = "pads"
	worn_accessory_slot = ACCESSORY_SLOT_DECORARMOR

/obj/item/clothing/accessory/pads/Initialize(mapload)
	. = ..()
	if(!(flags_atom & NO_GAMEMODE_SKIN))
		select_gamemode_skin(type)
	update_icon()

/obj/item/clothing/accessory/pads/bracers
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3 Vambraces"
	desc = "Attachable supplementary armor for the M3 armor system. A pair of composite ballistic vambraces to shield the forearms, with straps to ensure it doesn't ride up or down."
	icon_state = "bracers"
	item_state = "bracers"
	worn_accessory_slot = ACCESSORY_SLOT_DECORBRACER

/obj/item/clothing/accessory/pads/bracers/standard
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	flags_atom = NO_GAMEMODE_SKIN

/obj/item/clothing/accessory/pads/greaves
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3 Greaves"
	desc = "Attachable supplementary armor for the M3 armor system. Lightweight polymer clamshell-style plates enclose the lower legs to provide shrapnel and pistol protection."
	icon_state = "shinguards"
	item_state = "shinguards"
	worn_accessory_slot = ACCESSORY_SLOT_DECORSHIN

/obj/item/clothing/accessory/pads/greaves/standard
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	flags_atom = NO_GAMEMODE_SKIN

/obj/item/clothing/accessory/pads/kneepads
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3 Kneepads"
	desc = "Attachable supplementary armor for the M3 armor system. High impact ruggedized outer shell and polymer internals protect from shrapnel as well as low power ballistics."
	icon_state = "thighguards"
	item_state = "thighguards"
	worn_accessory_slot = ACCESSORY_SLOT_DECORKNEE

/obj/item/clothing/accessory/pads/kneepads/standard
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	flags_atom = NO_GAMEMODE_SKIN

/obj/item/clothing/accessory/paint
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "skull armor paint"
	desc = "A set of paint tones to etch a skull into a Marine's armor."
	icon_state = "skull"
	item_state = "skull"
	worn_accessory_slot = ACCESSORY_SLOT_PAINT

/obj/item/clothing/accessory/paint/medic
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "cross armor paint"
	desc = "A set of paint tones to etch a red cross into a Marine's armor."
	icon_state = "medic"
	item_state = "medic"

/obj/item/clothing/accessory/storage/webbing/m3
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3 Pattern Webbing"
	desc = "A sturdy mess of synthcotton belts and buckles designed to attach to the M3 Pattern Marine armor standard for the USCMC. This one is the slimmed down model designed for general purpose storage."
	icon_state = "m3webbing"
	hold = /obj/item/storage/internal/accessory/webbing/m3generic
	worn_accessory_slot = ACCESSORY_SLOT_M3UTILITY
	flags_atom = NO_GAMEMODE_SKIN

/obj/item/clothing/accessory/storage/webbing/m3/Initialize(mapload)
	. = ..()
	if(!(flags_atom & NO_GAMEMODE_SKIN))
		select_gamemode_skin(type)
	update_icon()

/obj/item/storage/internal/accessory/webbing/m3generic
	cant_hold = list(
		/obj/item/ammo_magazine/handful/shotgun,
		/obj/item/ammo_magazine/rifle,
	)

/obj/item/storage/internal/accessory/webbing/m3mag
	can_hold = list(
		/obj/item/attachable/bayonet,
		/obj/item/weapon/knife,
		/obj/item/device/flashlight/flare,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/m60,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/handful,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
		/obj/item/reagent_container/food/snacks,
	)
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
	)

/obj/item/storage/internal/accessory/black_vest/m3shotgun
	can_hold = list(
		/obj/item/ammo_magazine/handful,
	)

/obj/item/storage/internal/accessory/black_vest/m3grenade
	storage_slots = 7
	can_hold = list(
		/obj/item/explosive/grenade/high_explosive,
		/obj/item/explosive/grenade/high_explosive/super,
		/obj/item/explosive/grenade/high_explosive/training,
		/obj/item/explosive/grenade/incendiary,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/explosive/grenade/metal_foam,
		/obj/item/explosive/grenade/phosphorus,
		/obj/item/explosive/grenade/slug/baton,
	)

/obj/item/clothing/accessory/storage/webbing/m3/recon
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3-R Pattern Magazine Webbing"
	desc = "A set of magazine webbing made in an alternative configuration for standard M3 Pattern armor. This one is exclusively issued to Force Reconnoissance units."
	icon_state = "m3rwebbing"
	hold = /obj/item/storage/internal/accessory/webbing/m3mag/recon

/obj/item/storage/internal/accessory/webbing/m3mag/recon
	storage_slots = 4

/obj/item/clothing/accessory/storage/webbing/m3/recon/m40
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3-R Pattern Grenade Webbing"
	desc = "An alternative to the M3-R Pattern webbing fitted to store M40-hull grenades."
	icon_state = "m3rwebbingm40"
	hold = /obj/item/storage/internal/accessory/black_vest/m3grenade/recon

/obj/item/storage/internal/accessory/black_vest/m3grenade/recon
	storage_slots = 10

/obj/item/clothing/accessory/storage/webbing/m3/recon/shotgun
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3-R Pattern Shell Webbing"
	desc = "A modified variant of the M3-R Pattern grenade webbing for FORECON units, this one accepting 12 gauge."
	icon_state = "m3rwebbingshotgun"
	hold = /obj/item/storage/internal/accessory/black_vest/m3shotgun/recon

/obj/item/storage/internal/accessory/black_vest/m3shotgun/recon
	storage_slots = 7

/obj/item/clothing/accessory/storage/webbing/m3/recon/medic
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper M3-R Pattern Corpsman Webbing"
	desc = "A large pouch with M3-R Pattern webbing clips designed to house surgical tools for Corpsmen attached to FORECON units, where field hospitals are not readily available."
	icon_state = "m3rwebbingmedic"
	hold = /obj/item/storage/internal/accessory/black_vest/m3generic/recon

/obj/item/storage/internal/accessory/black_vest/m3generic
	cant_hold = list(
		/obj/item/ammo_magazine/handful/shotgun,
	)

/obj/item/storage/internal/accessory/black_vest/m3generic/recon
	storage_slots = 6
	can_hold = list(
		/obj/item/storage/surgical_case/regular,
		/obj/item/reagent_container/blood,
		/obj/item/tool/surgery/surgical_line,
		/obj/item/tool/surgery/synthgraft,
		/obj/item/device/healthanalyzer,
	)

/obj/item/clothing/accessory/storage/webbing/m56
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper Clip-on Pouch"
	desc = "A clip on synth-leather pouch designed to house a small collection of items for M56 weapon operators."
	icon_state = "m56pouch"
	hold = /obj/item/storage/internal/accessory/black_vest/m56
	worn_accessory_slot = ACCESSORY_SLOT_M56UTILITY

/obj/item/clothing/accessory/storage/webbing/m56/Initialize(mapload)
	. = ..()
	if(!(flags_atom & NO_GAMEMODE_SKIN))
		select_gamemode_skin(type)
	update_icon()

/obj/item/storage/internal/accessory/black_vest/m56
	storage_slots = 3

/obj/item/clothing/accessory/storage/webbing/m56/grenade
	icon = 'modular_chaos/icons/obj/items/clothing/ties.dmi'
	accessory_icons = list(
		WEAR_BODY = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
		WEAR_JACKET = 'modular_chaos/icons/mob/humans/onmob/ties.dmi',
	)
	inv_overlay_icon = 'modular_chaos/icons/obj/items/clothing/ties_overlay.dmi'
	name = "\improper Clip-on Grenade Band"
	desc = "A sturdy mess of synth-leather band designed to store a few grenades for M56 weapon operators."
	icon_state = "m56grenade"
	hold = /obj/item/storage/internal/accessory/black_vest/m56/grenade

/obj/item/storage/internal/accessory/black_vest/m56/grenade
	storage_slots = 4
	can_hold = list(
		/obj/item/explosive/grenade/high_explosive,
		/obj/item/explosive/grenade/high_explosive/super,
		/obj/item/explosive/grenade/high_explosive/training,
		/obj/item/explosive/grenade/incendiary,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/explosive/grenade/metal_foam,
		/obj/item/explosive/grenade/phosphorus,
		/obj/item/explosive/grenade/slug/baton,
	)
