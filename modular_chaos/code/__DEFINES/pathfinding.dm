// A* pathfinding of AI-controlled mobs (SSpathfinding), ported from cmss13-pve, where it lives in code/__DEFINES/xeno_ai.dm.
// Only the parts human AI uses are here: the fork has no xeno AI.

#define CALCULATING_PATH(X) (X in SSpathfinding.hash_path)

#define DIRECTION_CHANGE_PENALTY 2
#define DISTANCE_PENALTY 1
#define ASTAR_COST_FUNCTION(n) (abs(n.x - target.x)+abs(n.y - target.y)+abs(n.z - target.z))

#define OPEN_TURF_PENALTY 1
#define DOOR_PENALTY 3
#define HUMAN_PENALTY 4
#define XENO_PENALTY 20
#define OBJECT_PENALTY 20
#define FIRE_PENALTY 25
#define LOCKED_DOOR_PENALTY 25
#define SENTRY_PENALTY 25
#define VEHICLE_PENALTY 25
#define WINDOW_FRAME_PENALTY 25
#define BARRICADE_PENALTY 50
#define WALL_PENALTY 100
/// Extra cost of taking multi-z stairs to another level
#define STAIRS_PENALTY 2
/// Extra cost of climbing a ladder, which takes a while
#define LADDER_PENALTY 10

/// How many tiles of distance one level of difference counts as in get_dist_multiz()
#define MULTIZ_LEVEL_DISTANCE 5

/// Special blockers for pathfinding or obstacle handling
#define AI_SPECIAL_BLOCKERS list(/obj/flamer_fire, /mob/living, /obj/vehicle/multitile, /turf/open/space, /turf/open/gm/river, /turf/open_space)
