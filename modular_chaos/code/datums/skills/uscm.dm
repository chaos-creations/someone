// Skill sets of the FORECON platoon, ported from cmss13-pve: the squad sets with master endurance.

/datum/skills/pfc/recon
	name = "Recon Private"
	skills = list(
		SKILL_ENDURANCE = SKILL_ENDURANCE_MASTER,
	)

/datum/skills/combat_medic/recon
	name = "Recon Medic"
	skills = list(
		SKILL_FIREMAN = SKILL_FIREMAN_TRAINED,
		SKILL_MEDICAL = SKILL_MEDICAL_DOCTOR,
		SKILL_SURGERY = SKILL_SURGERY_NOVICE,
		SKILL_JTAC = SKILL_JTAC_BEGINNER,
		SKILL_ENDURANCE = SKILL_ENDURANCE_MASTER,
	)

/datum/skills/smartgunner/recon
	name = "Recon Smartgunner"
	skills = list(
		SKILL_FIREMAN = SKILL_FIREMAN_TRAINED,
		SKILL_SPEC_WEAPONS = SKILL_SPEC_SMARTGUN,
		SKILL_JTAC = SKILL_JTAC_BEGINNER,
		SKILL_ENDURANCE = SKILL_ENDURANCE_MASTER,
	)

/datum/skills/tl/recon
	name = "Recon Fireteam Leader"
	skills = list(
		SKILL_FIREMAN = SKILL_FIREMAN_TRAINED,
		SKILL_ENGINEER = SKILL_ENGINEER_TRAINED,
		SKILL_CONSTRUCTION = SKILL_CONSTRUCTION_ENGI,
		SKILL_JTAC = SKILL_JTAC_EXPERT,
		SKILL_LEADERSHIP = SKILL_LEAD_TRAINED,
		SKILL_ENDURANCE = SKILL_ENDURANCE_MASTER,
	)
