/// Every defense that is turned on, which human AI looks through for targets
GLOBAL_LIST_EMPTY_TYPED(all_active_defenses, /obj/structure/machinery/defenses)

// Mapped and premade defenses start turned on without power_on()
/obj/structure/machinery/defenses/Initialize()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(turned_on)
		GLOB.all_active_defenses |= src

/obj/structure/machinery/defenses/Destroy()
	CAN_BE_REDEFINED(TRUE)
	GLOB.all_active_defenses -= src
	return ..()

/obj/structure/machinery/defenses/power_on()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(turned_on)
		GLOB.all_active_defenses |= src

/obj/structure/machinery/defenses/power_off()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(!turned_on)
		GLOB.all_active_defenses -= src

// The Human Defense Creator Panel also offers the IFF of the factions that have human AI presets
/obj/structure/machinery/defenses/handle_iff(selection)
	CAN_BE_REDEFINED(TRUE)
	switch(selection)
		if(FACTION_CLF)
			faction_group = FACTION_LIST_CLF
		if(FACTION_FREELANCER)
			faction_group = FACTION_LIST_FREELANCER
		if(FACTION_TWE)
			faction_group = FACTION_LIST_TWE
		else
			return ..()
