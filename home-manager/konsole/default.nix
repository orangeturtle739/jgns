{ source-code-pro-nerdfont, ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.konsole;
in {
  options.jgns.konsole = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns konsole setup.
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
    home.packages = [ pkgs.konsole source-code-pro-nerdfont ];
    home.file.".local/share/konsole/mykonsole.colorscheme".source =
      ./mykonsole.colorscheme;
    home.file.".local/share/konsole/mykonsole.profile".text = ''
      [Appearance]
      ColorScheme=mykonsole
      Font=Source Code Pro Nerd Font,${
        toString cfg.fontSize
      },-1,5,63,0,0,0,0,0,Semibold

      [General]
      Name=myconsole
      Parent=FALLBACK/

      [Scrolling]
      ScrollBarPosition=2
            '';
    xdg.configFile.konsolerc.source = ./konsolerc;
  };
}

