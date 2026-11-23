// Ported from cmss13-pve for the USS Rover and its FORECON platoon

/datum/ammo/bullet/rifle/tracer
	icon_state = "bullet_red"

/datum/ammo/bullet/rifle/m4ra/du
	name = "A19 high velocity depleted uranium bullet"

	damage = 50 //Overall same damage as base rounds, but 15 tox DoT
	penetration = ARMOR_PENETRATION_TIER_10 //DU's a heavy armour-piercing kind of material
	accuracy = HIT_ACCURACY_TIER_4
	scatter = -SCATTER_AMOUNT_TIER_8

/datum/ammo/bullet/rifle/m4ra/du/set_bullet_traits()
	. = ..()
	LAZYADD(traits_to_give, list(
		BULLET_TRAIT_ENTRY(/datum/element/bullet_trait_penetrating)
	))

/datum/ammo/bullet/rifle/m4ra/du/on_hit_mob(mob/target, obj/projectile/fired_proj)
	target.AddComponent(/datum/component/status_effect/toxic_buildup, toxic_buildup = 15, toxic_buildup_dissipation = 0.3, max_buildup = 75)
	knockback(target, fired_proj, 16) // Can knockback out to 2/3rds-range
	if(target.mob_size >= MOB_SIZE_BIG)
		var/mob/living/L = target
		L.apply_armoured_damage(damage*1.3, ARMOR_BULLET, BRUTE, null, penetration) // As bugs don't take toxin damage, this should give it a little more oomf versus them
