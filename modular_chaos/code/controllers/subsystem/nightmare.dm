/// Returns every map insert context_name could load, as list(insert id = insert data), for the admin Nightmare menu
/datum/controller/subsystem/nightmare/proc/get_inserts(context_name)
	var/datum/nmcontext/context = contexts[context_name]
	if(!context.inserts)
		context.inserts = list()
		var/datum/nmnode/root = roots["[context_name]-[NIGHTMARE_ACT_BASE]"]
		root?.catalogue_inserts(context, context.inserts, list())
	return context.inserts

/datum/controller/subsystem/nightmare/load_map_config(context_name, map_type)
	CAN_BE_REDEFINED(TRUE)
	// Re-implements the upstream proc, whose map prefix is always in maps/, with the map_root of the map
	var/datum/map_config/map_config = SSmapping.configs[map_type]
	var/datum/nmcontext/context = new /datum/nmcontext/map
	contexts[context_name] = context
	context.config["prefix_map"] = "[map_config.map_root][map_config.map_path]"
	context.config["prefix_nightmare"] = map_config.nightmare_path
	load_file("[map_config.nightmare_path]/[NIGHTMARE_FILE_SCENARIO]", "[context_name]-[NIGHTMARE_ACT_SCENARIO]")
	load_file("[map_config.nightmare_path]/[NIGHTMARE_FILE_BASE]", "[context_name]-[NIGHTMARE_ACT_BASE]")
	log_debug("Nightmare: Loaded map environment {[context_name],[map_type]}")
