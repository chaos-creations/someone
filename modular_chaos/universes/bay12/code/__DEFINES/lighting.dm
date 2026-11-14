// Light colours and area lighting tones of Baystation 12 (code/__defines/lighting.dm in the source)

/// Clinical white light bulbs
#define LIGHT_COLOUR_WHITE "#fefefe"
/// Warm yellowish light bulbs
#define LIGHT_COLOUR_WARM "#fffee0"
/// Cool bluish light bulbs
#define LIGHT_COLOUR_COOL "#e0fefe"
/// Emergency red lighting
#define LIGHT_COLOUR_E_RED "#da0205"
/// Green 'READY' lighting
#define LIGHT_COLOUR_READY "#00ff00"
/// The colours a bulb picks from when nothing sets its colour
#define LIGHT_STANDARD_COLORS list(LIGHT_COLOUR_WHITE, LIGHT_COLOUR_WARM, LIGHT_COLOUR_COOL)

// The tones of the lights of an area (/area/var/lighting_tone)
#define AREA_LIGHTING_WHITE "white"
#define AREA_LIGHTING_WARM "warm"
#define AREA_LIGHTING_COOL "cool"
/// No tone of its own: each bulb keeps the colour it picks
#define AREA_LIGHTING_DEFAULT "default"

// Alternative lighting modes of bulbs
/// The red light of emergency lighting, when the APC turns the lights off to save its cell
#define LIGHTMODE_EMERGENCY "emergency_lighting"
/// The green light of ready lights
#define LIGHTMODE_READY "ready"
