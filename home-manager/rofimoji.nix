{ ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.rofi;
in {
  options.jgns.rofi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns rofi setup.
      '';
    };
    enableRofimoji = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = ''
        Enable the jgns rofimoji setup.
      '';
    };
    skinTone = mkOption {
      type = types.enum [
        "light"
        "medium-light"
        "moderate"
        "dark brown"
        "black"
        "neutral"
        "ask"
      ];
      default = "neutral";
      description = ''
        skin tone configuration; see https://github.com/fdw/rofimoji#configuration
      '';
    };
    extraConfig = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "extra configuration";
    };
    rofiPackage = mkOption {
      type = types.package;
      default = pkgs.rofi-wayland;
      description = "rofi package to use";
    };
    rofimojiPackage = mkOption {
      type = types.package;
      default = pkgs.rofimoji.override {
        waylandSupport = true;
        x11Support = false;
        rofi = cfg.rofiPackage;
      };
      description = "rofimoji package";
    };
    swayIntegration = mkOption {
      type = types.bool;
      default = config.jgns.graphical-session.enable;
      description = ''
        Integrate with sway.
      '';
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        theme = "Monokai";
      };
      home.packages = [ cfg.rofiPackage ];
    }
    (mkIf cfg.swayIntegration {
      wayland.windowManager.sway.config.keybindings = mkOptionDefault {
        "${config.jgns.graphical-session.modifier}+d" =
          ''exec "rofi -show run"'';
      };
    })
    (mkIf cfg.enableRofimoji (mkMerge [
      {
        home.packages = [ cfg.rofimojiPackage ];
        xdg.configFile."rofimoji.rc".text = generators.toKeyValue { }
          (cfg.extraConfig // { skin-tone = cfg.skinTone; });
      }
      (mkIf cfg.swayIntegration {
        wayland.windowManager.sway.config.keybindings = mkOptionDefault {
          "${config.jgns.graphical-session.modifier}+e" = ''exec "rofimoji"'';
        };
      })
    ]))
  ]);
}
