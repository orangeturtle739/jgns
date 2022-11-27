{ my_vi, ... }@extra:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.vi;
in {
  options.jgns.vi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable JGNS vi
      '';
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = { EDITOR = "${extra.my_vi}/bin/vim"; };
    home.packages = [ my_vi ];
  };
}

