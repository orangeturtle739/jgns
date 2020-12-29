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
      };
    };

    assertions = [{
      assertion = config.programs.git.enable;
      message = "programs.git.enable must be true to use the jgns config";
    }];
  };
}

