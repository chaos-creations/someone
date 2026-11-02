/// Returns every map insert context_name could load, as list(insert id = insert data), for the admin Nightmare menu
/datum/controller/subsystem/nightmare/proc/get_inserts(context_name)
	var/datum/nmcontext/context = contexts[context_name]
	if(!context.inserts)
		context.inserts = list()
		var/datum/nmnode/root = roots["[context_name]-[NIGHTMARE_ACT_BASE]"]
		root?.catalogue_inserts(context, context.inserts, list())
	return context.inserts
