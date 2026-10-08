-- Appearance, tiling behavior and XWayland scaling.

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 2,
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",

    col = {
      active_border = {
        colors = { "rgba(eba7ffff)", "rgba(9fe8d6ff)" },
        angle = 45,
      },
      inactive_border = "rgba(666677aa)",
    },
  },

  decoration = {
    rounding = 12,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.96,

    shadow = {
      enabled = true,
      range = 14,
      render_power = 3,
      color = "rgba(11111aff)",
    },

    blur = {
      enabled = true,
      size = 5,
      passes = 2,
      vibrancy = 0.15,
    },
  },

  animations = {
    enabled = true,
  },

  -- Important for XWayland applications such as some Proton/Win32 games.
  xwayland = {
    force_zero_scaling = true,
  },

  misc = {
    force_default_wallpaper = 1,
    disable_hyprland_logo = false,
  },

  dwindle = {
    preserve_split = true,
  },
})

hl.curve("easeOutQuint", {
  type = "bezier",
  points = { { 0.23, 1 }, { 0.32, 1 } },
})

hl.curve("quick", {
  type = "bezier",
  points = { { 0.15, 0 }, { 0.1, 1 } },
})

hl.animation({
  leaf = "global",
  enabled = true,
  speed = 7,
  bezier = "quick",
})

hl.animation({
  leaf = "windows",
  enabled = true,
  speed = 5,
  bezier = "easeOutQuint",
})

hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
})
