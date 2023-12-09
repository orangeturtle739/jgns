{ jgnsHome, home-manager, nixpkgs, vstring }:
{ config, lib, pkgs, ... }:
let
  home = (home-manager.lib.homeManagerConfiguration {
    pkgs = pkgs;
    modules = [
      ({ config, pkgs, ... }: {
        imports = [ jgnsHome ];
        jgns = {
          handy.enable = true;
          git.enable = true;
          gpg-ssh.enable = true;
          htop.enable = true;
          bash.enable = true;
          starship.enable = true;
          tmux.enable = true;
        };
        programs.git.enable = true;
        home = {
          username = "nixos";
          homeDirectory = "/home/nixos";
          stateVersion = "23.11";
        };
      })
    ];
  }).activationPackage;
in {
  imports = [
    # from https://github.com/tfc/nixos-offline-installer/blob/master/installer-configuration.nix
    "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
    "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
    "${nixpkgs}/nixos/modules/profiles/base.nix"
    "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    "${nixpkgs}/nixos/modules/installer/tools/tools.nix"
  ];

  services.xserver.enable = false;

  system.stateVersion = "23.11";

  environment.systemPackages = with pkgs; [
    file
    git
    mkpasswd
    python3
    tmux
    tree
    vim
    wget
    jgsysutil
  ];

  boot.blacklistedKernelModules = [ "nouveau" ];

  # based on nixos/modules/installer/cd-dvd/channel.nix
  # It's possible this could also be done with something like
  # system.activationScripts.mkhome = stringAfter [ "users" ]
  boot.postBootCommands = lib.mkAfter ''
    ${pkgs.coreutils}/bin/mkdir -p /nix/var/nix/profiles/per-user/nixos
    ${pkgs.coreutils}/bin/chown nixos:root /nix/var/nix/profiles/per-user/nixos
  '';
  systemd.services.home-activate = {
    description = "Activate home configuration";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = { Type = "oneshot"; };
    script = ''
      ${pkgs.su}/bin/su - nixos -c "${home}/activate"
    '';
  };

  isoImage.compressImage = false;
  isoImage.isoBaseName = "nixos-jgns";
  isoImage.isoName =
    "${config.isoImage.isoBaseName}-${vstring}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
  isoImage.storeContents = [ ];
  isoImage.includeSystemBuildDependencies =
    true; # unconfirmed if this is really needed
}
