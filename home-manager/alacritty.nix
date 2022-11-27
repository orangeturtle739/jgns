{ source-code-pro-nerdfont, ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.alacritty;
in {
  options.jgns.alacritty = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns alacritty setup.
      '';
    };
    fontSize = mkOption {
      type = types.ints.unsigned;
      default = 8;
      description = ''
        Konsole font size.
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ source-code-pro-nerdfont ];
    programs.alacritty = {
      enable = true;
      settings = {
        env = { TERM = "xterm-256color"; };
        window = { opacity = "0.75"; };
        font = {
          normal = {
            family = "Source Code Pro Nerd Font";
            style = "Semibold";
          };
          bold = { family = "Source Code Pro Nerd Font"; };
          italic = { family = "Source Code Pro Nerd Font"; };
          bold_italic = { family = "Source Code Pro Nerd Font"; };
          size = cfg.fontSize;
        };
      };
    };
  };
}
