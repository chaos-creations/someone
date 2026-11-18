/**
 * Starts its [/datum/cutscene] once enough players come close, then deletes itself
 *
 * Players are living humans played by someone. Once enough of them are within range, the cutscene starts at once,
 * or with start_prompt (see [/obj/effect/landmark/cutscene_trigger/dialogue]) a bubble saying "Click to talk"
 * shows up over the NPC of prompt_actor_id (or over the trigger), and the cutscene starts when one of them clicks it.
 * Walls with the same cutscene_id ([/obj/structure/blocker/invisible_wall/cutscene]) are removed when the cutscene finishes.
 */
/obj/effect/landmark/cutscene_trigger
	name = "cutscene trigger"
	icon = 'modular_chaos/icons/landmarks.dmi'
	icon_state = "cutscene_scene_start"
	/// ID of the cutscene, shared with its walls. Unique on the map
	var/cutscene_id
	/// Type of the [/datum/cutscene] to play
	var/cutscene_type
	/// How many players must be within trigger_range at once to start the cutscene
	var/required_players = 1
	/// Distance from the trigger in tiles at which players count
	var/trigger_range = 3
	/// Whether players who come within trigger_range while the cutscene plays join it
	var/join_while_playing = TRUE
	/// Whether a player starts the cutscene by clicking a bubble. Without it the cutscene starts as soon as enough players are near
	var/start_prompt = FALSE
	/// ID of the [/obj/effect/landmark/cutscene_actor] the bubble shows over. Without it the bubble shows over the trigger
	var/prompt_actor_id
	/// The cutscene playing, null until it starts
	var/datum/cutscene/cutscene
	/// The bubble players click to start the cutscene, shown while enough players are near
	var/obj/effect/cutscene_start_prompt/prompt
	/// What the bubble is shown over: the NPC of prompt_actor_id, or the trigger
	var/atom/prompt_anchor
	/// Players near the shown bubble, whose clicks on the bubble or the NPC under it start the cutscene
	var/list/mob/prompted_players = list()

/obj/effect/landmark/cutscene_trigger/Initialize(mapload, ...)
	. = ..()
	// Unit tests create every type without its mapped vars, only a mapped one without them is an error
	if(!cutscene_id || !ispath(cutscene_type, /datum/cutscene))
		if(mapload)
			stack_trace("Cutscene trigger at [AREACOORD(src)] has no cutscene_id or a wrong cutscene_type ([cutscene_type]).")
		return INITIALIZE_HINT_QDEL
	if(GLOB.cutscene_triggers[cutscene_id])
		stack_trace("Cutscene trigger at [AREACOORD(src)] has the cutscene_id [cutscene_id] of another trigger.")
		return INITIALIZE_HINT_QDEL
	GLOB.cutscene_triggers[cutscene_id] = src
	START_PROCESSING(SSobj, src)

/obj/effect/landmark/cutscene_trigger/Destroy()
	STOP_PROCESSING(SSobj, src)
	hide_prompt()
	if(GLOB.cutscene_triggers[cutscene_id] == src)
		GLOB.cutscene_triggers -= cutscene_id
	if(cutscene)
		UnregisterSignal(cutscene, COMSIG_CUTSCENE_FINISHED)
		cutscene = null
	return ..()

/obj/effect/landmark/cutscene_trigger/process(delta_time)
	var/list/mob/living/carbon/human/players = get_players_in_range()
	if(cutscene)
		if(join_while_playing)
			for(var/mob/living/carbon/human/player as anything in players)
				cutscene.add_participant(player)
		return
	if(length(players) < required_players)
		hide_prompt()
		return
	if(start_prompt)
		show_prompt(players)
		return
	start_cutscene(players)

/**
 * Shows the bubble over the NPC of prompt_actor_id, or over the trigger if it has none or it is gone,
 * and lets the players near start the cutscene by clicking the bubble or the NPC next to them
 */
/obj/effect/landmark/cutscene_trigger/proc/show_prompt(list/mob/players)
	prompt_anchor = src
	if(prompt_actor_id)
		var/obj/effect/landmark/cutscene_actor/actor_landmark = GLOB.cutscene_actors[prompt_actor_id]
		if(actor_landmark?.actor)
			prompt_anchor = actor_landmark.actor
	var/turf/prompt_turf = get_turf(prompt_anchor)
	if(!prompt)
		prompt = new(prompt_turf, src)
	else if(prompt.loc != prompt_turf)
		prompt.forceMove(prompt_turf)

	for(var/mob/player as anything in prompted_players - players)
		UnregisterSignal(player, COMSIG_MOB_PRE_CLICK)
	for(var/mob/player as anything in players - prompted_players)
		RegisterSignal(player, COMSIG_MOB_PRE_CLICK, PROC_REF(on_prompted_player_click))
	prompted_players = players.Copy()

/// Removes the bubble and stops listening to the clicks of the players near it
/obj/effect/landmark/cutscene_trigger/proc/hide_prompt()
	QDEL_NULL(prompt)
	prompt_anchor = null
	for(var/mob/player as anything in prompted_players)
		UnregisterSignal(player, COMSIG_MOB_PRE_CLICK)
	prompted_players.Cut()

/// A plain click of a player near the bubble on the bubble or the NPC under it starts the cutscene
/obj/effect/landmark/cutscene_trigger/proc/on_prompted_player_click(mob/player, atom/clicked_atom, list/mods)
	SIGNAL_HANDLER
	if(mods[SHIFT_CLICK] || mods[CTRL_CLICK] || mods[ALT_CLICK] || mods[MIDDLE_CLICK])
		return NONE
	if(clicked_atom != prompt && clicked_atom != prompt_anchor)
		return NONE
	// Starting the cutscene registers the participants' clicks again, which can't happen while this signal is being sent
	INVOKE_ASYNC(src, PROC_REF(on_prompt_clicked), player)
	return COMPONENT_INTERRUPT_CLICK

/// Starts the cutscene if the player who clicked the bubble is next to its NPC (or near the trigger without one) and enough players are near
/obj/effect/landmark/cutscene_trigger/proc/on_prompt_clicked(mob/user)
	if(cutscene)
		return
	var/list/mob/living/carbon/human/players = get_players_in_range()
	// Talking to an NPC needs the player next to it, without one being near the trigger is enough
	var/needs_adjacency = prompt_anchor && prompt_anchor != src
	if(!(user in players) || (needs_adjacency && !user.Adjacent(prompt_anchor)))
		to_chat(user, SPAN_WARNING("You need to come closer to talk."))
		return
	if(length(players) < required_players)
		to_chat(user, SPAN_WARNING("[required_players] people need to be here to start this."))
		return
	start_cutscene(players)

/// Returns the living humans played by someone within trigger_range
/obj/effect/landmark/cutscene_trigger/proc/get_players_in_range()
	var/list/mob/living/carbon/human/players = list()
	var/turf/trigger_turf = get_turf(src)
	for(var/mob/living/carbon/human/human as anything in GLOB.alive_human_list)
		if(!human.client || human.stat == DEAD)
			continue
		if(human.z != trigger_turf.z || get_dist(human, trigger_turf) > trigger_range)
			continue
		players += human
	return players

/**
 * Starts the cutscene for the players. Admins can call it to start it without waiting for players
 *
 * * players - Mobs that watch the cutscene, the players in range by default
 */
/obj/effect/landmark/cutscene_trigger/proc/start_cutscene(list/mob/players = get_players_in_range())
	if(cutscene)
		return
	hide_prompt()
	cutscene = new cutscene_type(cutscene_id, players)
	RegisterSignal(cutscene, COMSIG_CUTSCENE_FINISHED, PROC_REF(on_cutscene_finished))
	INVOKE_ASYNC(cutscene, TYPE_PROC_REF(/datum/cutscene, start))

/obj/effect/landmark/cutscene_trigger/proc/on_cutscene_finished()
	SIGNAL_HANDLER
	qdel(src)

/// Trigger of a conversation with an NPC: the players start it themselves by clicking the bubble over the NPC of prompt_actor_id
/obj/effect/landmark/cutscene_trigger/dialogue
	name = "cutscene dialogue trigger"
	icon_state = "cutscene_dialogue"
	start_prompt = TRUE

/**
 * Point a cutscene's cameras can glide to, found by camera_id: `focus("bridge_window")`
 *
 * Unlike a mob or an object on the map, it stays where it is mapped and shows nothing in the game.
 */
/obj/effect/landmark/cutscene_camera
	name = "cutscene camera"
	icon = 'modular_chaos/icons/landmarks.dmi'
	icon_state = "cutscene_scene_stage"
	/// ID the cutscene finds the point by. Unique on the map
	var/camera_id

/obj/effect/landmark/cutscene_camera/Initialize(mapload, ...)
	. = ..()
	// Unit tests create every type without its mapped vars, only a mapped one without them is an error
	if(!camera_id)
		if(mapload)
			stack_trace("Cutscene camera at [AREACOORD(src)] has no camera_id.")
		return INITIALIZE_HINT_QDEL
	if(GLOB.cutscene_cameras[camera_id])
		stack_trace("Cutscene camera at [AREACOORD(src)] has the camera_id [camera_id] of another camera.")
		return INITIALIZE_HINT_QDEL
	GLOB.cutscene_cameras[camera_id] = src

/obj/effect/landmark/cutscene_camera/Destroy()
	if(GLOB.cutscene_cameras[camera_id] == src)
		GLOB.cutscene_cameras -= camera_id
	return ..()

/**
 * Marks a mob a cutscene finds by actor_id with [/datum/cutscene/proc/actor]
 *
 * At round start the landmark either spawns a human in spawn_preset here,
 * or takes the first living mob standing on its tile (one placed on the map).
 */
/obj/effect/landmark/cutscene_actor
	name = "cutscene actor"
	icon = 'modular_chaos/icons/landmarks.dmi'
	icon_state = "cutscene_actor"
	/// ID the cutscene finds the actor by. Unique on the map
	var/actor_id
	/// Path of the /datum/equipment_preset a human spawned here at round start gets. Without it the actor is a mob placed on this tile
	var/spawn_preset
	/// Whether the spawned human gets human AI
	var/spawn_with_ai = FALSE
	/// Icon with a drawn portrait shown for the actor in the dialogue window. Without it the window shows how the actor looks
	var/portrait_icon
	/// Icon state of the portrait in portrait_icon
	var/portrait_state
	/// The actor, null until round start or after it is deleted
	var/mob/living/actor

/obj/effect/landmark/cutscene_actor/Initialize(mapload, ...)
	. = ..()
	// Unit tests create every type without its mapped vars, only a mapped one without them is an error
	if(!actor_id)
		if(mapload)
			stack_trace("Cutscene actor at [AREACOORD(src)] has no actor_id.")
		return INITIALIZE_HINT_QDEL
	if(GLOB.cutscene_actors[actor_id])
		stack_trace("Cutscene actor at [AREACOORD(src)] has the actor_id [actor_id] of another actor.")
		return INITIALIZE_HINT_QDEL
	GLOB.cutscene_actors[actor_id] = src
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(set_up_actor_next_tick)))

/obj/effect/landmark/cutscene_actor/Destroy()
	if(GLOB.cutscene_actors[actor_id] == src)
		GLOB.cutscene_actors -= actor_id
	if(actor)
		UnregisterSignal(actor, COMSIG_PARENT_QDELETING)
		actor = null
	return ..()

/**
 * Sets the actor up a tick later
 *
 * After round start the callback runs at once, still inside Initialize(), and a landmark created only to be deleted
 * (by unit tests, which create every type) would spawn its actor before being deleted.
 */
/obj/effect/landmark/cutscene_actor/proc/set_up_actor_next_tick()
	INVOKE_NEXT_TICK(src, PROC_REF(set_up_actor))

/// Spawns the actor, or finds it on the tile
/obj/effect/landmark/cutscene_actor/proc/set_up_actor()
	if(QDELETED(src))
		return
	var/turf/actor_turf = get_turf(src)
	if(!spawn_preset)
		set_actor(locate(/mob/living) in actor_turf)
		return

	var/mob/living/carbon/human/new_human = new(actor_turf)
	arm_equipment(new_human, spawn_preset, TRUE)
	new_human.setDir(dir)
	if(spawn_with_ai)
		new_human.AddComponent(/datum/component/human_ai)
	set_actor(new_human)

/// Makes the mob the actor
/obj/effect/landmark/cutscene_actor/proc/set_actor(mob/living/new_actor)
	if(!new_actor)
		stack_trace("Cutscene actor [actor_id] at [AREACOORD(src)] found no mob on its tile.")
		return
	actor = new_actor
	RegisterSignal(actor, COMSIG_PARENT_QDELETING, PROC_REF(on_actor_deleted))

/obj/effect/landmark/cutscene_actor/proc/on_actor_deleted()
	SIGNAL_HANDLER
	actor = null
