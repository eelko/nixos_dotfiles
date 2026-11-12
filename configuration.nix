{ config, lib, pkgs, pkgs-unstable, nixos-hardware, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      nixos-hardware.nixosModules.apple-t2
    ];

  # Allow unfree packages (e.g. tidal-hifi's bundled castlabs/Widevine Electron build).
  nixpkgs.config.allowUnfree = true;

  # MacBook T2 firmware load
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

  # T2 suspend workaround (t2linux wiki): the T2 resets its USB devices on
  # wake, which leaves the Touch Bar dead. Unload apple-bce before sleep and
  # reload it after resume. Wi-Fi (brcmfmac) is deliberately left alone: it
  # survives suspend by itself, and reloading it right after resume fails
  # with "Unable to change power state from D3cold to D0".
  systemd.services.t2-suspend-fix = {
    description = "Unload/reload apple-bce around suspend (T2 Touch Bar fix)";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/rmmod -f apple-bce";
      ExecStop = [
        "${pkgs.kmod}/bin/modprobe apple-bce"
        # The Touch Bar disappears with apple-bce; restart tiny-dfr so it
        # re-attaches to it. "-" = don't fail the unit if this fails.
        "-${pkgs.systemd}/bin/systemctl restart tiny-dfr.service"
      ];
    };
  };

  # Customizable Touch Bar via tiny-dfr (draws the bar through appletbdrm).
  # Settings are merged over the package defaults, see
  # ${pkgs.tiny-dfr}/share/tiny-dfr/config.toml for all keys and examples.
  # Buttons can only send key codes; to run a command, send e.g. F13
  # and bind that key in qtile.
  hardware.apple.touchBar = {
    enable = true;
    settings = {
      MediaLayerDefault = true;   # media keys by default, hold Fn for F1–F12
      EnablePixelShift = true;    # slowly shift contents to spare the OLED
      ShowButtonOutlines = false;
    };
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eelko = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
    ];
  };

  programs.fish.enable = true;

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

