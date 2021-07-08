{
  description = "jgns";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    # nixpkgs.url = "/home/jacob/git/nixpkgs";
    # nixpkgs.url = "github:orangeturtle739/nixpkgs/nixos-20.09";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:rycee/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jgrestic.url = "github:orangeturtle739/jgrestic";
    jgsysutil = {
      url = "github:orangeturtle739/jgsysutil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    duckdns-update = {
      url = "github:orangeturtle739/duckdns-update";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils
    , jgrestic, duckdns-update, jgsysutil }:
    let
      mkIf = cond: value:
        if cond then
          value
        else if builtins.isAttrs value then
          { }
        else if builtins.isList value then
          [ ]
        else if builtins.isString value then
          ""
        else
          builtins.abort "uhoh";
      packageSet = flake-utils.lib.eachSystem [ "x86_64-linux" "armv7l-linux" ]
        (system:
          let
            importNixpkgs = pkgs:
              import pkgs {
                inherit system;
                config = { allowUnfree = true; };
              };
            base = importNixpkgs nixpkgs;
            base-unstable = importNixpkgs nixpkgs-unstable;
            isAarch32 = system == "armv7l-linux";
            jgnsPackages = {
              duckdns-update = duckdns-update.defaultPackage.${system};
              solarwolf = base.callPackage ./packages/solarwolf { };
              ternimal = base.callPackage ./packages/ternimal { };
              codemod = base.callPackage ./packages/codemod { };
              my_vi = base.callPackage ./packages/my_vi { };
              luafmt = base.callPackage ./packages/luafmt { };
              pms = base.callPackage ./packages/pms { };
              source-code-pro-nerdfont =
                base.callPackage ./packages/source-code-pro-nerdfont { };
              lain = base.callPackage ./packages/lain { };
              awesome-freedesktop =
                base.callPackage ./packages/awesome-freedesktop { };
              awesome-wm-widgets =
                base.callPackage ./packages/awesome-wm-widgets { };
              splatmoji = base.callPackage ./packages/splatmoji { };
            } // (mkIf (!isAarch32) {
              jgrestic = jgrestic.defaultPackage.${system};
              jgsysutil = jgsysutil.defaultPackage.${system};
            });

            extra = { unstable = base-unstable; } // jgnsPackages;
            mkModule = arg: path: import path arg;
            jgnsHome = { ... }: {
              imports = map (mkModule extra) ([
                ./home-manager/mpd.nix
                ./home-manager/beets.nix
                ./home-manager/git.nix
                ./home-manager/gpg-ssh.nix
                ./home-manager/htop.nix
                ./home-manager/starship.nix
                ./home-manager/bash.nix
                ./home-manager/lorri.nix
                ./home-manager/tmux
                ./home-manager/konsole
                ./home-manager/chromium.nix
                ./home-manager/graphical-session
                ./home-manager/common.nix
                ./home-manager/base.nix
                ./home-manager/ssh-tunnel.nix
                ./home-manager/udiskie.nix
              ] ++ (mkIf (!isAarch32) [ ./home-manager/backup.nix ]));
            };
            jgnsNixos = { ... }: {
              imports = map (mkModule extra) [
                ./nixos/common.nix
                ./nixos/encrypted.nix
                ./nixos/trackpad.nix
                ./nixos/laptop-power.nix
                ./nixos/duckdns.nix
                ./nixos/tailscale-beta.nix
              ];
            };
            provision = mkIf (!isAarch32) {
              jgns-image = (nixpkgs.lib.nixosSystem rec {
                inherit system;
                modules = [
                  jgnsNixos
                  (mkModule extra ./provision {
                    inherit jgnsHome home-manager nixpkgs;
                    vstring =
                      if self ? rev then self.rev else self.lastModifiedDate;
                  })
                ];
              }).config.system.build.isoImage;
            };
          in {
            packages = jgnsPackages // provision;
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
