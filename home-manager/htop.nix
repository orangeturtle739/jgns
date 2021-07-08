{ ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.htop;
in {
  options.jgns.htop = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns htop setup.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.htop = {
      enable = true;
      settings = {
        hide_userland_threads = true;
        tree_view = true;
      };
    };
  };
}
