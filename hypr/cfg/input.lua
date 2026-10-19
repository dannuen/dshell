-- Keyboard, mouse, touchpad.

hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = false,
        repeat_rate = 40,
        repeat_delay = 250,
        follow_mouse = 1,
        accel_profile = "adaptive",

        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },

    binds = {
        scroll_event_delay = 0,
    },

    cursor = {
        sync_gsettings_theme = true,
    },
})
