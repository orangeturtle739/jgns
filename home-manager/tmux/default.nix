{ ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.tmux;
in {
  options.jgns.tmux = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns tmux setup.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}

