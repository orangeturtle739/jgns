{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.office;
in {
  options.jgns.office = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns office group of packages.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ libreoffice-fresh okular vlc simple-scan ];
  };
}
