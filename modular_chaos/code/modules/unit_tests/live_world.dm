#if defined(UNIT_TESTS_LIVE) || defined(SPACEMAN_DMM)

/**
 * Live unit test world: built with `-DUNIT_TESTS -DUNIT_TESTS_LIVE`, it starts the round without running any test and keeps running.
 *
 * Tests are then run one at a time in the live world, for example through the auxtools CLI:
 * `auxtools eval --spawn --wait "var/list/results = list(); RunUnitTest(/datum/unit_test/foo, results); return results"`.
 * Since no test run ends the round, the world never reaches FinishTestRun() and does not shut itself down.
 */
/world/HandleTestRun()
	CAN_BE_REDEFINED(TRUE)
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	UNTIL(SSticker.initialized)
	SSticker.request_start()

#endif
