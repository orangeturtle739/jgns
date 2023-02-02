{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.jgns.graphical-session;
  fontSpecOptions = {
    package = mkOption { type = types.package; };
    font = mkOption { type = types.str; };
  };
  fontSpec = types.submodule { options = fontSpecOptions; };
  iconFontSpec = types.submodule {
    options = fontSpecOptions // {
      i3status-rs-icon-set-name = mkOption { type = types.str; };
    };
  };
in {
  options.jgns.graphical-session = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns graphical session.
      '';
    };
    laptop = mkOption {
      type = types.bool;
      default = false;
      description = ''
        True if this is a laptop and should have a battery widget and screen brightness widget
      '';
    };
    lockTimeout = mkOption {
      type = types.ints.unsigned;
      default = 5 * 60;
      description = ''
        Timeout after which to lock the screen, in seconds.
      '';
    };
    dpmsTimeout = mkOption {
      type = types.ints.unsigned;
      default = 10 * 60;
      description = ''
        Timeout after which to activate dpms, in seconds.
      '';
    };
    fontSize = mkOption {
      type = types.float;
      default = 9.0;
      description = ''
        Font size for menu bar, notifications, etc
      '';
    };
    bg = mkOption {
      type = types.path;
      default = ./cx_sunset.jpg;
      description = ''
        Path to background image
      '';
    };
    fonts = mkOption {
      type = types.submodule {
        options = builtins.mapAttrs (name:
          { package, font, type ? fontSpec, extra ? { } }:
          mkOption {
            type = type;
            default = { inherit package font; } // extra;
            description = "Default ${name} font";
          }) {
            sans-serif = {
              package = pkgs.noto-fonts;
              font = "Noto Sans";
            };
            serif = {
              package = pkgs.noto-fonts;
              font = "Noto Serif";
            };
            monospace = {
              package = pkgs.fira-mono;
              font = "Fira Mono";
            };
            emoji = {
              package = pkgs.noto-fonts-emoji;
              font = "Noto Color Emoji";
            };
            icon = {
              type = iconFontSpec;
              package = pkgs.font-awesome;
              font = "Font Awesome 6 Free";
              extra = { i3status-rs-icon-set-name = "awesome6"; };
            };
          };
      };
      default = { };
      description = "Configuration for fonts";
    };
    modifier = mkOption {
      type = types.str;
      default = "Mod4";
      description = "base modifier for window shortcuts";
    };
    centerWindowTitle = mkOption {
      type = types.str;
      default = "sway_floating_center";
      description =
        "title for windows which sway should center and make floating";
    };
    openweathermapApiKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "openweathermap API key";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      KDE_SESSION_VERSION = "5";
      KDE_FULL_SESSION = "true";
      # make chromium and electron apps work
      NIXOS_OZONE_WL = "1";
    };

    # Enable once dbus menus work:
    # https://github.com/swaywm/sway/pull/6249
    # services.blueman-applet.enable = true;
    # services.network-manager-applet.enable = true;

    # https://github.com/NixOS/nixpkgs/issues/16026#issuecomment-224939125
    xdg.configFile = {
      "fontconfig/conf.d/30-default-fonts.conf".text = ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
        <fontconfig>
        	<alias binding="strong">
        		<family>sans-serif</family>
        		<prefer>
        			<family>${cfg.fonts.sans-serif.font}</family>
        		</prefer>
        	</alias>
        	<alias binding="strong">
        		<family>serif</family>
        		<prefer>
        			<family>${cfg.fonts.serif.font}</family>
        		</prefer>
        	</alias>
        	<alias binding="strong">
        		<family>monospace</family>
        		<prefer>
        			<family>${cfg.fonts.monospace.font}</family>
        		</prefer>
            </alias>

            <!-- https://gist.github.com/cole-h/8aab0ed9d65efe38496e8e27b96b6a3d -->
            <!-- Add generic family. -->
            <match target="pattern">
                <test qual="any" name="family"><string>emoji</string></test>
                <edit name="family" mode="assign" binding="same"><string>${cfg.fonts.emoji.font}</string></edit>
            </match>

            <!-- This adds ${cfg.fonts.emoji.font} as a final fallback font for the default font families. -->
            <match target="pattern">
                <test name="family"><string>sans</string></test>
                <edit name="family" mode="append"><string>${cfg.fonts.emoji.font}</string></edit>
            </match>

            <match target="pattern">
                <test name="family"><string>serif</string></test>
                <edit name="family" mode="append"><string>${cfg.fonts.emoji.font}</string></edit>
            </match>

            <match target="pattern">
                <test name="family"><string>sans-serif</string></test>
                <edit name="family" mode="append"><string>${cfg.fonts.emoji.font}</string></edit>
            </match>

            <match target="pattern">
                <test name="family"><string>monospace</string></test>
                <edit name="family" mode="append"><string>${cfg.fonts.emoji.font}</string></edit>
            </match>
        </fontconfig>
      '';
    };

    wayland.windowManager.sway =
      let fontNameList = [ cfg.fonts.monospace.font cfg.fonts.icon.font ];
      in {
        enable = true;
        xwayland = false;
        config = rec {
          fonts = {
            names = fontNameList;
            size = cfg.fontSize;
          };
          terminal = "${pkgs.alacritty}/bin/alacritty";
          modifier = "Mod4";
          keybindings = let
            forAllDigits = f: builtins.listToAttrs (map f (lib.range 0 9));
            mkSwaysomeBind = { cmd, extra ? "" }:
              i: {
                name = "${modifier}+${extra}${builtins.toString i}";
                value = ''exec "swaysome ${cmd} ${builtins.toString i}"'';
              };
            mkSwaysomeBindForAllDigits = arg: forAllDigits (mkSwaysomeBind arg);
          in lib.mkOptionDefault ({
            # https://github.com/swaywm/sway/issues/2910#issuecomment-752840549
            "Control+Mod1+l" = ''exec "sleep 0.5; killall -USR1 swayidle"'';
            "${modifier}+o" = ''exec "swaysome next_output"'';
            "${modifier}+Shift+o" = ''exec "swaysome prev_output"'';
            "${modifier}+q" = ''exec "chromium"'';
            "${modifier}+Shift+q" = "exit";
            "${modifier}+Shift+c" = "kill";
            "${modifier}+p" =
              ''exec grim -g "$(slurp -d)" - | wl-copy -t image/png'';
            "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioRaiseVolume" =
              "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" =
              "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86MonBrightnessUp" = "exec light -A 10";
            "XF86MonBrightnessDown" = "exec light -U 10";
            "XF86AudioMicMute" =
              "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          } // (mkSwaysomeBindForAllDigits { cmd = "focus"; })
            // (mkSwaysomeBindForAllDigits {
              cmd = "move";
              extra = "Shift+";
            }));
          window.commands = [{
            command = "floating enable, border pixel";
            criteria = { title = "^${cfg.centerWindowTitle}$"; };
          }];
          seat = { "*" = { hide_cursor = "1000"; }; };
          startup = [
            { command = "swaysome init 1"; }
            { command = "swaybg --image ${cfg.bg}"; }
          ];

          bars = [{
            position = "top";
            fonts = {
              names = fontNameList;
              size = cfg.fontSize;
            };
            statusCommand = let
              configFile =
                config.xdg.configFile."i3status-rust/config-top.toml";
            in "${pkgs.i3status-rust}/bin/i3status-rs ${configFile.source}";
            extraConfig = ''
              icon_theme Adwaita
            '';
          }];
          input = { "type:touchpad" = { click_method = "clickfinger"; }; };
        };
      };
    programs.i3status-rust = {
      enable = true;
      bars = {
        top = {
          icons = cfg.fonts.icon.i3status-rs-icon-set-name;
          theme = "solarized-dark";
          blocks = [
            { block = "focused_window"; }
            { block = "music"; }
            {
              block = "networkmanager";
              on_click = "alacritty --title ${cfg.centerWindowTitle} -e nmtui";
            }
            {
              block = "cpu";
              format = "{barchart} {utilization}";
            }
            { block = "memory"; }
            { block = "net"; }
          ] ++ (lists.optional cfg.laptop { block = "battery"; }) ++ [
            { block = "sound"; }
            {
              block = "sound";
              device = "@DEFAULT_SOURCE@";
              device_kind = "source";
              format = "";
            }
          ] ++ (lists.optional cfg.laptop { block = "backlight"; })
            ++ (lists.optional (cfg.openweathermapApiKey != null) {
              block = "weather";
              format =
                "{weather} ({location}) {temp} F, {wind} mph {direction}";
              autolocate = true;
              service = {
                name = "openweathermap";
                api_key = cfg.openweathermapApiKey;
                units = "imperial";
              };
            }) ++ [{
              block = "time";
              interval = 1;
              format = "%a %d %b %Y %H:%M:%S";
            }];
        };
      };
    };
    programs.mako = {
      enable = true;
      font = "${cfg.fonts.sans-serif.font} ${builtins.toString cfg.fontSize}";
    };
    home.packages = with pkgs; [
      cfg.fonts.emoji.package
      cfg.fonts.icon.package
      cfg.fonts.monospace.package
      cfg.fonts.sans-serif.package
      cfg.fonts.serif.package
      dolphin
      drm_info
      gnome3.gnome-themes-extra
      grim
      i3status-rust
      playerctl
      shutter
      slurp
      swaybg
      swaylock
      swaysome
      wev
      wl-clipboard
      wtype
      (pkgs.writeShellScriptBin "start_wayland" ''
        exec systemd-cat --identifier=sway sway $@
      '')
    ];
    programs.swaylock.settings = {
      color = "808080";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
    services.swayidle = let
      lockCommand =
        "${pkgs.swaylock}/bin/swaylock --daemonize --show-failed-attempts";
      dpmsCommand = state:
        "${config.wayland.windowManager.sway.package}/bin/swaymsg 'output * dpms ${state}'";
    in {
      enable = true;
      # Use timeouts instead of idlehint so they can be configured on a per-user basis.
      timeouts = [
        {
          timeout = cfg.lockTimeout;
          command = lockCommand;
        }
        {
          timeout = cfg.dpmsTimeout;
          command = dpmsCommand "off";
          resumeCommand = dpmsCommand "on";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = lockCommand;
        }
        {
          event = "lock";
          command = lockCommand;
        }
        {
          event = "unlock";
          command = "${pkgs.psmisc}/bin/killall -USR1 swaylock";
        }
      ];
    };

    jgns.udiskie = {
      enable = true;
      config = {
        program_options = {
          tray = false;
          notify = true;
          automount = true;
        };
      };
    };

    gtk = {
      enable = true;
      font = {
        package = pkgs.fira;
        name = "Fira Sans 10";
      };
      theme = {
        package = pkgs.gnome3.gnome-themes-extra;
        name = "Adwaita";
      };
      iconTheme = {
        package = pkgs.numix-icon-theme;
        name = "Numix";
      };
    };
  };
}
