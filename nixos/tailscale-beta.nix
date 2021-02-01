{ unstable, ... }:
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.jgns.tailscaleBeta;
in {
  options.jgns.tailscaleBeta = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Use tailscale beta
      '';
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config = {
      packageOverrides = super:
        let self = super.pkgs;
        in { tailscale = unstable.tailscale; };
    };
  };
}

