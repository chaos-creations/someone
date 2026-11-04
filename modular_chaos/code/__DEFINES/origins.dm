// Origins and accents of the fork, see modular_chaos/code/datums/origin/

// Star systems of the origin picker (/datum/star_system)
#define STAR_SYSTEM_SOL "Sol"

// Example origins of Sol, placeholders until the fork's own origins are written
#define ORIGIN_MERCURY "Mercury"
#define ORIGIN_VENUS "Venus"
#define ORIGIN_EARTH "Earth"
#define ORIGIN_LUNA "Luna"
#define ORIGIN_MARS "Mars"
#define ORIGIN_JUPITER "Jupiter"
#define ORIGIN_SATURN "Saturn"
#define ORIGIN_URANUS "Uranus"
#define ORIGIN_NEPTUNE "Neptune"

/**
 * Origins players can pick in the character setup (in place of upstream's GLOB.player_origins)
 *
 * The origin picker puts the planets of each star system on orbits around its star in this order, the first one closest,
 * and the moons (/datum/origin/var/moon_of) around their planets in this order too.
 */
#define CHAOS_PLAYER_ORIGINS list( \
	ORIGIN_MERCURY, ORIGIN_VENUS, ORIGIN_EARTH, ORIGIN_LUNA, ORIGIN_MARS, ORIGIN_JUPITER, ORIGIN_SATURN, ORIGIN_URANUS, ORIGIN_NEPTUNE, \
)

/// Origin of new characters, and of characters whose origin players can't pick any more; one of CHAOS_PLAYER_ORIGINS
#define CHAOS_DEFAULT_ORIGIN ORIGIN_EARTH

// Planet types the origin picker draws (/datum/origin/var/planet_type), the planet scenes of PixelPlanets.
// Keys of PLANET_TYPES in tgui/packages/tgui/interfaces/chaos/space/planetTypes.ts
/// Land with rivers and clouds ("Terran Wet")
#define PLANET_TYPE_TERRAN_WET "terran_wet"
/// Bare land in bands of color ("Terran Dry")
#define PLANET_TYPE_TERRAN_DRY "terran_dry"
/// Water, land masses and clouds
#define PLANET_TYPE_ISLANDS "islands"
/// Cratered rock, like a moon
#define PLANET_TYPE_NO_ATMOSPHERE "no_atmosphere"
/// Dark lower clouds under lighter upper ones
#define PLANET_TYPE_GAS_GIANT "gas_giant"
/// Bands of gas and a ring, which reaches out to 3 times the planet's size
#define PLANET_TYPE_GAS_GIANT_RINGED "gas_giant_ringed"
/// Ice with lakes and clouds
#define PLANET_TYPE_ICE_WORLD "ice_world"
/// Dark rock with craters and rivers of lava
#define PLANET_TYPE_LAVA_WORLD "lava_world"
/// A lumpy rock
#define PLANET_TYPE_ASTEROID "asteroid"
/// A black hole in an accretion disk, which reaches out to 3 times its size
#define PLANET_TYPE_BLACK_HOLE "black_hole"
/// A spiral galaxy
#define PLANET_TYPE_GALAXY "galaxy"
/// A star, with flares out to twice its size
#define PLANET_TYPE_STAR "star"

#define PLANET_TYPES list(PLANET_TYPE_TERRAN_WET, PLANET_TYPE_TERRAN_DRY, PLANET_TYPE_ISLANDS, PLANET_TYPE_NO_ATMOSPHERE, PLANET_TYPE_GAS_GIANT, PLANET_TYPE_GAS_GIANT_RINGED, PLANET_TYPE_ICE_WORLD, PLANET_TYPE_LAVA_WORLD, PLANET_TYPE_ASTEROID, PLANET_TYPE_BLACK_HOLE, PLANET_TYPE_GALAXY, PLANET_TYPE_STAR)

/// Placeholder accent until the fork's own accents are written
#define ACCENT_TEMPLATE "Template Accent"

/// Chat glyph of human AI that no player controls
#define HUMAN_AI_ACCENT_GLYPH "*"
