{ config, lib, pkgs, ... }:

with lib;

let cfg = config.jgns.tailscale;
in {
  options.jgns.tailscale = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Use tailscale beta
      '';
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    networking.firewall.checkReversePath = "loose";
  };
}

