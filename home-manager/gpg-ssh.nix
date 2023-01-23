{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.gpg-ssh;
in {
  options.jgns.gpg-ssh = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns gpg and ssh setup.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      # https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9
      # To prevent pinentry from opening on the wrong tty
      # when used with gpg-agent
      extraConfig = ''
        Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
      '';
    };
    programs.gpg = { enable = true; };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 60 * 60;
      defaultCacheTtlSsh = 60 * 60;
      maxCacheTtl = 2 * 60 * 60;
      maxCacheTtlSsh = 2 * 60 * 60;
      pinentryFlavor = "curses";
    };
  };
}
