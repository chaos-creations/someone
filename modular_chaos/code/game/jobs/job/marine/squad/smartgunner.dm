#define SGT_VARIANT "Sergeant"
#define CPL_VARIANT "Corporal"
#define LCPL_VARIANT "Lance Corporal"
#define PFC_VARIANT "Private First Class"

/datum/job/marine/smartgunner/forecon
	title = JOB_SQUAD_SMARTGUN_FORECON
	total_positions = 1
	spawn_positions = 1
	gear_preset = /datum/equipment_preset/uscm/sg/forecon
	job_options = list(SGT_VARIANT = "SGT", CPL_VARIANT = "CPL", LCPL_VARIANT = "LCPL", PFC_VARIANT = "PFC")
	variant_presets = list(
		CPL_VARIANT = /datum/equipment_preset/uscm/sg/forecon/corporal,
		LCPL_VARIANT = /datum/equipment_preset/uscm/sg/forecon/lance_corporal,
		PFC_VARIANT = /datum/equipment_preset/uscm/sg/forecon/pfc,
	)

/datum/job/marine/smartgunner/forecon/on_config_load()
	entry_message_body = "You are the smartgunner of your recon team. Your task is to provide heavy weapons support. Your personal gear and uniform are in your locker in the dorms."
	return ..()

/datum/job/marine/smartgunner/forecon/set_spawn_positions(count)
	return

/datum/job/marine/smartgunner/forecon/get_total_positions(latejoin = 0)
	return latejoin ? total_positions : spawn_positions

/obj/effect/landmark/start/marine/smartgunner/forecon
	name = JOB_SQUAD_SMARTGUN_FORECON
	squad = SQUAD_FORECON
	job = /datum/job/marine/smartgunner/forecon

#undef SGT_VARIANT
#undef CPL_VARIANT
#undef LCPL_VARIANT
#undef PFC_VARIANT
