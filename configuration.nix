# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, pkgs-unstable, nixos-hardware, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      nixos-hardware.nixosModules.apple-t2
    ];

  # Allow unfree packages (e.g. tidal-hifi's bundled castlabs/Widevine Electron build).
  nixpkgs.config.allowUnfree = true;

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation (final: {
      name = "brcm-firmware";
      src = /etc/nixos/firmware/brcm;
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp ${final.src}/* "$out/lib/firmware/brcm"
      '';
    }))
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.efiSysMountPoint = "/boot"; # make sure to change this to your EFI partition!
    systemd-boot.enable = true;
  };

  # Swap the Cmd and Option/Alt keys on the internal Apple keyboard.
  boot.kernelParams = [ "hid_apple.swap_opt_cmd=1" ];

  # A one-off GDM login as root left a stale AccountsService cache file
  # marking it as a regular (visible) user. Force it back to hidden on
  # every activation so it doesn't keep showing up in the GDM user list.
  systemd.tmpfiles.settings."10-hide-root-gdm"."/var/lib/AccountsService/users/root"."f+" = {
    argument = "[User]\nSystemAccount=true\n";
  };

  networking.hostName = "nixbox"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Let Electron apps (tidal-hifi, etc.) render natively under Wayland instead of XWayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eelko = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    vim
    alacritty
  ];

 fonts.packages = with pkgs; [
   nerd-fonts.jetbrains-mono
 ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "26.11"; # Do not change

}

