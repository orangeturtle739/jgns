{ ... }:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.jgns.ssh-tunnel;
  sshTunnelOpts = { name, ... }: {
    options = {
      description = mkOption {
        type = types.str;
        description = ''
          systemd unit description.
        '';
      };
      privateSshKey = mkOption {
        type = types.str;
        description = ''
          Path to private key file for ssh
        '';
      };
      portForwardSpec = mkOption {
        type = types.str;
        description = ''
          Port forwarding arguments for ssh.
        '';
        example = "-L 127.0.0.1:9000:127.0.0.1:9000";
      };
      host = mkOption {
        type = types.str;
        description = ''
          Host to SSH to.
        '';
        example = "ssh://joe@bob.org:123";
      };
      restartSec = mkOption {
        type = types.int;
        default = 15;
        description = ''
          systemd restart seconds
        '';
      };
      name = mkOption {
        type = types.str;
        description = "The name of this ssh-tunnel instance. No need to set.";
      };
    };
    config = { name = mkDefault name; };
  };

  mkNamedSshTunnel = cfg: {
    "ssh-tunnel-${cfg.name}" = {
      Unit = {
        Description = cfg.description;
        After = [ "network.target" ];

      };
      Service = {
        ExecStart = ''
          ${pkgs.openssh}/bin/ssh -v -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o IdentitiesOnly=yes -i ${cfg.privateSshKey} -nNT ${cfg.portForwardSpec} ${cfg.host}
        '';
        RestartSec = cfg.restartSec;
        Restart = "always";

      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };
in {
  options = {
    jgns.ssh-tunnel = mkOption {
      default = { };
      description = "Collection of named ssh tunnels";
      type = with types; attrsOf (submodule sshTunnelOpts);
      internal = true;
    };
  };

  config = {
    systemd.user.services =
      fold (a: b: a // b) { } (map mkNamedSshTunnel (attrValues cfg));
  };
}
