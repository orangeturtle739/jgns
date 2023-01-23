{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.starship;
in {
  options.jgns.starship = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns starship setup.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        python.disabled = true;
        env_var = {
          variable = "PINDICATOR";
          style = "bold white";
        };
      };
    };
    programs.bash.initExtra = ''
      function pindicator_append {
        if [[ $PINDICATOR  ]]; then
          PINDICATOR="[$PINDICATOR$1 ] "
        else
          PINDICATOR="[$1] "
        fi
        export PINDICATOR
      }
      if [[ $VIM ]]; then
        pindicator_append "vim"
        unset VIM
      fi
    '';
    programs.zoxide.enable = true;
    assertions = [{
      assertion = config.programs.bash.enable;
      message =
        "programs.bash.enable must be true to use the jgns starship config";
    }];
  };
}
