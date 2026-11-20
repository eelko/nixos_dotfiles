# nixbox: MacBook Pro 16,2 (Intel, T2).
# Flake output kept as `nixos-btw` so the nrs/update aliases keep working.
{ inputs, config, ... }:

{
  flake.nixosConfigurations.nixos-btw = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with config.flake.modules.nixos; [
      nix
      base
      eelko
      shell
      gnome
      browsers
      apple-t2
      nixbox
    ];
  };

  # Things that only make sense on this one machine.
  flake.modules.nixos.nixbox = {
    imports = [ ./_hardware-configuration.nix ];

    networking.hostName = "nixbox";

    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      efi.efiSysMountPoint = "/boot"; # make sure to change this to your EFI partition!
      systemd-boot.enable = true;
    };

    # Closing the lid does nothing (no suspend), on battery, on AC and docked.
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };

    system.stateVersion = "26.11"; # Do not change
  };
}
