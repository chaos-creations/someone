//Powernet sensors of Baystation 12 (code/modules/power/sensors/powernet_sensor.dm in the source)

/**
 * A Bay powernet sensor
 *
 * Reports on the network of the cable knot under it to power monitoring programs, which list the sensors by their tag.
 * The programs come with the consoles; until then nothing reads it.
 */
/obj/structure/machinery/power/bay_sensor
	name = "Powernet Sensor"
	desc = "Small machine which transmits data about specific powernet."
	icon = 'modular_chaos/universes/bay12/icons/obj/structures/machinery/power_sensor.dmi'
	icon_state = "floor_beacon"
	density = FALSE
	level = 1
	layer = WIRE_TERMINAL_LAYER
	/// The name the sensor is listed under; each one should have its own
	var/name_tag = "#UNKN#"
	/// Whether its reading shows on every monitoring program, whatever level they are on
	var/long_range = FALSE

/obj/structure/machinery/power/bay_sensor/Initialize(mapload, ...)
	. = ..()
	name = "[name_tag] - Powernet Sensor"
	var/turf/sensor_turf = loc
	if(istype(sensor_turf))
		hide(sensor_turf.intact_tile)

/obj/structure/machinery/power/bay_sensor/hide(intact)
	invisibility = intact ? 101 : 0
	alpha = intact ? 127 : 255

/**
 * A power in watts as a reading, in W, kW or MW
 *
 * Readings in kW and MW are rounded, and marked as approximate.
 * * amount - the power, in watts
 */
/obj/structure/machinery/power/bay_sensor/proc/reading_to_text(amount = 0)
	if(amount < 10000)
		return "[amount] W"
	if(amount < 10000000)
		return "~[round(amount / 100) / 10] kW"
	return "~[round(amount / 10000) / 100] MW"

/// The APCs on the sensor's network, which take their power from it directly here rather than through a terminal
/obj/structure/machinery/power/bay_sensor/proc/find_apcs()
	var/list/obj/structure/machinery/power/apc/apcs = list()
	if(!powernet)
		return apcs
	for(var/obj/structure/machinery/power/apc/apc in powernet.nodes)
		apcs += apc
	return apcs

/**
 * The reading of the sensor, for a monitoring program
 *
 * Returns an assoc list: "name" the tag; then either "error", or "apc_data" (a list per APC of "name", the modes of
 * its channels "s_equipment", "s_lighting" and "s_environment", "cell_charge" in percent or "NO CELL", "cell_status"
 * and "total_load"), "total_avail", "total_used_apc", "total_used_other", "total_used_all" and "load_percentage";
 * "alarm" always. CM networks have no fault alarm, so it is always 0.
 */
/obj/structure/machinery/power/bay_sensor/proc/return_reading_data()
	if(!powernet)
		connect_to_network()
	var/list/data = list("name" = name_tag, "alarm" = 0)
	if(!powernet)
		data["error"] = "# SYSTEM ERROR - NO POWERNET #"
		return data

	// The modes of APC channels, and charging states, by their values here
	var/static/list/channel_modes = list("M-OFF", "A-OFF", "M-ON", "A-ON")
	var/static/list/charging_states = list("N", "C", "F")
	var/total_apc_load = 0
	var/list/apc_data = list()
	for(var/obj/structure/machinery/power/apc/apc as anything in find_apcs())
		apc_data += list(list(
			"name" = apc.area.name,
			"s_equipment" = channel_modes[apc.equipment + 1],
			"s_lighting" = channel_modes[apc.lighting + 1],
			"s_environment" = channel_modes[apc.environ + 1],
			"cell_charge" = apc.cell ? round(apc.cell.percent()) : "NO CELL",
			"cell_status" = apc.cell ? charging_states[apc.charging + 1] : "N",
			"total_load" = reading_to_text(apc.lastused_total),
		))
		total_apc_load += apc.lastused_total
	data["apc_data"] = apc_data
	data["total_avail"] = reading_to_text(max(powernet.avail, 0))
	data["total_used_apc"] = reading_to_text(max(total_apc_load, 0))
	data["total_used_other"] = reading_to_text(max(powernet.viewload - total_apc_load, 0))
	data["total_used_all"] = reading_to_text(max(powernet.viewload, 0))
	data["load_percentage"] = powernet.avail ? round(powernet.viewload / powernet.avail * 100) : 100
	return data
