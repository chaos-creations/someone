/datum/squad
	/**
	 * Jobs of this squad when it crews a ship on its own as the ship's platoon (see [/datum/map_config/var/platoon]).
	 *
	 * Assoc list of job type to the title of the squad role it stands in for (JOB_SQUAD_LEADER and so on). It becomes the
	 * game mode's role_mappings, so a player's preferences and the squad's roles_cap for that role apply to the job.
	 * Null for squads that cannot be a platoon.
	 */
	var/list/platoon_jobs

/datum/squad/marine/forecon
	platoon_jobs = list(
		/datum/job/marine/leader/forecon = JOB_SQUAD_LEADER,
		/datum/job/marine/tl/forecon = JOB_SQUAD_TEAM_LEADER,
		/datum/job/marine/medic/forecon = JOB_SQUAD_MEDIC,
		/datum/job/marine/smartgunner/forecon = JOB_SQUAD_SMARTGUN,
		/datum/job/marine/standard/rto = JOB_SQUAD_MARINE,
		/datum/job/marine/standard/forecon = JOB_SQUAD_MARINE,
	)

/**
 * Turns this squad into the platoon of the round: the only squad marines join at roundstart and on late join.
 *
 * Other roundstart squads of the same faction stop taking new marines but keep existing, so whatever looks them up still finds them.
 * The platoon's jobs count as marine roles from then on, so menus, the manifest and squad checks treat them like the usual squad roles.
 * Its gear also loses the squad colour stripes, as platoons have none in cmss13-pve.
 */
/datum/squad/proc/make_platoon()
	for(var/datum/squad/other_squad as anything in GLOB.RoleAuthority.squads)
		if(other_squad == src || other_squad.faction != faction)
			continue
		other_squad.roundstart = FALSE
	roundstart = TRUE
	usable = TRUE
	active = TRUE
	locked = FALSE
	use_stripe_overlay = FALSE
	for(var/datum/job/platoon_job as anything in platoon_jobs)
		var/job_title = initial(platoon_job.title)
		GLOB.ROLES_MARINES |= job_title
		GLOB.ROLES_USCM |= job_title
