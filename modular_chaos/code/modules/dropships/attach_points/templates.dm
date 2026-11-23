// Dropship Cyclone, ported from cmss13-pve

/obj/effect/attach_point/weapon/cyclone
	ship_tag = DROPSHIP_CYCLONE

/obj/effect/attach_point/weapon/cyclone/left_wing
	name = "port wing weapon attach point"
	icon_state = "equip_base_l_wing"
	attach_id = 1
	dir = WEST
	firing_arc_min = -3
	firing_arc_max = 3
	transverse = -3
	long = 0

/obj/effect/attach_point/weapon/cyclone/left_fore
	name = "port fore weapon attach point"
	attach_id = 2
	dir = NORTH
	firing_arc_min = -6
	firing_arc_max = 0
	transverse = 0
	long = 0

/obj/effect/attach_point/weapon/cyclone/right_fore
	name = "starboard fore weapon attach point"
	attach_id = 3
	dir = NORTH
	firing_arc_min = 0
	firing_arc_max = 6
	transverse = 0
	long = 0

/obj/effect/attach_point/weapon/cyclone/right_wing
	name = "starboard wing weapon attach point"
	icon_state = "equip_base_r_wing"
	attach_id = 4
	dir = EAST
	firing_arc_min = -3
	firing_arc_max = 3
	transverse = 3
	long = 0

/obj/effect/attach_point/crew_weapon/cyclone
	ship_tag = DROPSHIP_CYCLONE

/obj/effect/attach_point/crew_weapon/cyclone/floor
	plane = FLOOR_PLANE

/obj/effect/attach_point/electronics/cyclone
	ship_tag = DROPSHIP_CYCLONE

/obj/effect/attach_point/fuel/cyclone
	ship_tag = DROPSHIP_CYCLONE

/obj/effect/attach_point/computer/cyclone
	ship_tag = DROPSHIP_CYCLONE
