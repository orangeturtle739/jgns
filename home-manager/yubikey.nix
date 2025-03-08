{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.gpg-ssh;
in {
  options.jgns.yubikey = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable yubikey related packages.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ yubikey-manager yubioath-flutter ];
  };
}

