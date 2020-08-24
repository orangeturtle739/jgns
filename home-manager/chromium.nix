{ ... }:
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.jgns.chromium;
in {
  options.jgns.chromium = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the jgns chromium setup.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      extensions = [
        # bitwarden
        # https://chrome.google.com/webstore/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb
        "nngceckbapebfimnlniiiahkandclblb"
        # adblock Plus
        # https://chrome.google.com/webstore/detail/adblock-plus-free-ad-bloc/cfhdojbkjhnklbpkdaibdccddilifddb
        "cfhdojbkjhnklbpkdaibdccddilifddb"
      ];
    };
  };
}
