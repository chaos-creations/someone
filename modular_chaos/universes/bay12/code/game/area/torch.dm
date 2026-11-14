//Areas of the SEV Torch (the areas of maps/torch/ and code/game/area/ in the source), written by
//tools/port_map.py areas, which this should be written by again rather than edited: the area types of the source the
//map places and their parents, under /area/torch, with their names, icons, sound environments, power and the tone
//of their lights.

/// Every area of the SEV Torch: a ship whose power runs along its cables, as in the source
/area/torch
	name = "SEV Torch"
	icon = 'modular_chaos/universes/bay12/icons/turf/areas.dmi'
	icon_state = "unknown"
	ceiling = CEILING_METAL
	powernet_name = "torch"
	bay_power = TRUE
	sound_environment = SOUND_ENVIRONMENT_STONEROOM
	ambience_exterior = AMBIENCE_ALMAYER
	ceiling_muffle = FALSE
	weather_enabled = FALSE

/area/torch/aquila
	name = "\improper SEV Aquila"
	icon_state = "shuttlered"

/area/torch/aquila/air
	name = "\improper SEV Aquila - Life Support Compartment"

/area/torch/aquila/airlock
	name = "\improper SEV Aquila - Airlock Compartment"

/area/torch/aquila/cockpit
	name = "\improper SEV Aquila - Cockpit"

/area/torch/aquila/crew
	name = "\improper SEV Aquila - Crew Compartment"

/area/torch/aquila/medical
	name = "\improper SEV Aquila - Medical Compartment"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/aquila/power
	name = "\improper SEV Aquila - Engineering Compartment"

/area/torch/aquila/storage
	name = "\improper SEV Aquila - Storage Bay"

/area/torch/aquila/suits
	name = "\improper SEV Aquila - Suit Storage Compartment"

/area/torch/assembly

/area/torch/assembly/chargebay
	name = "\improper Mech Bay"
	icon_state = "mechbay"

/area/torch/assembly/robotics
	name = "\improper Robotics Workshop"
	icon_state = "robotics"

/area/torch/assembly/robotics/laboratory
	name = "\improper Robotics Laboratory"

/area/torch/assembly/robotics/office
	name = "\improper Robotics Office"

/area/torch/assembly/robotics/surgery
	name = "\improper Robotics Operating Theatre"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/aux_eva
	name = "\improper Command EVA Storage"
	icon_state = "eva"

/area/torch/bridge
	name = "\improper SEV Torch Bridge"
	icon_state = "bridge"

/area/torch/bridge/disciplinary_board_room
	name = "\improper Disciplinary Board Room"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/bridge/disciplinary_board_room/deliberation
	name = "\improper Deliberation Room"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/bridge/hallway
	name = "\improper Bridge Access Hallway"
	icon_state = "bridge_hallway"

/area/torch/bridge/hallway/port
	name = "\improper Bridge Port Access Hallway"

/area/torch/bridge/hallway/starboard
	name = "\improper Bridge Starboard Access Hallway"

/area/torch/bridge/meeting_room
	name = "\improper Command Meeting Room"
	icon_state = "bridge_meeting"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM

/area/torch/bridge/storage
	name = "\improper Bridge Storage"

/area/torch/chapel
	name = "\improper Chapel"
	icon_state = "chapel"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/chapel/main
	name = "\improper Chapel"
	icon_state = "chapel"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/torch/chapel/memorial
	name = "\improper Memorial Room"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/torch/chapel/office
	name = "\improper Chaplain's Office"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/torch/command

/area/torch/command/armoury
	name = "\improper Emergency Armory"
	icon_state = "Warden"

/area/torch/command/armoury/access
	name = "\improper Emergency Armory - Access"

/area/torch/command/armoury/tactical
	name = "\improper Emergency Armory - Tactical"
	icon_state = "Tactical"

/area/torch/command/captainmess
	name = "Officer's Mess"
	icon_state = "bar"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/command/conference
	name = "Briefing Room"
	icon_state = "briefing_room"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM

/area/torch/command/disperser
	name = "\improper Obstruction Field Disperser"
	icon_state = "disperser"

/area/torch/command/pathfinder
	name = "\improper Pathfinder's Office"
	icon_state = "pathfinder_office"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM

/area/torch/command/pilot
	name = "\improper Pilot's Lounge"
	icon_state = "pilot_lounge"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM

/area/torch/command/probe_bay
	name = "\improper Probe Bay"
	icon_state = "disperser"

/area/torch/crew_quarters

/area/torch/crew_quarters/adherent
	name = "\improper Adherent Maintenence"
	icon_state = "robotics"

/area/torch/crew_quarters/chief_steward
	name = "\improper Chief Steward's Office"
	icon_state = "kitchen"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/commissary
	name = "\improper Commissary"
	icon_state = "crew_quarters"

/area/torch/crew_quarters/cryolocker
	name = "\improper Cryogenic Storage Wardrobe"
	icon_state = "locker"

/area/torch/crew_quarters/diplomatic_office
	name = "\improper Diplomatic Meeting Room"
	icon_state = "crew_quarters"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/crew_quarters/galley
	name = "\improper Galley"
	icon_state = "kitchen"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/crew_quarters/galleybackroom
	name = "\improper Galley Cold Storage"
	icon_state = "kitchen"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/crew_quarters/gym
	name = "\improper Gym"
	icon_state = "fitness"

/area/torch/crew_quarters/head
	name = "\improper Third Deck Head"
	icon_state = "toilet"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/crew_quarters/head/deck1
	name = "\improper First Deck Head"

/area/torch/crew_quarters/head/deck4
	name = "\improper Fourth Deck Head"

/area/torch/crew_quarters/head/sauna
	name = "\improper Sauna"
	icon_state = "sauna"

/area/torch/crew_quarters/heads
	icon_state = "head_quarters"

/area/torch/crew_quarters/heads/cobed
	name = "\improper Command - CO's Quarters"
	icon_state = "heads_cap"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/heads/office/ce
	name = "\improper Engineering - CE's Office"
	icon_state = "heads_ce"

/area/torch/crew_quarters/heads/office/cl
	name = "\improper Command - CL's Office"
	icon_state = "heads_cl"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/heads/office/cl/backroom
	name = "\improper Command - CL's Backroom"
	icon_state = "heads_cl"

/area/torch/crew_quarters/heads/office/cmo
	name = "\improper Command - CMO's Office"
	icon_state = "heads_cmo"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/crew_quarters/heads/office/co
	name = "\improper Command - CO's Office"
	icon_state = "heads_cap"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/heads/office/cos
	name = "\improper Command - CoS' Office"
	icon_state = "heads_hos"

/area/torch/crew_quarters/heads/office/rd
	name = "\improper Command - CSO's Office"
	icon_state = "heads_rd"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/crew_quarters/heads/office/sea
	name = "\improper Command - SEA's Office"
	icon_state = "heads_sea"

/area/torch/crew_quarters/heads/office/sgr
	name = "\improper Command - SCGR's Office"
	icon_state = "heads_sr"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/heads/office/xo
	name = "\improper Command - XO's Office"
	icon_state = "heads_hop"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/laundry
	name = "\improper Laundry Room"
	icon_state = "Sleep"

/area/torch/crew_quarters/lounge
	name = "\improper Lounge"
	icon_state = "crew_quarters"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/mess
	name = "\improper Mess Hall"
	icon_state = "cafeteria"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/observation
	name = "\improper Observation"
	icon_state = "fitness"

/area/torch/crew_quarters/office
	name = "\improper Computer Lab"
	icon_state = "conference"

/area/torch/crew_quarters/recreation
	name = "\improper Recreation"
	icon_state = "crew_quarters"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/safe_room
	name = "\improper Safe Room"
	icon_state = "crew_quarters"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/crew_quarters/safe_room/bridge
	name = "\improper Bridge Safe Room"

/area/torch/crew_quarters/safe_room/firstdeck
	name = "\improper First Deck Safe Room"

/area/torch/crew_quarters/safe_room/medical
	name = "\improper Medical Safe Room"

/area/torch/crew_quarters/safe_room/thirddeck
	name = "\improper Third Deck Safe Room"

/area/torch/crew_quarters/service_break_room
	name = "\improper Service Break Room"
	icon_state = "fitness"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/sleep/bunk
	name = "\improper Bunk Room"
	icon_state = "Sleep"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/crew_quarters/sleep/cryo
	name = "\improper Third Deck Cryogenic Storage"
	icon_state = "Sleep"

/area/torch/crew_quarters/sleep/cryo/aux
	name = "\improper First Deck Cryogenic Storage"
	icon_state = "Sleep"

/area/torch/engineering/atmos
	name = "\improper Atmospherics"
	icon_state = "atmos"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/torch/engineering/atmos/aux
	name = "\improper Auxiliary Atmospherics"
	icon_state = "atmos"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/engineering/atmos/storage
	name = "\improper Atmospherics Storage"
	icon_state = "atmos_storage"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/engineering/auxpower
	name = "\improper Auxiliary Power Storage"
	icon_state = "engine_smes"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/engineering/bluespace
	name = "Bluespace Drive Containment"
	icon_state = "engineering"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/torch/engineering/bluespacebay
	name = "Bluespace Drive Containment Control Room"
	icon_state = "engineering"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/engineering/engine_monitoring
	name = "\improper Engine Monitoring Room"
	icon_state = "engine_monitoring"

/area/torch/engineering/engine_room
	name = "\improper Engine Room"
	icon_state = "engine"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/torch/engineering/engine_smes
	name = "\improper Engineering SMES"
	icon_state = "engine_smes"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/engineering/engineering_bay
	name = "\improper Engineering Bay"
	icon_state = "engineering_locker"

/area/torch/engineering/foyer
	name = "\improper Engineering Foyer"
	icon_state = "engineering_foyer"

/area/torch/engineering/fuelbay
	name = "\improper Fuel Bay"
	icon_state = "engineering"

/area/torch/engineering/hardstorage
	name = "\improper Engineering Hard Storage"
	icon_state = "engineering_storage"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/engineering/hardstorage/aux
	name = "\improper Auxiliary Engineering Hard Storage"
	icon_state = "engineering_storage"

/area/torch/engineering/prototype

/area/torch/engineering/prototype/control
	name = "\improper Prototype Fusion Reactor Control Room"
	icon_state = "engine_monitoring"

/area/torch/engineering/prototype/engine
	name = "\improper Prototype Fusion Reactor Chamber"
	icon_state = "rust_reactor"

/area/torch/engineering/shieldbay
	name = "Shield Bay"
	icon_state = "engineering"

/area/torch/engineering/storage
	name = "\improper Engineering Storage"
	icon_state = "engineering_storage"

/area/torch/engineering/wastetank
	name = "\improper Waste Tank"
	icon_state = "engineering"

/area/torch/eva
	name = "\improper EVA Storage"
	icon_state = "eva"

/area/torch/exploration_shuttle
	name = "\improper Charon"
	icon_state = "shuttlered"

/area/torch/exploration_shuttle/airlock
	name = "\improper Charon - Airlock Compartment"

/area/torch/exploration_shuttle/atmos
	name = "\improper Charon - Atmos Compartment"

/area/torch/exploration_shuttle/cargo
	name = "\improper Charon - Cargo Bay"

/area/torch/exploration_shuttle/cockpit
	name = "\improper Charon - Cockpit"

/area/torch/exploration_shuttle/crew
	name = "\improper Charon - Crew Compartment"

/area/torch/exploration_shuttle/fuel
	name = "\improper Charon - Fuel Compartment"

/area/torch/exploration_shuttle/medical
	name = "\improper Charon - Medical Compartment"

/area/torch/exploration_shuttle/power
	name = "\improper Charon - Power Compartment"

/area/torch/guppy_hangar/start
	name = "\improper Guppy"
	icon_state = "shuttlered"

/area/torch/hallway
	name = "hallway"

/area/torch/hallway/primary/bridge/aft
	name = "\improper Bridge Aft Hallway"
	icon_state = "hallA"

/area/torch/hallway/primary/bridge/fore
	name = "\improper Bridge Fore Hallway"
	icon_state = "hallF"

/area/torch/hallway/primary/fifthdeck/aft
	name = "\improper Fifth Deck Aft Hallway"
	icon_state = "hallA"

/area/torch/hallway/primary/fifthdeck/fore
	name = "\improper Fifth Deck Fore Hallway"
	icon_state = "hallF"

/area/torch/hallway/primary/firstdeck/aft
	name = "\improper First Deck Aft Hallway"
	icon_state = "hallA"

/area/torch/hallway/primary/firstdeck/center
	name = "\improper First Deck Central Hallway"
	icon_state = "hallC1"

/area/torch/hallway/primary/firstdeck/fore
	name = "\improper First Deck Fore Hallway"
	icon_state = "hallF"

/area/torch/hallway/primary/fourthdeck/aft
	name = "\improper Fourth Deck Aft Hallway"
	icon_state = "hallA"

/area/torch/hallway/primary/fourthdeck/fore
	name = "\improper Fourth Deck Fore Hallway"
	icon_state = "hallF"

/area/torch/hallway/primary/seconddeck
	name = "Second Deck Central Hallway"
	icon_state = "hallC2"

/area/torch/hallway/primary/seconddeck/center
	name = "\improper Second Deck Stairwell"

/area/torch/hallway/primary/seconddeck/elevator
	name = "Second Deck Elevator Landing"
	icon_state = "hallC2_e"

/area/torch/hallway/primary/seconddeck/fore
	name = "Second Deck Fore Hallway"
	icon_state = "hallF2"

/area/torch/hallway/primary/thirddeck/aft
	name = "\improper Third Deck Aft Hallway"
	icon_state = "hallA"

/area/torch/hallway/primary/thirddeck/center
	name = "\improper Third Deck Central Hallway"
	icon_state = "hallC3"

/area/torch/hallway/primary/thirddeck/fore
	name = "\improper Third Deck Fore Hallway"
	icon_state = "hallF"

/area/torch/holocontrol
	name = "\improper Holodeck Control"
	icon_state = "Holodeck"

/area/torch/holodeck
	name = "\improper Holodeck"
	icon_state = "Holodeck"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/torch/holodeck/alphadeck
	name = "\improper Holodeck Alpha"

/area/torch/hydroponics
	name = "\improper Hydroponics"
	icon_state = "hydro"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/janitor
	name = "\improper Custodial Closet"
	icon_state = "janitor"

/area/torch/janitor/storage
	name = "\improper Custodial Storage Closet"

/area/torch/maintenance
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/torch/maintenance/auxsolarbridge
	name = "Solar Maintenance - Bridge"
	icon_state = "SolarcontrolS"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/maintenance/auxsolarport
	name = "Solar Maintenance - Port"
	icon_state = "SolarcontrolP"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/maintenance/auxsolarstarboard
	name = "Solar Maintenance - Starboard"
	icon_state = "SolarcontrolS"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/maintenance/bridge
	name = "Bridge Maintenance"
	icon_state = "maintcentral"

/area/torch/maintenance/bridge/aftport
	name = "Bridge Aft Port Maintenance"
	icon_state = "apmaint"

/area/torch/maintenance/bridge/aftstarboard
	name = "Bridge Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/torch/maintenance/bridge/foreport
	name = "Bridge Fore Port Maintenance"
	icon_state = "fpmaint"

/area/torch/maintenance/bridge/forestarboard
	name = "Bridge Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/torch/maintenance/disposal
	name = "Waste Disposal"
	icon_state = "disposal"

/area/torch/maintenance/fifthdeck
	name = "Fifth Deck Maintenance"
	icon_state = "maintcentral"

/area/torch/maintenance/fifthdeck/aftport
	name = "Fifth Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/torch/maintenance/fifthdeck/aftstarboard
	name = "Fifth Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/torch/maintenance/fifthdeck/fore
	name = "Fifth Deck Fore Maintenance"
	icon_state = "fmaint"

/area/torch/maintenance/firstdeck
	name = "First Deck Maintenance"
	icon_state = "maintcentral"

/area/torch/maintenance/firstdeck/aftport
	name = "First Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/torch/maintenance/firstdeck/aftstarboard
	name = "First Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/torch/maintenance/firstdeck/centralport
	name = "First Deck Port Maintenance"
	icon_state = "pmaint"

/area/torch/maintenance/firstdeck/centralstarboard
	name = "First Deck Starboard Maintenance"
	icon_state = "smaint"

/area/torch/maintenance/firstdeck/foreport
	name = "First Deck Fore Port Maintenance"
	icon_state = "fpmaint"

/area/torch/maintenance/firstdeck/forestarboard
	name = "First Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/torch/maintenance/fourthdeck
	name = "Fourth Deck Maintenance"
	icon_state = "maintcentral"

/area/torch/maintenance/fourthdeck/aft
	name = "Fourth Deck Aft Maintenance"
	icon_state = "amaint"

/area/torch/maintenance/fourthdeck/foreport
	name = "Fourth Deck Fore Port Maintenance"
	icon_state = "fpmaint"

/area/torch/maintenance/fourthdeck/forestarboard
	name = "Fourth Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/torch/maintenance/fourthdeck/port
	name = "Fourth Deck Port Maintenance"
	icon_state = "pmaint"

/area/torch/maintenance/fourthdeck/starboard
	name = "Fourth Deck Starboard Maintenance"
	icon_state = "smaint"

/area/torch/maintenance/incinerator
	name = "\improper Incinerator"
	icon_state = "disposal"

/area/torch/maintenance/seconddeck
	name = "Second Deck Maintenance"
	icon_state = "maintcentral"

/area/torch/maintenance/seconddeck/aftport
	name = "Second Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/torch/maintenance/seconddeck/aftstarboard
	name = "Second Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/torch/maintenance/seconddeck/central
	name = "Second Deck Central Maintenance"
	icon_state = "maintcentral"

/area/torch/maintenance/seconddeck/foreport
	name = "Second Deck Fore Port Maintenance"
	icon_state = "fpmaint"

/area/torch/maintenance/seconddeck/forestarboard
	name = "Second Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/torch/maintenance/substation
	name = "Substation"
	icon_state = "substation"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/maintenance/substation/bridge
	name = "Bridge Substation"

/area/torch/maintenance/substation/fifthdeck
	name = "Fifth Deck Substation"

/area/torch/maintenance/substation/firstdeck
	name = "First Deck Substation"

/area/torch/maintenance/substation/fourthdeck
	name = "Fourth Deck Substation"

/area/torch/maintenance/substation/hangar
	name = "Hangar Substation"

/area/torch/maintenance/substation/seconddeck
	name = "Second Deck Substation"

/area/torch/maintenance/substation/thirddeck
	name = "Third Deck Substation"

/area/torch/maintenance/thirddeck
	name = "Third Deck Maintenance"
	icon_state = "maintcentral"

/area/torch/maintenance/thirddeck/aftport
	name = "Third Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/torch/maintenance/thirddeck/aftstarboard
	name = "Third Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/torch/maintenance/thirddeck/foreport
	name = "Third Deck Fore Port Maintenance"
	icon_state = "fpmaint"

/area/torch/maintenance/thirddeck/forestarboard
	name = "Third Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/torch/maintenance/thirddeck/port
	name = "Third Deck Port Maintenance"
	icon_state = "pmaint"

/area/torch/maintenance/thirddeck/starboard
	name = "Third Deck Starboard Maintenance"
	icon_state = "smaint"

/area/torch/maintenance/waterstore
	name = "\improper Cistern"
	icon_state = "disposal"

/area/torch/medical
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/torch/medical/counselor
	name = "\improper Counselor's Office"
	icon_state = "medbay3"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/torch/medical/counselor/therapy
	name = "\improper Counselor's Therapy Room"
	icon_state = "medbay3"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/medical/equipstorage
	name = "\improper Medical Equipment Storage"
	icon_state = "medbay4"

/area/torch/medical/exam_room
	name = "\improper Exam Room"
	icon_state = "exam_room"

/area/torch/medical/foyer
	name = "\improper Medical Foyer"
	icon_state = "medbay"

/area/torch/medical/foyer/storeroom
	name = "\improper Medical Storeroom"
	icon_state = "medbay"

/area/torch/medical/locker
	name = "\improper Medical Locker Room"
	icon_state = "locker"

/area/torch/medical/medicalhallway
	name = "\improper Medical Public Hallway"
	icon_state = "medbay"

/area/torch/medical/medpaperworkoffice
	name = "\improper Medical Paperwork Office"
	icon_state = "locker"

/area/torch/medical/morgue
	name = "\improper Morgue"
	icon_state = "morgue"

/area/torch/medical/morgue/autopsy
	name = "\improper Autopsy"
	icon_state = "autopsy"

/area/torch/medical/sleeper
	name = "\improper Emergency Treatment Centre"
	icon_state = "exam_room"

/area/torch/medical/staging
	name = "\improper Infirmary Staging"
	icon_state = "patients"

/area/torch/medical/surgery
	name = "\improper Operating Theatre 1"
	icon_state = "surgery"

/area/torch/medical/surgery2
	name = "\improper Operating Theatre 2"
	icon_state = "surgery"

/area/torch/medical/washroom
	name = "\improper Medical Washroom"
	icon_state = "toilet"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/quartermaster

/area/torch/quartermaster/deckchief
	name = "\improper Deck Chief's Office"
	icon_state = "quart"

/area/torch/quartermaster/expedition
	name = "\improper Expedition Preparation"
	icon_state = "mining"

/area/torch/quartermaster/expedition/atmos
	name = "\improper Hangar Atmospheric Storage"
	icon_state = "mining"

/area/torch/quartermaster/expedition/eva
	name = "\improper Expedition EVA"
	icon_state = "mining"

/area/torch/quartermaster/expedition/storage
	name = "\improper Hangar Expedition Storage"
	icon_state = "mining"

/area/torch/quartermaster/exploration
	name = "\improper Exploration Equipment"
	icon_state = "exploration"

/area/torch/quartermaster/hangar
	name = "\improper Hangar Deck"
	icon_state = "hangar"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/torch/quartermaster/hangar/catwalks
	name = "\improper Upper Hangar Deck"
	icon_state = "hangar_catwalk_p"

/area/torch/quartermaster/office
	name = "\improper Supply Office"
	icon_state = "quartoffice"

/area/torch/quartermaster/shuttlefuel
	name = "\improper Shuttle Fuel Bay"
	icon_state = "toxstorage"

/area/torch/quartermaster/sorting
	name = "\improper Supply Sorting"
	icon_state = "quartstorage"

/area/torch/quartermaster/storage
	name = "\improper Supply Warehouse"
	icon_state = "quartstorage"
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/torch/quartermaster/storage/upper
	name = "\improper Supply Upper Warehouse"

/area/torch/rnd
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/rnd/canister
	name = "\improper Canister Storage"
	icon_state = "toxstorage"

/area/torch/rnd/development
	name = "\improper Fabricator Lab"
	icon_state = "devlab"

/area/torch/rnd/entry
	name = "\improper Research and Development Access"
	icon_state = "decontamination"

/area/torch/rnd/locker
	name = "\improper Research Locker Room"
	icon_state = "locker"

/area/torch/rnd/misc_lab
	name = "\improper Miscellaneous Research"
	icon_state = "misclab"

/area/torch/rnd/office
	name = "\improper Research Paperwork Office"
	icon_state = "devlab"

/area/torch/rnd/research
	name = "\improper Research Hallway"
	icon_state = "research"

/area/torch/rnd/xenobiology
	name = "\improper Xenobiology Lab"
	icon_state = "xeno_lab"

/area/torch/rnd/xenobiology/cell_1
	name = "\improper Xenobiology Containment Cell 1"
	icon_state = "xeno_lab_cell_1"

/area/torch/rnd/xenobiology/cell_2
	name = "\improper Xenobiology Containment Cell 2"
	icon_state = "xeno_lab_cell_2"

/area/torch/rnd/xenobiology/cell_3
	name = "\improper Xenobiology Containment Cell 3"
	icon_state = "xeno_lab_cell_3"

/area/torch/rnd/xenobiology/cell_4
	name = "\improper Xenobiology Containment Cell 4"
	icon_state = "xeno_lab_cell_4"

/area/torch/rnd/xenobiology/entry
	name = "\improper Xenobiology Access"
	icon_state = "xeno_lab"

/area/torch/rnd/xenobiology/xenoflora
	name = "\improper Xenoflora Lab"
	icon_state = "xeno_f_lab"

/area/torch/security

/area/torch/security/armoury
	name = "\improper Security - Armory"
	icon_state = "Warden"

/area/torch/security/bo
	name = "\improper Security - Brig Chief"
	icon_state = "Warden"

/area/torch/security/bridgecheck
	name = "\improper Bridge Deck Security Checkpoint"
	icon_state = "checkpoint"

/area/torch/security/brig
	name = "\improper Security - Brig"
	icon_state = "brig"

/area/torch/security/detectives_office
	name = "\improper Security - Investigations Office"
	icon_state = "detective"
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/security/evidence
	name = "\improper Security - Evidence Storage"
	icon_state = "security"

/area/torch/security/habcheck
	name = "\improper Third Deck Security Checkpoint"
	icon_state = "checkpoint"

/area/torch/security/hangcheck
	name = "\improper Fourth Deck Security Checkpoint"
	icon_state = "checkpoint"

/area/torch/security/locker
	name = "\improper Security - Locker Room"
	icon_state = "security"

/area/torch/security/nuke_storage
	name = "\improper Vault"
	icon_state = "nuke_storage"

/area/torch/security/opscheck
	name = "\improper First Deck Security Checkpoint"
	icon_state = "checkpoint"

/area/torch/security/processing
	name = "\improper Security - Processing"
	icon_state = "security"

/area/torch/security/questioning
	name = "\improper Security - Interview Room"
	icon_state = "security"

/area/torch/security/secure_storage
	name = "\improper Security - Secure Storage"
	icon_state = "security"

/area/torch/security/storage
	name = "\improper Security - Equipment Storage"
	icon_state = "security"

/area/torch/security/wing
	name = "\improper Security Wing"
	icon_state = "security"

/area/torch/shield
	name = "\improper Shield Generator"
	icon_state = "engineering"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/shield/bridge
	name = "\improper Bridge Shield Generator"

/area/torch/shuttle
	sound_environment = SOUND_ENVIRONMENT_BATHROOM
	requires_power = FALSE
	unlimited_power = TRUE

/area/torch/shuttle/escape_pod10/station
	name = "Escape Pod Five"

/area/torch/shuttle/escape_pod11/station
	name = "Escape Pod Six"

/area/torch/shuttle/escape_pod12/station
	name = "Escape Pod Seven"

/area/torch/shuttle/escape_pod13/station
	name = "Escape Pod Eight"

/area/torch/shuttle/escape_pod15/station
	name = "Escape Pod Ten"

/area/torch/shuttle/escape_pod16/station
	name = "Escape Pod Eleven"

/area/torch/shuttle/escape_pod17/station
	name = "Escape Pod Twelve"

/area/torch/shuttle/escape_pod6/station
	name = "Escape Pod One"

/area/torch/shuttle/escape_pod7/station
	name = "Escape Pod Two"

/area/torch/shuttle/escape_pod8/station
	name = "Escape Pod Three"

/area/torch/shuttle/escape_pod9/station
	name = "Escape Pod Four"

/area/torch/shuttle/petrov
	name = "\improper SRV Petrov"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/shuttle/petrov/analysis
	name = "\improper SRV Petrov - Analysis Lab"
	icon_state = "devlab"

/area/torch/shuttle/petrov/cell1
	name = "\improper SRV Petrov - Isolation Cell 1"
	icon_state = "shuttle"

/area/torch/shuttle/petrov/cell2
	name = "\improper SRV Petrov - Isolation Cell 2"
	icon_state = "shuttlegrn"

/area/torch/shuttle/petrov/cell3
	name = "\improper SRV Petrov - Isolation Cell 3"
	icon_state = "shuttle"

/area/torch/shuttle/petrov/cockpit
	name = "\improper SRV Petrov - Cockpit"
	icon_state = "shuttlered"

/area/torch/shuttle/petrov/control
	name = "\improper SRV Petrov - Control Room"
	icon_state = "checkpoint1"

/area/torch/shuttle/petrov/custodial
	name = "\improper SRV Petrov - Custodial"
	icon_state = "decontamination"
	lighting_tone = AREA_LIGHTING_DEFAULT

/area/torch/shuttle/petrov/equipment
	name = "\improper SRV Petrov - Equipment Storage"
	icon_state = "locker"

/area/torch/shuttle/petrov/eva
	name = "\improper SRV Petrov - EVA Storage"
	icon_state = "locker"

/area/torch/shuttle/petrov/hallwaya
	name = "\improper SRV Petrov - Lower Hallway"
	icon_state = "hallA"

/area/torch/shuttle/petrov/isolation
	name = "\improper SRV Petrov - Isolation Lab"
	icon_state = "xeno_lab"

/area/torch/shuttle/petrov/maint
	name = "\improper SRV Petrov - Maintenance"
	icon_state = "engine"
	lighting_tone = AREA_LIGHTING_DEFAULT

/area/torch/shuttle/petrov/phoron
	name = "\improper SRV Petrov - Sublimation Lab"
	icon_state = "toxstorage"

/area/torch/shuttle/petrov/rd
	name = "\improper SRV Petrov - CSO's Office"
	icon_state = "head_quarters"

/area/torch/shuttle/petrov/rnd
	name = "\improper SRV Petrov - Fabricator Lab"
	icon_state = "devlab"

/area/torch/shuttle/petrov/toxins
	name = "\improper SRV Petrov - Toxins Lab"
	icon_state = "toxstorage"

/area/torch/solar
	always_unpowered = TRUE

/area/torch/solar/auxstarboard
	name = "\improper Fore Starboard Solar Array"
	icon_state = "panelsA"

/area/torch/solar/bridge
	name = "\improper Bridge Solar Array"
	icon_state = "panelsS"

/area/torch/solar/port
	name = "\improper Port Auxiliary Solar Array"
	icon_state = "panelsP"

/area/torch/storage/auxillary

/area/torch/storage/auxillary/port
	name = "Port Auxillary Storage"
	icon_state = "auxstorage"

/area/torch/storage/auxillary/starboard
	name = "Starboard Auxillary Storage"
	icon_state = "auxstorage"

/area/torch/storage/cargo
	name = "Cargo Storage"
	icon_state = "quartstorage"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/storage/medical
	name = "Medical Storage"
	icon_state = "medbay4"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/torch/storage/research
	name = "Research Storage"
	icon_state = "toxstorage"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/storage/tech
	name = "Technical Storage"
	icon_state = "storage"

/area/torch/storage/tools
	name = "Auxiliary Tool Storage"
	icon_state = "auxstorage"

/area/torch/synth/borg_upload
	name = "\improper Cyborg Upload Chamber"
	icon_state = "ai_upload"

/area/torch/tcommsat

/area/torch/tcommsat/chamber
	name = "\improper Telecoms Central Compartment"
	icon_state = "tcomsatcham"

/area/torch/tcommsat/computer
	name = "\improper Telecoms Control Room"
	icon_state = "tcomsatcomp"

/area/torch/teleporter
	name = "\improper Teleporter"
	icon_state = "teleporter"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM

/area/torch/teleporter/firstdeck
	name = "\improper First Deck Teleporter"
	icon_state = "teleporter"

/area/torch/teleporter/fourthdeck
	name = "\improper Fourth Deck Teleporter"
	icon_state = "teleporter"

/area/torch/teleporter/seconddeck
	name = "\improper Second Deck Teleporter"
	icon_state = "teleporter"

/area/torch/teleporter/thirddeck
	name = "\improper Third Deck Teleporter"
	icon_state = "teleporter"

/area/torch/thruster
	icon_state = "thruster"

/area/torch/thruster/d1port
	name = "\improper First Deck Port Nacelle"

/area/torch/thruster/d1starboard
	name = "\improper First Deck Starboard Nacelle"

/area/torch/thruster/d3port
	name = "\improper Third Deck Port Nacelle"

/area/torch/thruster/d3starboard
	name = "\improper Third Deck Starboard Nacelle"

/area/torch/torchexterior
	name = "\improper Exterior Reinforcements"
	icon_state = "maint_exterior"

/area/torch/turbolift
	name = "\improper Turbolift"
	icon_state = "shuttle"
	sound_environment = SOUND_ENVIRONMENT_BATHROOM
	requires_power = FALSE
	unlimited_power = TRUE

/area/torch/turbolift/cargo_lift
	name = "\improper Cargo Lift"
	icon_state = "shuttle3"

/area/torch/turbolift/medical_lift
	name = "\improper Medical Lift"
	icon_state = "shuttle3"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/turbolift/robotics_lift
	name = "\improper Robotics Lift"
	icon_state = "shuttle3"

/area/torch/vacant
	name = "\improper Vacant Area"
	icon_state = "construction"

/area/torch/vacant/armory
	name = "\improper Vacant Armory"
	icon_state = "Tactical"

/area/torch/vacant/bar
	name = "\improper Hidden Bar"
	icon_state = "bar"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/vacant/brig
	name = "\improper Permanent Brig"
	icon_state = "brig"

/area/torch/vacant/cabin
	name = "\improper Vacant Cabins"
	icon_state = "crew_quarters"

/area/torch/vacant/cargo
	name = "\improper Requisitions Office"
	icon_state = "quart"

/area/torch/vacant/chapel
	name = "\improper Unused Chapel"
	icon_state = "chapel"

/area/torch/vacant/infirmary
	name = "\improper Auxiliary Infirmary"
	icon_state = "medbay"
	lighting_tone = AREA_LIGHTING_COOL

/area/torch/vacant/mess
	name = "\improper Old Mess"
	icon_state = "bar"
	lighting_tone = AREA_LIGHTING_WARM

/area/torch/vacant/monitoring
	name = "\improper Auxiliary Monitoring Room"
	icon_state = "engine_monitoring"
