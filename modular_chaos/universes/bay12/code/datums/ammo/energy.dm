// Dark matter shots of the Vox weapons, from Baystation 12 (code/modules/projectiles/projectile/beams.dm and energy.dm).
// Their damage is about upstream's for a rifle shot, as Baystation 12's is weighed against its own armor.

/datum/ammo/energy/darkmatter
	name = "dark matter bolt"
	icon_state = "pulse1"
	damage_type = BRUTE
	damage = 40
	penetration = ARMOR_PENETRATION_TIER_4
	accurate_range = 12
	max_range = 18
	shell_speed = AMMO_SPEED_TIER_4
	hit_effect_color = "#8E44AD"

/datum/ammo/energy/darkmatter/stun
	name = "dark matter wave"
	icon_state = "stun"
	damage_type = OXY
	damage = 0
	penetration = 0
	stamina_damage = 35
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST

/datum/ammo/energy/darkmatter/scatter
	name = "dark matter pellet"
	icon_state = "ion"
	damage = 15
	penetration = ARMOR_PENETRATION_TIER_2
	accurate_range = 5
	max_range = 8
	scatter = SCATTER_AMOUNT_TIER_3
	bonus_projectiles_type = /datum/ammo/energy/darkmatter/scatter/spread
	bonus_projectiles_amount = EXTRA_PROJECTILES_TIER_4

/datum/ammo/energy/darkmatter/scatter/spread
	bonus_projectiles_amount = 0
	scatter = SCATTER_AMOUNT_TIER_1

/// Short-ranged plasma of a plasma cutter, from Baystation 12's /obj/item/projectile/beam/plasmacutter
/datum/ammo/energy/plasmacutter
	name = "plasma arc"
	icon_state = "ion"
	damage = 25
	penetration = ARMOR_PENETRATION_TIER_6
	accurate_range = 3
	max_range = 5
	shell_speed = AMMO_SPEED_TIER_3
	hit_effect_color = "#FF8C00"
