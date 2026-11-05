// Origins
GLOBAL_LIST_INIT(chaos_player_origins, CHAOS_PLAYER_ORIGINS)
/// Star systems of the origin picker by name
GLOBAL_REFERENCE_LIST_INDEXED(star_systems, /datum/star_system, name)

/// Accents by name
GLOBAL_REFERENCE_LIST_INDEXED(accents, /datum/accent, name)

/// Symbols a player can pick as the glyph shown before their name in chat
GLOBAL_LIST_INIT(accent_glyphs, list(
	"!", "#", "$", "%", "&", "+", "=", "?", "@", "~", "^",
	"/", "\\", "(", ")", "{", "}", "\[", "]", "<", ">", "|",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
))

// Races
GLOBAL_LIST_INIT(chaos_player_races, CHAOS_PLAYER_RACES)
/// Playable races by id
GLOBAL_REFERENCE_LIST_INDEXED(playable_races, /datum/playable_race, id)
