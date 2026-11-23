// Presets of the FORECON platoon, ported from cmss13-pve. They give only the ID: the rest of the gear, the backpack
// included, waits in the marine's personal locker (/obj/structure/closet/secure_closet/marine_personal) and the platoon's vendors.

//*****************************************************************************************************/

/datum/equipment_preset/uscm/pfc/forecon
	name = "FORECON Squad Rifleman"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	assignment = JOB_SQUAD_MARINE_FORECON
	job_title = JOB_SQUAD_MARINE_FORECON
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/pfc/recon

/datum/equipment_preset/uscm/pfc/forecon/load_gear(mob/living/carbon/human/new_human)
	return // no backpack, see the top of the file

/datum/equipment_preset/uscm/pfc/forecon/pfc
	name = parent_type::name + " (E2 Rank)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/uscm/pfc/forecon/corporal
	name = parent_type::name + " (E4 Rank)"
	paygrades = list(PAY_SHORT_ME4 = JOB_PLAYTIME_TIER_0)

//*****************************************************************************************************/

/datum/equipment_preset/uscm/sg/forecon
	name = "FORECON Squad Smartgunner"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE
	assignment = JOB_SQUAD_SMARTGUN_FORECON
	job_title = JOB_SQUAD_SMARTGUN_FORECON
	paygrades = list(PAY_SHORT_ME5 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/smartgunner/recon

/datum/equipment_preset/uscm/sg/forecon/load_gear(mob/living/carbon/human/new_human)
	return // no backpack, see the top of the file

/datum/equipment_preset/uscm/sg/forecon/corporal
	name = parent_type::name + " (E4 Rank)"
	paygrades = list(PAY_SHORT_ME4 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/uscm/sg/forecon/lance_corporal
	name = parent_type::name + " (E3 Rank)"
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/uscm/sg/forecon/pfc
	name = parent_type::name + " (E2 Rank)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

//*****************************************************************************************************/

/datum/equipment_preset/uscm/rto
	name = "FORECON Radio Telephone Operator"
	flags = EQUIPMENT_PRESET_EXTRA|EQUIPMENT_PRESET_MARINE

	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SPECPREP)
	assignment = JOB_SQUAD_RTO
	job_title = JOB_SQUAD_RTO
	paygrades = list(PAY_SHORT_ME4 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "RTO"
	skills = /datum/skills/pfc/recon

	minimap_icon = "private"
	dress_under = list(/obj/item/clothing/under/marine/dress/blues)
	dress_over = list(/obj/item/clothing/suit/storage/jacket/marine/dress/blues)

/datum/equipment_preset/uscm/rto/lance_corporal
	name = parent_type::name + " (E3 Rank)"
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/uscm/rto/pfc
	name = parent_type::name + " (E2 Rank)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

//*****************************************************************************************************/

/datum/equipment_preset/uscm/medic/forecon
	name = "FORECON Squad Corpsman"
	assignment = JOB_SQUAD_MEDIC_FORECON
	job_title = JOB_SQUAD_MEDIC_FORECON
	paygrades = list(PAY_SHORT_ME5 = JOB_PLAYTIME_TIER_0)
	skills = /datum/skills/combat_medic/recon

/datum/equipment_preset/uscm/medic/forecon/load_gear(mob/living/carbon/human/new_human)
	return // no backpack, see the top of the file

/datum/equipment_preset/uscm/medic/forecon/corporal
	name = parent_type::name + " (E4 Rank)"
	paygrades = list(PAY_SHORT_ME4 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/uscm/medic/forecon/lance_corporal
	name = parent_type::name + " (E3 Rank)"
	paygrades = list(PAY_SHORT_ME3 = JOB_PLAYTIME_TIER_0)

/datum/equipment_preset/uscm/medic/forecon/pfc
	name = parent_type::name + " (E2 Rank)"
	paygrades = list(PAY_SHORT_ME2 = JOB_PLAYTIME_TIER_0)

//*****************************************************************************************************/

/datum/equipment_preset/uscm/tl/forecon
	name = "FORECON Assistant Squad Leader"
	assignment = JOB_SQUAD_TEAM_LEADER_FORECON
	job_title = JOB_SQUAD_TEAM_LEADER_FORECON
	paygrades = list(PAY_SHORT_ME6 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "ARSL"
	skills = /datum/skills/tl/recon

/datum/equipment_preset/uscm/tl/forecon/load_gear(mob/living/carbon/human/new_human)
	return // no backpack, see the top of the file

/datum/equipment_preset/uscm/tl/forecon/sergeant
	name = parent_type::name + " (E5 Rank)"
	paygrades = list(PAY_SHORT_ME5 = JOB_PLAYTIME_TIER_0)

//*****************************************************************************************************/

/datum/equipment_preset/uscm/leader/forecon
	name = "FORECON Squad Leader"
	assignment = JOB_SQUAD_LEADER_FORECON
	job_title = JOB_SQUAD_LEADER_FORECON
	paygrades = list(PAY_SHORT_ME8 = JOB_PLAYTIME_TIER_0)
	role_comm_title = "RSL"

/datum/equipment_preset/uscm/leader/forecon/load_gear(mob/living/carbon/human/new_human)
	return // no backpack, see the top of the file

/datum/equipment_preset/uscm/leader/forecon/gunnery_sergeant
	name = parent_type::name + " (E7 Rank)"
	paygrades = list(PAY_SHORT_ME7 = JOB_PLAYTIME_TIER_0)
