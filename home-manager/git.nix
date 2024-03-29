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
        init = { defaultBranch = "master"; };
        # The pager is used for git diff output, so use side-by-side for that.
        # The interactive diffFilter is used for things like git add -p,
        # so it can't be side by side otherwise it won't work:
        #   fatal: mismatched output from interactive.diffFilter
        #   hint: Your filter must maintain a one-to-one correspondence
        #   hint: between its input and output lines.
        # --color-only is also required for interactive.diffFilter for this same
        # reason.
        core = {
          pager = "${pkgs.gitAndTools.delta}/bin/delta --side-by-side";
        };
        interactive = {
          diffFilter = "${pkgs.gitAndTools.delta}/bin/delta --color-only";
        };
        delta = {
          syntax-theme = "Monokai Extended";
          line-numbers = true;
        };
        # Shows 3 things for a merge conflict: both sides and the common ancestor!
        # This makes merge conflcits much nicer.
        merge.conflictstyle = "diff3";
        # Make git try harder to resolve renames; this reduces conflicts during
        # cherry-pick/rebase/merge operations easier.
        # Note that merge.renameLimit defaults to the value of
        # diff.renameLimit.
        diff.renameLimit = 10000;
      };
    };

    programs.bash.initExtra = let
      forgit = pkgs.fetchFromGitHub {
        owner = "orangeturtle739";
        repo = "forgit";
        rev = "2a183c5a5639e6caf4bb6904b7d65808d4454b77";
        sha256 = "RG/2SXGw1WPv9FHaQbaIjj89MvOUwX58QkhO3VpIhHc=";
      };
    in ''
      # Fix the width of delta inside FZF
      # https://github.com/wfxr/forgit/issues/121#issuecomment-725358145
      export FORGIT_DIFF_PAGER='${pkgs.gitAndTools.delta}/bin/delta --side-by-side -w ''${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
      export FORGIT_SHOW_PAGER='${pkgs.gitAndTools.delta}/bin/delta --side-by-side -w ''${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
      source ${forgit}/forgit.plugin.sh
    '';
    home.packages = [ pkgs.fzf pkgs.gitAndTools.delta ];
    assertions = [{
      assertion = config.programs.git.enable;
      message = "programs.git.enable must be true to use the jgns config";
    }];
  };
}

