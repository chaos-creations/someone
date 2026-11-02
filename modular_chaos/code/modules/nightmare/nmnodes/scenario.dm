/// Adds the values this definition can set to the context directory, whether or not it gets picked
/datum/nmnode/scenario_def/proc/catalogue(datum/nmcontext/context)
	for(var/value in values)
		LAZYINITLIST(context.directory[value])
		context.directory[value] |= list(values[value])
