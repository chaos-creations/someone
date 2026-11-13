// Flags of Bay floors (/turf/open/floor/bay/var/flooring_flags), the TURF_* flags of /singleton/flooring in the source

/// The edges of the floor are drawn out over the turf next to it, rather than inside the floor
#define BAY_FLOOR_HAS_EDGES (1<<0)
/// The floor draws outer corners where it meets turfs it does not join on two sides
#define BAY_FLOOR_HAS_CORNERS (1<<1)
/// The floor draws inner corners where it joins on two sides but not diagonally
#define BAY_FLOOR_HAS_INNER_CORNERS (1<<2)
/// break_tile() cracks the floor
#define BAY_FLOOR_CAN_BREAK (1<<3)
/// burn_tile() scorches the floor
#define BAY_FLOOR_CAN_BURN (1<<4)
