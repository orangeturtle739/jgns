{
  description = "jgns";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    # nixpkgs.url = "/home/jacob/git/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:rycee/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jgrestic = {
      url = "github:orangeturtle739/jgrestic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jgsysutil = {
      url = "github:orangeturtle739/jgsysutil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    duckdns-update = {
      url = "github:orangeturtle739/duckdns-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, jgrestic, jgsysutil
    , duckdns-update }:
    let
      packageSet = flake-utils.lib.eachSystem [ "x86_64-linux" "armv7l-linux" ]
        (system:
          let
            overlays = [
              duckdns-update.overlays.default
              jgsysutil.overlays.default
              jgrestic.overlays.default
              (final: prev: {
                solarwolf = prev.callPackage ./packages/solarwolf { };
                source-code-pro-nerdfont =
                  prev.callPackage ./packages/source-code-pro-nerdfont { };
                ternimal = prev.callPackage ./packages/ternimal { };
                jgvi = prev.callPackage ./packages/jgvi.nix { };
                signal-desktop = prev.signal-desktop.overrideAttrs (super: {
                  # Revert https://github.com/NixOS/nixpkgs/issues/222043
                  preFixup = ''
                    gappsWrapperArgs+=(
                      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
                    )
                  '' + super.preFixup;
                });
              })
            ];
            jgnsHome = { ... }: {
              imports = [
                (import ./home-manager/alacritty.nix)
                (import ./home-manager/backup.nix)
                (import ./home-manager/base.nix)
                (import ./home-manager/bash.nix)
                (import ./home-manager/beets.nix)
                (import ./home-manager/chromium.nix)
                (import ./home-manager/fun.nix)
                (import ./home-manager/git.nix)
                (import ./home-manager/gpg-ssh.nix)
                (import ./home-manager/graphical-session)
                (import ./home-manager/handy.nix)
                (import ./home-manager/htop.nix)
                (import ./home-manager/lorri.nix)
                (import ./home-manager/mpd.nix)
                (import ./home-manager/office.nix)
                (import ./home-manager/rofimoji.nix)
                (import ./home-manager/ssh-tunnel.nix)
                (import ./home-manager/starship.nix)
                (import ./home-manager/tmux)
                (import ./home-manager/udiskie.nix)
                (import ./home-manager/vi.nix)
                ({ ... }: { nixpkgs.overlays = overlays; })
              ];
            };
            jgnsNixos = { ... }: {
              imports = [
                (import ./nixos/common.nix)
                (import ./nixos/duckdns.nix)
                (import ./nixos/encrypted.nix)
                (import ./nixos/keyd.nix)
                (import ./nixos/laptop-power.nix)
                (import ./nixos/tailscale.nix)
                ({ ... }: { nixpkgs.overlays = overlays; })
              ];
            };
            provision = {
              jgns-image = (nixpkgs.lib.nixosSystem rec {
                inherit system;
                modules = [
                  jgnsNixos
                  (import ./provision {
                    inherit jgnsHome home-manager nixpkgs;
                    vstring =
                      if self ? rev then self.rev else self.lastModifiedDate;
                  })
                ];
              }).config.system.build.isoImage;
            };
          in {
            packages = provision;
            homeModules = { jgns = jgnsHome; };
            nixosModules = { jgns = jgnsNixos; };
          });
    in nixpkgs.lib.attrsets.recursiveUpdate packageSet {
      lib = {
        mkHome = args: rec {
          package =
            (home-manager.lib.homeManagerConfiguration args).activationPackage;
          app = {
            type = "app";
            program = "${package}/activate";
          };
        };
      };
    };
}
