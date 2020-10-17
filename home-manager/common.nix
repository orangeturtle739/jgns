{ unstable, codemod, luafmt, my_vi, pms, solarwolf, ternimal, ymuse, ...
}@extra:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.common;
in {
  options.jgns.common = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns common configuration.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = { EDITOR = "${extra.my_vi}/bin/vim"; };
    home.packages = with pkgs;
      [
        acpi
        age
        arc-icon-theme
        ark
        asciinema
        bitwarden-cli
        breeze-icons
        calibre
        cantata
        cool-retro-term
        cura
        digikam
        dolphin
        file
        gcc
        gnumake
        kate
        killall
        libreoffice-fresh
        lsof
        lua
        lxappearance
        lxrandr
        mpc_cli
        ncat
        ncdu
        nix-index
        nix-prefetch-git
        nix-prefetch-github
        nixfmt
        okular
        openscad
        pavucontrol
        pv
        pypi2nix
        ripgrep
        signal-desktop
        simplescreenrecorder
        sl
        socat
        texlive.combined.scheme-full
        tig
        trash-cli
        tree
        udiskie
        unison
        unzip
        vgo2nix
        vlc
        wally-cli
        wget
        xorg.xeyes
        xorg.xwininfo
        yubikey-manager
      ] ++ [
        codemod
        luafmt
        my_vi
        pms
        solarwolf
        ternimal
        unstable.cached-nix-shell
        unstable.netris
        ymuse
      ];
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

    xdg.configFile."jgns/config.toml".text = ''
      nixos_dir = "~/system-config/nixos"
    '';
  };
}

