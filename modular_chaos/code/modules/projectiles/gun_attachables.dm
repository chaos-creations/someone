/obj/item/attachable/bayonet
	flags_human_ai = MELEE_WEAPON_ITEM

// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/obj/item/attachable/sling //Mostly cosmetic, some one-handed fire adjustments
	icon = 'modular_chaos/icons/obj/items/weapons/guns/attachments/rail.dmi'
	name = "two-point sling"
	desc = "A traditional strip of toughened nylon fabric with clips on either end for attaching to suitable mounting points on most longarms in the UA armed forces arsenals."
	icon_state = "pve-sling"
	attach_icon = "pve-sling_a"
	slot = "rail"

/obj/item/attachable/sling/New()
	..()
	accuracy_unwielded_mod = -HIT_ACCURACY_MULT_TIER_1
	recoil_unwielded_mod = -RECOIL_AMOUNT_TIER_2
	scatter_unwielded_mod = -SCATTER_AMOUNT_TIER_2

/obj/item/attachable/scope/mini/army
	desc = "An ARMAT S4 scope, type designation AN/PVQ-45. 2x magnification optic, increases accuracy while scoped, decreases RoF and increased wield speed."
	zoom_offset = 4

/obj/item/attachable/scope/pve
	icon_state = "miniscope"
	attach_icon = "miniscope_a"
	name = "AN/RVS-52 CCD television sight system"
	desc = "An ARMAT designed 3x magnification weapon sight, allows for greater accuracy at range and under low-light conditions. The mounting brackets are designed to fit on the most commonly-used rifles of the USCM. This one looks like it's been in service since the start of the Linna 349 campaign."
	zoom_offset = 3
	zoom_viewsize = 7
	allows_movement = TRUE
	var/dynamic_aim_slowdown = SLOWDOWN_ADS_MINISCOPE_DYNAMIC

/obj/item/attachable/scope/pve/New()
	..()
	damage_falloff_scoped_buff = -0.2

/obj/item/attachable/scope/pve/apply_scoped_buff(obj/item/weapon/gun/G, mob/living/carbon/user)
	. = ..()
	if(G.zoom)
		G.slowdown += dynamic_aim_slowdown

/obj/item/attachable/scope/pve/remove_scoped_buff(mob/living/carbon/user, obj/item/weapon/gun/G)
	G.slowdown -= dynamic_aim_slowdown
	..()

/obj/item/attachable/scope/mini_iff
	name = "B8 Smart-Scope"
	icon_state = "iffbarrel"
	attach_icon = "iffbarrel_a"
	desc = "An experimental B8 Smart-Scope, type designation XAN/PVG-110. Limited automated IFF trigger interlock system allows for use with the M44 Combat Revolver and M4RA Battle Rifle. Reduces damage due to the momentary trigger delay."
	slot = "rail"
	zoom_offset = 6
	zoom_viewsize = 7
	pixel_shift_y = 15
	var/dynamic_aim_slowdown = SLOWDOWN_ADS_MINISCOPE_DYNAMIC

/obj/item/attachable/scope/mini_iff/New()
	..()
	damage_mod = -BULLET_DAMAGE_MULT_TIER_4
	movement_onehanded_acc_penalty_mod = MOVEMENT_ACCURACY_PENALTY_MULT_TIER_6
	accuracy_unwielded_mod = 0

	accuracy_scoped_buff = HIT_ACCURACY_MULT_TIER_1
	delay_scoped_nerf = 0
	damage_falloff_scoped_buff = 0

/obj/item/attachable/scope/mini_iff/set_bullet_traits()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_iff)
	))

/obj/item/attachable/scope/mini_iff/activate_attachment(obj/item/weapon/gun/G, mob/living/carbon/user, turn_off)
	if(do_after(user, 8, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		allows_movement = 1
		. = ..()

/obj/item/attachable/scope/mini_iff/apply_scoped_buff(obj/item/weapon/gun/G, mob/living/carbon/user)
	. = ..()
	if(G.zoom)
		G.slowdown += dynamic_aim_slowdown

/obj/item/attachable/scope/mini_iff/remove_scoped_buff(mob/living/carbon/user, obj/item/weapon/gun/G)
	G.slowdown -= dynamic_aim_slowdown
	..()

// Sprites from upstream PR #13424; drop this copy once it is merged
/obj/item/attachable/attached_gun/grenade/mk1/recon
	icon = 'modular_chaos/icons/obj/items/weapons/guns/attachments/forecon.dmi'
	icon_state = "green_grenade-mk1"
	attach_icon = "green_grenade-mk1_a"

/// The M41AE2 bipod always in the jungle camo (the unprefixed upstream sprite), for the green recon HPR of FORECON
/obj/item/attachable/bipod/m41ae2/recon

/obj/item/attachable/bipod/m41ae2/recon/select_gamemode_skin(expected_type, list/override_icon_state, list/override_protection)
	return FALSE
