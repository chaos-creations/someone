// Explosion severities of Baystation 12, which ex_act() of ported atoms switches on as the source does

#define BAY_EX_ACT_DEVASTATING 1
#define BAY_EX_ACT_HEAVY 2
#define BAY_EX_ACT_LIGHT 3

/// The Bay severity of an explosion of the given CM power, split where CM machinery splits its own ex_act()
#define BAY_EX_ACT(severity) ((severity) >= EXPLOSION_THRESHOLD_MEDIUM ? BAY_EX_ACT_DEVASTATING : ((severity) >= EXPLOSION_THRESHOLD_LOW ? BAY_EX_ACT_HEAVY : BAY_EX_ACT_LIGHT))
