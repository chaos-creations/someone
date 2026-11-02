/datum/nmcontext
	/// All values each scenario parameter can take, as list(name = list(value, ...)). Used by the admin Nightmare menu
	var/list/directory = list()
	/// Every map insert the context could load, built on demand by /datum/controller/subsystem/nightmare/proc/get_inserts(). See /datum/nmnode/proc/add_catalogue_insert()
	var/list/inserts
	/// Admin overrides of inserts, as list(insert id = TRUE to force it, FALSE to block it)
	var/list/insert_overrides = list()
	/// Ids of the inserts that were loaded, as list(insert id = TRUE)
	var/list/loaded_inserts = list()

/datum/nmcontext/Destroy()
	CAN_BE_REDEFINED(TRUE)
	directory = null
	inserts = null
	insert_overrides = null
	loaded_inserts = null
	return ..()

/datum/nmcontext/run_tasks()
	CAN_BE_REDEFINED(TRUE)
	// Every context has resolved its base nodes by now, so all the inserts that rolled are scheduled
	apply_insert_overrides()
	. = ..()
	for(var/datum/nmtask/mapload/task in scheduler.donetasks)
		if(task.loaded)
			loaded_inserts[NIGHTMARE_INSERT_ID(task.landmark, task.filepath)] = TRUE
	return .

/// Removes the scheduled inserts admins blocked and schedules the ones they forced. Called once the base nodes are resolved
/datum/nmcontext/proc/apply_insert_overrides()
	if(!length(insert_overrides))
		return
	var/list/scheduled = list()
	for(var/datum/nmtask/mapload/task in scheduler.tasks)
		var/id = NIGHTMARE_INSERT_ID(task.landmark, task.filepath)
		if(insert_overrides[id] == FALSE)
			scheduler.remove_task(task)
			log_debug("Nightmare: Admin blocked insert [id]")
		else
			scheduled[id] = task
	for(var/id in insert_overrides)
		var/list/insert = inserts?[id]
		if(!insert_overrides[id] || !insert || scheduled[id])
			continue
		// The forced insert replaces whatever rolled for its landmark, unless it only adds on top
		if(!insert["keep"])
			for(var/other_id in scheduled)
				var/datum/nmtask/mapload/other = scheduled[other_id]
				if(other.landmark == insert["landmark"] && !insert_overrides[other_id])
					scheduler.remove_task(other)
					scheduled -= other_id
		var/datum/nmtask/mapload/task = new("Admin forced @ [insert["landmark"]]", insert["path"], insert["landmark"], insert["keep"])
		add_task(task)
		scheduled[id] = task
		log_debug("Nightmare: Admin forced insert [id]")
