/// How far, in pixels, pixel shifting can move a human or an item from where it normally stands
#define PIXEL_SHIFT_RADIUS 16
/// How long a dragged atom glides to the mouse after each mouse update. Updates come about once a tick, so it is a bit longer than that to smooth uneven ones
#define PIXEL_SHIFT_DRAG_GLIDE_TIME (world.tick_lag * 2)
/// How fast a human glides while the movement keys are held in pixel shift mode, in pixels a decisecond
#define PIXEL_SHIFT_KEY_SPEED 1
/// How long after the last movement key input the keys count as let go. Held keys repeat every MINIMAL_MOVEMENT_INTERVAL, the rest is for server lag
#define PIXEL_SHIFT_KEY_RELEASE_TIME (MINIMAL_MOVEMENT_INTERVAL + world.tick_lag)

#define COMSIG_KB_HUMAN_PIXEL_SHIFT_DOWN "keybinding_human_pixel_shift_down"
