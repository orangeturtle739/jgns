{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.beets;
in {
  options.jgns.beets = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns beets setup.
      '';
    };
    musicDirectory = mkOption {
      type = types.str;
      description = ''
        Path to the music directory.
      '';
    };
    libraryDb = mkOption {
      type = types.str;
      description = ''
        Path to the library db.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.beets = {
      enable = true;
      settings = {
        directory = cfg.musicDirectory;
        library = cfg.libraryDb;
        import = {
          languages = [ "en" ];
          plugins = [ "chroma" "web" "inline" ];
          asciify_paths = "yes";
          paths = {
            default = "$albumartist/$album%aunique{}/$disc_and_track $title";
            singleton = "$albumartist/$album%aunique{}/$disc_and_track $title";
          };
          item_fields = {
            disc_and_track =
              "u'%02i.%02i' % (disc, track) if disctotal > 1 else u'%02i' % (track)";
          };
        };
      };
    };
  };
}

