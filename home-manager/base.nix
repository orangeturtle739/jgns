{ unstable, luafmt, my_vi, pms, solarwolf, ternimal, ... }@extra:
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
    home.sessionVariables = { EDITOR = "${extra.my_vi}/bin/vim"; };
    home.packages = with pkgs;
      [
        acpi
        age
        bandwhich
        bat
        exa
        fd
        file
        gcc
        gnumake
        hyperfine
        kate
        killall
        lsof
        ncat
        ncdu
        nix-index
        nix-prefetch-git
        nix-prefetch-github
        nixfmt
        pavucontrol
        pv
        ripgrep
        sd
        simplescreenrecorder
        sl
        socat
        tig
        trash-cli
        tree
        unzip
        wget
        zip
      ] ++ [ fastmod my_vi unstable.netris ];
    # programs.home-manager.enable = true;
    programs.firefox.enable = true;
    programs.command-not-found.enable = true;
    programs.dircolors.enable = true;
    programs.jq.enable = true;
    programs.man.enable = true;
    programs.readline.enable = true;
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
    };
  };
}

