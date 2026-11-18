/// Actor ID of the officer in the demo cutscene
#define DEMO_OFFICER_ID "demo_officer"
/// Cutscene ID of the demo cutscene, shared by its trigger and walls
#define DEMO_CUTSCENE_ID "demo"

/**
 * Short cutscene that shows what the framework does, to try it out or copy from
 *
 * The officer is a [/obj/effect/landmark/cutscene_actor] with the actor ID "demo_officer".
 * Without one on the map a loudspeaker speaks instead, so any trigger can play it.
 *
 * To try it, map [/obj/effect/landmark/cutscene_trigger/dialogue/demo] with [/obj/effect/landmark/cutscene_actor/demo]
 * near it, and optionally [/obj/structure/blocker/invisible_wall/cutscene/demo] across the way on.
 */
/datum/cutscene/demo
	title = "Demo"
	elect_leader = TRUE

/datum/cutscene/demo/play()
	var/obj/effect/landmark/cutscene_actor/officer_landmark = GLOB.cutscene_actors[DEMO_OFFICER_ID]
	var/mob/living/officer = officer_landmark?.actor
	if(!can_act(officer))
		officer = null
	var/speaker = officer || "Loudspeaker"

	if(officer)
		turn_actor(officer, leader)
		emote(officer, "looks up from a datapad.")
	else
		narrate("A loudspeaker crackles to life above you.")
	say(speaker, "You're the relief team? Took you long enough.")

	switch(choose("Answer the officer", list(
		"marines" = "Colonial Marines. We're here to get you out.",
		"question" = "Who's asking?",
		"silence" = "...",
	), default_option = "silence"))
		if("marines")
			if(officer)
				emote(officer, "lets out a long breath.")
			say(speaker, "Good. The armory is down the hall, gear up.")
		if("question")
			say(speaker, "The lieutenant in charge of this mess. Now, who are you?")
			if(choose("Answer the officer", list("marines" = "Colonial Marines.", "leave" = "Forget it.")) == "leave")
				say(speaker, "Then find your own way out.")
				return
			say(speaker, "Fine. Follow the corridor, the armory is open.")
		if("silence")
			if(officer)
				emote(officer, "frowns.")
			say(speaker, "Not much for talking, huh. Suit yourselves.")

	if(officer)
		say(officer, "I'll catch up.")
		move_actor(officer, locate(officer.x + 3, officer.y, officer.z))
	narrate("Somewhere ahead, a heavy door grinds open.")

/// Trigger of the demo cutscene, with the "Click to talk" bubble over the demo officer
/obj/effect/landmark/cutscene_trigger/dialogue/demo
	cutscene_id = DEMO_CUTSCENE_ID
	cutscene_type = /datum/cutscene/demo
	prompt_actor_id = DEMO_OFFICER_ID

/// The officer of the demo cutscene, spawned at round start
/obj/effect/landmark/cutscene_actor/demo
	actor_id = DEMO_OFFICER_ID
	spawn_preset = /datum/equipment_preset/uscm_ship/so

/// Wall removed once the demo cutscene finishes
/obj/structure/blocker/invisible_wall/cutscene/demo
	cutscene_id = DEMO_CUTSCENE_ID

#undef DEMO_OFFICER_ID
#undef DEMO_CUTSCENE_ID
