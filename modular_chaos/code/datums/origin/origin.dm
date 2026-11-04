/datum/origin
	/// Name of the star system (/datum/star_system) the origin picker shows the planet in
	var/star_system = STAR_SYSTEM_SOL
	/// Name of the origin whose planet this one orbits as a moon (in the same star system), or null for a planet of the star
	var/moon_of
	/// Type of the homeworld planet the origin picker draws (PLANET_TYPE_*)
	var/planet_type = PLANET_TYPE_TERRAN_WET
	/// Any whole number: the same seed gives the same planet of the type
	var/planet_seed = 1
	/// Diameter of the planet in the origin picker, in px; it is drawn in pixel art of this many pixels
	var/planet_size = 64
	/**
	 * Colors of the planet as "#rrggbb", or null for the type's own. How many and in what order depends on the type,
	 * see the colorSlots of PLANET_TYPES in tgui/packages/tgui/interfaces/chaos/space/planetTypes.ts.
	 */
	var/list/planet_colors
	/// Whether the planet's colors are made from planet_seed (for types that can do that) instead of the type's own; planet_colors win over this
	var/planet_random_colors = FALSE
	/// Speed of the planet's own movement (its turn, clouds), 1 for normal
	var/planet_spin = 1
	/// Tilt of the planet's axis, in degrees
	var/planet_tilt = 0
	/// Accent a character of this origin gets unless they pick another one
	var/default_accent = ACCENT_TEMPLATE
	/// Accents a character of this origin can pick, or null for any accent
	var/list/allowed_accents

/// Returns whether a character of this origin can have the accent (a name in GLOB.accents)
/datum/origin/proc/can_have_accent(accent_name)
	if(!accent_name || !GLOB.accents[accent_name])
		return FALSE
	return !allowed_accents || (accent_name in allowed_accents)

// Example origins of Sol, the planets of the Solar System; their sizes are made readable, not to scale

/datum/origin/mercury
	name = ORIGIN_MERCURY
	desc = "You grew up in the shadowed craters of the planet closest to the Sun, where daylight could kill and night froze the air."
	planet_type = PLANET_TYPE_NO_ATMOSPHERE
	planet_seed = 1101
	planet_size = 26
	planet_colors = list("#b8b2a8", "#7d776f", "#4e4a45", "#7d776f", "#4e4a45")

/datum/origin/venus
	name = ORIGIN_VENUS
	desc = "You were born in the floating cities high in the acid clouds of Venus, where the ground below is a furnace."
	planet_type = PLANET_TYPE_GAS_GIANT
	planet_seed = 2202
	planet_size = 36
	planet_colors = list("#5a4826", "#5a4826", "#2a2112", "#3d3018", "#f7e7b0", "#e3c983", "#bf9c5e", "#8a6a42")
	planet_spin = 0.4
	planet_tilt = 3

/datum/origin/earth
	name = ORIGIN_EARTH
	desc = "You were born on Earth, the cradle of humanity, crowded, old and still the place everyone measures against."
	planet_type = PLANET_TYPE_ISLANDS
	planet_seed = 3303
	planet_size = 38
	planet_colors = list("#4fa4e8", "#2e6fc0", "#1c3a6e", "#8fbf55", "#4f8a3a", "#3a6630", "#2a4a2a", "#f5f6fa", "#c9cde0", "#8a90b0", "#5a6080")
	planet_tilt = 23

/datum/origin/luna
	name = ORIGIN_LUNA
	desc = "You were born in the old lunar colonies, under a black sky with the blue Earth hanging over the horizon."
	moon_of = ORIGIN_EARTH
	planet_type = PLANET_TYPE_NO_ATMOSPHERE
	planet_seed = 3304
	planet_size = 16
	planet_colors = list("#d8d8d0", "#9a9a94", "#5e5e5a", "#9a9a94", "#5e5e5a")

/datum/origin/mars
	name = ORIGIN_MARS
	desc = "You grew up in the terraforming domes of Mars, under a pink sky, among people who never stop talking about the old Earth."
	planet_type = PLANET_TYPE_TERRAN_DRY
	planet_seed = 4404
	planet_size = 30
	planet_colors = list("#e0814f", "#c4562f", "#8f3a22", "#5a2a1c", "#3a1d16")
	planet_tilt = 25

/datum/origin/jupiter
	name = ORIGIN_JUPITER
	desc = "You were raised on the stations among the moons of Jupiter, where the giant fills half the sky."
	planet_type = PLANET_TYPE_GAS_GIANT
	planet_seed = 5505
	planet_size = 80
	planet_colors = list("#3b2a20", "#3b2a20", "#120c08", "#24180f", "#f0d9b5", "#d9a066", "#b0703f", "#7d4a2e")
	planet_spin = 1.5
	planet_tilt = 3

/datum/origin/saturn
	name = ORIGIN_SATURN
	desc = "You grew up among the ice miners of Saturn's rings, where the work is cold and the view is the best in the system."
	planet_type = PLANET_TYPE_GAS_GIANT_RINGED
	planet_seed = 6606
	planet_size = 56
	planet_tilt = 27

/datum/origin/uranus
	name = ORIGIN_URANUS
	desc = "You were born on a research outpost by Uranus, the giant that rolls around the Sun on its side."
	planet_type = PLANET_TYPE_GAS_GIANT
	planet_seed = 7707
	planet_size = 46
	planet_colors = list("#1f3a40", "#1f3a40", "#0a1416", "#14262a", "#c8f2f2", "#9be0e6", "#6bbcc8", "#3f8a9a")
	planet_spin = 0.7
	planet_tilt = 98

/datum/origin/neptune
	name = ORIGIN_NEPTUNE
	desc = "You come from the edge of the Solar System, by deep blue Neptune, where supply ships come once a year."
	planet_type = PLANET_TYPE_GAS_GIANT
	planet_seed = 8808
	planet_size = 44
	planet_colors = list("#10214a", "#10214a", "#050a1a", "#0b1633", "#6f9cf0", "#4a72d8", "#3050b0", "#1f3580")
	planet_tilt = 28
