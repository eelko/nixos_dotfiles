# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #  boot.loader.grub.enable = true;
  #  boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "nodev"; # "/dev/vda" or "nodev" for efi only
  services.qemuGuest.enable = true;


  networking.hostName = "nixos-btw"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  services.displayManager.ly.enable = true;

  environment.sessionVariables = {
    # virtio-gpu's hardware cursor plane renders garbled/offset under wlroots
    # in this VM — composite the cursor in software instead.
    WLR_NO_HARDWARE_CURSORS = "1";
    # Xwayland apps (e.g. Firefox) otherwise fall back to their own default
    # cursor theme/size, producing a visible second pointer alongside the
    # native Wayland one — pin both to the same theme.
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # Sway (Wayland window manager)
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      waybar
      swaybg
      swaylock
      grim
      slurp
      wl-clipboard
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eelko = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgi4qYwTyT96lXkgTc/KOqxWy4cxKTU6DVDUxducCTN eelko@umbp"
    ];
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Basics
  programs.firefox.enable = true;
  programs.fish.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    rofi                  # application launcher for sway
    vim                   # basic editor
    wget                  # download stuff from the internet
    git                   # essential version management
    alacritty             # basic terminal emulator
    adwaita-icon-theme    # provides the Adwaita cursor theme (see sessionVariables below)
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05"; #Don't change this number
}

