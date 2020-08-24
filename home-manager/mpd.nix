{ ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.mpd;
in {
  options.jgns.mpd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns mpd setup.
      '';
    };
    musicDirectory = mkOption {
      type = types.str;
      description = ''
        Path to the music directory.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = { MPD_HOST = "$XDG_RUNTIME_DIR/mpd/socket"; };
    xdg.configFile."mpd/mpd.conf".text = ''
      music_directory "${cfg.musicDirectory}"
    '';
    systemd.user = {
      services.mpd = {
        Unit = {
          Description = "mpd";
          After = [ "network.target" "sound.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "notify";
          ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon";
          # allow MPD to use real-time priority 50
          LimitRTPRIO = "50";
          LimitRTTIME = "infinity";
          # disallow writing to /usr, /bin, /sbin, ...
          ProtectSystem = "yes";
          NoNewPrivileges = "yes";
          ProtectKernelTunables = "yes";
          ProtectControlGroups = "yes";
          # more paranoid security settings
          # AF_NETLINK is required by libsmbclient, or it will exit() .. *sigh*
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
          RestrictNamespaces = "yes";
          # Note that "ProtectKernelModules=yes" is missing in the user unit
          # because systemd 232 is unable to reduce its own capabilities
          # ("Failed at step CAPABILITIES spawning /usr/bin/mpd: Operation not
          # permitted")
        };
      };
      sockets.mpd = {
        Socket = {
          ListenStream = "%t/mpd/socket";
          Backlog = 5;
          KeepAlive = true;
          PassCredentials = true;
        };
        Install = { WantedBy = [ "sockets.target" ]; };
      };
    };
  };
}

