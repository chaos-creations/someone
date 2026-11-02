/**
 * Adds every map insert this node could schedule to inserts, for the admin Nightmare menu
 *
 * Arguments:
 * * inserts - list(insert id = insert data) being filled, see [/datum/nmnode/proc/add_catalogue_insert]
 * * notes - conditions inherited from parent nodes, as readable strings
 * * group - name of the closest pick node, to group its choices together
 */
/datum/nmnode/proc/catalogue_inserts(datum/nmcontext/context, list/inserts, list/notes, group)
	return

/// Returns the conditions and chance of this node itself as readable strings
/datum/nmnode/proc/get_notes()
	. = list()
	var/list/conds = raw["when"]
	if(islist(conds))
		for(var/pname in conds)
			if(copytext(pname, 1, 2) == "!")
				. += "[copytext(pname, 2)] != [conds[pname]]"
			else
				. += "[pname] = [conds[pname]]"
	if(isnum(raw["chance"]))
		. += "[raw["chance"] * 100]% chance"
	return .

/// Adds one insert to the catalogue. Its id matches the landmark and path of the /datum/nmtask/mapload it would schedule
/datum/nmnode/proc/add_catalogue_insert(datum/nmcontext/context, list/inserts, list/notes, group, filepath, landmark, keep)
	var/insert_id = NIGHTMARE_INSERT_ID(landmark, filepath)
	if(inserts[insert_id])
		return
	inserts[insert_id] = list(
		"id" = insert_id,
		"group" = group,
		"landmark" = landmark,
		"path" = filepath,
		"file" = replacetext(filepath, "[context.config["prefix_map"]]/", ""),
		"keep" = !!keep,
		"notes" = jointext(notes, ", "),
	)
