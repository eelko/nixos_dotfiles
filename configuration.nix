# Shared across every profile (sway / qtile / shell). Boot, hardware,
# networking, users, and anything else that doesn't depend on which
# window manager (if any) is in use. Also doubles as the full config for
# the plain-shell profile (plain console/getty login, no display manager)
# — the sway/qtile profiles layer desktops/sway-desktop.nix /
# desktops/qtile-desktop.nix (which enable ly) on top of this.

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
    vim                   # basic editor
    wget                  # download stuff from the internet
    git                   # essential version management
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05"; #Don't change this number
}
