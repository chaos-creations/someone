// Universes of the fork, see modular_chaos/code/datums/universe/

// Ids of the universes (/datum/universe/var/id), the values of the UNIVERSE config entry
#define UNIVERSE_CM "cm"
#define UNIVERSE_BAY12 "bay12"

/// Universe the server runs in when the config doesn't set UNIVERSE
#define CHAOS_DEFAULT_UNIVERSE UNIVERSE_CM

/// The universe the server runs in (/datum/universe), set by the UNIVERSE config entry
#define CURRENT_UNIVERSE (GLOB.universes[CONFIG_GET(string/universe)])
