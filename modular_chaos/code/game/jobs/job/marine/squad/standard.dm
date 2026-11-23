#define CPL_VARIANT "Corporal"
#define LCPL_VARIANT "Lance Corporal"
#define PFC_VARIANT "Private First Class"

/datum/job/marine/standard/forecon
	title = JOB_SQUAD_MARINE_FORECON
	total_positions = 2
	spawn_positions = 2
	gear_preset = /datum/equipment_preset/uscm/pfc/forecon
	job_options = list(LCPL_VARIANT = "LCPL", PFC_VARIANT = "PFC", CPL_VARIANT = "CPL")
	variant_presets = list(
		PFC_VARIANT = /datum/equipment_preset/uscm/pfc/forecon/pfc,
		CPL_VARIANT = /datum/equipment_preset/uscm/pfc/forecon/corporal,
	)

/datum/job/marine/standard/forecon/on_config_load()
	. = ..()
	entry_message_body = "You are a rifleman of a recon team, and that is your strength. What you lack alone, you gain standing shoulder to shoulder with the rest of the team. Your personal gear and uniform are in your locker in the dorms."

/datum/job/marine/standard/forecon/set_spawn_positions(count)
	return

/datum/job/marine/standard/rto
	title = JOB_SQUAD_RTO
	total_positions = 1
	spawn_positions = 1
	gear_preset = /datum/equipment_preset/uscm/rto
	job_options = list(CPL_VARIANT = "CPL", LCPL_VARIANT = "LCPL", PFC_VARIANT = "PFC")
	variant_presets = list(
		LCPL_VARIANT = /datum/equipment_preset/uscm/rto/lance_corporal,
		PFC_VARIANT = /datum/equipment_preset/uscm/rto/pfc,
	)

/datum/job/marine/standard/rto/on_config_load()
	. = ..()
	entry_message_body = "You are the radio telephone operator of a recon team: you keep it in touch with the ship and call in what it needs. Your personal gear and uniform are in your locker in the dorms."

/datum/job/marine/standard/rto/set_spawn_positions(count)
	return

/obj/effect/landmark/start/marine/forecon
	name = JOB_SQUAD_MARINE_FORECON
	squad = SQUAD_FORECON
	job = /datum/job/marine/standard/forecon

/obj/effect/landmark/start/marine/rto
	name = JOB_SQUAD_RTO
	squad = SQUAD_FORECON
	job = /datum/job/marine/standard/rto

#undef CPL_VARIANT
#undef LCPL_VARIANT
#undef PFC_VARIANT
