{ config, lib, pkgs, ... }:

with lib;

let cfg = config.jgns.duckdns;
in {
  options.jgns.duckdns = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the JGNS duckdns.
      '';
    };
    configFile = mkOption {
      type = types.str;
      description = ''
        path to TOML configuration file with domain and token.
      '';
    };
    timerOnCalendar = mkOption {
      type = types.str;
      default = "*:0/5";
      description = ''
        systemd timer OnCalendar spec
      '';
    };
    timerRandomizedDelay = mkOption {
      type = types.str;
      default = "1m";
      description = ''
        systemd RandomizedDelaySec field
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      timers.duckdns = {
        wantedBy = [ "timers.target" ];
        partOf = [ "duckdns.service" ];
        timerConfig = {
          OnCalendar = cfg.timerOnCalendar;
          RandomizedDelaySec = cfg.timerRandomizedDelay;
        };
      };
      services.duckdns = {
        serviceConfig = {
          Type = "simple";
          ExecStart =
            "${pkgs.duckdns-update}/bin/duckdns-update ${cfg.configFile}";
        };
      };
    };
  };
}

