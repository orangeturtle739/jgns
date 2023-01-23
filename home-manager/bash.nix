{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.bash;
in {
  options.jgns.bash = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns bash setup.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      historyControl = [ "erasedups" "ignoredups" ];
      initExtra = ''
        bind -x '"\C-g":"fg"'
      '';
    };
  };
}

