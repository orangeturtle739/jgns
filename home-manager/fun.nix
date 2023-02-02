{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.fun;
in {
  options.jgns.fun = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns fun packages.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ asciinema cool-retro-term solarwolf ternimal ];
  };
}

