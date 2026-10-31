// The Purgatory tab of the changelog: the fork's own entries, collected from commit messages by modular_chaos/tools/changelog.py

#define PURGATORY_CHANGELOG_ARCHIVE "modular_chaos/html/changelogs/archive/"

/datum/changelog
	/// Asset of each Purgatory changelog month requested so far, by date ("2026-10")
	var/static/list/purgatory_changelog_items = list()

/datum/changelog/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(.)
		return
	if(action != "get_purgatory_month")
		return
	var/date = params["date"]
	if(!(date in get_purgatory_changelog_dates()))
		return
	var/datum/asset/changelog_item/purgatory/changelog_item = purgatory_changelog_items[date]
	if(!changelog_item)
		changelog_item = new /datum/asset/changelog_item/purgatory(date)
		purgatory_changelog_items[date] = changelog_item
	return ui.send_asset(changelog_item)

/datum/changelog/ui_static_data()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	.["purgatory_dates"] = get_purgatory_changelog_dates()

/// Months ("2026-10") of the Purgatory changelog, newest first
/proc/get_purgatory_changelog_dates()
	var/list/dates = list()
	for(var/archive_file in sort_list(flist(PURGATORY_CHANGELOG_ARCHIVE)))
		if(copytext(archive_file, -4) != ".yml")
			continue
		dates.Insert(1, copytext(archive_file, 1, -4))
	return dates

/// Hash of this month of the Purgatory changelog, added to GLOB.changelog_hash so that new entries bold the changelog button
/proc/get_purgatory_changelog_hash()
	var/latest_changelog = file("[global.config.directory]/../[PURGATORY_CHANGELOG_ARCHIVE]" + time2text(world.timeofday, "YYYY-MM") + ".yml")
	return fexists(latest_changelog) ? md5(latest_changelog) : ""

/// A month of the Purgatory changelog, sent under a "purgatory-" name so that it does not clash with the same month of the upstream changelog
/datum/asset/changelog_item/purgatory
	_abstract = /datum/asset/changelog_item/purgatory

/datum/asset/changelog_item/purgatory/New(date)
	item_filename = SANITIZE_FILENAME("purgatory-[date].yml")
	SSassets.transport.register_asset(item_filename, file(PURGATORY_CHANGELOG_ARCHIVE + SANITIZE_FILENAME("[date].yml")))

#undef PURGATORY_CHANGELOG_ARCHIVE
