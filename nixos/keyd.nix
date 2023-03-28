{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.keyd;
in {
  options.jgns.keyd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable keyd.
      '';
    };
    config = mkOption {
      type = types.str;
      default = "";
      description = ''
        Configuration for keyd.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.groups.keyd = { };
    systemd.services.keyd = {
      requires = [ "local-fs.target" ];
      after = [ "local-fs.target" ];
      wantedBy = [ "sysinit.target" ];

      serviceConfig = { ExecStart = "${pkgs.keyd}/bin/keyd"; };
      restartTriggers = [ config.environment.etc."keyd/default.conf".source ];
    };
    environment.etc."keyd/default.conf".text = cfg.config;
    programs.wshowkeys.enable = true;
  };
}
