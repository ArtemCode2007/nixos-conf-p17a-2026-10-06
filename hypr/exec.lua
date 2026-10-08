-- Programs that should exist once per Hyprland session.

hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
  hl.exec_cmd("swaync")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("hyprpolkitagent")
  hl.exec_cmd("hypridle")
end)
