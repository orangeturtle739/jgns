{ unstable, ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.git;
in {
  options.jgns.git = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns git setup.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      aliases = { st = "status -sb"; };
      extraConfig = {
        push = { default = "current"; };
        pull = { ff = "only"; };
        # The pager is used for git diff output, so use side-by-side for that.
        # The interactive diffFilter is used for things like git add -p,
        # so it can't be side by side otherwise it won't work:
        #   fatal: mismatched output from interactive.diffFilter
        #   hint: Your filter must maintain a one-to-one correspondence
        #   hint: between its input and output lines.
        # --color-only is also required for interactive.diffFilter for this same
        # reason.
        core = {
          pager = "${unstable.gitAndTools.delta}/bin/delta --side-by-side";
        };
        interactive = {
          diffFilter = "${unstable.gitAndTools.delta}/bin/delta --color-only";
        };
        delta = {
          syntax-theme = "Monokai Extended";
          line-numbers = true;
        };
        # Shows 3 things for a merge conflict: both sides and the common ancestor!
        # This makes merge conflcits much nicer.
        merge.conflictstyle = "diff3";
      };
    };

    programs.bash.initExtra = let
      forgit = pkgs.fetchFromGitHub {
        owner = "wfxr";
        repo = "forgit";
        rev = "9699eec955d163c60847d7b6ac108eda0518dd50";
        sha256 = "KFd21uWeur2AEWCJ9w4/ZdHHa2CNmdrMxk0plY+YKcU=";
      };
    in ''
      # Fix the width of delta inside FZF
      # https://github.com/wfxr/forgit/issues/121#issuecomment-725358145
      export FORGIT_DIFF_PAGER='${unstable.gitAndTools.delta}/bin/delta --side-by-side -w ''${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
      export FORGIT_SHOW_PAGER='${unstable.gitAndTools.delta}/bin/delta --side-by-side -w ''${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
      source ${forgit}/forgit.plugin.sh
    '';
    home.packages = [ pkgs.fzf unstable.gitAndTools.delta ];
    assertions = [{
      assertion = config.programs.git.enable;
      message = "programs.git.enable must be true to use the jgns config";
    }];
  };
}

