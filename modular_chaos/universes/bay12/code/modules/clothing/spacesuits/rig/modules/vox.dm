// Rig modules of the Vox rigs, from Baystation 12 (code/modules/clothing/spacesuits/rig/modules/combat.dm and
// vision.dm) and its BoS layer (code/bos/modules/clothing/vox/vox_rig.dm). The mounted guns there fire from the
// shoulder; here they unfold into the hand, like the plasma caster of a Yautja does, and fire from the suit's cell.
// Their sprite on the suit shows them folded, so it is drawn only while they aren't in the hand.

/obj/item/rig_module/held/gun/plasmacutter
	name = "hardsuit mounted plasma cutter"
	desc = "A forearm-mounted plasma cutter."
	icon_state = "plasmacutter"
	interface_name = "mounted plasma cutter"
	interface_desc = "A forearm-mounted, suit-powered plasma cutter. Its arc is short-ranged but cuts through armor."
	suit_overlay_inactive = "plasmacutter"
	held_type = /obj/item/weapon/gun/energy/rig/plasmacutter

/obj/item/rig_module/held/gun/plasmacutter/darkmatter
	name = "plasmacutter"
	desc = "A portable darkmatter plasmacutter."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/rigs_bos.dmi'
	interface_name = "plasmacutter"
	interface_desc = "A portable darkmatter plasmacutter. Its arc is short-ranged but cuts through armor."
	suit_overlay_icon = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/rig_back_bos.dmi'

/obj/item/rig_module/held/gun/darkmatter
	name = "darkmatter cannon"
	desc = "A portable darkmatter generator with three firemodes."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/clothing/vox/rigs_bos.dmi'
	icon_state = "darkmatter"
	interface_name = "darkmatter cannon"
	interface_desc = "A portable darkmatter generator with three firemodes: stunning waves, focused bolts and a scatter burst. Fires from the suit's cell."
	suit_overlay_icon = 'modular_chaos/universes/bay12/icons/mob/humans/species/vox/onmob/rig_back_bos.dmi'
	suit_overlay_inactive = "darkmatter"
	held_type = /obj/item/weapon/gun/energy/rig/darkmatter

/obj/item/rig_module/vision/darkmatter
	interface_desc = "An integrated multi-mode vision system: night vision and a meson scanner."
	vision_modes = list(
		/datum/rig_vision/night,
		/datum/rig_vision/meson,
	)

/obj/item/weapon/gun/energy/rig/plasmacutter
	name = "mounted plasma cutter"
	desc = "A plasma cutter unfolded from a hardsuit gauntlet. It draws its power from the suit."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/weapons/guns/plasmacutter.dmi'
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	item_icons = list(
		WEAR_L_HAND = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/inhands/weapons/guns/guns_lefthand.dmi',
		WEAR_R_HAND = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/inhands/weapons/guns/guns_righthand.dmi',
	)
	fire_sound = 'sound/weapons/pred_plasma_shot.ogg'
	muzzle_flash = null
	ammo = /datum/ammo/energy/plasmacutter
	charge_cost = 100
	charge_icon = "plasmacutter"
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED

/obj/item/weapon/gun/energy/rig/plasmacutter/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_6)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_8
	damage_mult = BASE_BULLET_DAMAGE_MULT

/**
 * Darkmatter cannon of a Vox rig, with three firemodes switched by its unique action
 */
/obj/item/weapon/gun/energy/rig/darkmatter
	name = "darkmatter cannon"
	desc = "A darkmatter generator unfolded from a Vox hardsuit. It draws its power from the suit, and its unique action switches between stunning waves, focused bolts and a scatter burst."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/weapons/guns/darkcannon.dmi'
	icon_state = "darkcannon"
	item_state = "darkcannon"
	item_icons = list(
		WEAR_L_HAND = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/inhands/weapons/guns/guns_lefthand.dmi',
		WEAR_R_HAND = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/inhands/weapons/guns/guns_righthand.dmi',
	)
	fire_sound = 'sound/weapons/pulse.ogg'
	muzzle_flash = null
	ammo = /datum/ammo/energy/darkmatter/stun
	charge_cost = 150
	charge_icon = "darkcannon0"
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED
	/**
	 * The firemodes, each a list of: its name, the type of its ammo, the charge a shot takes and the fire delay
	 */
	var/list/firemodes = list(
		list("stunning", /datum/ammo/energy/darkmatter/stun, 150, FIRE_DELAY_TIER_6),
		list("focused", /datum/ammo/energy/darkmatter, 250, FIRE_DELAY_TIER_5),
		list("scatter burst", /datum/ammo/energy/darkmatter/scatter, 400, FIRE_DELAY_TIER_1),
	)
	/// Index of the current firemode in firemodes
	var/firemode_index = 1

/obj/item/weapon/gun/energy/rig/darkmatter/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_6)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_8
	damage_mult = BASE_BULLET_DAMAGE_MULT

/obj/item/weapon/gun/energy/rig/darkmatter/get_examine_text(mob/user)
	. = ..()
	var/list/firemode = firemodes[firemode_index]
	. += SPAN_NOTICE("It is set to fire [firemode[1]] shots.")

/obj/item/weapon/gun/energy/rig/darkmatter/unique_action(mob/user)
	firemode_index = firemode_index % length(firemodes) + 1
	var/list/firemode = firemodes[firemode_index]
	ammo = GLOB.ammo_list[firemode[2]]
	charge_cost = firemode[3]
	set_fire_delay(firemode[4])
	playsound(user, 'sound/weapons/handling/gun_burst_toggle.ogg', 15, TRUE)
	to_chat(user, SPAN_NOTICE("[src] is now set to [firemode[1]]."))
