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
  };

  config = mkIf cfg.enable {
    nixpkgs.config = { allowUnfree = true; };
    nix = {
      extraOptions = "experimental-features = nix-command flakes recursive-nix";
    };

    boot.kernel.sysctl = {
      # https://unix.stackexchange.com/questions/107703/why-is-my-pc-freezing-while-im-copying-a-file-to-a-pendrive/107722#107722
      # https://lwn.net/Articles/572911/
      # https://lwn.net/Articles/682582/
      # https://sysctl-explorer.net/vm/dirty_bytes/
      # https://sysctl-explorer.net/vm/dirty_background_bytes/
      # dirty_background_ratio specifies a percentage of memory; when at least
      # that percentage is dirty, the kernel will start writing those dirty
      # pages back to the backing device. So, if a system has 1000 pages of
      # memory and dirty_background_ratio is set to 10% (the default),
      # writeback will begin when 100 pages have been dirtied.
      # dirty_ratio specifies the percentage at which processes that are
      # dirtying pages are made to wait for writeback. If it is set to 20%
      # (again, the default) on that 1000-page system, a process dirtying pages
      # will be made to wait once the 200th page is dirtied. This mechanism
      # will, thus, slow the dirtying of pages while the system catches up.
      # dirty_background_bytes works like dirty_background_ratio except that the limit is specified as an absolute number of bytes.
      # dirty_bytes is the equivalent of dirty_ratio except that, once again, it is specified in bytes rather than as a percentage of total memory.
      "vm.dirty_background_bytes" = 16 * 1024 * 1024;
      "vm.dirty_bytes" = 48 * 1024 * 1024;
    };

    networking.networkmanager.enable = true;

    console.font = "Lat2-Terminus16";
    console.keyMap = "us";
    i18n = { defaultLocale = "en_US.UTF-8"; };

    environment.systemPackages = with pkgs; [
      file
      git
      mkpasswd
      smartmontools
      python3
      tmux
      tree
      vim
      wget
      keyd
      (pkgs.writeScriptBin "home-rebuild" ''
        nix run "$@" .#$(hostname)-home
      '')
    ];

    programs.light.enable = true;
    # Needed for blueman_applet, and probably other things
    programs.dconf.enable = true;

    services.openssh = { enable = true; };
    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
    services.udev.packages = [ pkgs.yubikey-personalization ];
    users.groups.plugdev = { };

    sound.enable = true;
    hardware.enableRedistributableFirmware = true;

    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
      settings = {
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
    hardware.sane.enable = true;

    hardware.pulseaudio = {
      enable = true;
      # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
      # Only the full build has Bluetooth support, so it must be selected here.
      # pactl list sinks short to get the names of the output devices
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };

    hardware.opengl.enable = true;
    # https://github.com/NixOS/nixpkgs/blob/6e284c8889b3e8a70cbabb5bde478bd2b9e88347/pkgs/applications/window-managers/sway/lock.nix#L31
    security.pam.services.swaylock = { };
    services.greetd = let
      wlgreet = pkgs.greetd.wlgreet.overrideAttrs (super: {
        patchs = super.patches ++ [ ./0001-Use-roboto.patch ];
        postPatch = ''
          substituteInPlace $cargoDepsCopy/wayland-sys/src/client.rs \
            --replace libwayland-client.so.0 ${pkgs.wayland}/lib/libwayland-client.so.0
          substituteInPlace $cargoDepsCopy/wayland-sys/.cargo-checksum.json \
            --replace d2f7c8d7f9346b750b3adcca6be2e7ddf0ba6c6da43b0f6f34b95e974cd635f2 \
              873874ca35b1fb7cbccd2fb93d145ba45d8dba2ef82b5752dbaab10d620bd1d6
          substituteInPlace $cargoDepsCopy/smithay-client-toolkit/src/seat/keyboard/ffi.rs \
            --replace libxkbcommon.so.0 ${pkgs.libxkbcommon}/lib/libxkbcommon.so.0
          substituteInPlace $cargoDepsCopy/smithay-client-toolkit/.cargo-checksum.json \
            --replace 3c557fc7129375d0ac473e0b1746931043fb3dd03b248e2e6c1b1b9d3c9be151 \
              1b0a8b7379a62fcb952421bec98b2a48f1c429d1924499419c684dc21c296b6c
        '';
      });
      swayConfig = pkgs.writeText "greetd-sway-config" ''
            # `-l` activates layer-shell mode. Notice that `swaymsg exit` will run after gtkgreet.
              exec "${wlgreet}/bin/wlgreet --command start_wayland; swaymsg exit"
              bindsym Mod4+shift+e exec swaynag \
        	-t warning \
        	-m 'What do you want to do?' \
        	-b 'Poweroff' 'systemctl poweroff' \
        	-b 'Reboot' 'systemctl reboot'
      '';
    in {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
        };
      };
    };
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}
