//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

// code/modules/unit_tests/_unit_tests.dm #undefs these three at its end, so they are copied from there and must be kept in sync with it.
// Its other TEST_* macros are still defined here.

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

#include "cyrillic_text.dm"
#include "human_ai.dm"
#include "origins.dm"
#include "races.dm"
#include "rigs.dm"
#include "universes.dm"
#include "vox.dm"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL

#endif
