/// Limited supply drop console that drops for the ship's platoon (see [/datum/map_config/var/platoon]) instead of Echo squad
/obj/structure/machinery/computer/supply_drop_console/limited/alternate
	icon = 'icons/obj/structures/props/almayer/almayer_props.dmi'
	icon_state = "sensor_comp2"

/obj/structure/machinery/computer/supply_drop_console/limited/alternate/New()
	..()
	var/platoon_type = SSmapping.get_main_ship_platoon()
	if(platoon_type && GLOB.RoleAuthority)
		current_squad = GLOB.RoleAuthority.squads_by_type[platoon_type]
