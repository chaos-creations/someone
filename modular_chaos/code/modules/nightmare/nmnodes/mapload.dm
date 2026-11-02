/datum/nmnode/mapload/landmark/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	if(!group)
		group = (name == id) ? landmark : name
	add_catalogue_insert(context, inserts, notes + get_notes(), group, context.get_file_path(filepath, "map"), landmark, keep)

/datum/nmnode/mapload/variations/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	if(!landmark)
		return
	notes = notes + get_notes()
	var/dir_path = context.get_file_path(filepath, "map")
	// Same files as /datum/nmnode/mapload/variations/resolve() picks from
	var/regex/matcher = new(@"^([0-9]+)([\.\+]).*?\.dmm$", "i")
	var/list/weights = list()
	var/sum = 0
	for(var/filename in flist(dir_path))
		if(!matcher.Find(filename))
			continue
		weights[filename] = text2num(matcher.group[1])
		sum += weights[filename]
	for(var/filename in weights)
		matcher.Find(filename)
		add_catalogue_insert(context, inserts, notes + "weight [weights[filename]]/[sum]", name, "[dir_path][matcher.match]", landmark, matcher.group[2] == "+")

/datum/nmnode/mapload/sprinkles/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	notes = notes + get_notes()
	var/dir_path = context.get_file_path(filepath, "map")
	// Same files and landmarks as /datum/nmnode/mapload/sprinkles/resolve() rolls
	var/regex/matcher = new(@"^([0-9]+)([\.\+])(([^_]+)(.*))?\.dmm$", "i")
	for(var/filename in flist(dir_path))
		if(!matcher.Find(filename) || !matcher.group[3])
			continue
		add_catalogue_insert(context, inserts, notes + "[matcher.group[1]]% chance", "[name]: [filepath]", "[dir_path][matcher.match]", matcher.group[3], matcher.group[2] == "+")
