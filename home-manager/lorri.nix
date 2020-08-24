{ ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.lorri;
in {
  options.jgns.lorri = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns lorri setup.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      stdlib = ''
        use_flake() {
          watch_file flake.nix
          watch_file flake.lock
          mkdir -p "$(direnv_layout_dir)"
          eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
        }
      '';
    };
    services.lorri.enable = true;
  };
}

