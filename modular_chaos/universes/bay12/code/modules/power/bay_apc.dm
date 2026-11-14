//Area power controllers of Baystation 12 (code/modules/power/apc.dm in the source)

/**
 * A Bay APC
 *
 * A CM APC with the sprites of the source (tools/bake_structures.py colours its lights the way the source does at
 * runtime), set 22 pixels out against the wall its dir points at. In an area with Bay power it is fed by the cable
 * knot on its turf, as the source's terminal under it is; its CM terminal only shows that wiring.
 *
 * A standard one gets the CM APC cell rather than the source's standard cell, as CM APCs turn their channels off below
 * a set charge (1250 and 750) that a cell of 1000 would always be under.
 */
/obj/structure/machinery/power/apc/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/apc.dmi'
	cell_type = /obj/item/cell/apc

/obj/structure/machinery/power/apc/bay/Initialize(mapload, ndir, building)
	. = ..()
	pixel_x = 0
	pixel_y = 0
	switch(dir)
		if(NORTH)
			pixel_y = 22
		if(SOUTH)
			pixel_y = -22
		if(EAST)
			pixel_x = 22
		if(WEST)
			pixel_x = -22

/obj/structure/machinery/power/apc/bay/make_terminal()
	. = ..()
	terminal.icon = icon
	terminal.icon_state = "term"

/obj/structure/machinery/power/apc/bay/high
	cell_type = /obj/item/cell/high

/obj/structure/machinery/power/apc/bay/super
	cell_type = /obj/item/cell/super

/obj/structure/machinery/power/apc/bay/hyper
	cell_type = /obj/item/cell/hyper

// When it turns the lights of its area off on its own to save its cell, their emergency lighting comes on, as in the source
/obj/structure/machinery/power/apc/bay/update()
	var/had_light = area.power_light
	. = ..()
	if(area.power_light != had_light)
		area.set_emergency_lighting(operating && !shorted && lighting == 1)
