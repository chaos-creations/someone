#define SSGT_VARIANT "Staff Sergeant"
#define SGT_VARIANT "Sergeant"

/datum/job/marine/tl/forecon
	title = JOB_SQUAD_TEAM_LEADER_FORECON
	total_positions = 1
	spawn_positions = 1
	gear_preset = /datum/equipment_preset/uscm/tl/forecon
	job_options = list(SSGT_VARIANT = "SSGT", SGT_VARIANT = "SGT")
	variant_presets = list(SGT_VARIANT = /datum/equipment_preset/uscm/tl/forecon/sergeant)

/datum/job/marine/tl/forecon/on_config_load()
	entry_message_body = "You are the second in command of your recon team. Help the squad leader run it and take over if they fall. Your personal gear and uniform are in your locker in the dorms."
	return ..()

/obj/effect/landmark/start/marine/tl/forecon
	name = JOB_SQUAD_TEAM_LEADER_FORECON
	squad = SQUAD_FORECON
	job = /datum/job/marine/tl/forecon

#undef SSGT_VARIANT
#undef SGT_VARIANT
