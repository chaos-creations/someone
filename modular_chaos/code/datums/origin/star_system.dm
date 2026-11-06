/**
 * Star system of the origin picker: the star in the middle and the space background
 *
 * The planets on its orbits are the origins of the universe (/datum/universe/var/origins) whose star_system is its name, each
 * drawn by its own planet_* vars, the first in the list closest to the star. Everything is generated in the window
 * from these parameters, see tgui/packages/tgui/interfaces/chaos/space/. Subtypes are the systems, in GLOB.star_systems.
 */
/datum/star_system
	/// Shown on the system's button in the origin picker, and the key of GLOB.star_systems
	var/name
	/// Any whole number: the same seed gives the same star
	var/star_seed = 4837
	/// Diameter of the star in px, without its flares, which reach out to twice that
	var/star_size = 72
	/**
	 * Colors of the star as "#rrggbb", or null for the PixelPlanets star (cyan): the blobs around it, 4 colors of the
	 * star from the brightest, and 2 of the flares
	 */
	var/list/star_colors = list("#fffbe4", "#f5ffe8", "#ffd832", "#ff823b", "#7c191a", "#ffd832", "#f5ffe8")
	/// Speed of the star's own movement, 1 for normal
	var/star_spin = 1
	/// Any whole number: the same seed gives the same background
	var/background_seed = 1
	/**
	 * Colors of the background: the name of a PixelSpace colorscheme ("NYX8", "AMMO-8", "winter wonderland", "borkfest",
	 * "submerged chimera", "DREAMSCAPE8", "coffee", "FUNKYFUTURE8", "POLLEN8", "Rust gold 8", "SLSO8",
	 * "Goosebumps gold", "OIL6"), or a list of 9 "#rrggbb" colors: the background, then 8 for the dust, nebulae and stars
	 */
	var/background_colorscheme = "NYX8"
	/// Whether the dust and nebulae of the background are dimmer
	var/background_darken = TRUE
	/// Whether the background has small distant planets, which can be taken for origins
	var/background_planets = FALSE

/// The Solar System, as an example of a real one
/datum/star_system/sol
	name = STAR_SYSTEM_SOL
	star_seed = 1543
	star_size = 76
	background_seed = 1977
	background_colorscheme = "OIL6"
