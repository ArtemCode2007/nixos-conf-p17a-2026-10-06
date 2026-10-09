{ pkgs, inputs, system, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  home.packages = with pkgs; [
    # -------------------------------------------------------------------------
    # DAILY USE
    # -------------------------------------------------------------------------

    firefox
    obsidian
    anki
    vesktop
    telegram-desktop
    vscode
    kitty
    nemo

    # Task manager / Microsoft To Do alternative.
    planify

    # Archive manager + 7-Zip-compatible CLI.
    peazip
    p7zip

    fuzzel
    waybar
    swaynotificationcenter

    # Network / tray / removable media
    networkmanagerapplet
    blueman
    udiskie

    # Clipboard / screenshots / media keys / idle / lock
    wl-clipboard
    cliphist
    grim
    slurp
    playerctl
    brightnessctl
    hyprlock
    hypridle
    hyprpaper
    hyprpolkitagent

    # Audio GUI / routing
    pavucontrol
    qpwgraph

    # -------------------------------------------------------------------------
    # DEVELOPMENT
    # -------------------------------------------------------------------------

    uv
    git
    python314
    python314Packages.pip
    python314Packages.virtualenv

    # Latest Node.js/npm from nixpkgs-unstable. npm is bundled with Node.js.
    unstable.nodejs_latest

    # OpenCode CLI; use it in Kitty or VS Code's integrated terminal.
    unstable.opencode

    fish
    fastfetch
    eza

    # -------------------------------------------------------------------------
    # SYSTEM INFORMATION / HARDWARE MONITORING
    # -------------------------------------------------------------------------

    btop
    hwinfo
    lshw
    lm_sensors
    smartmontools
    mission-center

    # -------------------------------------------------------------------------
    # GAMES / WINDOWS COMPATIBILITY
    # -------------------------------------------------------------------------

    prismlauncher
    qbittorrent
    steam
    wineWowPackages.stable

    # -------------------------------------------------------------------------
    # OFFICE / MEDIA / 3D / RECORDING
    # -------------------------------------------------------------------------

    libreoffice-qt
    vlc
    kodi
    blender
    obs-studio

    # AIMP-like player
    audacious

    # -------------------------------------------------------------------------
    # LOCAL AI / MCP
    # -------------------------------------------------------------------------

    # Vulkan-enabled llama.cpp for the Ryzen 7 8845HS / Radeon 780M.
    (unstable.llama-cpp.override {
      vulkanSupport = true;
    })


    # -------------------------------------------------------------------------
    # OPEN-SOURCE ALTERNATIVES TO ADOBE / WINDOWS-ONLY WORKFLOWS
    # -------------------------------------------------------------------------

    gimp
    inkscape
    audacity
    kdePackages.kdenlive
  ];
}
