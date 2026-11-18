/// Whether only staff can observe: players can't ghost out of their bodies or observe from the lobby. See [/mob/proc/is_observing_blocked]
GLOBAL_VAR_INIT(admin_only_observe, FALSE)

/// Cutscene triggers on the map, as list(cutscene ID = /obj/effect/landmark/cutscene_trigger)
GLOBAL_LIST_EMPTY(cutscene_triggers)
/// Cutscene actor landmarks on the map, as list(actor ID = /obj/effect/landmark/cutscene_actor)
GLOBAL_LIST_EMPTY(cutscene_actors)
/// Cutscene camera points on the map, as list(camera ID = /obj/effect/landmark/cutscene_camera)
GLOBAL_LIST_EMPTY(cutscene_cameras)
/// Walls removed by cutscenes, as list(cutscene ID = list of /obj/structure/blocker/invisible_wall/cutscene)
GLOBAL_LIST_EMPTY(cutscene_walls)
