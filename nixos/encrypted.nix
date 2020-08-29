{ ... }:
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.jgns.encrypted;
in {
  options.jgns.encrypted = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the JGNS encrypted root partition support.
      '';
    };
    cryptRootUUID = mkOption {
      type = types.str;
      description = ''
        The UUID of the LUKS partition.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        version = 2;
        device = "nodev";
        efiSupport = true;
      };
    };
    boot.initrd.luks = {
      reusePassphrases = true;
      devices = {
        root = {
          preLVM = true;
          allowDiscards = true;
          device = "/dev/disk/by-uuid/${cfg.cryptRootUUID}";
        };
      };
    };
  };
}
