// Fork additions to code/__DEFINES/__game.dm

// Game modes

#define GAMEMODE_EVENT "Event"
#define GAMEMODE_LOWPOP "Distress Signal: Lowpop"

// toggles_langchat, after the upstream LANGCHAT_SEE_EMOTES
/// Speech above heads shows up at once instead of being typed out, see modular_chaos/code/datums/langchat/langchat.dm
#define LANGCHAT_INSTANT_TEXT (1<<1)
