// Rigs: hardsuit control modules worn on the back (modular_chaos/code/modules/clothing/spacesuits/rig/).
// Their power is in the charge units of /obj/item/cell (an /obj/item/cell/high holds 10000).

/// Charge a rig takes every second while it is sealed and powered, before its modules
#define RIG_BASE_POWER_USE 1

// Results of /obj/item/rig_module/proc/use_module(), what the use keybinding did with the selected module
/// The module did nothing: the rig is offline, the module is broken or out of power
#define RIG_MODULE_USE_FAILED 0
/// The module did what it does
#define RIG_MODULE_USE_DONE 1
/// The module waits for the wearer to click a target, see /obj/item/rig/proc/set_aiming()
#define RIG_MODULE_USE_AIMING 2

#define COMSIG_KB_HUMAN_RIG_SELECT_MODULE_DOWN "keybinding_human_rig_select_module_down"
#define COMSIG_KB_HUMAN_RIG_USE_MODULE_DOWN "keybinding_human_rig_use_module_down"
