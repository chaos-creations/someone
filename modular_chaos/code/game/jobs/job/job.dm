/datum/job
	/// Gear presets of the job_options: assoc list of option name (a key of job_options) to preset type. An option missing here uses the initial gear_preset
	var/list/variant_presets

/datum/job/handle_job_options(option)
	CAN_BE_REDEFINED(TRUE)
	if(!variant_presets)
		return ..()
	gear_preset = variant_presets[option] || initial(gear_preset)
