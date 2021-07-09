{ unstable, luafmt, my_vi, pms, solarwolf, ternimal, ... }@extra:
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
    jgns.base.enable = true;
    home.packages = with pkgs;
      [
        ark
        asciinema
        bitwarden-cli
        calibre
        cantata
        cool-retro-term
        cura
        digikam
        dolphin
        libreoffice-fresh
        mpc_cli
        okular
        openscad
        signal-desktop
        texlive.combined.scheme-full
        udiskie
        unison
        vgo2nix
        vlc
        wally-cli
        yubikey-manager
      ] ++ [ luafmt solarwolf ternimal unstable.cached-nix-shell ];
  };
}

