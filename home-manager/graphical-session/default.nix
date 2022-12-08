{ lain, awesome-wm-widgets, splatmoji, ... }:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.jgns.graphical-session;
  mkGraphicalService = { description, command }: {
    Unit = {
      Description = description;
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = command;
      RestartSec = 3;
      Restart = "always";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
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
        Timeout after which to active dpms, in seconds.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      KDE_SESSION_VERSION = "5";
      KDE_FULL_SESSION = "true";
    };
    systemd.user = {
      services.volctl = mkGraphicalService {
        description = "volctl";
        command = "${pkgs.volctl}/bin/volctl";
      };
      services.shutter = mkGraphicalService {
        description = "shutter";
        command = "${pkgs.shutter}/bin/shutter --min_at_startup";
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        terminal = "${pkgs.alacritty}/bin/alacritty";
        modifier = "Mod4";
        keybindings = lib.mkOptionDefault {
          "Mod1+l" = "${pkgs.systemd}/bin/loginctl lock-sessions";
        };
      };
    };
    home.packages = with pkgs; [ swaylock wev ];
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
    wayland.windowManager.hyprland = {
      enable = false;
      xwayland = {
        enable = false;
        hidpi = false;
      };
      extraConfig = ''
        bind=SUPER,Return,exec,alacritty
        bind=SUPER + SHIFT,Q,exit
        bind=SUPER,Q,exec,chromium
        bind=SUPER,1,workspace,m+1
        bind=SUPER,2,workspace,m+2
        bind=SUPER,3,workspace,m+3
        bind=SUPER,4,workspace,m+4
        bind=SUPER,5,workspace,m+5
        bind=SUPER,6,workspace,m+6
        bind=SUPER,7,workspace,m+7
        bind=SUPER,8,workspace,m+8
        bind=SUPER,9,workspace,m+9
        bind=SUPER + CTRL,1,workspace,m-1
        bind=SUPER + CTRL,2,workspace,m-2
        bind=SUPER + CTRL,3,workspace,m-3
        bind=SUPER + CTRL,4,workspace,m-4
        bind=SUPER + CTRL,5,workspace,m-5
        bind=SUPER + CTRL,6,workspace,m-6
        bind=SUPER + CTRL,7,workspace,m-7
        bind=SUPER + CTRL,8,workspace,m-8
        bind=SUPER + CTRL,9,workspace,m-9
        bind=SUPER + SHIFT,1,movetoworkspacesilent,m+1
        bind=SUPER + SHIFT,2,movetoworkspacesilent,m+2
        bind=SUPER + SHIFT,3,movetoworkspacesilent,m+3
        bind=SUPER + SHIFT,4,movetoworkspacesilent,m+4
        bind=SUPER + SHIFT,5,movetoworkspacesilent,m+5
        bind=SUPER + SHIFT,6,movetoworkspacesilent,m+6
        bind=SUPER + SHIFT,7,movetoworkspacesilent,m+7
        bind=SUPER + SHIFT,8,movetoworkspacesilent,m+8
        bind=SUPER + SHIFT,9,movetoworkspacesilent,m+9
        bind=SUPER + CTRL + SHIFT,1,movetoworkspacesilent,m-1
        bind=SUPER + CTRL + SHIFT,2,movetoworkspacesilent,m-2
        bind=SUPER + CTRL + SHIFT,3,movetoworkspacesilent,m-3
        bind=SUPER + CTRL + SHIFT,4,movetoworkspacesilent,m-4
        bind=SUPER + CTRL + SHIFT,5,movetoworkspacesilent,m-5
        bind=SUPER + CTRL + SHIFT,6,movetoworkspacesilent,m-6
        bind=SUPER + CTRL + SHIFT,7,movetoworkspacesilent,m-7
        bind=SUPER + CTRL + SHIFT,8,movetoworkspacesilent,m-8
        bind=SUPER + CTRL + SHIFT,9,movetoworkspacesilent,m-9
        bind=SUPER,c,workspace,empty
        bind=SUPER,c,movecurrentworkspacetomonitor,current
        bind=SUPER + SHIFT,c,workspace,empty
        bind=SUPER + SHIFT,c,movewoworkspace,current
        bind=SUPER,h,movefocus,l
        bind=SUPER,j,movefocus,d
        bind=SUPER,k,movefocus,u
        bind=SUPER,l,movefocus,r
        bind=SUPER + SHIFT,h,movewindow,l
        bind=SUPER + SHIFT,j,movewindow,d
        bind=SUPER + SHIFT,k,movewindow,u
        bind=SUPER + SHIFT,l,movewindow,r
        bind=SUPER + CTRL,h,focusmonitor,l
        bind=SUPER + CTRL,j,focusmonitor,d
        bind=SUPER + CTRL,k,focusmonitor,u
        bind=SUPER + CTRL,l,focusmonitor,r
        bind=SUPER + CTRL,w,killactive
      '';
    };
    programs.eww = {
      enable = true;
      package = pkgs.eww-wayland;
      configDir = ./eww-config;
    };

    services.blueman-applet.enable = true;
    services.network-manager-applet.enable = true;
    jgns.udiskie = {
      enable = true;
      config = {
        program_options = {
          tray = true;
          notify = true;
          automount = true;
        };
      };
    };
    services.unclutter.enable = true;

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

    /* xsession = {
         enable = true;
         windowManager.awesome = {
           enable = true;
           luaModules = with pkgs; [ lain awesome-wm-widgets ];
         };
       };

       xdg.configFile.awesome.source = ./awesome-config;
       home.packages = with pkgs; [
         xorg.xeyes
         xorg.xwininfo
         lxappearance
         lxrandr
         lua
         breeze-icons
         arc-icon-theme
         fira
         fira-mono
         splatmoji
         ];
    */
  };
}
