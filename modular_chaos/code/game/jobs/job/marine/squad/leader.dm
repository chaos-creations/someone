#define MSSGT_VARIANT "Master Sergeant"
#define GYSGT_VARIANT "Gunnery Sergeant"

/datum/job/marine/leader/forecon
	title = JOB_SQUAD_LEADER_FORECON
	total_positions = 1
	spawn_positions = 1
	gear_preset = /datum/equipment_preset/uscm/leader/forecon
	job_options = list(MSSGT_VARIANT = "MSSGT", GYSGT_VARIANT = "GYSGT")
	variant_presets = list(GYSGT_VARIANT = /datum/equipment_preset/uscm/leader/forecon/gunnery_sergeant)

/datum/job/marine/leader/forecon/on_config_load()
	entry_message_body = "You lead your recon team. Keep it on task, working together and communicating, and report what you find. Your personal gear and uniform are in your locker in the dorms."
	return ..()

/obj/effect/landmark/start/marine/leader/forecon
	name = JOB_SQUAD_LEADER_FORECON
	squad = SQUAD_FORECON
	job = /datum/job/marine/leader/forecon

#undef MSSGT_VARIANT
#undef GYSGT_VARIANT
