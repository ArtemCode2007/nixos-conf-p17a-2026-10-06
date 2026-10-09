{ config, pkgs, lib, inputs, system, ... }:

{
  imports = [
    ./packages.nix
    ./mcp.nix
  ];

  home.username = "artem";
  home.homeDirectory = "/home/artem";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # FISH
  # ---------------------------------------------------------------------------

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      if test "$TERM" = "xterm-kitty"
        if type -q fastfetch
          fastfetch
        end
      end
    '';

    shellAliases = {
      ll = "eza -lah --group-directories-first";
    };
  };

  # ---------------------------------------------------------------------------
  # KITTY
  # ---------------------------------------------------------------------------

  programs.kitty = {
    enable = true;

    settings = {
      shell = "${pkgs.fish}/bin/fish";
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      cursor_shape = "beam";
    };
  };

  # ---------------------------------------------------------------------------
  # DISCORD
  # ---------------------------------------------------------------------------

  programs.vesktop = {
    enable = true;

    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      notifyAboutUpdates = true;

      plugins = {
        ClearURLs.enabled = true;
        FixYoutubeEmbeds.enabled = true;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # HYPRLAND LUA CONFIGURATION
  # ---------------------------------------------------------------------------

  xdg.configFile."hypr" = {
    source = ./hypr;
    recursive = true;
    force = true;
  };

  # ---------------------------------------------------------------------------
  # LOCK SCREEN
  # ---------------------------------------------------------------------------

  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = false;
        ignore_empty_input = true;
        fail_timeout = 2000;
        grace = 3;
      };

      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 7;
          brightness = 0.72;
          contrast = 0.92;
          vibrancy = 0.15;
        }
      ];

      "input-field" = [
        {
          monitor = "";
          size = "320, 62";
          position = "0, -80";
          dots_center = true;
          fade_on_empty = false;
          outline_thickness = 2;
          outer_color = "rgb(235, 167, 255)";
          inner_color = "rgba(20, 20, 30, 0.88)";
          font_color = "rgb(245, 245, 250)";
          check_color = "rgb(145, 225, 190)";
          fail_color = "rgb(255, 120, 140)";
          placeholder_text = "Password...";
        }
      ];

      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +'%H:%M')"'';
          color = "rgb(245, 245, 250)";
          font_size = 112;
          font_family = "JetBrains Mono";
          position = "0, 130";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "Welcome back, $USER";
          color = "rgba(245, 245, 250, 0.92)";
          font_size = 28;
          font_family = "JetBrains Mono";
          position = "0, -25";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # WAYBAR
  # ---------------------------------------------------------------------------

  programs.waybar = {
    enable = true;
    systemd.enable = false;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 6;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "cpu"
          "memory"
          "pulseaudio"
          "network"
          "battery"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        clock = {
          format = " {:%H:%M • %d.%m.%Y}";
          tooltip-format = "{:%A, %d %B %Y — %H:%M:%S}";
        };

        cpu = {
          format = "CPU {usage}%";
          interval = 2;
        };

        memory = {
          format = "RAM {percentage}%";
          interval = 2;
        };

        pulseaudio = {
          format = "VOL {volume}%";
          format-muted = "MUTE";
          scroll-step = 5;
          on-click = "pavucontrol";
          on-click-right = "qpwgraph";
        };

        network = {
          format-wifi = " {essid}";
          format-ethernet = "󰈀 {ipaddr}";
          format-disconnected = "󰖪 offline";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "BAT {capacity}%";
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrains Mono", monospace;
        font-size: 12px;
      }

      window#waybar {
        background: rgba(18, 18, 28, 0.82);
        color: #f4eef8;
        border-radius: 12px;
      }

      #workspaces,
      #clock,
      #cpu,
      #memory,
      #pulseaudio,
      #network,
      #battery {
        margin: 4px 3px;
        padding: 2px 9px;
        border-radius: 9px;
        background: rgba(255, 255, 255, 0.06);
      }

      #workspaces button {
        padding: 0 7px;
        margin: 0 2px;
        border-radius: 8px;
        color: #aaa3b4;
        background: transparent;
      }

      #workspaces button.active {
        color: #ffffff;
        background: rgba(235, 167, 255, 0.30);
      }
    '';
  };

  # ---------------------------------------------------------------------------
  # FUZZEL
  # ---------------------------------------------------------------------------

  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    terminal=kitty
    layer=overlay
    width=60
    lines=12
    horizontal-pad=20
    vertical-pad=12
    inner-pad=8

    [border]
    width=2
    radius=12
  '';

  # ---------------------------------------------------------------------------
  # HYPRIDLE
  # ---------------------------------------------------------------------------

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
      timeout = 300
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 600
      on-timeout = hyprctl dispatch dpms off
      on-resume = hyprctl dispatch dpms on
    }

    listener {
      timeout = 1800
      on-timeout = systemctl suspend
    }
  '';

  # ---------------------------------------------------------------------------
  # SCREENSHOTS
  # ---------------------------------------------------------------------------

  home.file."Pictures/Screenshots/.keep".text = "";

  # ---------------------------------------------------------------------------
  # OPENCODE / LOCAL LLAMA.CPP PROVIDER
  # ---------------------------------------------------------------------------

  # OpenCode uses the same manually started llama-server.
  # The model ID below matches the Qwen2.5-Coder GGUF used by llama-server.
  xdg.configFile."opencode/opencode.json".text =
  builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";

    provider."llama.cpp" = {
      npm = "@ai-sdk/openai-compatible";
      name = "llama-server (local)";

      options.baseURL = "http://127.0.0.1:10000/v1";

      models."Qwen3.5-9B-GGUF:UD-Q2_K_XL" = {
        name = "Qwen3.5-9B (local)";

        limit = {
          context = 50000;
          output = 24576;
        };
      };
    };
  };


}