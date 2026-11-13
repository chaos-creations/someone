//Doors of Baystation 12: airlocks, firedoors, blast doors and shutters (/obj/machinery/door in the source)

/**
 * Turns a door along the walls it is set in, as /obj/machinery/door/proc/update_dir() does in the source
 *
 * A door with walls, windows or window frames only north or south of it faces east, across a corridor running east to
 * west; any other door faces south. Bay doors do it on Initialize(), so mappers need not set their dir.
 */
/obj/structure/machinery/door/proc/face_bay_walls()
	var/connections = NONE
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(src, direction)
		if(!neighbor)
			continue
		if(istype(neighbor, /turf/closed/wall) || (locate(/obj/structure/window/framed) in neighbor) || (locate(/obj/structure/window_frame) in neighbor))
			connections |= direction
	if(connections && !(connections & (EAST|WEST)))
		setDir(EAST)
	else
		setDir(SOUTH)

/**
 * A Bay airlock
 *
 * Drawn the way set_airlock_overlays() draws it in the source: the frame in door_file, and over it greyscale layers
 * coloured at runtime: the paint in door_color, the fill (steel, paint, or glass in window_color), the stripe in
 * stripe_color, then the lights. The layers are images without an icon_state, so they show the state the door shows,
 * flicks included; each of their files has every state of the door. Mappers can paint a placed one with door_color and
 * stripe_color, or with color, which becomes door_color on Initialize().
 *
 * In the map editor the door shows icon_state from previews.dmi, its colour scheme baked; on Initialize() it switches
 * to door_file. update_icon() and do_animate() redo the parent's to add the layers; keep them in step with it.
 */
/obj/structure/machinery/door/airlock/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/previews.dmi'
	icon_state = "generic"
	openspeed = 6 // The six frames of the opening animation
	/// The frame of the door, with its panel and welds
	var/door_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/door.dmi'
	/// Steel fill of an unpainted door without glass
	var/fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/fill_steel.dmi'
	/// Paint of the frame, in door_color
	var/color_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/color.dmi'
	/// Fill of a painted door without glass, in door_color
	var/color_fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/fill_color.dmi'
	/// Stripe across the frame, in stripe_color
	var/stripe_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/stripe.dmi'
	/// Stripe across the fill of a door without glass, in stripe_color
	var/stripe_fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/fill_stripe.dmi'
	/// Window of a glass door, in window_color
	var/glass_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/fill_glass.dmi'
	/// Bolt, deny and opening lights, sparks, and the panel opening along with the door
	var/lights_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/station/lights.dmi'
	/// Colour the door is painted, null if it is bare steel
	var/door_color
	/// Colour of the stripe across it, null if it has none
	var/stripe_color
	/// Colour of the window of a glass door
	var/window_color = GLASS_COLOR
	/// Whether the door turns along the walls it is set in on Initialize(); two-tile doors keep their mapped dir
	var/faces_walls = TRUE

/obj/structure/machinery/door/airlock/bay/Initialize(mapload, ...)
	if(color) // Painted in the map editor
		door_color = color
		color = null
	icon = door_file
	. = ..()
	if(faces_walls)
		face_bay_walls()
	update_icon()

/obj/structure/machinery/door/airlock/bay/update_icon()
	overlays.Cut()
	if(!density)
		icon_state = "door_open"
		add_paint_overlays()
		return
	if(locked && lights)
		icon_state = "door_locked"
	else
		icon_state = "door_closed"
	add_paint_overlays()
	if(panel_open)
		overlays += image(icon, "panel_open")
	if(welded)
		overlays += image(icon, "welded")

/obj/structure/machinery/door/airlock/bay/do_animate(animation)
	if(animation != "opening" && animation != "closing")
		return ..()
	// The panel and welds go, the layers stay to play along
	overlays.Cut()
	add_paint_overlays()
	flick("[panel_open ? "o_" : ""]door_[animation]", src)

/// Adds the coloured layers over the frame, as set_airlock_overlays() stacks them in the source
/obj/structure/machinery/door/airlock/bay/proc/add_paint_overlays()
	if(door_color)
		overlays += paint_layer(color_file, door_color)
	if(glass)
		overlays += paint_layer(glass_file, window_color)
	else if(door_color)
		overlays += paint_layer(color_fill_file, door_color)
	else
		overlays += paint_layer(fill_file)
	if(stripe_color)
		overlays += paint_layer(stripe_file, stripe_color)
		if(!glass)
			overlays += paint_layer(stripe_fill_file, stripe_color)
	overlays += paint_layer(lights_file)

/**
 * A layer of a Bay airlock: an image of a whole file without an icon_state, which shows the state of the door
 *
 * The images are cached, as every door of a colour scheme uses the same few.
 * * layer_file - the layer
 * * color - colour it is multiplied by, null for none
 */
/obj/structure/machinery/door/airlock/bay/proc/paint_layer(layer_file, color)
	var/static/list/layer_cache = list()
	var/key = "[layer_file]-[color]"
	var/image/layer = layer_cache[key]
	if(!layer)
		layer = image(layer_file)
		layer.color = color
		layer_cache[key] = layer
	return layer

/obj/structure/machinery/door/airlock/bay/glass
	name = "\improper Glass Airlock"
	icon_state = "glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/command
	icon_state = "command"
	door_color = COLOR_COMMAND_BLUE

/obj/structure/machinery/door/airlock/bay/command/glass
	icon_state = "command_glass"
	stripe_color = COLOR_SKY_BLUE
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/security
	icon_state = "security"
	door_color = COLOR_NT_RED

/obj/structure/machinery/door/airlock/bay/security/glass
	icon_state = "security_glass"
	stripe_color = COLOR_ORANGE
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/engineering
	icon_state = "engineering"
	door_color = COLOR_AMBER

/obj/structure/machinery/door/airlock/bay/engineering/glass
	icon_state = "engineering_glass"
	stripe_color = COLOR_RED
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/atmos
	icon_state = "atmos"
	door_color = COLOR_AMBER
	stripe_color = COLOR_CYAN

/obj/structure/machinery/door/airlock/bay/atmos/glass
	icon_state = "atmos_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/medical
	icon_state = "medical"
	door_color = COLOR_WHITE
	stripe_color = COLOR_DEEP_SKY_BLUE

/obj/structure/machinery/door/airlock/bay/medical/glass
	icon_state = "medical_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/research
	icon_state = "research"
	door_color = COLOR_WHITE
	stripe_color = COLOR_RESEARCH

/obj/structure/machinery/door/airlock/bay/research/glass
	icon_state = "research_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/science
	icon_state = "science"
	door_color = COLOR_WHITE
	stripe_color = COLOR_VIOLET

/obj/structure/machinery/door/airlock/bay/science/glass
	icon_state = "science_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/mining
	name = "\improper Mining Airlock"
	icon_state = "mining"
	door_color = COLOR_PALE_ORANGE
	stripe_color = COLOR_BEASTY_BROWN

/obj/structure/machinery/door/airlock/bay/mining/glass
	icon_state = "mining_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/corporate
	icon_state = "corporate"
	door_color = COLOR_WHITE
	stripe_color = COLOR_BOTTLE_GREEN

/// The blue-grey of the Sol Central Government
/obj/structure/machinery/door/airlock/bay/sol
	icon_state = "sol"
	door_color = COLOR_BLUE_GRAY

/obj/structure/machinery/door/airlock/bay/sol/glass
	icon_state = "sol_glass"
	stripe_color = COLOR_AMBER
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/civilian
	icon_state = "civilian"
	stripe_color = COLOR_CIVIE_GREEN

/obj/structure/machinery/door/airlock/bay/civilian/glass
	icon_state = "civilian_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/maintenance
	name = "\improper Maintenance Access"
	icon_state = "maintenance"
	stripe_color = COLOR_AMBER

/obj/structure/machinery/door/airlock/bay/maintenance/glass
	icon_state = "maintenance_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/freezer
	name = "\improper Freezer Airlock"
	icon_state = "freezer"
	door_color = COLOR_WHITE

/obj/structure/machinery/door/airlock/bay/chaplain
	icon_state = "chaplain"
	stripe_color = COLOR_GRAY20

/obj/structure/machinery/door/airlock/bay/crystal
	name = "\improper Crystal Airlock"
	icon_state = "crystal"
	door_color = COLOR_CRYSTAL

/// An airlock to space or another ship, red with a warning sign
/obj/structure/machinery/door/airlock/bay/external
	name = "\improper External Airlock"
	icon_state = "external"
	door_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/external/door.dmi'
	fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/external/fill_steel.dmi'
	color_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/external/color.dmi'
	color_fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/external/fill_color.dmi'
	glass_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/external/fill_glass.dmi'
	lights_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/external/lights.dmi'
	door_color = COLOR_NT_RED

/obj/structure/machinery/door/airlock/bay/external/glass
	icon_state = "external_glass"
	opacity = FALSE
	glass = TRUE

/// The bolted door of an escape pod
/obj/structure/machinery/door/airlock/bay/external/escapepod
	name = "\improper Escape Pod"
	locked = TRUE

/// A round airtight hatch
/obj/structure/machinery/door/airlock/bay/hatch
	name = "\improper Airtight Hatch"
	icon_state = "hatch"
	door_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/hatch/door.dmi'
	fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/hatch/fill_steel.dmi'
	stripe_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/hatch/stripe.dmi'
	stripe_fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/hatch/fill_stripe.dmi'
	lights_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/hatch/lights.dmi'

/obj/structure/machinery/door/airlock/bay/hatch/maintenance
	name = "\improper Maintenance Hatch"
	icon_state = "hatch_maintenance"
	stripe_color = COLOR_AMBER

/obj/structure/machinery/door/airlock/bay/hatch/maintenance/bolted
	locked = TRUE

/// A heavy airlock of bare plates for vaults and armouries
/obj/structure/machinery/door/airlock/bay/highsecurity
	name = "\improper Secure Airlock"
	icon_state = "highsecurity"
	door_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/secure/door.dmi'
	fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/secure/fill_steel.dmi'
	lights_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/secure/lights.dmi'

/// The heavy door of a vault, which nothing sees through
/obj/structure/machinery/door/airlock/bay/vault
	name = "\improper Vault"
	icon_state = "vault"
	door_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/vault/door.dmi'
	fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/vault/fill_steel.dmi'
	lights_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/vault/lights.dmi'

/obj/structure/machinery/door/airlock/bay/vault/bolted
	locked = TRUE

/**
 * A Bay airlock two tiles wide (/obj/machinery/door/airlock/multi_tile in the source)
 *
 * It spans the tile east of it if it faces north or south and the tile north of it otherwise, as in the source; CM doors
 * do the other way round. The door turns along its walls before it initializes, as
 * /obj/machinery/door/airlock/multi_tile/on_update_icon() does in the source: with walls only north or south of it,
 * the far ones looked for past its second tile, it faces west and spans north; otherwise it faces south and spans east.
 */
/obj/structure/machinery/door/airlock/bay/double
	name = "\improper Airlock"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/previews_double.dmi'
	icon_state = "double"
	width = 2
	faces_walls = FALSE
	damage_cap = 650
	door_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/door.dmi'
	fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/fill_steel.dmi'
	color_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/color.dmi'
	color_fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/fill_color.dmi'
	stripe_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/stripe.dmi'
	stripe_fill_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/fill_stripe.dmi'
	glass_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/fill_glass.dmi'
	lights_file = 'modular_chaos/universes/bay12/icons/obj/structures/doors/airlocks/double/lights.dmi'

/obj/structure/machinery/door/airlock/bay/double/Initialize(mapload, ...)
	var/connections = NONE
	for(var/direction in GLOB.cardinals)
		var/turf/neighbor = get_step(src, direction)
		if(direction & (NORTH|EAST))
			neighbor = get_step(neighbor, direction)
		if(!neighbor)
			continue
		if(istype(neighbor, /turf/closed/wall) || (locate(/obj/structure/window/framed) in neighbor) || (locate(/obj/structure/window_frame) in neighbor))
			connections |= direction
	setDir((connections && !(connections & (EAST|WEST))) ? WEST : SOUTH)
	return ..()

/// Spans the tiles the way the source does, which its sprites are drawn for: east if it faces north or south, the other way round from CM doors
/obj/structure/machinery/door/airlock/bay/double/handle_multidoor()
	if(dir in list(NORTH, SOUTH))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size
	change_filler_opacity(opacity)

/obj/structure/machinery/door/airlock/bay/double/locate_filler_turfs()
	var/list/located_turfs = list()
	for(var/i in 1 to width - 1)
		var/turf/filler = (dir in list(NORTH, SOUTH)) ? locate(x + i, y, z) : locate(x, y + i, z)
		if(filler)
			located_turfs += filler
	return located_turfs

/obj/structure/machinery/door/airlock/bay/double/engineering
	name = "\improper Maintenance Hatch"
	icon_state = "double_engineering"
	door_color = COLOR_AMBER

/obj/structure/machinery/door/airlock/bay/double/civilian
	icon_state = "double_civilian"
	stripe_color = COLOR_CIVIE_GREEN

/obj/structure/machinery/door/airlock/bay/double/glass
	name = "\improper Glass Airlock"
	icon_state = "double_glass"
	opacity = FALSE
	glass = TRUE

/obj/structure/machinery/door/airlock/bay/double/glass/civilian
	icon_state = "double_civilian_glass"
	stripe_color = COLOR_CIVIE_GREEN

/obj/structure/machinery/door/airlock/bay/double/glass/command
	icon_state = "double_command_glass"
	door_color = COLOR_COMMAND_BLUE
	stripe_color = COLOR_SKY_BLUE

/obj/structure/machinery/door/airlock/bay/double/glass/security
	icon_state = "double_security_glass"
	door_color = COLOR_NT_RED
	stripe_color = COLOR_ORANGE

/obj/structure/machinery/door/airlock/bay/double/glass/medical
	icon_state = "double_medical_glass"
	door_color = COLOR_WHITE
	stripe_color = COLOR_DEEP_SKY_BLUE

/obj/structure/machinery/door/airlock/bay/double/glass/research
	icon_state = "double_research_glass"
	door_color = COLOR_WHITE
	stripe_color = COLOR_RESEARCH

/// A Bay firedoor, a full-tile emergency shutter that faces along its walls like Bay airlocks
/obj/structure/machinery/door/firedoor/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/firedoor.dmi'
	openspeed = 6 // The six frames of the opening animation

/obj/structure/machinery/door/firedoor/bay/Initialize(mapload, ...)
	. = ..()
	face_bay_walls()

/// A Bay blast door; like other blast doors it keeps the dir it is mapped with
/obj/structure/machinery/door/poddoor/bay
	name = "blast door"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/blastdoors_shutters.dmi'
	icon_state = "pdoor1"
	base_icon_state = "pdoor"

/obj/structure/machinery/door/poddoor/bay/open
	icon_state = "pdoor0"
	density = FALSE

/// The blast door that lets an escape pod go
/obj/structure/machinery/door/poddoor/bay/escape_pod
	name = "escape pod release door"

/// Bay shutters; they keep the dir they are mapped with
/obj/structure/machinery/door/poddoor/shutters/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/blastdoors_shutters.dmi'

/obj/structure/machinery/door/poddoor/shutters/bay/open
	icon_state = "shutter0"
	density = FALSE

// Windoors, the morgue door and simple doors

/// A Bay windoor, /obj/machinery/door/window in the source: a CM windoor with the sprites of the source
/obj/structure/machinery/door/window/bay
	name = "interior door"
	desc = "A strong door."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/windoor.dmi'

/// A Bay brig door, /obj/machinery/door/window/brigdoor in the source: a CM brig door with the secure windoor sprites
/obj/structure/machinery/door/window/brigdoor/bay
	name = "secure door"
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"

/obj/structure/machinery/door/window/bay/northleft
	dir = NORTH

/obj/structure/machinery/door/window/bay/eastleft
	dir = EAST

/obj/structure/machinery/door/window/bay/westleft
	dir = WEST

/obj/structure/machinery/door/window/bay/southleft
	dir = SOUTH

/obj/structure/machinery/door/window/bay/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/bay/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/bay/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/bay/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/brigdoor/bay/northleft
	dir = NORTH
	icon_state = "leftsecure"
	base_state = "leftsecure"

/obj/structure/machinery/door/window/brigdoor/bay/eastleft
	dir = EAST
	icon_state = "leftsecure"
	base_state = "leftsecure"

/obj/structure/machinery/door/window/brigdoor/bay/westleft
	dir = WEST
	icon_state = "leftsecure"
	base_state = "leftsecure"

/obj/structure/machinery/door/window/brigdoor/bay/southleft
	dir = SOUTH
	icon_state = "leftsecure"
	base_state = "leftsecure"

/obj/structure/machinery/door/window/brigdoor/bay/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/structure/machinery/door/window/brigdoor/bay/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/structure/machinery/door/window/brigdoor/bay/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/structure/machinery/door/window/brigdoor/bay/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/// The sliding door of a morgue, /obj/machinery/door/morgue in the source
/obj/structure/machinery/door/morgue/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/doormorgue.dmi'

/// A Bay simple door (/obj/machinery/door/unpowered/simple in the source): a CM mineral door
/obj/structure/mineral_door/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/doors/material_doors.dmi'

/obj/structure/mineral_door/bay/plastic
	icon_state = "plastic"
	mineralType = "plastic"

/// A plastic door that starts open
/obj/structure/mineral_door/bay/plastic/open
	icon_state = "plasticopen"
	open = TRUE
	density = FALSE
	opacity = FALSE

/obj/structure/mineral_door/bay/plastic/open/Initialize(mapload, ...)
	. = ..()
	update_icon()
