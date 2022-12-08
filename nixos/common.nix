{ ... }:
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
    idleTimeoutMin = mkOption {
      type = types.ints.unsigned;
      default = 5;
      description = ''
        Timeout after which to lock the screen, in minutes.
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
      lightlocker
      (pkgs.writeScriptBin "home-rebuild" ''
        nix run "$@" .#$(hostname)-home
      '')
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

    /* services.xserver = {
         enable = true;
         layout = "us";
         displayManager = {
           lightdm.enable = true;
           sessionCommands = ''
             ${pkgs.lightlocker}/bin/light-locker &
           '';
         };
         windowManager.awesome.enable = true;
         # https://wiki.archlinux.org/index.php/Display_Power_Management_Signaling
         serverFlagsSection = ''
           Option "BlankTime" "${toString cfg.idleTimeoutMin}"
           Option "StandbyTime" "${toString cfg.idleTimeoutMin}"
           Option "SuspendTime" "${toString cfg.idleTimeoutMin}"
           Option "OffTime" "${toString cfg.idleTimeoutMin}"
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

         # Sometimes the x server starts slowly so increase the number of retries
         services.display-manager.startLimitBurst = lib.mkForce 10;
       };
    */

    hardware.opengl.enable = true;
    # https://github.com/NixOS/nixpkgs/blob/6e284c8889b3e8a70cbabb5bde478bd2b9e88347/pkgs/applications/window-managers/sway/lock.nix#L31
    security.pam.services.swaylock = { };
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
        };
      };
    };
    programs.wshowkeys.enable = true;
    virtualisation.virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}

