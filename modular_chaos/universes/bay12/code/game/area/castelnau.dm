//Areas of the RMV Castelnau, the ship of the Regulators (maps/castelnau/castelnau_areas.dm in Proxi-BoS-Bay12)

/// Every area of the Castelnau: a ship with its own power network, as on the Almayer
/area/castelnau
	name = "Castelnau"
	icon = 'modular_chaos/universes/bay12/icons/turf/areas.dmi'
	icon_state = "unknown"
	ceiling = CEILING_METAL
	powernet_name = "castelnau"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	ambience_exterior = AMBIENCE_ALMAYER
	ceiling_muffle = FALSE
	weather_enabled = FALSE

/// The four escape pods of the ship (/area/shuttle/escape_podN/station in the source): powered on their own, like shuttles
/area/castelnau/escape_pod
	name = "Escape Pod"
	icon_state = "shuttle"
	requires_power = FALSE
	unlimited_power = TRUE

/// The small craft docked in the ship: the Cheapskate, the Bixie and the Perseus (/area/shuttle/castelnau in the source)
/area/castelnau/shuttle
	name = "Castelnau - Shuttle"
	icon_state = "invi"

/area/castelnau/civ

/area/castelnau/civ/bar
	name = "Bar"
	icon_state = "bar"

/area/castelnau/civ/bunk
	name = "Dormitory"
	icon_state = "Sleep"

/area/castelnau/civ/cryo
	name = "Cryostorage"
	icon_state = "Sleep"

/area/castelnau/civ/janitor
	name = "Custodial Closet"
	icon_state = "janitor"

/area/castelnau/civ/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/castelnau/civ/kitchen_backroom
	name = "Kitchen Storage"
	icon_state = "kitchen_back"

/area/castelnau/civ/laundry
	name = "Laundry Room"
	icon_state = "Sleep"

/area/castelnau/civ/lounge
	name = "Lounge"
	icon_state = "crew_quarters"

/area/castelnau/civ/restroom
	name = "Restroom"
	icon_state = "toilet"

/area/castelnau/command

/area/castelnau/command/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/castelnau/command/bridge/storage
	name = "Bridge storage"
	icon_state = "bridge"

/area/castelnau/command/captain
	name = "Command - Main Office"
	icon_state = "captain"

/area/castelnau/command/eva
	name = "EVA Storage"
	icon_state = "eva"

/area/castelnau/command/fo
	name = "Command - First Mate's Quarters"
	icon_state = "captain"

/area/castelnau/command/tcoms
	name = "Telecoms Central Compartment"
	icon_state = "tcomsatcham"

/area/castelnau/engineering

/area/castelnau/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/castelnau/engineering/engine_room
	name = "Reactor Room"
	icon_state = "engine"

/area/castelnau/engineering/engine_smes
	name = "Engineering SMES"
	icon_state = "engine_smes"

/area/castelnau/engineering/engineering_monitoring
	name = "Engineering Monitoring Room"
	icon_state = "engine_monitoring"

/area/castelnau/engineering/foyer
	name = "Engineering Foyer"
	icon_state = "engineering_foyer"

/area/castelnau/engineering/gen_room
	name = "Generators Room"
	icon_state = "engine"

/area/castelnau/engineering/hardstorage
	name = "Engineering Hard Storage"
	icon_state = "engineering_storage"

/area/castelnau/engineering/lab
	name = "Reverse Engineering Lab"
	icon_state = "research"

/area/castelnau/engineering/reactor_control_room
	name = "Reactor Control Room"
	icon_state = "engine"

/area/castelnau/engineering/robotics
	name = "Engineering Robotics Lab"
	icon_state = "robotics"

/area/castelnau/engineering/shield
	name = "Shield Generator"
	icon_state = "engineering"

/area/castelnau/engineering/storage
	name = "Engineering Storage"
	icon_state = "engineering_storage"

/area/castelnau/engineering/substation
	name = "Substation"
	icon_state = "eng_substation"

/area/castelnau/engineering/substation/third
	name = "Third Desk Substation"
	icon_state = "engineering"

/area/castelnau/hallway

/area/castelnau/hallway/primary

/area/castelnau/hallway/primary/firstdeck

/area/castelnau/hallway/primary/firstdeck/aft
	name = "First Deck Aft Hallway"
	icon_state = "hallA"

/area/castelnau/hallway/primary/firstdeck/center
	name = "First Deck Central Hallway"
	icon_state = "hallC1"

/area/castelnau/hallway/primary/firstdeck/fore
	name = "First Deck Fore Hallway"
	icon_state = "hallF"

/area/castelnau/hallway/primary/seconddeck

/area/castelnau/hallway/primary/seconddeck/center
	name = "Second Deck Central Hallway"
	icon_state = "hallC3"

/area/castelnau/hallway/primary/seconddeck/central_stairwell
	name = "Second Deck Central Stairwell"
	icon_state = "hallC2"

/area/castelnau/hallway/primary/thirddeck

/area/castelnau/hallway/primary/thirddeck/aft
	name = "Third Deck Aft Hallway"
	icon_state = "hallA"

/area/castelnau/hallway/primary/thirddeck/fore
	name = "Third Deck Fore Hallway"
	icon_state = "hallF"

/area/castelnau/maintenance

/area/castelnau/maintenance/auxsolarport
	name = "Solar Maintenance - Port"
	icon_state = "SolarcontrolP"

/area/castelnau/maintenance/auxsolarstarboard
	name = "Solar Maintenance - Starboard"
	icon_state = "SolarcontrolS"

/area/castelnau/maintenance/firstdeck

/area/castelnau/maintenance/firstdeck/aft
	name = "First Deck Aft Maintenance"
	icon_state = "amaint"

/area/castelnau/maintenance/firstdeck/aftport
	name = "First Deck Aft Port Maintenance"
	icon_state = "apmaint"

/area/castelnau/maintenance/firstdeck/aftstarboard
	name = "First Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/castelnau/maintenance/firstdeck/centralstarboard
	name = "First Deck Fore Maintenance"
	icon_state = "fpmaint"

/area/castelnau/maintenance/firstdeck/foreport
	name = "First Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/castelnau/maintenance/firstdeck/forestarboard
	name = "First Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/castelnau/maintenance/seconddeck

/area/castelnau/maintenance/seconddeck/aftstarboard
	name = "Second Deck Aft Starboard Maintenance"
	icon_state = "asmaint"

/area/castelnau/maintenance/seconddeck/forestarboard
	name = "Second Deck Fore Starboard Maintenance"
	icon_state = "fsmaint"

/area/castelnau/maintenance/seconddeck/port
	name = "Second Deck Port Maintenance"
	icon_state = "pmaint"

/area/castelnau/maintenance/seconddeck/starboard
	name = "Second Deck Starboard Maintenance"
	icon_state = "smaint"

/area/castelnau/maintenance/thirddeck

/area/castelnau/maintenance/thirddeck/port
	name = "Third Deck Port Maintenance"
	icon_state = "pmaint"

/area/castelnau/maintenance/thirddeck/starboard
	name = "Third Deck Starboard Maintenance"
	icon_state = "smaint"

/area/castelnau/medical

/area/castelnau/medical/chemistry
	name = "Chemistry"
	icon_state = "chem"

/area/castelnau/medical/infirmreception
	name = "Infirmary Reception"
	icon_state = "medbay2"

/area/castelnau/medical/maintenance_equipstorage
	name = "Infirmary Maintenance Storage"
	icon_state = "medbay4"

/area/castelnau/medical/morgue
	name = "Morgue"
	icon_state = "morgue"

/area/castelnau/medical/subacute
	name = "Sub-Acute Ward"
	icon_state = "patients"

/area/castelnau/medical/surgery
	name = "Operating Theatre"
	icon_state = "surgery"

/area/castelnau/security

/area/castelnau/security/armory
	name = "Armory"
	icon_state = "security_armory"

/area/castelnau/security/aux
	name = "Security - Auxiliary Equipment"
	icon_state = "security_brig"

/area/castelnau/security/brig
	name = "Security - Brig"
	icon_state = "security_brig"

/area/castelnau/security/detective
	name = "Security - Investigator Office"
	icon_state = "detective"

/area/castelnau/security/equip
	name = "Security - Equipment"
	icon_state = "security_equip"

/area/castelnau/security/hall
	name = "Security - Hall"
	icon_state = "security"

/area/castelnau/security/ivestigation
	name = "Laboratory"
	icon_state = "security_inv"

/area/castelnau/security/observation
	name = "Brig Observation"
	icon_state = "security_obs"

/area/castelnau/security/processing
	name = "Security - Processing"
	icon_state = "security_processing"

/area/castelnau/security/sheriff
	name = "Security - Sheriff Office"

/area/castelnau/solar
	ceiling = CEILING_NONE

/area/castelnau/solar/port
	name = "Port Auxiliary Solar Array"
	icon_state = "panelsP"

/area/castelnau/storage

/area/castelnau/storage/cargo
	name = "Cargo Storage"
	icon_state = "quartstorage"

/area/castelnau/storage/primary
	name = "Primary Tool Storage"
	icon_state = "primarystorage"

/area/castelnau/storage/tech
	name = "Technical Storage"
	icon_state = "storage"

/area/castelnau/supply

/area/castelnau/supply/smelter
	name = "Smelter"
	icon_state = "hangar"

/area/castelnau/supply/teleporter
	name = "Teleporter"
	icon_state = "teleporter"

/area/castelnau/thruster
	icon_state = "thruster"

/area/castelnau/thruster/d1port
	name = "First Deck Port Nacelle"

/area/castelnau/thruster/d1starboard
	name = "First Deck Starboard Nacelle"

/area/castelnau/thruster/d2port
	name = "Second Deck Port Nacelle"

/area/castelnau/thruster/d2starboard
	name = "Second Deck Starboard Nacelle"

/area/castelnau/shuttle/bixie

/area/castelnau/shuttle/bixie/cargo
	name = "Bixie - Cargo Bay"
	icon_state = "bix_carg"

/area/castelnau/shuttle/bixie/cockpit
	name = "Bixie - Cockpit"
	icon_state = "bix_helm"

/area/castelnau/shuttle/bixie/power
	name = "Bixie - Power Compartment"
	icon_state = "bix_eng"

/area/castelnau/shuttle/cheapskate
	name = "Cheapskate"
	icon_state = "invi"

/area/castelnau/shuttle/cheapskate/cargo
	name = "Cheapskate - Supply Office"
	icon_state = "cheap_sup"

/area/castelnau/shuttle/cheapskate/cargo/extwar
	name = "Cheapskate - Supply External Warehouse"

/area/castelnau/shuttle/cheapskate/cargo/outer
	name = "Cheapskate - Docking Area"

/area/castelnau/shuttle/cheapskate/cargo/smoking
	name = "Cheapskate - Supply Smoking Room"

/area/castelnau/shuttle/cheapskate/cargo/war
	name = "Cheapskate - Supply Warehouse"

/area/castelnau/shuttle/cheapskate/cm
	name = "Cheapskate - Chief Merchant"
	icon_state = "cheap_com"

/area/castelnau/shuttle/cheapskate/cockpit
	name = "Cheapskate - Cockpit"
	icon_state = "cheap_com"

/area/castelnau/shuttle/cheapskate/conference
	name = "Cheapskate - Conference Room"
	icon_state = "cheap_com"

/area/castelnau/shuttle/cheapskate/cryo
	name = "Cheapskate - Cryogenic Storage"
	icon_state = "cheap_cryo"

/area/castelnau/shuttle/cheapskate/eva
	name = "Cheapskate - EVA"
	icon_state = "cheap_eva"

/area/castelnau/shuttle/cheapskate/maint
	name = "Cheapskate - Maintenance"
	icon_state = "cheap_maint"

/area/castelnau/shuttle/cheapskate/maint/dock
	name = "Cheapskate - Dock"

/area/castelnau/shuttle/cheapskate/maint/storage
	name = "Cheapskate - Maintenance Storage"

/area/castelnau/shuttle/cheapskate/maint/supairlock
	name = "Cheapskate - Supply Airlock"

/area/castelnau/shuttle/cheapskate/med
	name = "Cheapskate - Medical Bay"
	icon_state = "cheap_med"

/area/castelnau/shuttle/cheapskate/merch
	name = "Cheapskate - Outlet Shop"
	icon_state = "cheap_merch"

/area/castelnau/shuttle/cheapskate/sec
	name = "Cheapskate - Security"
	icon_state = "cheap_sec"

/area/castelnau/shuttle/perseus

/area/castelnau/shuttle/perseus/cargo
	name = "Perseus - Cargo Bay"
	icon_state = "per_carg"

/area/castelnau/shuttle/perseus/cockpit
	name = "Perseus - cockpit"
	icon_state = "per_helm"

/area/castelnau/shuttle/perseus/power
	name = "Perseus - Power Compartment"
	icon_state = "per_eng"
