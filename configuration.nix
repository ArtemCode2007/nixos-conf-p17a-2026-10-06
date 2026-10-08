{ config, pkgs, inputs, system, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ---------------------------------------------------------------------------
  # BOOT / KERNEL
  # ---------------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NixOS 26.05's linuxPackages_latest is older than the current stable
  # upstream kernel. Track the latest kernel supplied by nixpkgs-unstable,
  # while keeping the rest of the OS on NixOS 26.05.
  boot.kernelPackages = unstable.linuxPackages_latest;

  # ---------------------------------------------------------------------------
  # NIX / FLAKES
  # ---------------------------------------------------------------------------

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ---------------------------------------------------------------------------
  # HOST / LOCALE
  # ---------------------------------------------------------------------------

  networking.hostName = "p17a";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Minsk";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.supportedLocales = [
    "ru_RU.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  console = {
    font = "cyr-sun16";
    keyMap = "ru";
  };

  # ---------------------------------------------------------------------------
  # GRAPHICS: AMD Radeon 780M / Wayland
  # ---------------------------------------------------------------------------

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.enableRedistributableFirmware = true;

  # Required for Steam/Proton, Discord, VS Code, etc.
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  # ---------------------------------------------------------------------------
  # HYPRLAND + WAYLAND SESSION
  # ---------------------------------------------------------------------------

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  
  services.greetd = {
  enable = true;

  settings = {
    default_session = {
      command =
        "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'uwsm start -- Hyprland'";
      user = "greeter";
    };
  };
};

  # ---------------------------------------------------------------------------
  # XDG PORTALS / POLKIT / SESSION SERVICES
  # ---------------------------------------------------------------------------

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  security.polkit.enable = true;
  security.pam.services.hyprlock = { };

  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # ---------------------------------------------------------------------------
  # AUDIO
  # ---------------------------------------------------------------------------

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ---------------------------------------------------------------------------
  # LAPTOP: INPUT / POWER / BLUETOOTH
  # ---------------------------------------------------------------------------

  services.libinput.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ---------------------------------------------------------------------------
  # REMOVABLE MEDIA: FAT32 / NTFS
  # ---------------------------------------------------------------------------

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # ---------------------------------------------------------------------------
  # GAMES: Steam / Proton / XWayland
  # ---------------------------------------------------------------------------

  programs.steam.enable = true;

  # Gamescope is available for games that ignore the native monitor mode.
  programs.gamescope = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # LOCAL AI: Open WebUI
  # ---------------------------------------------------------------------------

  # Open WebUI is intentionally provided from nixpkgs-unstable so the
  # 26.05 system can use a current Open WebUI release/module-compatible package.
  services.open-webui = {
    enable = true;
    package = unstable.open-webui;
    stateDir = "/var/lib/open-webui";
    host = "127.0.0.1";
    port = 3000;
    openFirewall = false;

    environment = {
      ENABLE_PERSISTENT_CONFIG = "true";
      AIOHTTP_CLIENT_TIMEOUT_MODEL_LIST = "30";
      # Native MCP is provided by Open WebUI itself; Node/npm are not
      # required just to enable MCP.
    };
  };

  # ---------------------------------------------------------------------------
  # USER
  # ---------------------------------------------------------------------------

  users.users.artem = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "render"
    ];
  };

  # ---------------------------------------------------------------------------
  # SYSTEM PACKAGES
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    pciutils
    usbutils
  ];

  # ---------------------------------------------------------------------------
  # NIXOS STATE VERSION
  # ---------------------------------------------------------------------------

  system.stateVersion = "26.05";
}
