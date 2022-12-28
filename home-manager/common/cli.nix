{ my_vi, pms, solarwolf, ternimal, ... }@extra:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.common.cli;
in {
  options.jgns.common.cli = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable usefull CLI tools
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      acpi
      age
      bandwhich
      bat
      btop
      cached-nix-shell
      du-dust
      eva
      exa
      fastmod
      fd
      file
      gcc
      gnumake
      hyperfine
      killall
      lsof
      ncdu
      netris
      nix-index
      nix-prefetch-git
      nix-prefetch-github
      nixfmt
      nmap
      procs
      pv
      ripgrep
      sd
      sl
      socat
      tig
      trash-cli
      tree
      unzip
      wget
      zip
    ];
    programs.broot.enable = true;
    programs.bottom.enable = true;
    programs.dircolors.enable = true;
    programs.jq.enable = true;
    programs.man.enable = true;
    programs.readline.enable = true;
  };
}

