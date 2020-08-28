{ jgrestic, ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.backup;
in {
  options.jgns.backup = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns local backup service.
      '';
    };
    cryptUuid = mkOption {
      type = types.str;
      description = ''
        UUID of the LUKS volume on which the backups are stored.
      '';
    };
    backupDir = mkOption {
      type = types.str;
      description = ''
        Directory where backup is stored.
      '';
    };
    keyFilePath = mkOption {
      type = types.str;
      description = ''
        Path to the keyfile (read only at runtime).
      '';
    };
    backupTime = mkOption {
      type = types.str;
      default = "*-*-* 02:00:00";
      description = ''
        systemd OnCalendar timespec for when to run the backup service.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ jgrestic ];
    systemd.user = {
      timers.userbackup = {
        Unit = { PartOf = [ "userbackup.service" ]; };
        Timer = { OnCalendar = cfg.backupTime; };
        Install = { WantedBy = [ "timers.target" ]; };
      };
      services.userbackup = {
        Unit = { Description = "User backup service"; };
        Service = {
          Type = "simple";
          ExecStartPre =
            "${pkgs.udiskie}/bin/udiskie-mount --verbose --recursive ${cfg.cryptUuid}";
          ExecStart = "${jgrestic}/bin/jgrestic backup --root ${cfg.backupDir}";
          TimeoutStartSec = "2min";
        };
      };
    };
    xdg.configFile."udiskie/config.yml".text = ''
      device_config:
        - id_uuid: "${cfg.cryptUuid}"
          keyfile: "${cfg.keyFilePath}"
          automount: true
    '';
  };
}

