/datum/nmnode/branch/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	notes = notes + get_notes()
	for(var/datum/nmnode/node as anything in nodes)
		node.catalogue_inserts(context, inserts, notes, group)

/datum/nmnode/branch/include/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	var/list/datum/nmnode/nodes = SSnightmare.parse_file(context.get_file_path(filepath, "nightmare"))
	notes = notes + get_notes()
	for(var/datum/nmnode/node as anything in nodes)
		node.catalogue_inserts(context, inserts, notes, group)
	QDEL_LIST(nodes)

/datum/nmnode/picker/resolve(datum/nmcontext/context)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(!.)
		return
	// Only picked definitions get resolved, so catalogue every possible one here
	for(var/datum/nmnode/scenario_def/def in choices)
		def.catalogue(context)
	return .

/datum/nmnode/picker/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	notes = notes + get_notes()
	if(name != id)
		group = name
	var/total_weight = 0
	for(var/datum/nmnode/node as anything in choices)
		total_weight += isnum(node.raw["weight"]) ? node.raw["weight"] : 1
	for(var/datum/nmnode/node as anything in choices)
		var/weight = isnum(node.raw["weight"]) ? node.raw["weight"] : 1
		node.catalogue_inserts(context, inserts, notes + "picks [amount], weight [weight]/[total_weight]", group)
