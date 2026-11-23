#define SGT_VARIANT "Sergeant"
#define CPL_VARIANT "Corporal"
#define LCPL_VARIANT "Lance Corporal"
#define PFC_VARIANT "Private First Class"

/datum/job/marine/medic/forecon
	title = JOB_SQUAD_MEDIC_FORECON
	total_positions = 1
	spawn_positions = 1
	gear_preset = /datum/equipment_preset/uscm/medic/forecon
	job_options = list(SGT_VARIANT = "SGT", CPL_VARIANT = "CPL", LCPL_VARIANT = "LCPL", PFC_VARIANT = "PFC")
	variant_presets = list(
		CPL_VARIANT = /datum/equipment_preset/uscm/medic/forecon/corporal,
		LCPL_VARIANT = /datum/equipment_preset/uscm/medic/forecon/lance_corporal,
		PFC_VARIANT = /datum/equipment_preset/uscm/medic/forecon/pfc,
	)

/datum/job/marine/medic/forecon/on_config_load()
	entry_message_body = "You keep your recon team alive. You may not be a fully-fledged doctor, but you stand between life and death when it matters. Your personal gear and uniform are in your locker in the dorms."
	return ..()

/datum/job/marine/medic/forecon/set_spawn_positions(count)
	return

/datum/job/marine/medic/forecon/get_total_positions(latejoin = 0)
	return latejoin ? total_positions : spawn_positions

/obj/effect/landmark/start/marine/medic/forecon
	name = JOB_SQUAD_MEDIC_FORECON
	squad = SQUAD_FORECON
	job = /datum/job/marine/medic/forecon

#undef SGT_VARIANT
#undef CPL_VARIANT
#undef LCPL_VARIANT
#undef PFC_VARIANT
