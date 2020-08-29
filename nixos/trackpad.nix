{ ... }:
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.jgns.laptop-power;
in {
  options.jgns.trackpad = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the JGNS trackpad settings.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.xserver.libinput = {
      enable = true;
      tapping = false;
      # Enables two finger right click
      # https://wayland.freedesktop.org/libinput/doc/latest/configuration.html#click-method
      clickMethod = "clickfinger";
    };
  };
}

