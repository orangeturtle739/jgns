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
        font size
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ source-code-pro-nerdfont ];
    programs.alacritty = {
      enable = true;
      settings = {
        env = { TERM = "xterm-256color"; };
        window = { opacity = 0.75; };
        font = {
          normal = {
            family = "SauceCodePro Nerd Font";
            style = "Semibold";
          };
          bold = { family = "SauceCodePro Nerd Font"; };
          italic = { family = "SauceCodePro Nerd Font"; };
          bold_italic = { family = "SauceCodePro Nerd Font"; };
          size = cfg.fontSize;
        };
        colors = {
          primary = {
            background = "#000000";
            foreground = "#b2b2b2";
            dim_foreground = "#656565";
            bright_foreground = "#ffffff";
          };
          normal = {
            black = "#000000";
            red = "#b21818";
            green = "#18b218";
            yellow = "#b2b218";
            blue = "#1818b2";
            magenta = "#b218b2";
            cyan = "#18b2b2";
            white = "#b2b2b2";
          };
          /* dim = {
               black = "#181818";
               red = "#650000";
               green = "#006500";
               yellow = "#655e00";
               blue = "#000065";
               magenta = "#650065";
               cyan = "#006565";
               white = "#656565";
             };
             bright = {
               black = "#686868";
               red = "#ff5454";
               green = "#54ff54";
               yellow = "#ffff54";
               blue = "#5454ff";
               magenta = "#ff54ff";
               cyan = "#54ffff";
               white = "#ffffff";
               };
          */
        };
      };
    };
  };
}
