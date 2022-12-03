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
      services.compton = mkGraphicalService {
        description = "compton";
        command = "${pkgs.compton}/bin/compton";
      };
      services.shutter = mkGraphicalService {
        description = "shutter";
        command = "${pkgs.shutter}/bin/shutter --min_at_startup";
      };
    };

    /*
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = {
        enable = false;
        hidpi = false;
      };
    };
    */

    /* services.picom = {
       enable = true;
       backend = "glx";
       extraArgs = ["--log-level" "DEBUG"];
       };
    */
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

    xsession = {
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
  };
}
