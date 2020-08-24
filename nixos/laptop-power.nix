{ config, lib, pkgs, ... }:

with lib;

let cfg = config.jgns.laptop-power;
in {
  options.jgns.laptop-power = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the JGNS laptop power settings.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.sleep.extraConfig = ''
      HibernateDelaySec=15m
    '';
    services.logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchDocked = "suspend-then-hibernate";
    };
    services.upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
    };
  };
}

