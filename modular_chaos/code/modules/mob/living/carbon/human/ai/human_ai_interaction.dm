/// How long an AI human takes to pry open a powered airlock it has no access to, the time a small xeno takes
#define HUMAN_AI_AIRLOCK_PRY_TIME (4 SECONDS)

/atom/proc/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(get_turf(src) == target)
		return 0
	return INFINITY

/atom/proc/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(!mouse_opacity || (level < 2))
		return FALSE

	if(!brain.unholster_any_weapon())
		ai_human.a_intent_change(INTENT_HARM)

	ai_human.do_click(src, "", list())
	ai_human.face_atom(src)
	return TRUE


/////////////////////////////
//         OBJECTS         //
/////////////////////////////
/obj/structure/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	if(!density)
		return 0

	return OBJECT_PENALTY

/obj/structure/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(climbable)
		if(!ai_human.action_busy)
			do_climb(ai_human)
		return TRUE

	return ..()

/////////////////////////////
//       MINERAL DOOR      //
/////////////////////////////
/obj/structure/mineral_door/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(!brain.primary_weapon)
		return INFINITY

	return DOOR_PENALTY

/obj/structure/mineral_door/resin/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	var/obj/item/weapon/gun/primary_weapon = brain.primary_weapon
	if(!primary_weapon)
		return TRUE

	brain.unholster_primary()
	brain.ensure_primary_hand(primary_weapon)

	return ..()


/////////////////////////////
//        PLATFORMS        //
/////////////////////////////
/obj/structure/platform/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return DOOR_PENALTY


/////////////////////////////
//         PODDDOORS       //
/////////////////////////////
/obj/structure/machinery/door/poddoor/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	if(!(stat & NOPOWER))
		return INFINITY

	if(density && !operating && !unacidable && brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR))
		return DOOR_PENALTY

	return INFINITY

/obj/structure/machinery/door/poddoor/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(!(stat & NOPOWER) || !brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR))
		return

	brain.holster_primary()
	var/obj/item/crowbar = brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR)
	brain.equip_item_from_equipment_map(HUMAN_AI_TOOLS, crowbar)
	ai_human.do_click(src, "", list())
	brain.store_item(crowbar, brain.storage_has_room(crowbar), HUMAN_AI_TOOLS)

/////////////////////////////
//         AIRLOCK         //
/////////////////////////////
/obj/structure/machinery/door/airlock/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	// Clicks and hits don't open these, and bullets need far too many to break one, so they're walls to us
	if(locked || welded || isElectrified())
		return INFINITY

	if(human_ai_has_access(ai_human))
		return DOOR_PENALTY

	// Otherwise only a crowbar gets us through: at once without power, slowly with it, never through a heavy airlock
	if(!brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR))
		return INFINITY

	if(!arePowerSystemsOn())
		return DOOR_PENALTY

	if(heavy)
		return INFINITY

	return LOCKED_DOOR_PENALTY

/obj/structure/machinery/door/airlock/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	// It opens as we walk into it
	if(human_ai_has_access(ai_human))
		return

	var/obj/item/crowbar = brain.get_tool_from_equipment_map(TRAIT_TOOL_CROWBAR)
	if(!crowbar || ai_human.action_busy || operating)
		return

	var/powered = arePowerSystemsOn()
	if(powered && heavy)
		return

	brain.holster_primary()
	if(!brain.equip_item_from_equipment_map(HUMAN_AI_TOOLS, crowbar))
		return

	if(powered)
		human_ai_pry_open(ai_human, crowbar)
	else
		// A crowbar opens an airlock without power at once
		ai_human.do_click(src, "", list())

	if(!QDELETED(brain))
		brain.store_item(crowbar, brain.storage_has_room(crowbar), HUMAN_AI_TOOLS)

/**
 * Returns TRUE if the AI human opens the airlock by walking into it, making the same checks as bumpopen().
 *
 * * ai_human - the AI human about to walk into the airlock
 */
/obj/structure/machinery/door/airlock/proc/human_ai_has_access(mob/living/carbon/human/ai_human)
	return arePowerSystemsOn() && allowed(requiresID() ? ai_human : null)

/**
 * Has an AI human force open a powered airlock it has no access to with a crowbar, as xenos pry airlocks open.
 *
 * Sleeps for HUMAN_AI_AIRLOCK_PRY_TIME. Ordinary players need a maintenance jack and super strength for this,
 * the AI makes do with any crowbar so that locked doors don't stop it for good.
 *
 * * ai_human - the AI human prying, holding the crowbar
 * * crowbar - the crowbar it pries with
 */
/obj/structure/machinery/door/airlock/proc/human_ai_pry_open(mob/living/carbon/human/ai_human, obj/item/crowbar)
	ai_human.visible_message(SPAN_DANGER("[ai_human] jams [crowbar] into [src] and starts to pry it open."),
	SPAN_DANGER("You jam [crowbar] into [src] and start to pry it open."))
	playsound(src, "pry", 15, TRUE)
	if(!do_after(ai_human, HUMAN_AI_AIRLOCK_PRY_TIME, INTERRUPT_ALL, BUSY_ICON_HOSTILE))
		return

	if(QDELETED(src) || !density || locked || welded)
		return

	ai_human.visible_message(SPAN_DANGER("[ai_human] forces [src] open with [crowbar]."),
	SPAN_DANGER("You force [src] open with [crowbar]."))
	open(TRUE)

/////////////////////////////
//         HUMANS         //
/////////////////////////////
/mob/living/carbon/human/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return HUMAN_PENALTY

/mob/living/carbon/human/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(stat == DEAD)
		return TRUE

	if(brain.faction_check(src))
		var/random_intent = pick(INTENT_DISARM, INTENT_HARM, INTENT_HELP, INTENT_DISARM, INTENT_HARM) // lower chance of help intent
		ai_human.a_intent = random_intent
		if(get_ai_brain())
			a_intent = random_intent
		return TRUE

	if((body_position == LYING_DOWN) && (brain.current_target != src))
		return TRUE

	return ..()

/////////////////////////////
//          XENOS          //
/////////////////////////////
/mob/living/carbon/xenomorph/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return XENO_PENALTY

/mob/living/carbon/xenomorph/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(brain.faction_check(src))
		return TRUE

	return ..()

/////////////////////////////
//         VEHICLES        //
/////////////////////////////
/obj/vehicle/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return VEHICLE_PENALTY


/////////////////////////////
//       OPEN SPACE        //
/////////////////////////////
// A fall hurts and lands who knows where, so it's never a way to go, even when picked as where to step to
/turf/open_space/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	return INFINITY

/////////////////////////////
//      MOUNTED GUNS       //
/////////////////////////////
// Too sturdy to bash through, and likely our own
/obj/structure/machinery/m56d_hmg/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(get_turf(src) == target)
		return 0
	return INFINITY

/////////////////////////////
//         SENTRY          //
/////////////////////////////
/obj/structure/machinery/defenses/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return SENTRY_PENALTY

/////////////////////////////
//       BARRICADES        //
/////////////////////////////
/obj/structure/barricade/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(!is_wired)
		if(!ai_human.action_busy)
			do_climb(ai_human)
		return TRUE

	return ..()

/obj/structure/barricade/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return BARRICADE_PENALTY

/obj/structure/barricade/plasteel/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	if(!closed) // this means it's closed
		ai_human.do_click(src, "", list())
	else
		. = ..()
	if(!closed)
		close(src)

/obj/structure/barricade/handrail/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return DOOR_PENALTY


/////////////////////////////
//          FIRE           //
/////////////////////////////
/obj/flamer_fire/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/braineno, direction, turf/target)
	. = ..()
	if(!.)
		return

	if(ai_human.on_fire)
		return FIRE_PENALTY

	return INFINITY // STOP. TOUCHING. THE FLAMES!

/////////////////////////////
//          WALLS          //
/////////////////////////////
/turf/closed/wall/resin/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/braineno, direction, turf/target)
	. = ..()
	if(!.)
		return

	return WALL_PENALTY


/////////////////////////////
//          FLOOR          //
/////////////////////////////
/*
	Sometimes open turfs are passed back as obstacles due to platforms and such,
	generally it's fast so very slight penalty mainly for handling subtypes properly
*/
/turf/open/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return OPEN_TURF_PENALTY

/turf/open/human_ai_act(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain)
	return FALSE

/turf/open/space/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(!.)
		return

	return INFINITY


/////////////////////////////
//          RIVER          //
/////////////////////////////
/turf/open/gm/river/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	. = ..()
	if(. && !covered)
		. += base_river_slowdown

/turf/open/gm/river/desert/human_ai_obstacle(mob/living/carbon/human/ai_human, datum/human_ai_brain/brain, direction, turf/target)
	if(toxic && !covered)
		return FIRE_PENALTY

	return ..()

/// Returns TRUE if the vehicle isn't wrecked and can still drive or shoot, whether anyone is inside or not
/obj/vehicle/multitile/proc/ai_can_fight()
	if(health <= 0)
		return FALSE

	for(var/obj/item/hardpoint/hardpoint as anything in get_hardpoints_copy())
		if(hardpoint.health <= 0)
			continue

		var/obj/item/hardpoint/holder/hardpoint_holder = hardpoint.loc
		if(istype(hardpoint_holder) && (hardpoint_holder.health <= 0))
			continue

		if(istype(hardpoint, /obj/item/hardpoint/locomotion) || istype(hardpoint, /obj/item/hardpoint/primary) || istype(hardpoint, /obj/item/hardpoint/secondary))
			return TRUE

	return FALSE

/// Returns TRUE if the vehicle is worth shooting at: someone alive sits at its controls and it can still drive or shoot
/obj/vehicle/multitile/proc/ai_is_threat()
	for(var/seat_role in seats)
		var/mob/living/seated_mob = seats[seat_role]
		if(seated_mob && (seated_mob.stat != DEAD))
			return ai_can_fight()

	return FALSE

#undef HUMAN_AI_AIRLOCK_PRY_TIME
