{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.bash;
in {
  options.jgns.bash = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns bash setup.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      historyControl = [ "erasedups" "ignoredups" ];
      initExtra = ''
        bind -x '"\C-g":"fg"'
        # Point gpg-agent at the current tty before every prompt so
        # pinentry-curses appears in the pane where the command was
        # actually run (tmux + curses pinentry otherwise races to
        # whichever pane started bash last).
        PROMPT_COMMAND='gpg-connect-agent --quiet updatestartuptty /bye >/dev/null 2>&1; '"''${PROMPT_COMMAND:-}"
      '';
    };
  };
}

