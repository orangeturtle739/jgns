{ jgsysutil, ... }:
{ jgnsHome, home-manager, nixpkgs, vstring }:
{ config, lib, pkgs, ... }:
let
  home = (home-manager.lib.homeManagerConfiguration {
    pkgs = pkgs;
    modules = [
      ({ config, pkgs, ... }: {
        imports = [ jgnsHome ];
        jgns = {
          # common.enable = true;
          git.enable = true;
          # gpg-ssh.enable = true;
          htop.enable = true;
          bash.enable = true;
          starship.enable = true;
          # lorri.enable = true;
          tmux.enable = true;
          # konsole.enable = true;
          # chromium.enable = true;
          # graphical-session.enable = true;
        };
        programs.git.enable = true;
        home = {
          username = "nixos";
          homeDirectory = "/home/nixos";
          stateVersion = "22.11";
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

  system.stateVersion = "22.11";

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

  # https://www.virtualbox.org/ticket/19516
  # Linux kernel version: 5.7 - we need changes (fixed in 6.1.10)
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  # virtualisation.virtualbox.guest.enable = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
  # virtualisation.virtualbox.guest.enable = builtins.trace pkgs.stdenv.hostPlatform.system false;

  jgns = {
    # common.enable = true;
    # trackpad.enable = true;
  };

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
