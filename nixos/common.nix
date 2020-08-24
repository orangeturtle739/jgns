{ config, lib, pkgs, ... }:

with lib;

let cfg = config.jgns.common;
in {
  options.jgns.common = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the JGNS common setup.
      '';
    };
    idleTimeoutSec = mkOption {
      type = types.ints.unsigned;
      default = 300;
      description = ''
        Timeout after which to lock the scren, in seconds.
      '';
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config = {
      allowUnfree = true;
      packageOverrides = super:
        let self = super.pkgs;
        in {
          cups-filters = super.cups-filters.overrideAttrs (oldAttrs: rec {
            version = "1.27.5";
            src = super.fetchurl {
              url =
                "https://github.com/OpenPrinting/cups-filters/releases/download/release-1-27-5/cups-filters-1.27.5.tar.gz";
              sha256 = "1didsqmdh9fs0pmcbcqsr2s2msjcyvf0p5bfmwhfdqhcwlf0ir08";
            };
            configureFlags =
              (lib.lists.remove "--with-test-font-path=/path-does-not-exist"
                oldAttrs.configureFlags) ++ [
                  "--with-test-font-path=${self.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf"
                ];
          });
        };
    };
    nix = {
      package = pkgs.nixFlakes;
      systemFeatures = [ "recursive-nix" "nix-command" ];
      extraOptions = "experimental-features = nix-command flakes recursive-nix";
    };

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.networkmanager.enable = true;

    console.font = "Lat2-Terminus16";
    console.keyMap = "us";
    i18n = { defaultLocale = "en_US.UTF-8"; };

    time.timeZone = "America/New_York";

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
      lightlocker
    ];

    programs.light.enable = true;
    # Needed for blueman_applet, and probably other things
    programs.dconf.enable = true;

    services.openssh = {
      enable = true;
      forwardX11 = true;
    };
    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.udev.extraRules = ''
          # https://github.com/zsa/wally/blob/2.0.0-linux/dist/linux64/50-wally.rules
          # https://github.com/NixOS/nixpkgs/pull/91203
          # Rule for the Moonlander
          SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
          # Rule for the Ergodox EZ
          SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
          SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
          # Rule for the Planck EZ
          SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev";
      	# Teensy rules for the Ergodox EZ Original / Shine / Glow
      	ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
      	ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
      	SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
      	KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

      	# STM32 rules for the Planck EZ Standard / Glow
      	SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
              '';
    users.groups.plugdev = { };

    sound.enable = true;
    hardware.enableRedistributableFirmware = true;
    hardware.ckb-next.enable = true;

    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
      config = {
        General = {
          ControllerMode = "bredr";
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    services.blueman.enable = true;
    services.udisks2.enable = true;
    services.printing.enable = true;
    # https://wiki.debian.org/CUPSQuickPrintQueues?action=show&redirect=QuickPrintQueuesCUPS
    # https://wiki.debian.org/CUPSDriverlessPrinting
    # avahi-browse -rt _ipp._tcp
    # ~ via ❄️  impure
    # ❯ driverless
    # ipp://BRN30055C50102E.local:631/ipp/print
    # ~ via ❄️  impure took 3s
    # ❯ lpadmin -p bob -v ipp://BRN30055C50102E.local:631/ipp/print -E -m driverless:ipp://BRN30055C50102E.local:631/ipp/print
    # lpadmin: Printer drivers are deprecated and will stop working in a future version of CUPS.
    services.printing.startWhenNeeded = false;
    services.printing.browsedConf = ''
      CreateIPPPrinterQueues All
      CreateRemoteCUPSPrinterQueues No
      HttpMaxRetries 10
      DebugLogging stderr
    '';
    programs.system-config-printer.enable = true;

    hardware.pulseaudio = {
      enable = true;
      # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
      # Only the full build has Bluetooth support, so it must be selected here.
      # pactl list sinks short to get the names of the output devices
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };

    services.xserver = {
      enable = true;
      layout = "us";
      displayManager = {
        lightdm.enable = true;
        sessionCommands = ''
          ${pkgs.lightlocker}/bin/light-locker &
        '';
      };
      windowManager.awesome.enable = true;
    };

    services.logind = {
      extraConfig = ''
        IdleAction=lock
        IdleActionSec=${toString cfg.idleTimeoutSec}
      '';
    };
    systemd = {
      services.lock = {
        before = [ "sleep.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/loginctl lock-sessions";
          ExecStartPost = "${pkgs.coreutils}/bin/sleep 1";
        };
        wantedBy = [ "sleep.target" ];
      };
    };

    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}

