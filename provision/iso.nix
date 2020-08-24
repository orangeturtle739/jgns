{ config, pkgs, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  environment.systemPackages = with pkgs; [
    file
    git
    mkpasswd
    python3
    restic
    tmux
    tree
    vim
    wget
    (pkgs.callPackage ./../nixos/common/jgns.nix { })
  ];
}
