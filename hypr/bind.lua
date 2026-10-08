-- Key bindings. Super is the Windows key.

local mainMod = "SUPER"

local terminal = "kitty"
local browser = "firefox"
local fileManager = "nemo"
local launcher = "fuzzel"
local lock = "loginctl lock-session"
local audioPanel = "pavucontrol"
local screenshot =
  'mkdir -p "$HOME/Pictures/Screenshots" && file="$HOME/Pictures/Screenshots/$(date +\'%Y-%m-%d_%H-%M-%S\').png" && grim -g "$(slurp)" "$file" && wl-copy < "$file"'

-- Applications.
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(launcher))
hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(audioPanel))

-- Window management.
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("hyprctl dispatch fullscreen"))

-- Logout / system controls.
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("systemctl suspend"))

-- Focus.
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move windows.
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.exec_cmd("hyprctl dispatch movewindow l"))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("hyprctl dispatch movewindow r"))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.exec_cmd("hyprctl dispatch movewindow u"))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.exec_cmd("hyprctl dispatch movewindow d"))

-- Workspaces 1..10.
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Existing-workspace scrolling.
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window movement / resize.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio device volume: allow up to 200%.
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)

hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)

hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true }
)

-- Microphone volume: allow up to 200%.
hl.bind(
  mainMod .. " + ALT + up",
  hl.dsp.exec_cmd("wpctl set-volume -l 2.0 @DEFAULT_AUDIO_SOURCE@ 5%+"),
  { locked = true, repeating = true }
)

hl.bind(
  mainMod .. " + ALT + down",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"),
  { locked = true, repeating = true }
)

hl.bind(
  mainMod .. " + ALT + M",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true }
)

hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true }
)

-- Brightness.
hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
  { locked = true, repeating = true }
)

hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
  { locked = true, repeating = true }
)

-- Media player.
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshot: save to ~/Pictures/Screenshots and copy the same file to clipboard.
hl.bind("Print", hl.dsp.exec_cmd(screenshot))
