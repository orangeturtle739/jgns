{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.jgns.udiskie;
  # json is valid yaml it's OK that udiskie uses yaml
  udiskieConfigFile =
    pkgs.writeText "config.yml" "${builtins.toJSON cfg.config}";
  commandArgs = concatStringsSep " "
    ([ "--verbose" "--config=${udiskieConfigFile}" ]
      ++ optional config.xsession.preferStatusNotifierItems "--appindicator");

in {
  options.jgns.udiskie = {
    enable = mkEnableOption "udiskie mount daemon";
    config = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        udiskie configuration. See https://www.mankier.com/8/udiskie.
      '';
    };
  };

  config = mkIf config.jgns.udiskie.enable {
    systemd.user.services.udiskie = {
      Unit = {
        Description = "udiskie mount daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = { ExecStart = "${pkgs.udiskie}/bin/udiskie ${commandArgs}"; };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
    home.packages = with pkgs; [ udiskie ];
    assertions = [{
      assertion = !config.services.udiskie.enable;
      message = "jgns udiskie conflicts with home-manager udiskie";
    }];
  };
}
