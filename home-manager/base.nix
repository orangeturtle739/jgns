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
      # home-manager 26.05 flipped this default to false. We were on the
      # old default implicitly (home.stateVersion < 26.05); keep exporting
      # XDG_*_DIR so shells and scripts relying on them don't break.
      userDirs.setSessionVariables = true;
    };
  };
}

