//Solar panels, trackers and their control consoles of Baystation 12 (code/modules/power/solar.dm and tracker.dm in the source)

/// How far, in tiles, a panel or tracker can be from the console that controls it
#define SOLAR_MAX_DIST 40
/// Power a panel facing the sun head on makes, in watts
#define SOLAR_GEN_RATE 1500

// How a solar control console turns its panels
/// It does not
#define BAY_SOLAR_TRACK_OFF 0
/// Steadily, at its tracking rate
#define BAY_SOLAR_TRACK_TIMED 1
/// After the sun, as its tracker follows it
#define BAY_SOLAR_TRACK_AUTO 2

/**
 * A Bay solar panel
 *
 * Linked to a solar control console on its network, it makes power as long as nothing opaque stands between it and
 * the sun, the more the closer it faces it. The console turns it.
 */
/obj/structure/machinery/power/bay_solar
	name = "solar panel"
	desc = "A solar electrical generator."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/solar_panels.dmi'
	icon_state = "sp_base"
	density = TRUE
	power_machine = TRUE
	health = 10
	/// The id of the array, kept from the map though nothing reads it, as in the source
	var/id = 0
	/// Whether something opaque stands between it and the sun
	var/obscured = FALSE
	/// The share of full sunlight it gets, 0 to 1
	var/sunfrac = 0
	/// How much more power it makes than a standard panel
	var/efficiency = 1
	/// The direction it faces, in degrees clockwise from north
	var/adir = SOUTH
	/// The console it is linked to
	var/obj/structure/machinery/power/bay_solar_control/control
	/// Whether it is broken, its glass shattered
	var/broken = FALSE

/// A Bay improved solar panel, twice as efficient
/obj/structure/machinery/power/bay_solar/improved
	name = "improved solar panel"
	efficiency = 2

/obj/structure/machinery/power/bay_solar/Initialize(mapload, obj/item/bay_solar_assembly/assembly)
	. = ..()
	if(!assembly)
		assembly = new(src)
		assembly.glass_type = /obj/item/stack/sheet/glass
		assembly.anchored = TRUE
	assembly.forceMove(src)
	if(assembly.glass_type == /obj/item/stack/sheet/glass/reinforced)
		health *= 2
	// On a map, the cables are not set up yet; the networks are made once they are
	if(!mapload)
		connect_to_network()
	start_processing()
	update_icon()

/obj/structure/machinery/power/bay_solar/Destroy()
	unset_control()
	return ..()

/**
 * Links the panel to a console, if it is close enough
 *
 * Returns TRUE if it linked.
 * * controller - the console
 */
/obj/structure/machinery/power/bay_solar/proc/set_control(obj/structure/machinery/power/bay_solar_control/controller)
	if(controller && get_dist(src, controller) > SOLAR_MAX_DIST)
		return FALSE
	control = controller
	return TRUE

/// Unlinks the panel from its console
/obj/structure/machinery/power/bay_solar/proc/unset_control()
	if(control)
		control.connected_panels -= src
	control = null

/obj/structure/machinery/power/bay_solar/update_icon()
	overlays.Cut()
	if(broken)
		overlays += image(icon, "solar_panel-b", layer = ABOVE_MOB_LAYER)
		return
	overlays += image(icon, "solar_panel", layer = ABOVE_MOB_LAYER)
	setDir(angle2dir(adir))

/// Works out how much of the sunlight the panel gets
/obj/structure/machinery/power/bay_solar/proc/update_solar_exposure()
	if(obscured)
		sunfrac = 0
		return
	// The smaller angle between where the panel faces and where the sun is
	var/panel_angle = min(abs(adir - SSbay_sun.angle), 360 - abs(adir - SSbay_sun.angle))
	if(panel_angle > 90)
		sunfrac = 0
		return
	sunfrac = cos(panel_angle) ** 2

/obj/structure/machinery/power/bay_solar/process()
	if(broken || !control)
		return
	if(!powernet)
		return
	if(powernet != control.powernet)
		unset_control()
		return
	if(obscured)
		return
	var/generated = SOLAR_GEN_RATE * sunfrac * efficiency
	add_avail(generated)
	control.gen += generated

/// Breaks the panel, shattering its glass
/obj/structure/machinery/power/bay_solar/proc/set_broken()
	if(broken)
		return
	broken = TRUE
	new /obj/item/shard(loc)
	new /obj/item/shard(loc)
	var/obj/item/bay_solar_assembly/assembly = locate() in src
	assembly?.glass_type = null
	unset_control()
	update_icon()

/obj/structure/machinery/power/bay_solar/update_health(damage = 0)
	health -= damage
	if(health <= 0)
		set_broken()

/obj/structure/machinery/power/bay_solar/ex_act(severity)
	switch(BAY_EX_ACT(severity))
		if(BAY_EX_ACT_DEVASTATING)
			if(prob(15))
				new /obj/item/shard(loc)
			qdel(src)
		if(BAY_EX_ACT_HEAVY)
			if(prob(25))
				new /obj/item/shard(loc)
				qdel(src)
				return
			if(prob(50))
				set_broken()
		if(BAY_EX_ACT_LIGHT)
			if(prob(25))
				set_broken()

/obj/structure/machinery/power/bay_solar/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_CROWBAR))
		return ..()
	playsound(loc, 'sound/machines/click.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] begins to take the glass off \the [src]."))
	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
		return
	var/obj/item/bay_solar_assembly/assembly = locate() in src
	if(assembly)
		assembly.forceMove(loc)
		assembly.give_glass()
	playsound(loc, 'sound/items/Deconstruct.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] takes the glass off \the [src]."))
	qdel(src)

/// Traces a line towards the sun to find whether the panel is in shadow, then works out its sunlight
/obj/structure/machinery/power/bay_solar/proc/occlusion()
	var/trace_x = x
	var/trace_y = y
	obscured = FALSE
	for(var/i in 1 to 20)
		trace_x += SSbay_sun.dx
		trace_y += SSbay_sun.dy
		var/turf/traced = locate(round(trace_x, 0.5), round(trace_y, 0.5), z)
		// Not obscured once it reaches the edge
		if(!traced || traced.x == 1 || traced.x == world.maxx || traced.y == 1 || traced.y == world.maxy)
			break
		if(traced.opacity)
			obscured = TRUE
			break
	update_solar_exposure()

/**
 * A Bay solar tracker
 *
 * Linked to a console set to track automatically, it follows the sun and has the console turn its panels to face it.
 */
/obj/structure/machinery/power/bay_tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/solar_panels.dmi'
	icon_state = "tracker"
	density = TRUE
	/// The id of the array, kept from the map though nothing reads it, as in the source
	var/id = 0
	/// The direction of the sun it last tracked, in degrees clockwise from north
	var/sun_angle = 0
	/// The console it is linked to
	var/obj/structure/machinery/power/bay_solar_control/control

/obj/structure/machinery/power/bay_tracker/Initialize(mapload, obj/item/bay_solar_assembly/assembly)
	. = ..()
	if(!assembly)
		assembly = new(src)
		assembly.glass_type = /obj/item/stack/sheet/glass
		assembly.tracker = TRUE
		assembly.anchored = TRUE
	assembly.forceMove(src)
	if(!mapload)
		connect_to_network()

/obj/structure/machinery/power/bay_tracker/Destroy()
	unset_control()
	return ..()

/**
 * Links the tracker to a console, if it is close enough
 *
 * Returns TRUE if it linked.
 * * controller - the console
 */
/obj/structure/machinery/power/bay_tracker/proc/set_control(obj/structure/machinery/power/bay_solar_control/controller)
	if(controller && get_dist(src, controller) > SOLAR_MAX_DIST)
		return FALSE
	control = controller
	return TRUE

/// Unlinks the tracker from its console
/obj/structure/machinery/power/bay_tracker/proc/unset_control()
	if(control)
		control.connected_tracker = null
	control = null

/**
 * Turns the tracker to the sun, and has its console face the panels there if they are still on one network
 *
 * * angle - the direction of the sun, in degrees clockwise from north
 */
/obj/structure/machinery/power/bay_tracker/proc/set_angle(angle)
	sun_angle = angle
	// 22.5 degrees of bias make 67.5 to 112.5 east, and so on
	setDir(turn(NORTH, -angle - 22.5))
	if(powernet && powernet == control?.powernet)
		control.cdir = angle

/obj/structure/machinery/power/bay_tracker/attackby(obj/item/attacking_item, mob/user)
	if(!HAS_TRAIT(attacking_item, TRAIT_TOOL_CROWBAR))
		return ..()
	playsound(loc, 'sound/machines/click.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] begins to take the glass off \the [src]."))
	if(!do_after(user, 5 SECONDS, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src))
		return
	var/obj/item/bay_solar_assembly/assembly = locate() in src
	if(assembly)
		assembly.forceMove(loc)
		assembly.give_glass()
	playsound(loc, 'sound/items/Deconstruct.ogg', 25, TRUE)
	user.visible_message(SPAN_NOTICE("[user] takes the glass off \the [src]."))
	qdel(src)

/**
 * A Bay solar panel assembly, from which panels and trackers are built
 *
 * Wrenched down, it becomes a panel once two sheets of glass are put on it, or a tracker if it has tracker electronics
 * in it. Its glass is CM glass until Bay materials are ported.
 */
/obj/item/bay_solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/solar_panels.dmi'
	icon_state = "sp_base"
	item_state = "electropack"
	w_class = SIZE_HUGE
	anchored = FALSE
	/// Whether it has tracker electronics in it
	var/tracker = FALSE
	/// The type of the glass on it, null if it has none
	var/glass_type

/obj/item/bay_solar_assembly/attack_hand(mob/user)
	// Bolted down, it cannot be picked up
	if(!anchored && isturf(loc))
		return ..()

/// Drops the glass the assembly had, two sheets of it
/obj/item/bay_solar_assembly/proc/give_glass()
	if(!glass_type)
		return
	new glass_type(loc, 2)
	glass_type = null

/obj/item/bay_solar_assembly/attackby(obj/item/attacking_item, mob/user)
	if(isturf(loc) && HAS_TRAIT(attacking_item, TRAIT_TOOL_WRENCH))
		anchored = !anchored
		if(anchored)
			pixel_x = 0
			pixel_y = 0
			user.visible_message(SPAN_NOTICE("[user] wrenches \the [src] into place."))
		else
			user.visible_message(SPAN_NOTICE("[user] unwrenches \the [src] from its place."))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, TRUE)
		return
	if(anchored && istype(attacking_item, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/glass = attacking_item
		if(!glass.use(2))
			to_chat(user, SPAN_WARNING("You need two sheets of glass to put them into a solar panel."))
			return
		glass_type = glass.type
		playsound(loc, 'sound/machines/click.ogg', 25, TRUE)
		user.visible_message(SPAN_NOTICE("[user] places the glass on \the [src]."))
		if(tracker)
			new /obj/structure/machinery/power/bay_tracker(get_turf(src), src)
		else
			new /obj/structure/machinery/power/bay_solar(get_turf(src), src)
		return
	if(!tracker && istype(attacking_item, /obj/item/bay_tracker_electronics))
		tracker = TRUE
		qdel(attacking_item)
		user.visible_message(SPAN_NOTICE("[user] inserts the electronics into \the [src]."))
		return
	if(tracker && HAS_TRAIT(attacking_item, TRAIT_TOOL_CROWBAR))
		new /obj/item/bay_tracker_electronics(loc)
		tracker = FALSE
		user.visible_message(SPAN_NOTICE("[user] takes out the electronics from \the [src]."))
		return
	return ..()

/// The electronics that make a solar panel assembly a tracker
/obj/item/bay_tracker_electronics
	name = "tracker electronics"
	icon = 'modular_chaos/universes/bay12/icons/obj/items/circuitboards.dmi'
	icon_state = "door_electronics"
	w_class = SIZE_SMALL

/**
 * A Bay solar control console
 *
 * It finds the panels and the tracker on its network when told to, and turns the panels: to a set direction, steadily
 * at a set rate, or after the sun as its tracker follows it. It draws power from its area as a console does.
 */
/obj/structure/machinery/power/bay_solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/computer.dmi'
	icon_state = "computer"
	density = TRUE
	power_machine = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 250
	/// The id of the array, kept from the map though nothing reads it, as in the source
	var/id = 0
	/// The direction the panels face, in degrees clockwise from north
	var/cdir = 0
	/// The direction timed tracking turns the panels to at the next update
	var/targetdir = 0
	/// Power the panels made this tick so far, in watts
	var/gen = 0
	/// Power the panels made last tick, in watts
	var/lastgen = 0
	/// How it turns the panels, one of BAY_SOLAR_TRACK_*
	var/track = BAY_SOLAR_TRACK_OFF
	/// How fast timed tracking turns the panels, in degrees an hour, clockwise if positive
	var/trackrate = 600
	/// The world.time timed tracking turns the panels a degree further at
	var/nexttime = 0
	/// The tracker the console follows the sun with
	var/obj/structure/machinery/power/bay_tracker/connected_tracker
	/// The panels the console turns
	var/list/obj/structure/machinery/power/bay_solar/connected_panels = list()

/obj/structure/machinery/power/bay_solar_control/Initialize(mapload)
	. = ..()
	start_processing()
	if(!mapload)
		connect_to_network()
	set_panels(cdir)

/obj/structure/machinery/power/bay_solar_control/Destroy()
	for(var/obj/structure/machinery/power/bay_solar/panel as anything in connected_panels)
		panel.unset_control()
	connected_tracker?.unset_control()
	SSbay_sun.controllers -= src
	return ..()

// Power machines here count as powered regardless of their area; the console runs off its own, as in the source
/obj/structure/machinery/power/bay_solar_control/powered(chan = -1)
	var/area/console_area = get_area(src)
	if(!console_area)
		return FALSE
	return console_area.powered(chan == -1 ? power_channel : chan)

/obj/structure/machinery/power/bay_solar_control/connect_to_network()
	. = ..()
	if(powernet)
		SSbay_sun.controllers |= src
	return .

/obj/structure/machinery/power/bay_solar_control/disconnect_from_network()
	. = ..()
	SSbay_sun.controllers -= src
	return .

/// Links the panels and the tracker on the console's network that are not linked to a console yet
/obj/structure/machinery/power/bay_solar_control/proc/search_for_connected()
	if(!powernet)
		return
	for(var/obj/structure/machinery/power/machine in powernet.nodes)
		if(istype(machine, /obj/structure/machinery/power/bay_solar))
			var/obj/structure/machinery/power/bay_solar/panel = machine
			if(!panel.control && panel.set_control(src))
				connected_panels |= panel
		else if(istype(machine, /obj/structure/machinery/power/bay_tracker) && !connected_tracker)
			var/obj/structure/machinery/power/bay_tracker/tracker = machine
			if(!tracker.control && tracker.set_control(src))
				connected_tracker = tracker

/// Turns the panels where the tracking mode says, every update of the sun
/obj/structure/machinery/power/bay_solar_control/proc/update()
	if(inoperable())
		return
	switch(track)
		if(BAY_SOLAR_TRACK_TIMED)
			if(trackrate)
				cdir = targetdir
		if(BAY_SOLAR_TRACK_AUTO)
			connected_tracker?.set_angle(SSbay_sun.angle)
	set_panels(cdir)

/obj/structure/machinery/power/bay_solar_control/process()
	lastgen = gen
	gen = 0
	if(inoperable())
		return
	if(connected_tracker && connected_tracker.powernet != powernet)
		connected_tracker.unset_control()
	// Timed tracking turns the panels a degree at a time
	if(track == BAY_SOLAR_TRACK_TIMED && trackrate && nexttime <= world.time)
		targetdir = (targetdir + trackrate / abs(trackrate) + 360) % 360
		nexttime += 36000 / abs(trackrate)

/obj/structure/machinery/power/bay_solar_control/update_icon()
	overlays.Cut()
	if(stat & BROKEN)
		icon_state = "broken"
		return
	if(stat & NOPOWER)
		icon_state = "computer"
		return
	icon_state = "solar"
	if(cdir > -1)
		overlays += image(icon, "solcon-o", dir = angle2dir(cdir))

/**
 * Turns the panels to a direction at once
 *
 * * new_dir - the direction, in degrees clockwise from north
 */
/obj/structure/machinery/power/bay_solar_control/proc/set_panels(new_dir)
	for(var/obj/structure/machinery/power/bay_solar/panel as anything in connected_panels)
		panel.adir = new_dir
		panel.occlusion()
		panel.update_icon()
	update_icon()

/// Has the tracker follow the sun
/obj/structure/machinery/power/bay_solar_control/proc/set_to_track_sun()
	connected_tracker.set_angle(SSbay_sun.angle)

/obj/structure/machinery/power/bay_solar_control/ex_act(severity)
	switch(BAY_EX_ACT(severity))
		if(BAY_EX_ACT_DEVASTATING)
			qdel(src)
		if(BAY_EX_ACT_HEAVY)
			if(prob(50))
				set_broken()
		if(BAY_EX_ACT_LIGHT)
			if(prob(25))
				set_broken()

/// Breaks the console
/obj/structure/machinery/power/bay_solar_control/proc/set_broken()
	stat |= BROKEN
	update_icon()

/obj/structure/machinery/power/bay_solar_control/attack_hand(mob/user)
	if(..())
		return
	if(stat & (BROKEN|NOPOWER))
		return
	tgui_interact(user)

/obj/structure/machinery/power/bay_solar_control/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "chaos/BaySolarControl", name)
		ui.open()

/obj/structure/machinery/power/bay_solar_control/ui_data(mob/user)
	return list(
		"generated" = round(lastgen),
		"sun_angle" = round(SSbay_sun.angle),
		"sun_direction" = dir2text(angle2dir(SSbay_sun.angle)),
		"array_angle" = cdir,
		"array_direction" = dir2text(angle2dir(cdir)),
		"track" = track,
		"trackrate" = trackrate,
		"panels" = length(connected_panels),
		"tracker" = !!connected_tracker,
	)

/obj/structure/machinery/power/bay_solar_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("turn")
			var/change = text2num(params["change"])
			if(!(abs(change) in list(1, 15)))
				return
			cdir = clamp((360 + cdir + change) % 360, 0, 359)
			targetdir = cdir
			// Turned by hand, it stops tracking the sun
			if(track == BAY_SOLAR_TRACK_AUTO)
				track = BAY_SOLAR_TRACK_OFF
			set_panels(cdir)
			return TRUE
		if("rate")
			var/change = text2num(params["change"])
			if(!(abs(change) in list(1, 30, 180)))
				return
			trackrate = clamp(trackrate + change, -7200, 7200)
			if(trackrate)
				nexttime = world.time + 36000 / abs(trackrate)
			return TRUE
		if("track")
			var/new_track = text2num(params["track"])
			if(!(new_track in list(BAY_SOLAR_TRACK_OFF, BAY_SOLAR_TRACK_TIMED, BAY_SOLAR_TRACK_AUTO)))
				return
			track = new_track
			if(track == BAY_SOLAR_TRACK_AUTO)
				if(connected_tracker)
					set_to_track_sun()
					set_panels(cdir)
			else if(track == BAY_SOLAR_TRACK_TIMED)
				targetdir = cdir
				if(trackrate)
					nexttime = world.time + 36000 / abs(trackrate)
				set_panels(targetdir)
			return TRUE
		if("search")
			search_for_connected()
			if(connected_tracker && track == BAY_SOLAR_TRACK_AUTO)
				set_to_track_sun()
			set_panels(cdir)
			return TRUE

/**
 * A Bay solar control console that finds its array and starts tracking the sun by itself
 *
 * It does so on its first tick rather than when the map loads, as the networks of a map are made after it loads.
 */
/obj/structure/machinery/power/bay_solar_control/autostart
	track = BAY_SOLAR_TRACK_AUTO
	/// Whether it has looked for its array yet
	var/started = FALSE

/obj/structure/machinery/power/bay_solar_control/autostart/process()
	if(!started && powernet)
		started = TRUE
		search_for_connected()
		if(connected_tracker)
			set_to_track_sun()
		set_panels(cdir)
	return ..()

#undef SOLAR_MAX_DIST
#undef SOLAR_GEN_RATE
#undef BAY_SOLAR_TRACK_OFF
#undef BAY_SOLAR_TRACK_TIMED
#undef BAY_SOLAR_TRACK_AUTO
