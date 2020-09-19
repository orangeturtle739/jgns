{ jgrestic, ... }:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.jgns.backup;
  backupOpts = { name, ... }: {
    options = {
      backupConfig = mkOption {
        type = types.attrs;
        description = ''
          jgrestic configuration
        '';
      };
      backupTime = mkOption {
        type = types.str;
        default = "*-*-* 02:00:00";
        description = ''
          systemd OnCalendar timespec for when to run the backup service.
        '';
      };
      name = mkOption {
        type = types.str;
        description = "The name of this backup instance. No need to set.";
      };
    };
    config = { name = mkDefault name; };
  };
  mkConfigFile = x: pkgs.writeText "config.json" "${builtins.toJSON x}";
in {
  options = {
    jgns.backup = mkOption {
      default = { };
      description = "Collection of named backup services";
      type = with types; attrsOf (submodule backupOpts);
      internal = true;
    };
  };
  config = mkIf (cfg != { }) {
    home.packages = [ jgrestic pkgs.restic ];
    systemd.user = {
      services = lib.attrsets.mapAttrs' (name: cfg:
        attrsets.nameValuePair "backup-${cfg.name}" {
          Unit = { Description = "Backup service ${cfg.name}"; };
          Service = {
            Type = "simple";
            ExecStart = "${jgrestic}/bin/jgrestic backup ${
                mkConfigFile cfg.backupConfig
              }";
          };
        }) cfg;
      timers = lib.attrsets.mapAttrs' (name: cfg:
        attrsets.nameValuePair "backup-${cfg.name}" {
          Unit = { PartOf = [ "backup-${cfg.name}.service" ]; };
          Timer = { OnCalendar = cfg.backupTime; };
          Install = { WantedBy = [ "timers.target" ]; };
        }) cfg;
    };
  };
}

