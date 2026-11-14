//Buttons of Baystation 12 (code/game/machinery/buttons.dm, and the buttons of doors/blast_door.dm and structures/window.dm in the source)

/**
 * A Bay button
 *
 * Pressed, it flips its active state and sends that to the machines with its id_tag, as the radio of the source does
 * on the frequency of the button; what they do with it is up to the subtype. It needs power, and draws a burst of it
 * each press.
 *
 * Bay access is not ported yet, so the buttons the map limits to some jobs are open to everyone.
 */
/obj/structure/machinery/bay_button
	name = "button"
	desc = "A remote control switch for something."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/buttons.dmi'
	icon_state = "launcherbtt"
	power_channel = POWER_CHANNEL_ENVIRON
	use_power = USE_POWER_IDLE
	idle_power_usage = 10
	/// The tag of the machines it sends to
	var/id_tag
	/// Whether it is on, which each press flips
	var/active = FALSE
	/// Whether it is still busy with the last press
	var/operating = FALSE
	/// How long a press keeps it busy
	var/cooldown = 1 SECONDS

/obj/structure/machinery/bay_button/Initialize(mapload, ...)
	. = ..()
	update_icon()

/obj/structure/machinery/bay_button/attack_hand(mob/user)
	if(inoperable())
		return
	add_fingerprint(user)
	if(iscarbon(user))
		playsound(src, pick(GLOB.bay_button_sounds), 60)
	activate(user)

/obj/structure/machinery/bay_button/attackby(obj/item/attacking_item, mob/user)
	attack_hand(user)

/obj/structure/machinery/bay_button/attack_remote(mob/user)
	attack_hand(user)

/**
 * Presses the button
 *
 * * user - who pressed it, if anyone did
 */
/obj/structure/machinery/bay_button/proc/activate(mob/user)
	set waitfor = FALSE
	if(operating)
		return
	operating = TRUE
	active = !active
	transmit()
	use_power(500)
	update_icon()
	sleep(cooldown)
	operating = FALSE
	update_icon()

/// Sends the change of its state to the machines with its tag; a plain button has none to send to
/obj/structure/machinery/bay_button/proc/transmit()
	return

/obj/structure/machinery/bay_button/update_icon()
	icon_state = operating ? "launcheract" : "launcherbtt"

/obj/structure/machinery/bay_button/power_change()
	..()
	update_icon()

/// A Bay button with a light switch sprite
/obj/structure/machinery/bay_button/switch_sprite
	icon_state = "light0"

/obj/structure/machinery/bay_button/switch_sprite/update_icon()
	icon_state = "light[operating]"

/// A Bay button with a door control sprite
/obj/structure/machinery/bay_button/alternate
	icon_state = "doorctrl"

/obj/structure/machinery/bay_button/alternate/update_icon()
	icon_state = operating ? "doorctrl" : "doorctrl2"

/// A Bay door button, which opens the airlocks with its tag if they are closed and closes them if they are open
/obj/structure/machinery/bay_button/alternate/door

/obj/structure/machinery/bay_button/alternate/door/update_icon()
	icon_state = operating ? "[initial(icon_state)]1" : initial(icon_state)

/obj/structure/machinery/bay_button/alternate/door/transmit()
	if(!id_tag)
		return
	for(var/obj/structure/machinery/door/airlock/airlock in GLOB.machines)
		if(airlock.id == id_tag)
			toggle_airlock(airlock)

/**
 * Does to an airlock with the button's tag what the button does
 *
 * * airlock - the airlock
 */
/obj/structure/machinery/bay_button/alternate/door/proc/toggle_airlock(obj/structure/machinery/door/airlock/airlock)
	if(airlock.density)
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/structure/machinery/door, open))
	else
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/structure/machinery/door, close))

/// A Bay bolt button, which bolts the airlocks with its tag if they are unbolted and unbolts them if they are bolted
/obj/structure/machinery/bay_button/alternate/door/bolts

/obj/structure/machinery/bay_button/alternate/door/bolts/toggle_airlock(obj/structure/machinery/door/airlock/airlock)
	if(airlock.locked)
		airlock.unlock()
	else
		airlock.lock()

/// A Bay blast door button, which opens the blast doors and shutters with its tag if they are closed and closes them if they are open
/obj/structure/machinery/bay_button/blast_door
	name = "remote blast door-control"
	desc = "It controls blast doors, remotely."
	icon_state = "blastctrl"

/obj/structure/machinery/bay_button/blast_door/update_icon()
	icon_state = operating ? "blastctrl1" : "blastctrl"

/obj/structure/machinery/bay_button/blast_door/transmit()
	if(!id_tag)
		return
	for(var/obj/structure/machinery/door/poddoor/blast_door in GLOB.machines)
		if(blast_door.id != id_tag)
			continue
		if(blast_door.density)
			INVOKE_ASYNC(blast_door, TYPE_PROC_REF(/obj/structure/machinery/door, open))
		else
			INVOKE_ASYNC(blast_door, TYPE_PROC_REF(/obj/structure/machinery/door, close))

/**
 * A Bay window tint control
 *
 * Not a radio button: it tints or clears the electrochromic windows in range with its id, or with no id at all. When
 * its power goes while it is on, it clears them.
 */
/obj/structure/machinery/bay_button/windowtint
	name = "window tint control"
	desc = "A remote control switch for electrochromic windows."
	icon_state = "light0"
	/// The id of the windows it tints
	var/id
	/// How far the windows it tints can be, in tiles
	var/range = 7

/obj/structure/machinery/bay_button/windowtint/activate(mob/user)
	if(operating)
		return
	for(var/obj/structure/window/framed/bay/window in range(src, range))
		if(window.polarized && (window.id == id || !window.id))
			window.toggle_tint()
	for(var/obj/structure/window/bay/reinforced/polarized_full/pane in range(src, range))
		if(pane.id == id || !pane.id)
			pane.toggle_tint()
	return ..()

/obj/structure/machinery/bay_button/windowtint/power_change()
	..()
	if(active && inoperable())
		activate()

/obj/structure/machinery/bay_button/windowtint/update_icon()
	icon_state = "light[active]"
