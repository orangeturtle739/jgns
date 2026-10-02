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
      enableDefaultConfig = false;
      # Upstream OpenSSH directive names — `matchBlocks` is deprecated in
      # favour of `settings`, which is freeform and passes keys through
      # verbatim. `settings."*"` is still emitted last, after any named
      # host blocks, so first-match-wins ordering is unchanged.
      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

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
      # Cache long enough that in practice a passphrase is entered once
      # per gpg-agent lifetime (i.e. per boot). The agent dies on reboot,
      # so the in-memory cache is cleared regardless of the TTL.
      defaultCacheTtl = 30 * 24 * 60 * 60;
      defaultCacheTtlSsh = 30 * 24 * 60 * 60;
      maxCacheTtl = 30 * 24 * 60 * 60;
      maxCacheTtlSsh = 30 * 24 * 60 * 60;
      pinentry.package = pkgs.pinentry-curses;
    };

    # See https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
    # We want to use PCSD for smart card authentication so yubikeys can be used
    programs.gpg.scdaemonSettings = { disable-ccid = true; };
  };
}
