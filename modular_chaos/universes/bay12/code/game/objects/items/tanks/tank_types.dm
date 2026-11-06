/// The small nitrogen tank a Vox breathes from on their belt (/datum/species/vox/proc/equip_survival_gear())
/obj/item/tank/emergency_nitrogen
	name = "emergency nitrogen tank"
	desc = "Used for emergencies. Contains very little nitrogen, so try to conserve it until you actually need it."
	icon = 'modular_chaos/universes/bay12/icons/obj/items/tank.dmi'
	icon_state = "emergency_nitro"
	item_icons = list(
		WEAR_WAIST = 'modular_chaos/universes/bay12/icons/mob/humans/onmob/clothing/belts/belts.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/equipment/tanks_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/equipment/tanks_righthand.dmi',
	)
	flags_equip_slot = SLOT_WAIST
	w_class = SIZE_TINY
	force = 4
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	volume = 2
	gas_type = GAS_TYPE_NITROGEN
	pressure = 3*ONE_ATMOSPHERE
	pressure_full = 3*ONE_ATMOSPHERE
