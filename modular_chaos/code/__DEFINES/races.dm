// Playable races of the fork, see modular_chaos/code/datums/race/

// Ids of the races (/datum/playable_race/var/id), kept in the saves
#define RACE_HUMAN "human"
#define RACE_SYNTHETIC "synthetic"

// How the race picker shows a race option (/datum/race_option/var/kind), see chaos/RacePicker.tsx
/// One of a few values, picked with buttons
#define RACE_OPTION_CHOICE "choice"
/// On or off, picked with a checkbox
#define RACE_OPTION_TOGGLE "toggle"
/// A "#rrggbb" color, picked in upstream's color picker
#define RACE_OPTION_COLOR "color"
/// A line of text, typed in a text input
#define RACE_OPTION_TEXT "text"
