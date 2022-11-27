{ unstable, luafmt, my_vi, pms, solarwolf, ternimal, ... }@extra:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.base;
in {
  options.jgns.base = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns base configuration.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.extraOutputsToInstall = [ "man" "doc" ];

    manual = {
      html.enable = true;
      json.enable = true;
      manpages.enable = true;
    };
    systemd.user.startServices = true;

    fonts.fontconfig.enable = true;
    xdg = {
      enable = true;
      userDirs.enable = true;
    };
  };
}

