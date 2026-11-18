// Cutscenes, see [/datum/cutscene]

/// Trait source of the traits a cutscene puts on its participants
#define TRAIT_SOURCE_CUTSCENE "t_s_cutscene"

/// From [/datum/cutscene/proc/finish]: ()
#define COMSIG_CUTSCENE_FINISHED "cutscene_finished"

/// The wall blocks the way from round start until its cutscene ends
#define CUTSCENE_WALL_UNTIL_END "until_end"
/// The wall only blocks the way while its cutscene plays, so players can't leave in the middle of it
#define CUTSCENE_WALL_DURING "during"

// What the participants of a cutscene are doing
#define CUTSCENE_PHASE_PLAYING "playing"
#define CUTSCENE_PHASE_VOTE "vote"
#define CUTSCENE_PHASE_CHOICE "choice"
#define CUTSCENE_PHASE_FINISHED "finished"

/// How long the black bars take to slide out, the length of their "title_card_r" animation
#define CUTSCENE_LETTERBOX_TIME (1.6 SECONDS)

/// Name of the exception a cutscene helper throws to stop play() once the cutscene is aborted
#define CUTSCENE_ABORTED "cutscene_aborted"

/// Color of NPC names in the subtitles
#define CUTSCENE_COLOR_NPC "#e8a33a"
/// Color of player names in the subtitles, and of vote counters
#define CUTSCENE_COLOR_PLAYER "#5aa5f0"
/// Outline of the answer under the leader's mouse
#define CUTSCENE_COLOR_HOVER "#e8a33a"

// Answers floating around the leader, see [/atom/movable/screen/cutscene/thought]
/// Average width of a character of maptext in pixels, to size the answers to their text
#define CUTSCENE_CHAR_WIDTH 6
/// Height of a line of maptext in pixels
#define CUTSCENE_LINE_HEIGHT 11
/// Widest answer in pixels, longer answers wrap
#define CUTSCENE_THOUGHT_MAX_WIDTH 160
/// How far answers to the sides are from the middle of the leader, plus half their width, in pixels
#define CUTSCENE_THOUGHT_RADIUS_X 28
/// How far answers above and below are from the middle of the leader, in pixels
#define CUTSCENE_THOUGHT_RADIUS_Y 34
