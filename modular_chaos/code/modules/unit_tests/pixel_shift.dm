/// A pixel shift stays within its radius, hides what overlaps the walls south of the tile and is undone by moving
/datum/unit_test/pixel_shift

/datum/unit_test/pixel_shift/Run()
	var/mob/living/carbon/human/shifter = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/start_turf = get_turf(shifter)
	TEST_ASSERT(istype(get_step(start_turf, SOUTH), /turf/closed) && istype(get_step(start_turf, SOUTHWEST), /turf/closed), "The test room has no walls south and southwest of its bottom left floor")

	var/datum/component/pixel_shifted/shift = shifter.LoadComponent(/datum/component/pixel_shifted)
	shift.shift_to(shifter.base_pixel_x, shifter.base_pixel_y - PIXEL_SHIFT_RADIUS * 2)
	TEST_ASSERT_EQUAL(shifter.pixel_y, shifter.base_pixel_y - PIXEL_SHIFT_RADIUS, "A shift past the radius was not cut down to it")
	TEST_ASSERT(shifter.get_filter("pixel_shift_cut_south"), "A human shifted over the wall south of it is drawn over the wall")
	TEST_ASSERT(!shifter.get_filter("pixel_shift_cut_west"), "A human shifted straight south is cut by the wall southwest of it")

	shift.shift_to(shifter.base_pixel_x - 8, shifter.base_pixel_y - 8)
	TEST_ASSERT(shifter.get_filter("pixel_shift_cut_west"), "A human shifted southwest is drawn over the wall southwest of it")

	shift.shift_to(shifter.base_pixel_x, shifter.base_pixel_y + 8)
	TEST_ASSERT(!shifter.get_filter("pixel_shift_cut_south") && !shifter.get_filter("pixel_shift_cut_west"), "A human shifted north is still cut by the walls south of it")

	shift.shift_to(shifter.base_pixel_x, shifter.base_pixel_y)
	shift.glide_toward(SOUTH, PIXEL_SHIFT_KEY_SPEED)
	TEST_ASSERT_EQUAL(shifter.pixel_y, shifter.base_pixel_y - PIXEL_SHIFT_RADIUS, "A glide does not head for the edge of the radius")
	TEST_ASSERT(shifter.get_filter("pixel_shift_cut_south"), "A human gliding over the wall south of it is drawn over the wall")
	shift.stop_glide()
	TEST_ASSERT_EQUAL(shifter.pixel_y, shifter.base_pixel_y, "A glide stopped at once does not stop where it started")

	shift.shift_to(shifter.base_pixel_x, shifter.base_pixel_y - 8, PIXEL_SHIFT_DRAG_GLIDE_TIME)
	TEST_ASSERT_EQUAL(shifter.pixel_y, shifter.base_pixel_y - 8, "A gliding shift does not end where it was asked to")
	sleep(PIXEL_SHIFT_DRAG_GLIDE_TIME + world.tick_lag * 2)
	var/list/south_mask = LAZYACCESS(shifter.filter_data, "pixel_shift_cut_south")
	TEST_ASSERT(south_mask, "The wall mask is gone after a glide over the wall")
	TEST_ASSERT_EQUAL(south_mask["y"], -world.icon_size - shifter.pixel_y, "The wall mask did not follow the human to the end of its glide")

	shifter.forceMove(get_step(start_turf, EAST))
	TEST_ASSERT(!shifter.GetComponent(/datum/component/pixel_shifted), "Moving did not undo the pixel shift")
	TEST_ASSERT_EQUAL(shifter.pixel_y, shifter.base_pixel_y, "Moving did not put the human back in place")
	TEST_ASSERT(!shifter.get_filter("pixel_shift_cut_south"), "Moving did not remove the wall cut")
