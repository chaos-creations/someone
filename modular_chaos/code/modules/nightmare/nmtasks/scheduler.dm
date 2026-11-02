/// Unschedules and deletes a task that has not run yet
/datum/nmtask/scheduler/proc/remove_task(datum/nmtask/task)
	tasks -= task
	qdel(task)
