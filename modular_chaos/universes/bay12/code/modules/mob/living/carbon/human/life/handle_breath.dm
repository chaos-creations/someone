/// Toxin damage of a breath of a gas that poisons the species (/datum/species/var/poisonous_gases)
#define BREATH_POISON_DAMAGE 1

/**
 * Suffocates a species that can't breathe the gas (/datum/species/var/breathable_gases), as if there were no air,
 * and poisons it with a gas that is poisonous to it; any other breath goes to upstream
 */
/mob/living/carbon/human/handle_breath(list/air_info)
	CAN_BE_REDEFINED(TRUE)
	if(!air_info || (status_flags & GODMODE) || !species?.breathable_gases || (air_info[1] in species.breathable_gases))
		return ..()
	oxygen_alert = max(oxygen_alert, 1)
	apply_damage(HUMAN_MAX_OXYLOSS, OXY)
	if(air_info[1] in species.poisonous_gases)
		apply_damage(BREATH_POISON_DAMAGE, TOX)
	return FALSE

#undef BREATH_POISON_DAMAGE
