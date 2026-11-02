/**
 * Pixel shift mode of a human: the movement keys move them inside their tile instead of walking,
 * and dragging an item within reach with the left mouse button moves the item inside its tile
 *
 * The shifted atom gets [/datum/component/pixel_shifted]. Clicks on anything but items work as usual, and so do clicks with modifier keys.
 * Dragging and dropping items on the floor is off while the mode is on, so a shifted item is not also dropped onto what is under the mouse.
 */
/datum/component/pixel_shifting
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Weakref to the item being dragged right now, if any
	var/datum/weakref/dragged_ref
	/// Where the dragged item was grabbed, in pixels from the bottom left of its icon, so that it does not jump to the mouse
	var/grab_x = 0
	/// Where the dragged item was grabbed, in pixels from the bottom left of its icon, so that it does not jump to the mouse
	var/grab_y = 0
	/// Direction of the movement keys the parent glides in, if they are held
	var/key_direction
	/// world.time of the last movement key input. Held keys repeat it, so a long gap means they were let go
	var/last_key_time = 0
	/// Timer checking whether the movement keys were let go, while they are held
	var/release_timer

/datum/component/pixel_shifting/Initialize()
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/pixel_shifting/RegisterWithParent()
	..()
	RegisterSignal(parent, COMSIG_CLIENT_MOB_MOVE, PROC_REF(on_move_key))
	RegisterSignal(parent, COMSIG_MOB_MOUSEDOWN, PROC_REF(on_mouse_down))
	RegisterSignal(parent, COMSIG_MOB_MOUSEDRAG, PROC_REF(on_mouse_drag))
	RegisterSignal(parent, COMSIG_MOB_MOUSEUP, PROC_REF(on_mouse_up))
	RegisterSignal(parent, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH), PROC_REF(stop))
	to_chat(parent, SPAN_NOTICE("Pixel shifting is on: the movement keys shift you instead of walking, and the left mouse button drags items next to you. Toggle it again to walk."))

/datum/component/pixel_shifting/UnregisterFromParent()
	..()
	UnregisterSignal(parent, list(COMSIG_CLIENT_MOB_MOVE, COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEUP, COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH))
	deltimer(release_timer)
	release_timer = null
	if(!QDELETED(parent))
		to_chat(parent, SPAN_NOTICE("Pixel shifting is off."))

/// Turns the mode off
/datum/component/pixel_shifting/proc/stop()
	SIGNAL_HANDLER
	qdel(src)

/**
 * Glides the parent in the direction of the movement keys instead of walking, when they can be shifted
 *
 * Held keys repeat every movement step, but one even glide looks smoother than a glide a step,
 * so only a new direction starts a new glide, and [/datum/component/pixel_shifting/proc/check_key_release] stops it.
 */
/datum/component/pixel_shifting/proc/on_move_key(mob/living/carbon/human/source, turf/new_loc, direction)
	SIGNAL_HANDLER
	// Buckled, lying and the like move as usual, or fail to
	if(!can_shift_self(source))
		return
	last_key_time = world.time
	var/datum/component/pixel_shifted/shift = source.LoadComponent(/datum/component/pixel_shifted)
	if(direction != key_direction || !shift.is_gliding())
		key_direction = direction
		shift.glide_toward(direction, PIXEL_SHIFT_KEY_SPEED)
	if(!release_timer)
		release_timer = addtimer(CALLBACK(src, PROC_REF(check_key_release)), world.tick_lag, TIMER_STOPPABLE|TIMER_LOOP)
	return COMPONENT_OVERRIDE_MOVE

/// Stops the glide of the parent where it is seen once the movement keys are let go
/datum/component/pixel_shifting/proc/check_key_release()
	if(world.time - last_key_time <= PIXEL_SHIFT_KEY_RELEASE_TIME)
		return
	deltimer(release_timer)
	release_timer = null
	key_direction = null
	var/mob/living/carbon/human/human_parent = parent
	var/datum/component/pixel_shifted/shift = human_parent.GetComponent(/datum/component/pixel_shifted)
	shift?.stop_glide()

/datum/component/pixel_shifting/proc/on_mouse_down(mob/living/carbon/human/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(!modifiers[LEFT_CLICK] || modifiers[SHIFT_CLICK] || modifiers[CTRL_CLICK] || modifiers[ALT_CLICK])
		return
	if(!can_shift_item(source, object))
		return
	var/list/mouse_pixel = get_mouse_pixel(source.client, params)
	if(!mouse_pixel)
		return
	var/obj/item/item = object
	grab_x = mouse_pixel[1] - ((item.x - 1) * world.icon_size + item.pixel_x)
	grab_y = mouse_pixel[2] - ((item.y - 1) * world.icon_size + item.pixel_y)
	dragged_ref = WEAKREF(item)
	return COMSIG_MOB_CLICK_CANCELED

/datum/component/pixel_shifting/proc/on_mouse_drag(mob/living/carbon/human/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	var/obj/item/item = dragged_ref?.resolve()
	if(!item)
		return
	if(!can_shift_item(source, item))
		dragged_ref = null
		return COMSIG_MOB_CLICK_CANCELED
	var/list/mouse_pixel = get_mouse_pixel(source.client, params)
	if(!mouse_pixel)
		return COMSIG_MOB_CLICK_CANCELED
	var/datum/component/pixel_shifted/shift = item.LoadComponent(/datum/component/pixel_shifted)
	shift.shift_to(mouse_pixel[1] - grab_x - (item.x - 1) * world.icon_size, mouse_pixel[2] - grab_y - (item.y - 1) * world.icon_size, PIXEL_SHIFT_DRAG_GLIDE_TIME)
	return COMSIG_MOB_CLICK_CANCELED

/datum/component/pixel_shifting/proc/on_mouse_up(mob/living/carbon/human/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(!dragged_ref)
		return
	dragged_ref = null
	return COMSIG_MOB_CLICK_CANCELED

/// Whether user can shift themselves right now: standing free, not pulled, buckled or leaning on a wall, which set the offsets themselves
/datum/component/pixel_shifting/proc/can_shift_self(mob/living/carbon/human/user)
	if(user.is_mob_incapacitated() || user.body_position == LYING_DOWN)
		return FALSE
	return isturf(user.loc) && !user.buckled && !user.anchored && !user.pulledby && !HAS_TRAIT(user, TRAIT_HAULED) && !HAS_TRAIT_FROM(user, TRAIT_UNDENSE, WALL_HIDING_TRAIT)

/// Whether user can shift target right now: an unanchored item on the floor within reach
/datum/component/pixel_shifting/proc/can_shift_item(mob/living/carbon/human/user, atom/target)
	if(!isitem(target) || user.is_mob_incapacitated() || user.body_position == LYING_DOWN)
		return FALSE
	var/obj/item/item = target
	return isturf(item.loc) && !item.anchored && user.Adjacent(item)

/// Whether a drag and drop of dropped should be ignored, as it is a pixel shift
/datum/component/pixel_shifting/proc/is_shift_drop(atom/dropped)
	return isitem(dropped) && isturf(dropped.loc)

/**
 * Returns where on the map the mouse was in a mouse event, as list(x, y) in pixels from the bottom left corner of the map, or null
 *
 * Arguments:
 * * user_client - the client the event came from
 * * params - the params of the event, whose screen-loc is "x:pixel_x,y:pixel_y" on the map, counted from 1
 */
/datum/component/pixel_shifting/proc/get_mouse_pixel(client/user_client, params)
	if(!user_client)
		return null
	var/list/modifiers = params2list(params)
	var/screen_loc = modifiers[SCREEN_LOC]
	var/turf/eye_turf = get_turf(user_client.get_eye())
	if(!screen_loc || !eye_turf)
		return null
	// Same conversion as params2turf(), which works in whole tiles
	var/list/screen_pixel = params2screenpixel(screen_loc)
	var/list/view_size = getviewsize(user_client.view)
	var/map_x = (eye_turf.x - floor(view_size[1] * 0.5) - 1) * world.icon_size + screen_pixel[1] - 1 + user_client.get_pixel_x()
	var/map_y = (eye_turf.y - floor(view_size[2] * 0.5) - 1) * world.icon_size + screen_pixel[2] - 1 + user_client.get_pixel_y()
	return list(map_x, map_y)
