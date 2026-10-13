{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-kernel-modules"

      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"

      "spotify"
      "osu-lazer-bin"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bign = {
    isNormalUser = true;
    extraGroups = [
      "wheel"  # Enable ‘sudo’ for the user.
      "docker"
      "wireshark" # Capture all interfaces without superuser priviledges
    ];
    shell = pkgs.zsh;

    packages = with pkgs; [
      # Terminal Programs
      kitty
      neovim
      opencode
      firefox

      man-pages
      man-pages-posix

      gcc
      clang
      gdb
      fastfetch
      btop
      gnumake
      python3
      typst
      zip

      #######################
      ### "Desktop" Stuff ###
      #######################

      waybar
      swaybg
      gruvbox-gtk-theme
      vlc
      gruvbox-kvantum
      qview
      hyprshot
      hyprlock
      hyprlauncher
      hyprshutdown
      brightnessctl
      pavucontrol
      # Bluetooth GUI (doesn't work but makes it work) see:
      # https://github.com/bluez/bluez/issues/673#issuecomment-1849132576
      # https://wiki.nixos.org/wiki/Bluetooth
      blueman # basically the same as `services.blueman.enable = true;`
      # Dolphin with Wayland and SVG Icon support
      kdePackages.qtwayland
      kdePackages.qtsvg
      kdePackages.dolphin

      wl-clipboard
      opentabletdriver

      #######################
      ### Normal Programs ###
      #######################

      brave
      vesktop
      heroic
      spotify
      libreoffice-fresh
      wireshark

      osu-lazer-bin

      # Minecraft
      prismlauncher

      # Flatpak (only for Hytale)
      flatpak
    ];
  };

  environment.systemPackages = with pkgs; [
    tree
    vim
    wget
    zip
    unzip
  ];

  ################
  ### Programs ###
  ################

  virtualisation.docker.enable = true;

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.wireshark = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };

  # FUCK NANO
  programs.nano.enable = false;

  programs.git = {
    enable = true;
    config = {
      user = {
        email = "lukasnagler17@gmail.com";
        name = "Lukas Nagler";
      };
      init.defaultBranch = "master";
      pull.ff = "only";
    };
  };

  programs.zsh = {
    enable = true;
    enableLsColors = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      theme = "strug";
    };
  };

  environment.variables = {
    EDITOR = "nvim";
  };

  # Flatpak apps (aka Hytale)
  environment.sessionVariables.XDG_DATA_DIRS = [
    "$XDG_DATA_DIRS:/home/bign/.local/share/flatpak/exports/share"
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  ####################
  ### Nix Settings ###
  ####################

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.optimise = {
    automatic = true;
    dates = ["weekly"];
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

  ################
  ### Graphics ###
  ################

  hardware.graphics = {
    enable = true;
    extraPackages = [];

    # 32bit Support (eg. Steam)
    enable32Bit = true;
  };
  hardware.nvidia.open = false;

  services.xserver.videoDrivers = ["nvidia"]; # Amazing naming. This is for Xorg and Wayland
  boot.initrd.kernelModules = ["nvidia"];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
    config = {
      preferred = {
        default = [
          "hyprland"
          "kde"
        ];
        "org.freedesktop.impl.portal.FileChooser" = "kde";
      };
    };
    extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
  };

  environment.sessionVariables = {
    GTK_THEME = "Gruvbox-Dark";

    # Hint to Electron Apps to use Wayland
    NIXOS_OZONE_WL = "1";

    # XDG Variables
    XDG_DESKTOP_DIR = "";
    XDG_DOWNLOAD_DIR = "$HOME/Downloads";
    XDG_TEMPLATES_DIR = "";
    XDG_PUBLICSHARE_DIR = "";
    XDG_DOCUMENTS_DIR = "$HOME/Documents";
    XDG_MUSIC_DIR = "";
    XDG_PICTURES_DIR = "$HOME/Pictures";
    XDG_VIDEOS_DIR = "";
  };

  ####################################
  ### "Hardware" / Low-level stuff ###
  ####################################

  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 15;
    };
    efi.canTouchEfiVariables = true;
  };

  # Greeter
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  networking.hostName = "nix"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";

  i18n.defaultLocale = "en_US.UTF-8";
  console = lib.mkDefault {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Automount USB devices
  services.udisks2.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.openssh.enable = true;

  #########################
  ### DO NOT CHANGE !!! ###
  #########################

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # NOTE: Does not work with flakes!!!
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
