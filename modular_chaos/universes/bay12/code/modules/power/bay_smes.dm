//SMES units and their terminals of Baystation 12 (code/modules/power/smes.dm, smes_construction.dm and terminal.dm in the source)

/// Charge of a Bay SMES here per unit of charge in the source: CM SMES units keep charge in SMESRATE units, Bay ones in CELLRATE units (1/1800)
#define BAY_SMES_CHARGE_SCALE 90
/// The SMESRATE of code/modules/power/smes.dm, which undefines it: charge per watt a CM SMES takes in or gives out each tick
#define SMESRATE 0.05

/**
 * A Bay power terminal: the wiring an SMES charges through, on the turf next to it and facing it
 *
 * A power machine of its own, on a cable knot, so the SMES draws from the network of that cable while it feeds the
 * network under itself.
 */
/obj/structure/machinery/power/bay_terminal
	name = "terminal"
	desc = "It's an underfloor wiring terminal for power equipment."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/apc.dmi'
	icon_state = "term"
	level = 1
	layer = WIRE_TERMINAL_LAYER
	/// The SMES charging through the terminal
	var/obj/structure/machinery/power/smes/bay/master

/obj/structure/machinery/power/bay_terminal/Initialize(mapload, ...)
	. = ..()
	var/turf/terminal_turf = loc
	if(level == 1 && istype(terminal_turf))
		hide(terminal_turf.intact_tile)

/obj/structure/machinery/power/bay_terminal/hide(intact)
	invisibility = intact ? 101 : 0
	alpha = intact ? 127 : 255

/obj/structure/machinery/power/bay_terminal/Destroy()
	if(master?.input_terminal == src)
		master.input_terminal = null
	master = null
	return ..()

/**
 * A Bay SMES, /obj/machinery/power/smes/buildable in the source, with one standard coil
 *
 * A CM SMES that charges as the source's do: it asks the network of its terminal for power each tick, and is given only
 * what is left once everything else on that network drew (/datum/powernet/bay/process()). It outputs to the network
 * under it and takes back what that one did not use, as CM SMES units do. Its capacity and transfer rates are the
 * source's for the coils it has; the charge is in CM units (BAY_SMES_CHARGE_SCALE).
 */
/obj/structure/machinery/power/smes/bay
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/smes.dmi'
	icon_state = "smes"
	should_be_mapped = TRUE
	capacity = 50000 * BAY_SMES_CHARGE_SCALE
	charge = 0
	input_level = 50000
	input_level_max = 250000
	output_level = 50000
	output_level_max = 250000
	outputting = FALSE
	/// The terminal the SMES charges through, null if it has none
	var/obj/structure/machinery/power/bay_terminal/input_terminal
	/// Power the SMES asked its terminal's network for this tick, in watts
	var/target_load = 0
	/// The charge, inputting and outputting states the overlays show, to redraw them only when one changes
	var/list/shown_state

/obj/structure/machinery/power/smes/bay/Initialize()
	. = ..()
	// The parent looks for a CM terminal and marks the SMES broken without one; it charges through a Bay one instead
	for(var/direction in GLOB.cardinals)
		var/obj/structure/machinery/power/bay_terminal/found = locate() in get_step(src, direction)
		if(found && !found.master && found.dir == REVERSE_DIR(direction))
			input_terminal = found
			found.master = src
			break
	stat &= ~BROKEN
	updateicon()
	start_processing()
	return INITIALIZE_HINT_ROUNDSTART

/obj/structure/machinery/power/smes/bay/Destroy()
	if(input_terminal)
		input_terminal.master = null
		input_terminal = null
	return ..()

/obj/structure/machinery/power/smes/bay/process()
	if(stat & BROKEN)
		return
	var/list/state = list(chargedisplay(), inputting, outputting && powernet && charge > 0)
	if(state ~! shown_state)
		shown_state = state
		updateicon()
	// What the terminal's network gives comes in input_power(), from what is left over there
	inputting = 0
	target_load = 0
	if(input_attempt && input_terminal?.powernet && charge < capacity)
		target_load = min((capacity - charge) / SMESRATE, input_level)
		var/datum/powernet/bay/network = input_terminal.powernet
		network.smes_demand += target_load
		network.inputting |= src
	output_used = 0
	if(outputting && powernet && charge > 0)
		output_used = min(charge / SMESRATE, output_level)
		charge -= output_used * SMESRATE
		add_avail(output_used)

/**
 * Charges the SMES with a share of what it asked its terminal's network for, /obj/machinery/power/smes/proc/input_power() in the source
 *
 * Returns the power drawn, in watts.
 * * percentage - the share, 0 to 100
 */
/obj/structure/machinery/power/smes/bay/proc/input_power(percentage)
	var/to_input = clamp(target_load * percentage / 100, 0, target_load)
	charge = min(charge + to_input * SMESRATE, capacity)
	input_available = to_input
	if(percentage >= 100)
		inputting = 2
	else if(to_input)
		inputting = 1
	return to_input

/obj/structure/machinery/power/smes/bay/updateicon()
	overlays.Cut()
	if(stat & BROKEN)
		return
	if(!outputting)
		overlays += image(icon, "smes-op0")
	else if(powernet && charge > 0)
		overlays += image(icon, "smes-op2")
	else
		overlays += image(icon, "smes-op1")
	if(inputting == 2)
		overlays += image(icon, "smes-oc2")
	else if(inputting == 1)
		overlays += image(icon, "smes-oc1")
	else if(input_attempt)
		overlays += image(icon, "smes-oc0")
	var/charge_level = chargedisplay()
	if(charge_level)
		overlays += image(icon, "smes-og[charge_level]")
	if(open_hatch)
		overlays += image(icon, "smes-panel")

/**
 * A Bay SMES set up when the map loads, /obj/machinery/power/smes/buildable/preset in the source
 *
 * The underscored vars say what to set: transfer rates at their maximum, charging and outputting on, full charge.
 */
/obj/structure/machinery/power/smes/bay/preset
	/// Whether it starts fully charged
	var/fully_charged = FALSE
	/// Whether it starts charging at its maximum rate
	var/input_maxed = FALSE
	/// Whether it starts charging
	var/input_on = FALSE
	/// Whether it starts outputting at its maximum rate
	var/output_maxed = FALSE
	/// Whether it starts outputting
	var/output_on = FALSE

/obj/structure/machinery/power/smes/bay/preset/Initialize()
	if(input_maxed)
		input_level = input_level_max
	if(output_maxed)
		output_level = output_level_max
	input_attempt = input_on
	outputting = output_on
	if(fully_charged)
		charge = capacity
	return ..()

/obj/structure/machinery/power/smes/bay/preset/on_full
	fully_charged = TRUE
	input_maxed = TRUE
	input_on = TRUE
	output_maxed = TRUE
	output_on = TRUE

// The SMES units of the Torch (maps/torch/torch_presets.dm in the source), with their capacity and rates from their coils

/// A substation: two standard coils
/obj/structure/machinery/power/smes/bay/preset/torch/substation
	capacity = 100000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 500000
	output_level_max = 500000
	input_maxed = TRUE
	output_maxed = TRUE

/obj/structure/machinery/power/smes/bay/preset/torch/substation_full
	capacity = 100000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 500000
	output_level_max = 500000
	fully_charged = TRUE
	input_maxed = TRUE
	input_on = TRUE
	output_maxed = TRUE
	output_on = TRUE

/// The substation of the fusion engine: a standard coil and two transmission coils
/obj/structure/machinery/power/smes/bay/preset/torch/substation_full/rust
	capacity = 90000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 2750000
	output_level_max = 2750000

/// The output of the main engine: a standard coil, two transmission and two capacitance coils
/obj/structure/machinery/power/smes/bay/preset/torch/engine_main
	capacity = 590000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 2950000
	output_level_max = 2950000
	fully_charged = TRUE
	input_maxed = TRUE
	input_on = TRUE
	output_maxed = TRUE
	output_on = TRUE

/// The output of the fusion engine, as the main one but empty
/obj/structure/machinery/power/smes/bay/preset/torch/engine_empty
	capacity = 590000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 2950000
	output_level_max = 2950000
	input_maxed = TRUE
	input_on = TRUE
	output_maxed = TRUE
	output_on = TRUE

/// The SMES of a shuttle: a standard, a transmission and a capacitance coil
/obj/structure/machinery/power/smes/bay/preset/torch/shuttle
	capacity = 320000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 1600000
	output_level_max = 1600000
	fully_charged = TRUE
	input_maxed = TRUE
	input_on = TRUE
	output_maxed = TRUE
	output_on = TRUE

/// The hangar, which charges the shuttles: a standard coil and two transmission coils
/obj/structure/machinery/power/smes/bay/preset/torch/hangar
	capacity = 90000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 2750000
	output_level_max = 2750000
	fully_charged = TRUE
	input_maxed = TRUE
	input_on = TRUE
	output_maxed = TRUE
	output_on = TRUE

/// The SMES of the bridge solar array: two standard coils
/obj/structure/machinery/power/smes/bay/preset/torch/bridge_solar
	name_tag = "Solar - Bridge"
	capacity = 100000 * BAY_SMES_CHARGE_SCALE
	input_level_max = 500000
	output_level_max = 500000
	fully_charged = TRUE
	input_maxed = TRUE
	input_on = TRUE
	output_maxed = TRUE
	output_on = TRUE

#undef BAY_SMES_CHARGE_SCALE
#undef SMESRATE
