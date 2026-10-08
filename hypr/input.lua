-- Keyboard, mouse and touchpad behavior.

hl.config({
  input = {
    kb_layout = "us,ru",
    kb_variant = "",
    kb_model = "",
    kb_options = "grp:alt_shift_toggle",
    kb_rules = "",

    follow_mouse = 1,
    sensitivity = 0,

    touchpad = {
      natural_scroll = false,
      tap_to_click = true,
      disable_while_typing = true,
      scroll_factor = 1.0,
    },
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})
