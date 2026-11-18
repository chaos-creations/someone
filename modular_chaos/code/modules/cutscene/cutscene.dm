/**
 * A scripted scene played for the players who walk up to its [/obj/effect/landmark/cutscene_trigger]
 *
 * A cutscene is written as the body of [/datum/cutscene/proc/play], top to bottom, with the helper procs below.
 * Each helper sleeps for as long as its part of the scene takes, so the scene goes on line by line,
 * and a dialogue branches with plain DM on what [/datum/cutscene/proc/choose] returns:
 *
 * ```dm
 * /datum/cutscene/checkpoint
 * 	title = "Checkpoint"
 * 	elect_leader = TRUE
 * 	required_actors = list("checkpoint_guard")
 *
 * /datum/cutscene/checkpoint/play()
 * 	var/mob/living/guard = actor("checkpoint_guard")
 * 	emote(guard, "raises a hand.")
 * 	say(guard, "Stop right there. Who are you?")
 * 	switch(choose("What do you answer?", list("friend" = "Colonial Marines, we're here to help.", "rude" = "None of your business.")))
 * 		if("friend")
 * 			say(guard, "Thank god. Go on through.")
 * 		if("rude")
 * 			say(guard, "Suit yourself.")
 * 	narrate("The gate creaks open.")
 * ```
 *
 * Players who walk up to the trigger become participants. While the cutscene plays they see black bars with subtitles,
 * their cameras glide to whoever speaks, and they can't move or click the world.
 * If the cutscene has a choice, the participants first vote for a leader by clicking a character.
 * The answers then show up beside the leader, and only the leader can click one.
 *
 * When play() returns (or runtimes, or an admin aborts the cutscene with [/datum/cutscene/proc/abort]),
 * the cutscene finishes: the [/obj/structure/blocker/invisible_wall/cutscene] walls with its ID are removed
 * and the participants are let go.
 */
/datum/cutscene
	/// Name of the cutscene in logs and admin messages
	var/title = "Cutscene"
	/// Whether the participants vote for a leader as soon as the cutscene starts. Without it they vote on the first [/datum/cutscene/proc/choose]
	var/elect_leader = FALSE
	/// Whether the participants can't move or click the world while the cutscene plays
	var/freeze_participants = TRUE
	/// Whether the black bars with subtitles are shown
	var/show_letterbox = TRUE
	/// Whether the participants' HUD (inventory, action buttons) is hidden while the cutscene plays, as with F12
	var/hide_hud = TRUE
	/// Whether the cameras of the participants glide to whoever says or does something
	var/camera_follows_speaker = TRUE
	/// How long the cameras take to glide to a new focus
	var/camera_pan_time = 1 SECONDS
	/// IDs of the [/obj/effect/landmark/cutscene_actor] whose actors must be alive for the cutscene to play. If one is missing or dead, the cutscene is skipped and finishes at once
	var/list/required_actors = list()
	/// Longest the leader vote lasts. It ends earlier once every participant has voted
	var/vote_duration = 20 SECONDS
	/// How long the leader has to pick an answer before the default answer is picked
	var/choice_duration = 60 SECONDS
	/// How long a line stays before the next one, per character of its text
	var/line_delay_per_character = 0.1 SECONDS
	/// Shortest time a line stays before the next one
	var/line_delay_minimum = 3 SECONDS

	/// ID of the trigger that started the cutscene, also the ID of the walls removed when it finishes
	var/cutscene_id
	/// Mobs of the players watching the cutscene
	var/list/mob/participants = list()
	/// Clients the cutscene is shown to, as list(participant mob = client). The client is null while the participant is logged out
	var/list/viewers = list()
	/// HUD versions of the participants whose HUD is hidden, to restore when the cutscene ends, as list(participant mob = HUD_STYLE_* define)
	var/list/hidden_hud_versions = list()
	/// The participant who picks the answers, null until voted for
	var/mob/leader
	/// What the participants are doing, one of the CUTSCENE_PHASE_* defines
	var/phase = CUTSCENE_PHASE_PLAYING
	/// Votes for the leader, as list(REF(voter) = REF(candidate))
	var/list/leader_votes = list()
	/// When the current vote or choice ends, as world.time
	var/phase_deadline
	/// Answers of the current choice, as list(answer ID = text)
	var/list/choice_options
	/// ID of the answer the leader picked in the current choice, null until then
	var/picked_option
	/// Whether [/datum/cutscene/proc/start] has been called
	var/started = FALSE
	/// Whether the cutscene has finished. Helpers stop play() once it is set
	var/finished = FALSE

	/// Atom the cameras of the participants point at, null for their own mobs
	var/atom/camera_focus
	/// Black bars at the top and bottom of the screen, a list for adding to and removing from screens
	var/list/atom/movable/screen/cutscene/letterbox/letterbox_bars = list()
	/// Subtitles in the bottom bar
	var/atom/movable/screen/cutscene/subtitle/subtitle
	/// Thoughts of the answers of the current choice
	var/list/atom/movable/screen/cutscene/thought/option_screens = list()
	/// Vote counters above the candidates during the leader vote, as list(candidate mob = image)
	var/list/vote_counters = list()

/datum/cutscene/New(cutscene_id, list/mob/participants)
	. = ..()
	src.cutscene_id = cutscene_id
	if(show_letterbox)
		letterbox_bars += new /atom/movable/screen/cutscene/letterbox
		subtitle = new
	for(var/mob/participant as anything in participants)
		add_participant(participant)

/datum/cutscene/Destroy(force)
	finish()
	for(var/mob/participant as anything in participants.Copy())
		remove_participant(participant)
	clear_options()
	clear_vote_counters()
	QDEL_LIST(letterbox_bars)
	QDEL_NULL(subtitle)
	camera_focus = null
	leader = null
	return ..()

/**
 * The scene itself, see [/datum/cutscene]
 *
 * Called by [/datum/cutscene/proc/start] once everything is set up. The cutscene finishes when it returns.
 */
/datum/cutscene/proc/play()
	return

/**
 * Plays the cutscene from start to finish. Sleeps until it finishes
 *
 * Skips it if one of the required actors is missing or dead.
 */
/datum/cutscene/proc/start()
	started = TRUE
	for(var/actor_id in required_actors)
		var/mob/living/required_actor = actor(actor_id)
		if(QDELETED(required_actor) || required_actor.stat == DEAD)
			log_game("Cutscene [type] ([cutscene_id]) was skipped, its actor [actor_id] is missing or dead.")
			finish()
			return

	log_game("Cutscene [type] ([cutscene_id]) started for [english_list(participants)].")
	message_admins("Cutscene [title] ([cutscene_id]) started for [length(participants)] player\s.")

	for(var/obj/structure/blocker/invisible_wall/cutscene/wall as anything in LAZYACCESS(GLOB.cutscene_walls, cutscene_id))
		wall.on_cutscene_start()
	for(var/mob/participant as anything in participants)
		set_up_participant(participant)
	for(var/atom/movable/screen/cutscene/letterbox/bar as anything in letterbox_bars)
		bar.slide_in()

	try
		if(elect_leader)
			run_leader_vote()
		play()
	catch(var/exception/error)
		if(error.name != CUTSCENE_ABORTED)
			stack_trace("Cutscene [type] runtimed: [error.name] at [error.file]:[error.line]")
	finish()

/// Stops the cutscene in the middle and finishes it. play() stops at its next helper call
/datum/cutscene/proc/abort()
	if(finished)
		return
	log_game("Cutscene [type] ([cutscene_id]) was aborted.")
	finish()

/// Removes the walls, returns the cameras, lets the participants go and deletes the cutscene once the bars slide out
/datum/cutscene/proc/finish()
	if(finished)
		return
	finished = TRUE
	phase = CUTSCENE_PHASE_FINISHED

	var/list/walls = LAZYACCESS(GLOB.cutscene_walls, cutscene_id)
	for(var/obj/structure/blocker/invisible_wall/cutscene/wall as anything in walls?.Copy())
		qdel(wall)
	clear_options()
	clear_vote_counters()
	set_subtitle(null)
	focus_camera(null)
	for(var/mob/participant as anything in participants)
		REMOVE_TRAIT(participant, TRAIT_IMMOBILIZED, TRAIT_SOURCE_CUTSCENE)
		UnregisterSignal(participant, list(COMSIG_MOB_PRE_CLICK, COMSIG_MOB_RESET_VIEW))
	for(var/atom/movable/screen/cutscene/letterbox/bar as anything in letterbox_bars)
		bar.slide_out()
	for(var/mob/participant as anything in participants)
		restore_hud(participant)

	SEND_SIGNAL(src, COMSIG_CUTSCENE_FINISHED)
	if(!QDELETED(src))
		QDEL_IN(src, max(camera_pan_time, CUTSCENE_LETTERBOX_TIME))

// Participants

/**
 * Makes the mob a participant of the cutscene. Does nothing if it already is one or the cutscene has finished
 *
 * A participant added after the start, like a player who walks up while it plays, joins in at once.
 */
/datum/cutscene/proc/add_participant(mob/participant)
	if(finished || (participant in participants))
		return
	participants += participant
	viewers[participant] = participant.client
	RegisterSignal(participant, COMSIG_PARENT_QDELETING, PROC_REF(on_participant_deleted))
	RegisterSignal(participant, COMSIG_MOB_LOGIN, PROC_REF(on_participant_login))
	RegisterSignal(participant, COMSIG_MOB_LOGOUT, PROC_REF(on_participant_logout))
	// Before start() the participants are set up all together
	if(started)
		set_up_participant(participant)

/// Freezes the participant if the cutscene does that and shows them the cutscene
/datum/cutscene/proc/set_up_participant(mob/participant)
	if(freeze_participants)
		ADD_TRAIT(participant, TRAIT_IMMOBILIZED, TRAIT_SOURCE_CUTSCENE)
	RegisterSignal(participant, COMSIG_MOB_PRE_CLICK, PROC_REF(on_participant_click), override = TRUE)
	RegisterSignal(participant, COMSIG_MOB_RESET_VIEW, PROC_REF(on_participant_reset_view), override = TRUE)
	hide_participant_hud(participant)
	show_to(viewers[participant])
	update_camera(participant)

/// Removes the mob from the participants and lets it go
/datum/cutscene/proc/remove_participant(mob/participant)
	if(!(participant in participants))
		return
	// The HUD first, since bringing it back clears the screen and shows the cutscene again
	restore_hud(participant)
	hide_from(viewers[participant])
	participants -= participant
	viewers -= participant
	leader_votes -= REF(participant)
	UnregisterSignal(participant, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_MOB_PRE_CLICK, COMSIG_MOB_RESET_VIEW))
	if(camera_focus && !QDELETED(participant))
		participant.reset_view(null)
	REMOVE_TRAIT(participant, TRAIT_IMMOBILIZED, TRAIT_SOURCE_CUTSCENE)
	if(leader == participant)
		leader = null

/datum/cutscene/proc/on_participant_deleted(mob/participant)
	SIGNAL_HANDLER
	remove_participant(participant)

/// The player came back to the participant: shows the cutscene to their client again
/datum/cutscene/proc/on_participant_login(mob/participant)
	SIGNAL_HANDLER
	viewers[participant] = participant.client
	if(started && !finished)
		// Logging in shows the HUD again
		hidden_hud_versions -= participant
		hide_participant_hud(participant)
		show_to(participant.client)
		update_camera(participant)

/// The player left the participant (ghosted, disconnected): their client no longer sees the cutscene
/datum/cutscene/proc/on_participant_logout(mob/participant)
	SIGNAL_HANDLER
	hide_from(viewers[participant])
	viewers[participant] = null

/// Keeps anything else from moving the participant's camera off the cutscene's focus
/datum/cutscene/proc/on_participant_reset_view(mob/participant, atom/focus)
	SIGNAL_HANDLER
	if(camera_focus && !finished)
		return COMPONENT_OVERRIDE_VIEW
	return NONE

/// Whether the participant can still vote and lead: it is still played by someone and alive
/datum/cutscene/proc/is_active_participant(mob/participant)
	return !QDELETED(participant) && participant.client && participant.stat != DEAD

/// Returns the participants who can still vote and lead
/datum/cutscene/proc/get_active_participants()
	var/list/mob/active_participants = list()
	for(var/mob/participant as anything in participants)
		if(is_active_participant(participant))
			active_participants += participant
	return active_participants

/**
 * Handles every click of a participant while the cutscene plays
 *
 * Clicks on the cutscene's own screen objects (the answers) go through, a click on a candidate during the leader vote
 * is a vote, and any other click is blocked if the participants are frozen.
 */
/datum/cutscene/proc/on_participant_click(mob/participant, atom/clicked_atom, list/mods)
	SIGNAL_HANDLER
	if(istype(clicked_atom, /atom/movable/screen/cutscene))
		return NONE
	if(phase == CUTSCENE_PHASE_VOTE && (clicked_atom in participants))
		vote_for_leader(participant, clicked_atom)
		return COMPONENT_INTERRUPT_CLICK
	if(freeze_participants)
		return COMPONENT_INTERRUPT_CLICK
	return NONE

// Screen and camera

/// Hides the participant's HUD if the cutscene does that, remembering how it was
/datum/cutscene/proc/hide_participant_hud(mob/participant)
	if(!hide_hud || !participant.hud_used || (participant in hidden_hud_versions))
		return
	hidden_hud_versions[participant] = participant.hud_used.hud_version
	// Clears the whole screen, so the cutscene shows itself to the participant again after this
	participant.hud_used.show_hud(HUD_STYLE_NOHUD)

/// Gives the participant their HUD back as it was, and the cutscene's screen objects that are still there
/datum/cutscene/proc/restore_hud(mob/participant)
	if(!(participant in hidden_hud_versions))
		return
	var/hud_version = hidden_hud_versions[participant]
	hidden_hud_versions -= participant
	if(!participant.hud_used || !participant.client)
		return
	participant.hud_used.show_hud(hud_version)
	if(participant in participants)
		show_to(viewers[participant])

/// Shows the bars, subtitles, answers and vote counters to the client
/datum/cutscene/proc/show_to(client/viewer)
	if(!viewer)
		return
	viewer.screen |= letterbox_bars
	if(subtitle)
		viewer.screen |= subtitle
	viewer.screen |= option_screens
	for(var/candidate in vote_counters)
		viewer.images |= vote_counters[candidate]

/// Removes everything the cutscene shows from the client and returns its camera
/datum/cutscene/proc/hide_from(client/viewer)
	if(!viewer)
		return
	viewer.screen -= letterbox_bars
	if(subtitle)
		viewer.screen -= subtitle
	viewer.screen -= option_screens
	for(var/candidate in vote_counters)
		viewer.images -= vote_counters[candidate]
	animate(viewer, pixel_x = 0, pixel_y = 0, time = camera_pan_time, easing = SINE_EASING)

/**
 * Glides the cameras of all participants to the atom
 *
 * * target - What the cameras point at. null returns them to the participants' own mobs
 */
/datum/cutscene/proc/focus_camera(atom/target)
	// Answers are placed around the middle of the screen, so they belong to the old focus
	if(target != camera_focus)
		clear_options()
	camera_focus = target
	for(var/mob/participant as anything in participants)
		update_camera(participant)

/**
 * Glides the camera of the participant to the current focus
 *
 * The client's eye moves to the focus at once, so the map around it is drawn, and a pixel offset that starts
 * where the old eye was and goes to zero makes the move smooth.
 */
/datum/cutscene/proc/update_camera(mob/participant)
	var/client/viewer = viewers[participant]
	if(!viewer)
		return
	var/atom/old_eye = viewer.get_eye()
	var/atom/new_eye = camera_focus || participant
	if(old_eye == new_eye)
		return
	var/turf/old_turf = get_turf(old_eye)
	var/turf/new_turf = get_turf(new_eye)
	if(camera_focus)
		viewer.perspective = EYE_PERSPECTIVE
		viewer.set_eye(camera_focus)
	else
		participant.reset_view(null)
	if(!old_turf || !new_turf || old_turf.z != new_turf.z)
		return
	viewer.set_pixel_x(viewer.get_pixel_x() + (old_turf.x - new_turf.x) * world.icon_size)
	viewer.set_pixel_y(viewer.get_pixel_y() + (old_turf.y - new_turf.y) * world.icon_size)
	animate(viewer, pixel_x = 0, pixel_y = 0, time = camera_pan_time, easing = SINE_EASING)

/// Shows the text as the subtitles. null clears them
/datum/cutscene/proc/set_subtitle(text)
	subtitle?.set_text(text)

/// Returns the name of the speaker for the subtitles, colored as an NPC or as the leader
/datum/cutscene/proc/subtitle_name(speaker)
	if(!ismob(speaker))
		return "<b style='color: [CUTSCENE_COLOR_NPC]'>[speaker]</b>"
	var/mob/speaking_mob = speaker
	return "<b style='color: [(speaking_mob in participants) ? CUTSCENE_COLOR_PLAYER : CUTSCENE_COLOR_NPC]'>[speaking_mob.name]</b>"

// Leader

/**
 * Makes the participants vote for a leader by clicking a character and sleeps until the vote ends
 *
 * The candidate with the most votes wins, ties are broken at random, and if nobody voted a random participant leads.
 * There is no vote with a single participant, who just leads.
 */
/datum/cutscene/proc/run_leader_vote()
	var/list/mob/candidates = get_active_participants()
	if(!length(candidates))
		return
	if(length(candidates) == 1)
		set_leader(candidates[1])
		return

	phase = CUTSCENE_PHASE_VOTE
	leader_votes = list()
	phase_deadline = world.time + vote_duration
	focus_camera(null)
	update_vote_counters()
	for(var/mob/candidate as anything in candidates)
		to_chat(candidate, SPAN_NOTICE("Click a character to vote for who leads the conversation."))

	while(world.time < phase_deadline && length(leader_votes) < length(get_active_participants()))
		set_subtitle("<i>Click a character to choose who leads the conversation ([round((phase_deadline - world.time) * 0.1)]s)</i>")
		sleep(0.5 SECONDS)
		check_aborted()

	var/list/vote_counts = count_leader_votes()
	var/list/mob/winners = list()
	var/most_votes = 0
	for(var/mob/candidate as anything in vote_counts)
		var/votes = vote_counts[candidate]
		if(votes > most_votes)
			most_votes = votes
			winners = list(candidate)
		else if(votes == most_votes)
			winners += candidate

	phase = CUTSCENE_PHASE_PLAYING
	phase_deadline = null
	clear_vote_counters()
	set_subtitle(null)
	if(!length(winners))
		winners = get_active_participants()
	if(length(winners))
		set_leader(pick(winners))

/// Counts the vote of the participant for the candidate
/datum/cutscene/proc/vote_for_leader(mob/voter, mob/candidate)
	if(!is_active_participant(voter) || !is_active_participant(candidate))
		return
	leader_votes[REF(voter)] = REF(candidate)
	to_chat(voter, SPAN_NOTICE("You vote for [candidate.name] to lead the conversation."))
	update_vote_counters()

/// Returns the votes of active participants for active participants, as list(candidate mob = number of votes)
/datum/cutscene/proc/count_leader_votes()
	var/list/vote_counts = list()
	for(var/mob/candidate as anything in get_active_participants())
		vote_counts[candidate] = 0
	for(var/mob/voter as anything in get_active_participants())
		var/mob/candidate = locate(leader_votes[REF(voter)])
		if(candidate in vote_counts)
			vote_counts[candidate]++
	return vote_counts

/// Shows over each candidate how many votes they have
/datum/cutscene/proc/update_vote_counters()
	var/list/vote_counts = count_leader_votes()
	for(var/mob/candidate as anything in vote_counts)
		var/image/counter = vote_counters[candidate]
		if(!counter)
			counter = image(loc = candidate)
			counter.plane = RUNECHAT_PLANE
			counter.layer = ABOVE_HUD_LAYER
			counter.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA|KEEP_APART|RESET_COLOR|RESET_TRANSFORM
			counter.maptext_width = 96
			counter.maptext_height = 16
			counter.maptext_x = -32
			counter.maptext_y = 34
			vote_counters[candidate] = counter
			for(var/mob/participant as anything in participants)
				var/client/viewer = viewers[participant]
				viewer?.images |= counter
		var/votes = vote_counts[candidate]
		counter.maptext = MAPTEXT("<center><span style='color: [votes ? CUTSCENE_COLOR_PLAYER : "#ffffff"]'>[votes] vote[votes == 1 ? "" : "s"]</span></center>")

/// Removes the vote counters
/datum/cutscene/proc/clear_vote_counters()
	for(var/mob/participant as anything in participants)
		var/client/viewer = viewers[participant]
		if(!viewer)
			continue
		for(var/candidate in vote_counters)
			viewer.images -= vote_counters[candidate]
	vote_counters.Cut()

/// Makes the participant the leader and tells everyone
/datum/cutscene/proc/set_leader(mob/new_leader)
	leader = new_leader
	for(var/mob/participant as anything in participants)
		to_chat(participant, SPAN_NOTICE("[new_leader == participant ? "You lead" : "[new_leader.name] leads"] the conversation."))

/// Makes sure there is an active leader: votes for one if there never was one, hands over to a random participant if the leader left
/datum/cutscene/proc/ensure_leader()
	if(is_active_participant(leader))
		return
	if(!leader)
		run_leader_vote()
		return
	var/list/mob/candidates = get_active_participants()
	if(length(candidates))
		set_leader(pick(candidates))

// Answers

/**
 * Shows the answers of the current choice as thoughts floating around the leader, who is in the middle of the screen
 *
 * The first four go right, left, below and above the leader, more are spread evenly around them.
 */
/datum/cutscene/proc/show_options()
	clear_options()
	var/static/list/layouts = list(
		list(0),
		list(0, 180),
		list(0, 180, 270),
		list(0, 180, 270, 90),
	)
	var/option_count = length(choice_options)
	var/half_tile = world.icon_size * 0.5
	var/index = 0
	for(var/option_id in choice_options)
		index++
		var/angle = option_count <= length(layouts) ? layouts[option_count][index] : (index - 1) * 360 / option_count
		var/atom/movable/screen/cutscene/thought/thought = new(null, src, option_id, "[index]. [choice_options[option_id]]")
		// Thoughts to the sides are pushed out by half their width, so they don't cover the leader
		var/center_x = half_tile + cos(angle) * (CUTSCENE_THOUGHT_RADIUS_X + thought.maptext_width * 0.5)
		var/center_y = half_tile + sin(angle) * CUTSCENE_THOUGHT_RADIUS_Y
		thought.place(round(center_x), round(center_y))
		option_screens += thought
	for(var/mob/participant as anything in participants)
		var/client/viewer = viewers[participant]
		viewer?.screen |= option_screens

/// Removes the answers from the screens
/datum/cutscene/proc/clear_options()
	for(var/mob/participant as anything in participants)
		var/client/viewer = viewers[participant]
		viewer?.screen -= option_screens
	QDEL_LIST(option_screens)

/// Called when someone clicks an answer. Only the leader's click during a choice counts
/datum/cutscene/proc/pick_option(mob/user, option_id)
	if(phase != CUTSCENE_PHASE_CHOICE || user != leader || !(option_id in choice_options))
		return
	picked_option = option_id

// Helpers for play()

/// Stops play() if the cutscene has finished in the meantime
/datum/cutscene/proc/check_aborted()
	if(finished)
		throw EXCEPTION(CUTSCENE_ABORTED)

/// Returns how long the line of text stays before the next one
/datum/cutscene/proc/line_delay(text)
	return max(line_delay_minimum, length_char(text) * line_delay_per_character)

/// Returns the actor of the [/obj/effect/landmark/cutscene_actor] with the ID, or null if it has none
/datum/cutscene/proc/actor(actor_id)
	var/obj/effect/landmark/cutscene_actor/actor_landmark = GLOB.cutscene_actors[actor_id]
	if(!actor_landmark)
		stack_trace("Cutscene [type] looked for actor [actor_id], which isn't on the map.")
		return null
	return actor_landmark.actor

/// Whether the actor can still act: it exists and is conscious
/datum/cutscene/proc/can_act(mob/living/acting_mob)
	return !QDELETED(acting_mob) && acting_mob.stat == CONSCIOUS

/// Sleeps for the time
/datum/cutscene/proc/wait(time)
	check_aborted()
	if(time > 0)
		sleep(time)
	check_aborted()

/**
 * Glides the cameras to the atom and waits until they get there
 *
 * * target - What the cameras point at. null returns them to the participants' own mobs
 */
/datum/cutscene/proc/focus(atom/target)
	check_aborted()
	focus_camera(target)
	wait(camera_pan_time)

/**
 * Makes the speaker say the line out loud and waits until it has been typed out over their head and read
 *
 * * speaker - Mob that says the line, the cameras glide to it. A text is a voice that isn't on the map (a radio, a loudspeaker): the line is only in the subtitles
 * * text - What is said
 * * delay - How long to wait after the line, by default as long as it takes to read it
 */
/datum/cutscene/proc/say(speaker, text, delay)
	check_aborted()
	if(!ismob(speaker))
		set_subtitle("[subtitle_name(speaker)]: [text]")
		wait(isnull(delay) ? line_delay(text) : delay)
		return
	var/mob/living/speaking_mob = speaker
	if(camera_follows_speaker && camera_focus != speaking_mob)
		focus(speaking_mob)
	if(can_act(speaking_mob))
		speaking_mob.say(text)
	show_line(speaking_mob, text)
	wait(isnull(delay) ? line_delay(text) : delay)

/**
 * Shows the line of the mob in the subtitles only if it couldn't say it out loud, since a line said out loud
 * is already typed out over the mob's head and in the chat
 */
/datum/cutscene/proc/show_line(mob/living/speaking_mob, text, italic = FALSE)
	if(can_act(speaking_mob))
		set_subtitle(null)
		return
	set_subtitle(italic ? "<i>[subtitle_name(speaking_mob)] [text]</i>" : "[subtitle_name(speaking_mob)]: [text]")

/**
 * Makes the actor do an emote (like "nods.") and waits until it has been read
 *
 * * acting_mob - Mob that does the emote, the cameras glide to it
 * * text - The emote, without the name
 * * delay - How long to wait after it, by default as long as it takes to read it
 */
/datum/cutscene/proc/emote(mob/living/acting_mob, text, delay)
	check_aborted()
	if(camera_follows_speaker && acting_mob && camera_focus != acting_mob)
		focus(acting_mob)
	if(can_act(acting_mob))
		acting_mob.manual_emote(text)
	show_line(acting_mob, text, italic = TRUE)
	wait(isnull(delay) ? line_delay(text) : delay)

/**
 * Tells the participants what happens, in the subtitles and the chat
 *
 * * text - What happens
 * * delay - How long to wait after it, by default as long as it takes to read it
 */
/datum/cutscene/proc/narrate(text, delay)
	check_aborted()
	for(var/mob/participant as anything in participants)
		to_chat(participant, SPAN_NOTICE("<i>[text]</i>"))
	set_subtitle("<i>[text]</i>")
	wait(isnull(delay) ? line_delay(text) : delay)

/**
 * Asks the leader a question and sleeps until they answer. Returns the ID of the answer
 *
 * Votes for a leader first if there is none yet. The cameras glide to the leader and the answers float around them.
 * Without an answer in [/datum/cutscene/var/choice_duration] the default answer is picked.
 * The leader's character then says the answer out loud.
 *
 * * prompt - The question, shown in the subtitles
 * * options - Answers as list(answer ID = text the leader says)
 * * default_option - ID of the answer picked if the leader doesn't pick one, the first answer by default
 */
/datum/cutscene/proc/choose(prompt, list/options, default_option)
	check_aborted()
	if(!length(options))
		CRASH("Cutscene [type] asked [prompt] without answers.")

	ensure_leader()
	if(leader)
		focus(leader)
	choice_options = options
	picked_option = null
	phase = CUTSCENE_PHASE_CHOICE
	phase_deadline = world.time + choice_duration
	show_options()
	if(leader)
		to_chat(leader, SPAN_NOTICE("Click one of the answers floating around your character."))

	while(!picked_option && world.time < phase_deadline)
		set_subtitle("<i>[prompt]: [leader ? "[subtitle_name(leader)] answers" : "nobody answers"] ([round((phase_deadline - world.time) * 0.1)]s)</i>")
		sleep(0.5 SECONDS)
		check_aborted()
		if(leader && !is_active_participant(leader))
			ensure_leader()
			if(leader)
				focus_camera(leader)

	var/option_id = picked_option || default_option || options[1]
	phase = CUTSCENE_PHASE_PLAYING
	phase_deadline = null
	choice_options = null
	picked_option = null
	clear_options()

	var/answer = options[option_id]
	set_subtitle(null)
	if(can_act(leader))
		leader.say(answer)
	if(leader)
		show_line(leader, answer)
	else
		set_subtitle("???: [answer]")
	wait(line_delay(answer))
	return option_id

/**
 * Walks the actor to the destination step by step and sleeps until it gets there or gets stuck
 *
 * * moved_mob - Mob that walks
 * * destination - Where it walks to
 * * step_delay - Time between steps
 */
/datum/cutscene/proc/move_actor(mob/living/moved_mob, atom/destination, step_delay = 0.4 SECONDS)
	check_aborted()
	var/turf/destination_turf = get_turf(destination)
	var/max_steps = get_dist(moved_mob, destination_turf) * 2
	for(var/i in 1 to max_steps)
		if(!can_act(moved_mob) || get_turf(moved_mob) == destination_turf)
			break
		if(!step_towards(moved_mob, destination_turf))
			break
		wait(step_delay)

/// Turns the actor to face the direction or the atom
/datum/cutscene/proc/turn_actor(mob/living/turned_mob, direction_or_target)
	check_aborted()
	if(!can_act(turned_mob) || !direction_or_target)
		return
	turned_mob.setDir(isatom(direction_or_target) ? get_dir(turned_mob, direction_or_target) : direction_or_target)

/**
 * Plays a sound
 *
 * * sound_to_play - The sound
 * * source - Where it plays from, heard by everyone near. Without it only the participants hear it, as if in their heads
 * * volume - Its volume
 */
/datum/cutscene/proc/play_sound(sound_to_play, atom/source, volume = 50)
	check_aborted()
	if(source)
		playsound(source, sound_to_play, volume)
		return
	for(var/mob/participant as anything in participants)
		if(participant.client)
			playsound_client(participant.client, sound_to_play, vol = volume)
