{
  description = "jgns";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:rycee/home-manager/bqv-flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jgrestic.url = "github:orangeturtle739/jgrestic";
    duckdns-update = {
      url = "github:orangeturtle739/duckdns-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils
    , jgrestic, duckdns-update }:
    let
      packageSet = flake-utils.lib.eachSystem [
        "aarch64-linux"
        "x86_64-linux"
        "armv7l-linux"
      ] (system:
        let
          importNixpkgs = pkgs:
            import pkgs {
              inherit system;
              config = { allowUnfree = true; };
            };
          base = importNixpkgs nixpkgs;
          base-unstable = importNixpkgs nixpkgs-unstable;
          jgnsPackages = {
            jgrestic = jgrestic.defaultPackage.${system};
            duckdns-update = duckdns-update.defaultPackage.${system};
            solarwolf = base.callPackage ./packages/solarwolf { };
            ternimal = base.callPackage ./packages/ternimal { };
            codemod = base.callPackage ./packages/codemod { };
            my_vi = base.callPackage ./packages/my_vi { };
            luafmt = base.callPackage ./packages/luafmt { };
            pms = base.callPackage ./packages/pms { };
            source-code-pro-nerdfont =
              base.callPackage ./packages/source-code-pro-nerdfont { };
            ymuse = base.callPackage ./packages/ymuse { };
            lain = base.callPackage ./packages/lain { };
            awesome-freedesktop =
              base.callPackage ./packages/awesome-freedesktop { };
            awesome-wm-widgets =
              base.callPackage ./packages/awesome-wm-widgets { };
          };

          extra = { unstable = base-unstable; } // jgnsPackages;
          mkModule = arg: path: import path arg;
          jgnsHome = { ... }: {
            imports = map (mkModule extra) [
              ./home-manager/mpd.nix
              ./home-manager/beets.nix
              ./home-manager/git.nix
              ./home-manager/gpg-ssh.nix
              ./home-manager/htop.nix
              ./home-manager/starship.nix
              ./home-manager/bash.nix
              ./home-manager/lorri.nix
              ./home-manager/backup.nix
              ./home-manager/tmux
              ./home-manager/konsole
              ./home-manager/chromium.nix
              ./home-manager/graphical-session
              ./home-manager/common.nix
            ];
          };
          jgnsNixos = { ... }: {
            imports = map (mkModule extra) [
              ./nixos/common.nix
              ./nixos/encrypted.nix
              ./nixos/trackpad.nix
              ./nixos/laptop-power.nix
              ./nixos/duckdns.nix
            ];
          };
        in {
          packages = jgnsPackages;
          homeModules = { jgns = jgnsHome; };
          nixosModules = { jgns = jgnsNixos; };
        });
    in packageSet // {
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
